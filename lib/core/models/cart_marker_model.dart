import 'package:uuid/uuid.dart';

class CartMarker {
  final String id;
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final String shopName;
  final String? description;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  CartMarker({
    String? id,
    required this.userId,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.shopName,
    this.description,
    this.photoUrls = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'latitude': latitude,
      'longitude': longitude,
      'shop_name': shopName,
      'description': description,
      'photo_urls': photoUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  factory CartMarker.fromJson(Map<String, dynamic> json) {
    return CartMarker(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      shopName: json['shop_name'] ?? '',
      description: json['description'],
      photoUrls: List<String>.from(json['photo_urls'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
    );
  }
}
