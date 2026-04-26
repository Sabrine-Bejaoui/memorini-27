class ProductModel {
  final int id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String mainImage;
  final String? images;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.mainImage,
    this.images,
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
    );
  }
}
