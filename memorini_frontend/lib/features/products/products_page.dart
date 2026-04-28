import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/cart_store.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/memorini_header.dart';
import '../../models/product_model.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ApiService.isAdmin(),
      builder: (context, roleSnapshot) {
        if (roleSnapshot.data == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted)
              Navigator.pushReplacementNamed(context, '/admin');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return ValueListenableBuilder<int>(
          valueListenable: ApiService.authStateVersion,
          builder: (context, _, __) {
            return Scaffold(
              body: Column(
                children: [
                  const MemoriniHeader(activeRoute: '/products'),
                  Expanded(
                    child: FutureBuilder<List<ProductModel>>(
                      future: ApiService.getProducts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Impossible de charger les produits',
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/products',
                                      ),
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          );
                        }

                        final products = snapshot.data ?? [];
                        final screenWidth = MediaQuery.of(context).size.width;
                        final columns = screenWidth >= 1500
                            ? 4
                            : screenWidth >= 1100
                            ? 3
                            : screenWidth >= 760
                            ? 2
                            : 1;
                        return FutureBuilder<int?>(
                          future: ApiService.getUserId(),
                          builder: (context, authSnapshot) {
                            final isLoggedIn = (authSnapshot.data ?? 0) > 0;
                            return SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                28,
                                30,
                                28,
                                40,
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'BOUTIQUE',
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Nos produits',
                                    style: TextStyle(
                                      fontSize: screenWidth > 1100 ? 68 : 46,
                                      color: AppColors.burgundy,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Consultez les produits et ajoutez-les directement au panier.',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 48),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: products.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: columns,
                                          crossAxisSpacing: 18,
                                          mainAxisSpacing: 18,
                                          childAspectRatio: 0.69,
                                        ),
                                    itemBuilder: (context, index) =>
                                        _ProductCard(
                                          product: products[index],
                                          isLoggedIn: isLoggedIn,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isLoggedIn;

  const _ProductCard({required this.product, required this.isLoggedIn});

  Future<List<String>?> _pickProductPhotos(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: false,
    );
    if (result == null) return null;

    if (result.files.length < 20) {
      if (!context.mounted) return null;
      AppToast.show(
        context,
        message:
            'Vous devez telecharger minimum 20 photos pour passer une commande.',
        type: AppToastType.error,
      );
      return null;
    }

    return result.files.map((file) => file.name).toList();
  }

  Future<void> _addToCart(BuildContext context) async {
    final userId = await ApiService.getUserId();
    if (userId == null) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        message: 'Vous devez vous connecter avant d’ajouter au panier.',
        type: AppToastType.warning,
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    final selectedPhotos = await _pickProductPhotos(context);
    if (selectedPhotos == null) return;

    CartStore.add(
      CartItem(
        id: 'product-${product.id}',
        name: product.name,
        type: 'product',
        details: product.description.isEmpty
            ? 'Produit standard'
            : product.description,
        qty: 1,
        unitPrice: product.price,
        photos: selectedPhotos,
      ),
    );

    if (!context.mounted) return;
    AppToast.show(
      context,
      message: 'Produit ajouté au panier.',
      type: AppToastType.success,
    );
  }

  Future<void> _orderFromDetails(BuildContext context) async {
    await _addToCart(context);
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/cart');
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (product.mainImage.isNotEmpty)
                Image.network(
                  product.mainImage,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 250,
                    color: const Color(0xFFF3EEE7),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 250,
                  color: const Color(0xFFF3EEE7),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 28,
                        color: AppColors.burgundy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        height: 1.5,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} DT',
                          style: const TextStyle(
                            fontSize: 24,
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _addToCart(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.burgundy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              icon: const Icon(Icons.shopping_cart_outlined),
                              label: const Text('Ajouter'),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _orderFromDetails(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.burgundy,
                                side: const BorderSide(
                                  color: AppColors.burgundy,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              icon: const Icon(Icons.receipt_long_outlined),
                              label: const Text('Commander'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetails(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EEE7),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: product.mainImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(product.mainImage),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                        : null,
                  ),
                  child: product.mainImage.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 54,
                            color: AppColors.textMuted,
                          ),
                        )
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppColors.burgundy,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${product.price.toStringAsFixed(2)} DT',
                            style: const TextStyle(
                              fontSize: 24,
                              color: AppColors.burgundy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => isLoggedIn
                              ? _showDetails(context)
                              : _addToCart(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.burgundy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isLoggedIn ? 'Voir' : 'Ajouter',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
