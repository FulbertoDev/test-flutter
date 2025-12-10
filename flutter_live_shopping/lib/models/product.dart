import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable(explicitToJson: true)
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? salePrice;
  final List<String> images;
  final String thumbnail;
  final int stock;
  final Map<String, dynamic>? variations;
  final bool isFeatured;
  final DateTime? featuredAt;
  final String category;
  final double rating;
  final int reviewsCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.salePrice,
    required this.images,
    required this.thumbnail,
    required this.stock,
    this.variations,
    this.isFeatured = false,
    this.featuredAt,
    required this.category,
    required this.rating,
    required this.reviewsCount,
  });

  double get currentPrice => salePrice ?? price;
  bool get isOnSale => salePrice != null && salePrice! < price;
  double get discountPercentage =>
      isOnSale ? ((price - salePrice!) / price * 100) : 0;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? salePrice,
    List<String>? images,
    String? thumbnail,
    int? stock,
    Map<String, dynamic>? variations,
    bool? isFeatured,
    DateTime? featuredAt,
    String? category,
    double? rating,
    int? reviewsCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      images: images ?? this.images,
      thumbnail: thumbnail ?? this.thumbnail,
      stock: stock ?? this.stock,
      variations: variations ?? this.variations,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredAt: featuredAt ?? this.featuredAt,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }
}
