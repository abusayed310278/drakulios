import 'package:dio/dio.dart';

class TranslationService {
  static const _apiKey = 'AIzaSyAQ48SsZfnOzxSiHt6avx8yu2GWC4XC5Dc';
  static const _endpoint =
      'https://translation.googleapis.com/language/translate/v2';

  final Dio _dio = Dio();

  Future<String> translateText(String text, String targetLang) async {
    try {
      final response = await _dio.post(
        _endpoint,
        queryParameters: {
          'q': text,
          'target': targetLang,
          'key': _apiKey,
          'format': 'text',
        },
      );
      return response.data['data']['translations'][0]['translatedText'];
    } on DioException catch (e) {
      // ignore: avoid_print
      print('[Translate] API error ${e.response?.statusCode}: ${e.response?.data}');
      return text;
    } catch (e) {
      // ignore: avoid_print
      print('[Translate] Unexpected error: $e');
      return text;
    }
  }
}
