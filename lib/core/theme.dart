import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// REUNI Design System
/// Slogan: "Second Hand, New Stories"
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF78B86A); // เขียว
  static const Color background = Color(0xFFFAF9F5);
  static const Color text = Color(0xFF292727);
  static const Color secondary = Color(0xFF737373);
  static const Color ai = Color(0xFF3BAFA3); // ฟ้าอมเขียว (สำหรับฟีเจอร์ AI)
  static const Color white = Color(0xFFFFFFFF);
  static const Color yellow = Color(0xFFF5C95B);
  static const Color pink = Color(0xFFF4C9D2);

  static const Color error = Color(0xFFE0554F);
  static const Color success = primary;
}

/// Spacing scale ใช้หน่วยฐาน 8px ตามที่ระบุใน design system
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

class AppRadius {
  AppRadius._();
  static const double button = 24; // ปุ่มมุมมน
  static const double card = 16; // card มุมมน
  static const double input = 12;
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base = GoogleFonts.notoSansThai();

  static TextStyle h1 = _base.copyWith(
      fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text);
  static TextStyle h2 = _base.copyWith(
      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text);
  static TextStyle h3 = _base.copyWith(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text);
  static TextStyle body = _base.copyWith(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.text);
  static TextStyle bodyBold = _base.copyWith(
      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text);
  static TextStyle caption = _base.copyWith(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.secondary);
  static TextStyle price = _base.copyWith(
      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary);
}

ThemeData buildReuniTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
      primary: AppColors.primary,
      secondary: AppColors.ai,
    ),
    fontFamily: GoogleFonts.notoSansThai().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.text,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppTextStyles.bodyBold.copyWith(color: AppColors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    ),
  );
}
