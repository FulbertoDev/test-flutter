// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  salePrice: (json['salePrice'] as num?)?.toDouble(),
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  thumbnail: json['thumbnail'] as String,
  stock: (json['stock'] as num).toInt(),
  variations: json['variations'] as Map<String, dynamic>?,
  isFeatured: json['isFeatured'] as bool? ?? false,
  featuredAt: json['featuredAt'] == null
      ? null
      : DateTime.parse(json['featuredAt'] as String),
  category: json['category'] as String,
  rating: (json['rating'] as num).toDouble(),
  reviewsCount: (json['reviewsCount'] as num).toInt(),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'salePrice': instance.salePrice,
  'images': instance.images,
  'thumbnail': instance.thumbnail,
  'stock': instance.stock,
  'variations': instance.variations,
  'isFeatured': instance.isFeatured,
  'featuredAt': instance.featuredAt?.toIso8601String(),
  'category': instance.category,
  'rating': instance.rating,
  'reviewsCount': instance.reviewsCount,
};
