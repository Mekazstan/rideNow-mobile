import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/core/utils/theme/app_colors.dart';

/// AppTheme - Main theme configuration for the application
class AppTheme {
  // Light theme color configurations
  static final _lightAppColors = AppColorExtension.light();

  // Dark theme color configurations
  static final _darkAppColors = AppColorExtension.dark();

  // Font styles for light theme
  static final _lightFontTheme = AppFontThemeExtension(
    // Headings
    heading1Bold: GoogleFonts.karla(
      fontSize: 45,
      height: 1.25, // 40px line height
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    heading1SemiBold: GoogleFonts.karla(
      fontSize: 45,
      height: 1.25, // 40px line height
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    heading1Medium: GoogleFonts.karla(
      fontSize: 45,
      height: 1.25, // 40px line height
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    heading1Regular: GoogleFonts.karla(
      fontSize: 45,
      height: 1.25, // 40px line height
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    heading2Bold: GoogleFonts.karla(
      fontSize: 32,
      height: 1.33, // 32px line height
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    heading2SemiBold: GoogleFonts.karla(
      fontSize: 32,
      height: 1.33, // 32px line height
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    heading2Medium: GoogleFonts.karla(
      fontSize: 32,
      height: 1.33, // 32px line height
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    heading2Regular: GoogleFonts.karla(
      fontSize: 32,
      height: 1.33, // 32px line height
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    heading3Bold: GoogleFonts.karla(
      fontSize: 28,
      height: 1.4,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    heading3SemiBold: GoogleFonts.karla(
      fontSize: 28,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    heading3Medium: GoogleFonts.karla(
      fontSize: 28,
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    heading3Regular: GoogleFonts.karla(
      fontSize: 28,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    // Text styles
    textLgBold: GoogleFonts.karla(
      fontSize: 24,
      height: 1.33, // 24px line height
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    textLgSemiBold: GoogleFonts.karla(
      fontSize: 24,
      height: 1.33, // 24px line height
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    textLgMedium: GoogleFonts.karla(
      fontSize: 24,
      height: 1.33, // 24px line height
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    textLgRegular: GoogleFonts.karla(
      fontSize: 24,
      height: 1.33, // 24px line height
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    textBaseBold: GoogleFonts.karla(
      fontSize: 20,
      height: 1.5, // 24px line height
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    textBaseSemiBold: GoogleFonts.karla(
      fontSize: 20,
      height: 1.5, // 24px line height
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    textBaseMedium: GoogleFonts.karla(
      fontSize: 20,
      height: 1.5, // 24px line height
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    textBaseRegular: GoogleFonts.karla(
      fontSize: 20,
      height: 1.5, // 24px line height
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    textMdBold: GoogleFonts.karla(
      fontSize: 16,
      height: 1.43, // 20px line height
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    textMdSemiBold: GoogleFonts.karla(
      fontSize: 16,
      height: 1.43, // 20px line height
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    textMdMedium: GoogleFonts.karla(
      fontSize: 16,
      height: 1.43, // 20px line height
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    textMdRegular: GoogleFonts.karla(
      fontSize: 16,
      height: 1.43, // 20px line height
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    textSmBold: GoogleFonts.karla(
      fontSize: 16, // Adjusted to match "Link" in image
      height: 1.33, // 16px line height
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    textSmSemiBold: GoogleFonts.karla(
      fontSize: 16, // Adjusted to match "Link" in image
      height: 1.33, // 16px line height
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    textSmMedium: GoogleFonts.karla(
      fontSize: 16, // Adjusted to match "Link" in image
      height: 1.33, // 16px line height
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    textSmRegular: GoogleFonts.karla(
      fontSize: 16, // Adjusted to match "Link" in image
      height: 1.33, // 16px line height
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    textXsBold: GoogleFonts.karla(
      fontSize: 12,
      height: 1.4, // 14px line height
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    textXsSemiBold: GoogleFonts.karla(
      fontSize: 12,
      height: 1.4, // 14px line height
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    textXsMedium: GoogleFonts.karla(
      fontSize: 12,
      height: 1.4, // 14px line height
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    textXsRegular: GoogleFonts.karla(
      fontSize: 12,
      height: 1.4, // 14px line height
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    // Legacy styles
    headerLarger: GoogleFonts.karla(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headerSmall: GoogleFonts.karla(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    subHeader: GoogleFonts.karla(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: AppColors.textTertiary,
    ),
    bodyMedium: GoogleFonts.karla(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
  );

  // Font styles for dark theme
  static final _darkFontTheme = AppFontThemeExtension(
    // Headings
    heading1Bold: GoogleFonts.karla(
      fontSize: 45,
      height: 1.25, // 40px line height
      fontWeight: FontWeight.w700,
      color: AppColorDark.textPrimary,
    ),
    heading1SemiBold: GoogleFonts.karla(
      fontSize: 45,
      height: 1.25, // 40px line height
      fontWeight: FontWeight.w600,
      color: AppColorDark.textPrimary,
    ),
    heading1Medium: GoogleFonts.karla(
      fontSize: 45,
      height: 1.25, // 40px line height
      fontWeight: FontWeight.w500,
      color: AppColorDark.textPrimary,
    ),
    heading1Regular: GoogleFonts.karla(
      fontSize: 45,
      height: 1.25, // 40px line height
      fontWeight: FontWeight.w400,
      color: AppColorDark.textPrimary,
    ),
    heading2Bold: GoogleFonts.karla(
      fontSize: 32,
      height: 1.33, // 32px line height
      fontWeight: FontWeight.w700,
      color: AppColorDark.textPrimary,
    ),
    heading2SemiBold: GoogleFonts.karla(
      fontSize: 32,
      height: 1.33, // 32px line height
      fontWeight: FontWeight.w600,
      color: AppColorDark.textPrimary,
    ),
    heading2Medium: GoogleFonts.karla(
      fontSize: 32,
      height: 1.33, // 32px line height
      fontWeight: FontWeight.w500,
      color: AppColorDark.textPrimary,
    ),
    heading2Regular: GoogleFonts.karla(
      fontSize: 32,
      height: 1.33, // 32px line height
      fontWeight: FontWeight.w400,
      color: AppColorDark.textPrimary,
    ),
    heading3Bold: GoogleFonts.karla(
      fontSize: 28,
      height: 1.4,
      fontWeight: FontWeight.w700,
      color: AppColorDark.textPrimary,
    ),
    heading3SemiBold: GoogleFonts.karla(
      fontSize: 28,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: AppColorDark.textPrimary,
    ),
    heading3Medium: GoogleFonts.karla(
      fontSize: 28,
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: AppColorDark.textPrimary,
    ),
    heading3Regular: GoogleFonts.karla(
      fontSize: 28,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: AppColorDark.textPrimary,
    ),
    // Text styles
    textLgBold: GoogleFonts.karla(
      fontSize: 24,
      height: 1.33, // 24px line height
      fontWeight: FontWeight.w700,
      color: AppColorDark.textPrimary,
    ),
    textLgSemiBold: GoogleFonts.karla(
      fontSize: 24,
      height: 1.33, // 24px line height
      fontWeight: FontWeight.w600,
      color: AppColorDark.textPrimary,
    ),
    textLgMedium: GoogleFonts.karla(
      fontSize: 24,
      height: 1.33, // 24px line height
      fontWeight: FontWeight.w500,
      color: AppColorDark.textPrimary,
    ),
    textLgRegular: GoogleFonts.karla(
      fontSize: 24,
      height: 1.33, // 24px line height
      fontWeight: FontWeight.w400,
      color: AppColorDark.textPrimary,
    ),
    textBaseBold: GoogleFonts.karla(
      fontSize: 20,
      height: 1.5, // 24px line height
      fontWeight: FontWeight.w700,
      color: AppColorDark.textPrimary,
    ),
    textBaseSemiBold: GoogleFonts.karla(
      fontSize: 20,
      height: 1.5, // 24px line height
      fontWeight: FontWeight.w600,
      color: AppColorDark.textPrimary,
    ),
    textBaseMedium: GoogleFonts.karla(
      fontSize: 20,
      height: 1.5, // 24px line height
      fontWeight: FontWeight.w500,
      color: AppColorDark.textPrimary,
    ),
    textBaseRegular: GoogleFonts.karla(
      fontSize: 20,
      height: 1.5, // 24px line height
      fontWeight: FontWeight.w400,
      color: AppColorDark.textPrimary,
    ),
    textMdBold: GoogleFonts.karla(
      fontSize: 16,
      height: 1.43, // 20px line height
      fontWeight: FontWeight.w700,
      color: AppColorDark.textPrimary,
    ),
    textMdSemiBold: GoogleFonts.karla(
      fontSize: 16,
      height: 1.43, // 20px line height
      fontWeight: FontWeight.w600,
      color: AppColorDark.textPrimary,
    ),
    textMdMedium: GoogleFonts.karla(
      fontSize: 16,
      height: 1.43, // 20px line height
      fontWeight: FontWeight.w500,
      color: AppColorDark.textPrimary,
    ),
    textMdRegular: GoogleFonts.karla(
      fontSize: 16,
      height: 1.43, // 20px line height
      fontWeight: FontWeight.w400,
      color: AppColorDark.textPrimary,
    ),
    textSmBold: GoogleFonts.karla(
      fontSize: 16, // Adjusted to match "Link" in image
      height: 1.33, // 16px line height
      fontWeight: FontWeight.w700,
      color: AppColorDark.textPrimary,
    ),
    textSmSemiBold: GoogleFonts.karla(
      fontSize: 16, // Adjusted to match "Link" in image
      height: 1.33, // 16px line height
      fontWeight: FontWeight.w600,
      color: AppColorDark.textPrimary,
    ),
    textSmMedium: GoogleFonts.karla(
      fontSize: 16, // Adjusted to match "Link" in image
      height: 1.33, // 16px line height
      fontWeight: FontWeight.w500,
      color: AppColorDark.textPrimary,
    ),
    textSmRegular: GoogleFonts.karla(
      fontSize: 16, // Adjusted to match "Link" in image
      height: 1.33, // 16px line height
      fontWeight: FontWeight.w400,
      color: AppColorDark.textPrimary,
    ),
    textXsBold: GoogleFonts.karla(
      fontSize: 12,
      height: 1.4, // 14px line height
      fontWeight: FontWeight.w700,
      color: AppColorDark.textPrimary,
    ),
    textXsSemiBold: GoogleFonts.karla(
      fontSize: 12,
      height: 1.4, // 14px line height
      fontWeight: FontWeight.w600,
      color: AppColorDark.textPrimary,
    ),
    textXsMedium: GoogleFonts.karla(
      fontSize: 12,
      height: 1.4, // 14px line height
      fontWeight: FontWeight.w500,
      color: AppColorDark.textPrimary,
    ),
    textXsRegular: GoogleFonts.karla(
      fontSize: 12,
      height: 1.4, // 14px line height
      fontWeight: FontWeight.w400,
      color: AppColorDark.textPrimary,
    ),
    // Legacy styles
    headerLarger: GoogleFonts.karla(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColorDark.textPrimary,
    ),
    headerSmall: GoogleFonts.karla(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColorDark.textPrimary,
    ),
    subHeader: GoogleFonts.karla(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: AppColorDark.textTertiary,
    ),
    bodyMedium: GoogleFonts.karla(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColorDark.textPrimary,
    ),
  );

  // Define the static light theme configurations
  static final light = () {
    final defaultTheme = ThemeData.light();
    return defaultTheme.copyWith(
      colorScheme: _lightAppColors.toColorScheme(Brightness.light),
      scaffoldBackgroundColor: _lightAppColors.bgB1,
      appBarTheme: AppBarTheme(
        color: _lightAppColors.bgB0,
        titleTextStyle: _lightFontTheme.heading2Bold,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        // Corrected: CardTheme instead of CardThemeData
        color: _lightAppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textTheme: TextTheme(
        // Map Material's text theme to our custom styles
        displayLarge: _lightFontTheme.heading1Bold,
        displayMedium: _lightFontTheme.heading2Bold,
        displaySmall: _lightFontTheme.heading3Bold,
        headlineLarge: _lightFontTheme.heading1SemiBold,
        headlineMedium: _lightFontTheme.heading2SemiBold,
        headlineSmall: _lightFontTheme.heading3SemiBold,
        titleLarge: _lightFontTheme.textLgBold,
        titleMedium: _lightFontTheme.textBaseBold,
        titleSmall: _lightFontTheme.textMdBold,
        bodyLarge: _lightFontTheme.textLgRegular,
        bodyMedium: _lightFontTheme.textBaseRegular,
        bodySmall: _lightFontTheme.textMdRegular,
        labelLarge: _lightFontTheme.textSmBold,
        labelMedium: _lightFontTheme.textSmRegular,
        labelSmall: _lightFontTheme.textXsRegular,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightAppColors.blue600,
          foregroundColor: _lightAppColors.textWhite,
          disabledBackgroundColor: _lightAppColors.inactiveButton,
          disabledForegroundColor: _lightAppColors.textPrimary,
          textStyle: _lightFontTheme.textMdBold,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightAppColors.blue600,
          disabledForegroundColor: _lightAppColors.textTertiary,
          textStyle: _lightFontTheme.textMdBold,
          side: BorderSide(color: _lightAppColors.blue600),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightAppColors.blue600,
          disabledForegroundColor: _lightAppColors.textTertiary,
          textStyle: _lightFontTheme.textMdBold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: _lightAppColors.bgB0,
        filled: true,
        labelStyle: _lightFontTheme.textMdRegular.copyWith(
          color: _lightAppColors.textTertiary,
        ),
        hintStyle: _lightFontTheme.textMdRegular.copyWith(
          color: _lightAppColors.textTertiary,
        ),
        errorStyle: _lightFontTheme.textSmRegular.copyWith(
          color: _lightAppColors.red500,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: _lightAppColors.gray300),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _lightAppColors.gray300),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _lightAppColors.blue600),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _lightAppColors.red500),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _lightAppColors.red500),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      extensions: [_lightAppColors, _lightFontTheme],
    );
  }();

  static final dark = () {
    final defaultTheme = ThemeData.dark();
    return defaultTheme.copyWith(
      colorScheme: _darkAppColors.toColorScheme(Brightness.dark),
      scaffoldBackgroundColor: _darkAppColors.bgB0,
      appBarTheme: AppBarTheme(
        color: _darkAppColors.bgB0,
        titleTextStyle: _darkFontTheme.heading2Bold,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        // Corrected: CardTheme instead of CardThemeData
        color: _darkAppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textTheme: TextTheme(
        // Map Material's text theme to our custom styles
        displayLarge: _darkFontTheme.heading1Bold,
        displayMedium: _darkFontTheme.heading2Bold,
        displaySmall: _darkFontTheme.heading3Bold,
        headlineLarge: _darkFontTheme.heading1SemiBold,
        headlineMedium: _darkFontTheme.heading2SemiBold,
        headlineSmall: _darkFontTheme.heading3SemiBold,
        titleLarge: _darkFontTheme.textLgBold,
        titleMedium: _darkFontTheme.textBaseBold,
        titleSmall: _darkFontTheme.textMdBold,
        bodyLarge: _darkFontTheme.textLgRegular,
        bodyMedium: _darkFontTheme.textBaseRegular,
        bodySmall: _darkFontTheme.textMdRegular,
        labelLarge: _darkFontTheme.textSmBold,
        labelMedium: _darkFontTheme.textSmRegular,
        labelSmall: _darkFontTheme.textXsRegular,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkAppColors.blue500,
          foregroundColor: _darkAppColors.textWhite,
          disabledBackgroundColor: _darkAppColors.inactiveButton,
          disabledForegroundColor: _darkAppColors.textPrimary,
          textStyle: _darkFontTheme.textMdBold,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkAppColors.blue500,
          disabledForegroundColor: _darkAppColors.textTertiary,
          textStyle: _darkFontTheme.textMdBold,
          side: BorderSide(color: _darkAppColors.blue500),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkAppColors.blue500,
          disabledForegroundColor: _darkAppColors.textTertiary,
          textStyle: _darkFontTheme.textMdBold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: _darkAppColors.bgB0,
        filled: true,
        labelStyle: _darkFontTheme.textMdRegular.copyWith(
          color: _darkAppColors.textTertiary,
        ),
        hintStyle: _darkFontTheme.textMdRegular.copyWith(
          color: _darkAppColors.textTertiary,
        ),
        errorStyle: _darkFontTheme.textSmRegular.copyWith(
          color: _darkAppColors.red500,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: _darkAppColors.gray400),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _darkAppColors.gray400),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _darkAppColors.blue500),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _darkAppColors.red500),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _darkAppColors.red500),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      extensions: [_darkAppColors, _darkFontTheme],
    );
  }();
}

extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}

extension AppThemeExtension on ThemeData {
  AppColorExtension get colors =>
      extension<AppColorExtension>() ??
      AppColorExtension.light(); // Fallback to light
  AppFontThemeExtension get fonts =>
      extension<AppFontThemeExtension>() ??
      AppFontThemeExtension.fromTextTheme(
        ThemeData.light().textTheme, // Provide a default TextTheme
        AppColors.textPrimary, // Provide a default color
      );
}
