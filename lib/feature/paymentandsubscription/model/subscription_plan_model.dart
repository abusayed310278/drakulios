import 'package:flutter/material.dart';

class PlanModel {
  const PlanModel({
    this.subscriptionId,
    this.billingPeriod,
    this.amount,
    required this.title,
    required this.markerColor,
    required this.borderColor,
    required this.background,
    required this.bullets,
    required this.priceMain,
    this.priceAccent,
    this.accentColor,
    this.note,
  });

  final String? subscriptionId;
  final String? billingPeriod;
  final double? amount;
  final String title;
  final Color markerColor;
  final Color borderColor;
  final Gradient background;
  final List<String> bullets;
  final String priceMain;
  final String? priceAccent;
  final Color? accentColor;
  final String? note;
}

class PlanTheme {
  const PlanTheme({
    required this.markerColor,
    required this.borderColor,
    required this.background,
    required this.accentColor,
  });

  final Color markerColor;
  final Color borderColor;
  final Gradient background;
  final Color accentColor;
}
