import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shared visual primitives used across screens so cards, chips and
/// section headers stay visually consistent without every screen
/// re-declaring the same BoxDecoration boilerplate.
///
/// This is a small theme utility, not a View/ViewModel/Service — it's
/// intentionally kept separate from the screen files (alongside
/// AppColors/AppTheme) since it has no per-screen state or behavior.
class AppDecorations {
  AppDecorations._();

  /// Standard white card: rounded corners, hairline border, soft shadow.
  static BoxDecoration card({double radius = 16}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.line),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withOpacity(0.05),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// Same as [card] but with a colored accent stripe on the left edge —
  /// used by stat cards and request cards to signal status at a glance.
  static BoxDecoration accentCard(Color accent, {double radius = 16}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border(
        top: BorderSide(color: AppColors.line),
        right: BorderSide(color: AppColors.line),
        bottom: BorderSide(color: AppColors.line),
        left: BorderSide(color: accent, width: 4.5),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withOpacity(0.05),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// Soft header banner gradient used on a few screens for visual anchor.
  static const BoxDecoration headerGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.orange, AppColors.orangeDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(24),
    ),
  );
}
