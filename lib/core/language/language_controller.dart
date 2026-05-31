import 'package:get/get.dart';

import 'static_text_localizer.dart';
import 'translaction_service.dart';

class LanguageController extends GetxController {
  static LanguageController get instance => Get.find<LanguageController>();

  final TranslationService _service = TranslationService();
  var selectedLang = 'en'.obs;

  // lang+text → translated result cache
  final Map<String, String> _cache = {};

  // Static lookup — instant, no API call
  String? translateStatic(String text) {
    return StaticTextLocalizer.lookup(text, selectedLang.value);
  }

  // Dynamic lookup — static first, then Google Translate API with cache
  Future<String> translate(String text) async {
    if (selectedLang.value == 'en') return text;

    final staticResult = StaticTextLocalizer.lookup(text, selectedLang.value);
    if (staticResult != null) return staticResult;

    final cacheKey = '${selectedLang.value}:$text';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    // ignore: avoid_print
    print('[Translate] API call → "$text" → ${selectedLang.value}');
    final translated = await _service.translateText(text, selectedLang.value);
    // ignore: avoid_print
    print('[Translate] Result → "$translated"');
    _cache[cacheKey] = translated;
    return translated;
  }

  void changeLanguage(String lang) {
    selectedLang.value = lang;
  }

  Future<String?> changeLanguageWithValidation(String lang) async {
    changeLanguage(lang);
    return null;
  }

  void detectDeviceLanguage() {
    final deviceLang = Get.deviceLocale?.languageCode ?? 'en';
    const supported = {'en', 'bn', 'es'};
    selectedLang.value = supported.contains(deviceLang) ? deviceLang : 'en';
  }
}
