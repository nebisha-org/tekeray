// lib/features/listings/data/property.dart
import 'package:json_annotation/json_annotation.dart';
part 'property.g.dart';

@JsonSerializable()
class Property {
  final String? id; // optional, in case backend adds it later
  final String title;
  final String location;
  final String imageUrl;
  final num price; // robust: supports int or double
  final String description;

  Property({
    this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.description,
  });

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(_normalize(json));
  Map<String, dynamic> toJson() => _$PropertyToJson(this);

  // normalize price if backend sends it as string
  static Map<String, dynamic> _normalize(Map<String, dynamic> j) {
    final m = Map<String, dynamic>.from(j);
    final p = m['price'];
    if (p is String) {
      final parsed = num.tryParse(p);
      if (parsed != null) m['price'] = parsed;
    }
    return m;
  }
}
