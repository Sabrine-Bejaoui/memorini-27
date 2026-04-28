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

  List<_OrderLine> _parseItems(dynamic rawItems) {
    if (rawItems == null) return const [];
    try {
      final decoded = rawItems is String ? jsonDecode(rawItems) : rawItems;
      if (decoded is List) {
        return decoded.whereType<Map>().map((item) {
          final map = Map<String, dynamic>.from(item);
          final qty = int.tryParse(map['qty']?.toString() ?? '1') ?? 1;
          final unitPrice =
              double.tryParse(map['unit_price']?.toString() ?? '') ??
              double.tryParse(map['price']?.toString() ?? '') ??
              0;
          final total =
              double.tryParse(map['total']?.toString() ?? '') ??
              (qty * unitPrice);
          return _OrderLine(
            name: map['name']?.toString() ?? 'Produit',
            qty: qty,
            unitPrice: unitPrice,
            total: total,
          );
        }).toList();
      }
    } catch (_) {}
    return const [];
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return '-';
    final date = DateTime.tryParse(rawDate.toString());
    if (date == null) return rawDate.toString();
    final d = date.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/$year à $hour:$minute';
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
                    child: Text(
                      'Impossible de charger les commandes. Connectez-vous pour continuer.',
                    ),
                  );
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const Center(
                    child: Text('Aucune commande pour le moment.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final status = order['status']?.toString() ?? 'Pending';
                    final lines = _parseItems(order['items']);
                    final orderDate = _formatDate(
                      order['created_at'] ?? order['createdAt'],
                    );
                    final totalPrice =
                        double.tryParse(
                          order['total_price']?.toString() ?? '',
                        ) ??
                        0;
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Commande - Date : $orderDate',
                                style: const TextStyle(
                                  color: AppColors.burgundy,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    status,
                                  ).withValues(alpha: .16),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Statut : ${_statusLabel(status)}',
                                  style: TextStyle(
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F6F1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.softBorder),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Produit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Qté',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Prix',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Total',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 18),
                                if (lines.isEmpty)
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Détails produits indisponibles',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  )
                                else
                                  ...List.generate(lines.length, (lineIndex) {
                                    final line = lines[lineIndex];
                                    return TweenAnimationBuilder<double>(
                                      duration: Duration(
                                        milliseconds: 240 + (lineIndex * 60),
                                      ),
                                      tween: Tween(begin: 0, end: 1),
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(0, 12 * (1 - value)),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                line.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${line.qty}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${line.unitPrice.toStringAsFixed(2)} DT',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${line.total.toStringAsFixed(2)} DT',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  color: AppColors.burgundy,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Total commande : ${totalPrice.toStringAsFixed(2)} DT',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.burgundy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.local_shipping_outlined,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${order['address'] ?? '-'}, ${order['city'] ?? '-'}',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${order['phone1'] ?? '-'} ${order['phone2'] != null ? ' / ${order['phone2']}' : ''}',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
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

class _OrderLine {
  final String name;
  final int qty;
  final double unitPrice;
  final double total;

  const _OrderLine({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.total,
  });
}
