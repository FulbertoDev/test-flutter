import 'package:json_annotation/json_annotation.dart';

part 'seller.g.dart';

@JsonSerializable(explicitToJson: true)
class Seller {
  final String id;
  final String name;
  final String storeName;
  final String avatar;

  Seller({
    required this.id,
    required this.name,
    required this.storeName,
    required this.avatar,
  });

  factory Seller.fromJson(Map<String, dynamic> json) => _$SellerFromJson(json);
  Map<String, dynamic> toJson() => _$SellerToJson(this);
}
