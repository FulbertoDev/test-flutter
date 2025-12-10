import 'package:json_annotation/json_annotation.dart';

import '../utils/app_enums.dart';

part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final Map<String, String> selectedVariations;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.selectedVariations = const {},
  });

  double get total => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ShippingAddress {
  final String name;
  final String street;
  final String city;
  final String postalCode;
  final String country;

  ShippingAddress({
    required this.name,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressFromJson(json);
  Map<String, dynamic> toJson() => _$ShippingAddressToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Order {
  final String id;
  final String userId;
  final String liveEventId;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final ShippingAddress shippingAddress;

  Order({
    required this.id,
    required this.userId,
    required this.liveEventId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.shippingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
