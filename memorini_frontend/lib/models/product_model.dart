class ProductVariantStock {
  final String size;
  final String color;
  final int stock;

  ProductVariantStock({
    required this.size,
    required this.color,
    required this.stock,
  });

  factory ProductVariantStock.fromJson(Map<String, dynamic> json) {
    return ProductVariantStock(
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'size': size,
    'color': color,
    'stock': stock,
  };
}

class ProductModel {
  final int id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String mainImage;
  final String? images;
  final String stockMode;
  final int? stock;
  final List<ProductVariantStock> variantStock;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.mainImage,
    this.images,
    this.stockMode = 'none',
    this.stock,
    this.variantStock = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'standard',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      mainImage: json['main_image']?.toString() ?? '',
      images: json['images']?.toString(),
      stockMode: json['stock_mode']?.toString() ?? 'none',
      stock: json['stock'] == null
          ? null
          : int.tryParse(json['stock'].toString()),
      variantStock: (json['variant_stock'] is List)
          ? (json['variant_stock'] as List)
                .whereType<Map>()
                .map(
                  (e) => ProductVariantStock.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }
}
