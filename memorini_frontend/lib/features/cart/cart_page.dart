import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/cart_store.dart';
import '../../core/widgets/memorini_header.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _placing = false;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Tunis');

  @override
  void initState() {
    super.initState();
    _guardAdmin();
  }

  Future<void> _guardAdmin() async {
    final isAdmin = await ApiService.isAdmin();
    if (isAdmin && mounted) {
      Navigator.pushReplacementNamed(context, '/admin');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _openCheckout(List<CartItem> items) async {
    final userId = await ApiService.getUserId();
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez vous connecter avant de passer commande.')),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Confirmer la commande', style: TextStyle(color: AppColors.burgundy)),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(labelText: 'Nom complet'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Nom obligatoire' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Téléphone'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Téléphone obligatoire' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: const InputDecoration(labelText: 'Adresse'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Adresse obligatoire' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'Ville'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Ville obligatoire' : null,
                        ),
                        const SizedBox(height: 18),
                        const Text('Résumé de la commande', style: _sectionTitle),
                        const SizedBox(height: 8),
                        ...items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('${item.qty} x ${item.name} — ${item.total.toStringAsFixed(2)} DT'),
                            )),
                        const Divider(),
                        _totalLine('Total produits', CartStore.subtotal),
                        _totalLine('Livraison', CartStore.livraison),
                        _totalLine('Total à payer', CartStore.total, big: true),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _placing ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: _placing
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setDialogState(() => _placing = true);
                          setState(() => _placing = true);
                          try {
                            final order = await ApiService.createOrder(
                              fullName: _fullNameController.text.trim(),
                              phone1: _phoneController.text.trim(),
                              address: _addressController.text.trim(),
                              city: _cityController.text.trim(),
                              totalPrice: CartStore.total,
                              items: items.map((item) => item.toJson()).toList(),
                            );
                            final orderId = int.tryParse(order['id'].toString());
                            if (orderId != null) {
                              await ApiService.createPayment(orderId: orderId, amount: CartStore.total);
                            }
                            CartStore.clear();
                            if (!mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Votre commande a été confirmée avec succès.'),
                                backgroundColor: AppColors.burgundy,
                              ),
                            );
                            Navigator.pushNamed(context, '/orders');
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _placing = false);
                              setDialogState(() => _placing = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.burgundy, foregroundColor: Colors.white),
                  child: Text(_placing ? 'Confirmation...' : 'Confirmer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _totalLine(String label, double amount, {bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: big ? FontWeight.bold : FontWeight.normal))),
          Text(
            '${amount.toStringAsFixed(2)} DT',
            style: TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.bold, fontSize: big ? 18 : 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MemoriniHeader(activeRoute: '/cart'),
          Expanded(
            child: ValueListenableBuilder<List<CartItem>>(
              valueListenable: CartStore.items,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 54, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        const Text('Votre panier est vide', style: TextStyle(fontSize: 22, color: AppColors.burgundy)),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/products'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.burgundy, foregroundColor: Colors.white),
                          child: const Text('Voir les produits'),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1050),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Votre panier', style: TextStyle(fontSize: 54, color: AppColors.burgundy, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                ...List.generate(items.length, (index) => _cartItemCard(items[index], index)),
                                TextButton.icon(
                                  onPressed: CartStore.clear,
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Vider le panier'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 22),
                          SizedBox(
                            width: 340,
                            child: _summaryCard(items),
                          ),
                        ],
                      ),
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

  Widget _cartItemCard(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: const Color(0xFFF3EEE7), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontSize: 22, color: AppColors.burgundy, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item.details, style: const TextStyle(color: AppColors.textMuted)),
                if (item.photos.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('Photos : ${item.photos.join(', ')}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textMuted)),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(onPressed: item.qty > 1 ? () => CartStore.updateQty(index, item.qty - 1) : null, icon: const Icon(Icons.remove)),
                    Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => CartStore.updateQty(index, item.qty + 1), icon: const Icon(Icons.add)),
                    const SizedBox(width: 12),
                    Text('${item.unitPrice.toStringAsFixed(2)} DT / unité'),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(onPressed: () => CartStore.removeAt(index), icon: const Icon(Icons.close)),
              Text('${item.total.toStringAsFixed(2)} DT', style: const TextStyle(fontSize: 20, color: AppColors.burgundy, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(List<CartItem> items) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Résumé', style: TextStyle(fontSize: 26, color: AppColors.burgundy, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${item.qty} x ${item.name}'),
              )),
          const Divider(height: 26),
          _totalLine('Total produits', CartStore.subtotal),
          _totalLine('Livraison', CartStore.livraison),
          _totalLine('Total à payer', CartStore.total, big: true),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _placing ? null : () => _openCheckout(items),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Passer commande', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

const TextStyle _sectionTitle = TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.bold, fontSize: 16);
