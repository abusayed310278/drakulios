import 'package:flutter/widgets.dart';

class TranslationScope extends InheritedWidget {
  const TranslationScope({
    required this.enabled,
    required super.child,
    super.key,
  });

  final bool enabled;

  static bool isEnabled(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TranslationScope>();
    return scope?.enabled ?? true;
  }

  @override
  bool updateShouldNotify(covariant TranslationScope oldWidget) {
    return oldWidget.enabled != enabled;
  }
}
