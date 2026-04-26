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
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      mainImage: json['main_image'],
      images: json['images'],
    );
  }
}