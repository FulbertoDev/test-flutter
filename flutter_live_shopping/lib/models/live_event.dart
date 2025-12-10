import 'package:json_annotation/json_annotation.dart';

import '../utils/app_enums.dart';
import 'product.dart';
import 'seller.dart';

part 'live_event.g.dart';

@JsonSerializable(explicitToJson: true)
class LiveEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final LiveEventStatus status;
  final Seller seller;
  final List<Product> products;
  final Product? featuredProduct;
  final int viewerCount;
  final String? streamUrl;
  final String? replayUrl;
  final String thumbnailUrl;

  LiveEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.seller,
    this.products = const [],
    this.featuredProduct,
    this.viewerCount = 0,
    this.streamUrl,
    this.replayUrl,
    required this.thumbnailUrl,
  });

  factory LiveEvent.fromJson(
    Map<String, dynamic> json,
    List<Product> products,
    Product? featured,
  ) {
    return LiveEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      status: LiveEventStatus.values.firstWhere(
        (e) => e.name == json['status'] as String,
      ),
      seller: Seller.fromJson(json['seller'] as Map<String, dynamic>),
      products: products,
      featuredProduct: featured,
      viewerCount: json['viewerCount'] as int? ?? 0,
      streamUrl: json['streamUrl'] as String?,
      replayUrl: json['replayUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }

  /*
  factory LiveEvent.fromJson(Map<String, dynamic> json) =>
      _$LiveEventFromJson(json);*/
  Map<String, dynamic> toJson() => _$LiveEventToJson(this);

  LiveEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    LiveEventStatus? status,
    Seller? seller,
    List<Product>? products,
    Product? featuredProduct,
    int? viewerCount,
    String? streamUrl,
    String? replayUrl,
    String? thumbnailUrl,
  }) {
    return LiveEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      seller: seller ?? this.seller,
      products: products ?? this.products,
      featuredProduct: featuredProduct ?? this.featuredProduct,
      viewerCount: viewerCount ?? this.viewerCount,
      streamUrl: streamUrl ?? this.streamUrl,
      replayUrl: replayUrl ?? this.replayUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
