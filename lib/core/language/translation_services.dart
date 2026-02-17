

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class TranslationService {
  final Dio _dio = Dio();

  Future<String> translateText(String text, String targetLang) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    if (apiKey == null || apiKey.trim().isEmpty) {
      return text;
    }

    const endpoint = 'https://translation.googleapis.com/language/translate/v2';

    try {
      final response = await _dio.post(endpoint, queryParameters: {
        'q': text,
        'target': targetLang,
        'key': apiKey,
      });

      return response.data['data']['translations'][0]['translatedText'];
    } catch (e) {
      print('Translation error: $e');
      return text; // fallback
    }
  }
}
