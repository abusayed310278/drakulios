

import 'package:get/get.dart';
import 'translation_services.dart';

class LanguageController extends GetxController {
  final TranslationService _service = TranslationService();
  var selectedLang = 'en'.obs; // default English
  final Map<String, String> _cache = {};

  // Translate any text
  Future<String> translate(String text) async {
    if (selectedLang.value == 'en') return text;

    final key = '$text-${selectedLang.value}';
    if (_cache.containsKey(key)) return _cache[key]!;

    try {
      final translated = await _service.translateText(text, selectedLang.value);
      _cache[key] = translated;
      return translated;
    } catch (e) {
      print('Translation error: $e');
      return text;
    }
  }

  // Change language
  void changeLanguage(String lang) {
    selectedLang.value = lang;
    _cache.clear();
  }

  // Detect device language
  void detectDeviceLanguage() {
    final lang = Get.deviceLocale?.languageCode ?? 'en';
    selectedLang.value = lang;
  }
}
