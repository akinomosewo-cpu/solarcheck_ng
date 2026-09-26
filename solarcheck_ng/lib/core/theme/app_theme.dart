import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm, airy light palette with a single vibrant solar-orange accent used
/// sparingly for primary actions, stats and highlights.
class AppColors {
  AppColors._();
  static const Color primary = Color(0xFFFF7A1A);
  static const Color primaryDeep = Color(0xFFE8630A);
  static const Color success = Color(0xFF1FAE6B);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger = Color(0xFFE24B4B);
  static const Color info = Color(0xFF5B7FDE);
  static const Color background = Color(0xFFFAF4EC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFF3E7);
  static const Color textPrimary = Color(0xFF221B14);
  static const Color textSecondary = Color(0xFF847A6C);
  static const Color textTertiary = Color(0xFFC2B8A8);
  static const Color border = Color(0xFFF0E6D8);
  static const Color onPrimary = Colors.white;
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF9142), Color(0xFFFF6A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft, diffuse shadow used on cards in place of a flat border, matching
  /// the elevated-but-airy look of the reference designs.
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF3D2B14).withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 10),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: const Color(0xFF3D2B14).withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}

class AppTextStyles {
  AppTextStyles._();
  static TextStyle get displayHero => GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1);
  static TextStyle get displayLarge => GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.6);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.4);
  static TextStyle get displaySmall => GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3);
  static TextStyle get headlineLarge => GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700);
  static TextStyle get headlineMedium => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700);
  static TextStyle get headlineSmall => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700);
  static TextStyle get bodyLarge => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get labelLarge => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600);
  static TextStyle get labelMedium => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600);
  static TextStyle get labelSmall => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3);
}

class AppTheme {
  AppTheme._();
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.danger,
      onPrimary: AppColors.onPrimary,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: AppTextStyles.headlineSmall,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: AppTextStyles.headlineSmall,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
      backgroundColor: AppColors.surfaceElevated,
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      indicatorColor: AppColors.primary.withValues(alpha: 0.14),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return AppTextStyles.labelSmall.copyWith(color: selected ? AppColors.primary : AppColors.textSecondary);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? AppColors.primary : AppColors.textSecondary);
      }),
    ),
  );

  /// Kept for callers that still reference [AppTheme.dark]; now maps to the
  /// warm light theme, which is this app's single committed aesthetic.
  static ThemeData get dark => light;
}

/// A small colorful pill used for statuses, categories and badges (e.g.
/// "Verified installer", equipment type, warranty status).
class AppChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppChip({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
