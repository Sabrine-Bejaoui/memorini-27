import 'package:flutter/material.dart';
import 'dart:convert';

import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/memorini_header.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService.getMyOrders();
    _guardAdmin();
  }

  Future<void> _guardAdmin() async {
    final isAdmin = await ApiService.isAdmin();
    if (isAdmin && mounted) {
      Navigator.pushReplacementNamed(context, '/admin');
    }
  }

  String _itemsLabel(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => '${e['name']?.toString() ?? 'Article'} x${e['qty']?.toString() ?? '1'}')
            .join(', ');
      }
    } catch (_) {}
    return raw;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Confirmed':
        return 'Confirmée';
      case 'Shipped':
        return 'Expédiée';
      case 'Delivered':
        return 'Livrée';
      case 'Cancelled':
        return 'Annulée';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MemoriniHeader(activeRoute: '/orders'),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Impossible de charger les commandes. Connectez-vous pour continuer.'),
                  );
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const Center(child: Text('Aucune commande pour le moment.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final status = order['status']?.toString() ?? 'Pending';
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
                          Row(
                            children: [
                              Text(
                                'Commande #${order['id']}',
                                style: const TextStyle(
                                  color: AppColors.burgundy,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withValues(alpha: .16),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w700),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_itemsLabel(order['items']?.toString() ?? ''), style: const TextStyle(fontSize: 16))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.payment_outlined, size: 18, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Text('${order['total_price']} DT', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.burgundy)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Text('${order['address'] ?? '-'}, ${order['city'] ?? '-'}', style: const TextStyle(color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 18, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Text('${order['phone1'] ?? '-'} ${order['phone2'] != null ? ' / ${order['phone2']}' : ''}', style: const TextStyle(color: AppColors.textMuted)),
                            ],
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
  }
}
