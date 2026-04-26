import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/memorini_header.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getMyOrders();
  }

  String _parseItems(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List && decoded.isNotEmpty) {
        return decoded.map((e) => '${e['name']} x${e['qty']}').join(', ');
      }
    } catch (_) {}
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MemoriniHeader(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Impossible de charger les commandes. Connecte-toi d abord.'),
                  );
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const Center(child: Text('Aucune commande pour le moment.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(30),
                  itemCount: orders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final status = order['status']?.toString() ?? 'pending';
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Commande #${order['id']}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: AppColors.burgundy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                status,
                                style: const TextStyle(
                                  color: AppColors.burgundy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Articles: ${_parseItems(order['items']?.toString() ?? '')}'),
                          Text('Total: ${order['total_price']} €'),
                          Text('Adresse: ${order['address']}, ${order['city']}'),
                          Text('Téléphones: ${order['phone1']} / ${order['phone2'] ?? '-'}'),
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
