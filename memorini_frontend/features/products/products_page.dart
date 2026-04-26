import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/memorini_header.dart';
import '../../models/product_model.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MemoriniHeader(),
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: ApiService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Erreur chargement produits'));
                }

                final products = snapshot.data ?? [];

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(70),
                    child: Column(
                      children: [
                        const Text(
                          'BOUTIQUE',
                          style: TextStyle(color: AppColors.gold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Nos tirages photo',
                          style: TextStyle(
                            fontSize: 46,
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Choisissez le format qui sublimera vos souvenirs.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 45),
                        Wrap(
                          spacing: 12,
                          children: const [
                            Chip(label: Text('Tous')),
                            Chip(label: Text('Standard')),
                            Chip(label: Text('Carré')),
                            Chip(label: Text('Vintage')),
                            Chip(label: Text('Grand format')),
                          ],
                        ),
                        const SizedBox(height: 45),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 28,
                            mainAxisSpacing: 28,
                            childAspectRatio: 0.72,
                          ),
                          itemBuilder: (context, index) {
                            final product = products[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.softBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      ),
                                      child: Center(
                                        child: Text(product.mainImage),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.category.toUpperCase(),
                                          style: const TextStyle(color: Colors.black45, letterSpacing: 2),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: AppColors.burgundy,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          product.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 18),
                                        Row(
                                          children: [
                                            Text(
                                              '${product.price.toStringAsFixed(2)} €',
                                              style: const TextStyle(
                                                fontSize: 24,
                                                color: AppColors.burgundy,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            OutlinedButton(
                                              onPressed: () {},
                                              child: const Text('Voir'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}