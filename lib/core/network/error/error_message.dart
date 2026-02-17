import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

class ErrorMessage {
  static String from(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final serverMessage = _extractServerMessage(error.response?.data);

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out. Please try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Check your network and retry.';
        case DioExceptionType.badCertificate:
          return 'Secure connection failed. Please try again later.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.badResponse:
          if (status == 401 || status == 403) {
            return 'You are not authorized. Please sign in again.';
          }
          if (status == 404) return 'Requested resource was not found.';
          if (status == 400 || status == 422) {
            return serverMessage ?? 'Please check your input and try again.';
          }
          if (status != null && status >= 500) {
            return 'Server is temporarily unavailable. Please try again shortly.';
          }
          return serverMessage ?? fallback;
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return 'No internet connection. Check your network and retry.';
          }
          return _clean(error.message) ?? fallback;
      }
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    if (error is SocketException) {
      return 'No internet connection. Check your network and retry.';
    }
    return _clean(error.toString()) ?? fallback;
  }

  static String? _extractServerMessage(dynamic data) {
    if (data is Map) {
      final dynamic message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return _clean(message);
      }

      final dynamic errors = data['errors'] ?? data['error'];
      if (errors is List && errors.isNotEmpty) {
        for (final item in errors) {
          if (item is String && item.trim().isNotEmpty) {
            return _clean(item);
          }
          if (item is Map) {
            final msg = item['message'] ?? item['msg'] ?? item['error'];
            if (msg is String && msg.trim().isNotEmpty) {
              return _clean(msg);
            }
          }
        }
      }

      final dynamic nested = data['data'];
      if (nested is Map) {
        final nestedMessage = _extractServerMessage(nested);
        if (nestedMessage != null) return nestedMessage;
      }
    }
    if (data is String && data.trim().isNotEmpty) {
      return _clean(data);
    }
    return null;
  }

  static String? _clean(String? raw) {
    if (raw == null) return null;
    final value = raw
        .replaceFirst('Exception: ', '')
        .replaceFirst('DioException: ', '')
        .replaceFirst('DioError: ', '')
        .trim();
    if (value.isEmpty) return null;
    if (value.startsWith('DioException [bad response]')) return null;
    return value;
  }
}
