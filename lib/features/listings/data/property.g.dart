// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Property _$PropertyFromJson(Map<String, dynamic> json) => Property(
  id: json['id'] as String?,
  title: json['title'] as String,
  location: json['location'] as String,
  imageUrl: json['imageUrl'] as String,
  price: json['price'] as num,
  description: json['description'] as String,
);

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'location': instance.location,
  'imageUrl': instance.imageUrl,
  'price': instance.price,
  'description': instance.description,
};
