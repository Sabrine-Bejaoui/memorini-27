import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/memorini_header.dart';
import '../../models/product_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  ProductModel? _product;
  int _qty = 1;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final products = await ApiService.getProducts();
      final userName = await ApiService.getUserName();
      if (!mounted) return;
      setState(() {
        _product = products.isNotEmpty ? products.first : null;
        _nameController.text = userName ?? '';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de charger le panier')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _total => (_product?.price ?? 0) * _qty;

  Future<void> _placeOrder() async {
    if (_product == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final order = await ApiService.createOrder(
        fullName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        phone1: _phone1Controller.text.trim(),
        phone2: _phone2Controller.text.trim(),
        totalPrice: _total,
        items: [
          {
            'product_id': _product!.id,
            'name': _product!.name,
            'qty': _qty,
            'unit_price': _product!.price,
          }
        ],
      );
      await ApiService.createPayment(
        orderId: order['id'] as int,
        amount: _total,
        method: 'cash_on_delivery',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande passée avec succès')),
      );
      Navigator.pushNamed(context, '/orders');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MemoriniHeader(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _product == null
                    ? const Center(child: Text('Aucun produit dans le panier'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.softBorder),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _product!.name,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        color: AppColors.burgundy,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(_product!.description),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                                          icon: const Icon(Icons.remove),
                                        ),
                                        Text('$_qty', style: const TextStyle(fontSize: 18)),
                                        IconButton(
                                          onPressed: () => setState(() => _qty++),
                                          icon: const Icon(Icons.add),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${_total.toStringAsFixed(2)} €',
                                          style: const TextStyle(
                                            fontSize: 34,
                                            color: AppColors.burgundy,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 26),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.softBorder),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Checkout',
                                        style: TextStyle(
                                          fontSize: 32,
                                          color: AppColors.burgundy,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(labelText: 'Nom complet'),
                                        validator: (v) =>
                                            (v == null || v.isEmpty) ? 'Nom requis' : null,
                                      ),
                                      TextFormField(
                                        controller: _addressController,
                                        decoration: const InputDecoration(labelText: 'Adresse'),
                                        validator: (v) =>
                                            (v == null || v.isEmpty) ? 'Adresse requise' : null,
                                      ),
                                      TextFormField(
                                        controller: _cityController,
                                        decoration: const InputDecoration(labelText: 'Ville'),
                                        validator: (v) =>
                                            (v == null || v.isEmpty) ? 'Ville requise' : null,
                                      ),
                                      TextFormField(
                                        controller: _phone1Controller,
                                        decoration: const InputDecoration(labelText: 'Téléphone 1'),
                                        validator: (v) => (v == null || v.isEmpty)
                                            ? 'Téléphone principal requis'
                                            : null,
                                      ),
                                      TextFormField(
                                        controller: _phone2Controller,
                                        decoration: const InputDecoration(labelText: 'Téléphone 2'),
                                      ),
                                      const SizedBox(height: 18),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.gold,
                                            foregroundColor: AppColors.burgundy,
                                          ),
                                          onPressed: _submitting ? null : _placeOrder,
                                          child: _submitting
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                )
                                              : const Text('Passer la commande'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
