import 'package:flutter/material.dart';

class TrainingPlanModel {
  const TrainingPlanModel({
    required this.title,
    required this.markerColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.bullets,
    required this.numberedItems,
  });

  final String title;
  final Color markerColor;
  final Color borderColor;
  final Color backgroundColor;
  final List<String> bullets;
  final List<String> numberedItems;
}
