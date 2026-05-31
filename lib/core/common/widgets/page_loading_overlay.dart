import 'package:flutter/material.dart';

class PageLoadingOverlay extends StatelessWidget {
  const PageLoadingOverlay({super.key, required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (!loading) return const SizedBox.shrink();
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
          color: Colors.black.withValues(alpha: 0.22),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: Color(0xFFF3B41A)),
        ),
      ),
    );
  }
}
