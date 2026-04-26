import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final String type;
  final String details;
  final int qty;
  final double unitPrice;
  final List<String> photos;

  CartItem({
    required this.id,
    required this.name,
    required this.type,
    required this.details,
    required this.qty,
    required this.unitPrice,
    this.photos = const [],
  });

  double get total => qty * unitPrice;

  CartItem copyWith({int? qty}) {
    return CartItem(
      id: id,
      name: name,
      type: type,
      details: details,
      qty: qty ?? this.qty,
      unitPrice: unitPrice,
      photos: photos,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'details': details,
        'qty': qty,
        'unit_price': unitPrice,
        'total': total,
        'photos': photos,
      };
}

class CartStore {
  static final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);
  static const double livraison = 8.0;

  static double get subtotal => items.value.fold(0.0, (sum, item) => sum + item.total);
  static double get total => items.value.isEmpty ? 0.0 : subtotal + livraison;

  static void add(CartItem item) {
    final current = [...items.value];
    final index = current.indexWhere((old) => old.id == item.id);
    if (index >= 0) {
      current[index] = current[index].copyWith(qty: current[index].qty + item.qty);
      items.value = current;
    } else {
      items.value = [...current, item];
    }
  }

  static void updateQty(int index, int qty) {
    if (index < 0 || index >= items.value.length || qty < 1) return;
    final current = [...items.value];
    current[index] = current[index].copyWith(qty: qty);
    items.value = current;
  }

  static void removeAt(int index) {
    if (index < 0 || index >= items.value.length) return;
    final current = [...items.value]..removeAt(index);
    items.value = current;
  }

  static void clear() {
    items.value = [];
  }
}
