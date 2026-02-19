import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  const CustomSnackbar._();

  static void show(String message) {
    final text = message.trim();
    if (text.isEmpty) return;

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFFF3B41A),
      titleText: const SizedBox.shrink(),
      messageText: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
