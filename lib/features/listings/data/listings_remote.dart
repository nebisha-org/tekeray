// lib/features/listings/data/listings_remote.dart
import 'package:dio/dio.dart';
import '../../../core/http_client.dart';
import 'property.dart';

class ListingsRemote {
  ListingsRemote(this.dio);
  final Dio dio;

  Future<List<Property>> fetchProperties() async {
    try {
      final res = await dio.get('/api/properties');
      final data = res.data;
      if (data is List) {
        return data
            .map((e) => Property.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      throw ApiException('Unexpected payload');
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Network error',
        status: e.response?.statusCode,
      );
    }
  }
}
