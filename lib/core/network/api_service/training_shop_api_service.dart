import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import 'api_client.dart';

class TrainingShopApiService {
  TrainingShopApiService({ApiClient? client}) : _client = client ?? ApiClient(ApiEndpoints.baseUrl);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> getTodayTrainings() async {
    final Response res = await _client.get(ApiEndpoints.trainingToday);
    return _toList(res.data);
  }

  Future<List<Map<String, dynamic>>> getTodayNutritions() async {
    final Response res = await _client.get(ApiEndpoints.nutritionToday);
    return _toList(res.data);
  }

  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    final Response res = await _client.get(ApiEndpoints.subscriptions);
    return _toList(res.data);
  }

  List<Map<String, dynamic>> _toList(dynamic raw) {
    if (raw is Map && raw['data'] is List) {
      return (raw['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return <Map<String, dynamic>>[];
  }
}
