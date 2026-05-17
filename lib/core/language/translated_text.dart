import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'language_controller.dart';
import 'translation_scope.dart';

class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool autoSize;

  const TranslatedText(
    this.text, {
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.autoSize = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!TranslationScope.isEnabled(context)) return _plain(text);

    final controller = LanguageController.instance;

    return Obx(() {
      final lang = controller.selectedLang.value;
      if (lang == 'en') return _plain(text);

      // Static hit — instant, no widget rebuilds
      final staticResult = controller.translateStatic(text);
      if (staticResult != null) return _plain(staticResult);

      // Dynamic text — use a keyed StatefulWidget so future resets only on
      // language change, not on every Obx rebuild
      return _AsyncTranslatedText(
        key: ValueKey('$lang:$text'),
        text: text,
        lang: lang,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    });
  }

  Widget _plain(String t) {
    final text = Text(
      t,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
    if (!autoSize) return text;
    return FittedBox(fit: BoxFit.scaleDown, child: text);
  }
}

// Holds the Future in State so it survives parent rebuilds
class _AsyncTranslatedText extends StatefulWidget {
  const _AsyncTranslatedText({
    required super.key,
    required this.text,
    required this.lang,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;
  final String lang;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  State<_AsyncTranslatedText> createState() => _AsyncTranslatedTextState();
}

class _AsyncTranslatedTextState extends State<_AsyncTranslatedText> {
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    _future = LanguageController.instance.translate(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _future,
      builder: (_, snapshot) => Text(
        snapshot.data ?? widget.text,
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        textAlign: widget.textAlign,
      ),
    );
  }
}
