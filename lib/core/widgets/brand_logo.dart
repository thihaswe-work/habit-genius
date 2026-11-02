import 'package:flutter/material.dart';

/// Habit Genius brand mark shared by the splash screen and navigation.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF6C4DF6).withValues(alpha: 0.22),
            blurRadius: size * 0.24,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/brand/brand_logo.png',
        fit: BoxFit.cover,
        semanticLabel: 'Habit Genius logo',
      ),
    );
  }
}
