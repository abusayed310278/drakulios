/* import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'language_controller.dart';

class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  TranslatedText(this.text, {this.style});

  final LanguageController languageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return FutureBuilder<String>(
        future: languageController.translate(text),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(text, style: style); // default English while loading
          }
          return Text(snapshot.data ?? text, style: style);
        },
      );
    });
  }
}
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'language_controller.dart';

class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  TranslatedText(
    this.text, {
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    super.key,
  });

  final LanguageController languageController =
      Get.isRegistered<LanguageController>()
          ? Get.find<LanguageController>()
          : Get.put(LanguageController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return FutureBuilder<String>(
        future: languageController.translate(text),
        builder: (context, snapshot) {
          return Text(
            snapshot.data ?? text,
            style: style,
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
          );
        },
      );
    });
  }
}
