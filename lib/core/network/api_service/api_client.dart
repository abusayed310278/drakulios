import 'dart:io';
import 'package:darkolious/core/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'token_meneger.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(String baseUrl)
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = "Bearer $token";
          }

          print("➡ [REQUEST] ${options.method} ${options.uri}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("[RESPONSE] ${response.statusCode} ${response.data}");
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          Get.closeAllSnackbars();

          bool _bypassAuthHandling(String path) {
            return path.contains("/auth/login") ||
                path.contains("/auth/social-login") ||
                path.contains("/auth/signup") ||
                path.contains("/auth/register") ||
                path.contains("/auth/switch-role") ||
                path.contains("/professional") ||
                path.contains("/request-history") ||
                path.contains("/users/me");
          }

          // Skip logout for auth/register + professional create endpoints
          if (_bypassAuthHandling(e.requestOptions.path)) {
            return handler.next(e); // just pass error
          }

          final token = await TokenManager.getToken();

          // Token missing → force logout
          if (token == null || token.trim().isEmpty) {
            print("Token missing → logout...");
            await TokenManager.clearToken();
            // Get.offAll(() => HandyEmailLoginScreen());
            return handler.reject(e);
          }

          // Token expired → refresh and retry
          if (e.response?.statusCode == 401) {
            try {
              await _refreshToken();
              final newToken = await TokenManager.getToken();
              if (newToken != null && newToken.trim().isNotEmpty) {
                e.requestOptions.headers['Authorization'] = "Bearer $newToken";
              }
              final retryResponse = await _dio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            } catch (err) {
              print("⚠ Token refresh failed. Logging out...");
              await TokenManager.clearToken();
              // Get.offAll(() => HandyEmailLoginScreen());
              return handler.reject(e);
            }
          }

          return handler.reject(e);
        },
      ),
    );
  }

  // --- Refresh token logic ---
  /*  Future<void> _refreshToken() async {
    final refreshToken = await TokenManager.getRefreshToken();
    if (refreshToken != null) {
      final response = await _dio.post(
        "$baseApiUrl/auth/refresh-token",
        data: {"refreshToken": refreshToken},
        cancelToken: CancelToken(),
      );
      final data = response.data["data"];
      await TokenManager.accessToken(data["accessToken"]);
      await TokenManager.refreshToken(data["refreshToken"]);
      print("Token refreshed successfully");
    } else {
      print("No refresh token available");
    }
  } */
  Future<void> _refreshToken() async {
    final refreshToken = await TokenManager.getRefreshToken();

    if (refreshToken == null || refreshToken.trim().isEmpty) {
      throw Exception("No refresh token");
    }

    // 🔥 Dio (NO interceptor)
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    final response = await refreshDio.post(
      ApiEndpoints.refreshToken,
      data: {"refreshToken": refreshToken},
    );

    final data = response.data["data"];

    await TokenManager.accessToken(data["accessToken"]);
    await TokenManager.refreshToken(data["refreshToken"]);

    print("✅ Token refreshed successfully");
  }

  // --- HTTP methods ---
  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return await _dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return await _dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> patch(String url, {dynamic data, File? file}) async {
    return await _dio.patch(url, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }
}
