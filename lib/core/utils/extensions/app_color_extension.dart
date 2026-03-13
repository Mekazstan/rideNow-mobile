import 'package:flutter/material.dart';

/// `ThemeExtension` for app custom colors.
///
/// This extension includes colors from the app palette and can be easily used
/// throughout the app for consistent theming.
///
/// Usage example: `Theme.of(context).extension<AppColorExtension>()?.textPrimary`.
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  const AppColorExtension({
    // Text colors
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textQuaternary,
    required this.textWhite,

    // Brand colors
    required this.brandDefault,
    required this.brandContrast,
    required this.brandHover,
    required this.brandActive,
    required this.brandStroke,
    required this.brandFill,

    // Navy colors
    required this.navy50,
    required this.navy100,
    required this.navy200,
    required this.navy300,
    required this.navy400,
    required this.navy500,
    required this.navy600,
    required this.navy700,
    required this.navy800,
    required this.navy900,
    required this.navy950,

    // Orange colors
    required this.orange50,
    required this.orange100,
    required this.orange200,
    required this.orange300,
    required this.orange400,
    required this.orange500,
    required this.orange600,
    required this.orange700,
    required this.orange800,
    required this.orange900,
    required this.orange950,

    // Pink colors
    required this.pink50,
    required this.pink100,
    required this.pink200,
    required this.pink300,
    required this.pink400,
    required this.pink500,
    required this.pink600,
    required this.pink700,
    required this.pink800,
    required this.pink900,
    required this.pink950,

    // Green colors
    required this.green50,
    required this.green100,
    required this.green200,
    required this.green300,
    required this.green400,
    required this.green500,
    required this.green600,
    required this.green700,
    required this.green800,
    required this.green900,
    required this.green950,

    // Red colors
    required this.red50,
    required this.red100,
    required this.red200,
    required this.red300,
    required this.red400,
    required this.red500,
    required this.red600,
    required this.red700,
    required this.red800,
    required this.red900,
    required this.red950,

    // Gray colors
    required this.gray50,
    required this.gray100,
    required this.gray200,
    required this.gray300,
    required this.gray400,
    required this.gray500,
    required this.gray600,
    required this.gray700,
    required this.gray800,
    required this.gray900,
    required this.gray950,

    // Blue colors
    required this.blue50,
    required this.blue100,
    required this.blue200,
    required this.blue300,
    required this.blue400,
    required this.blue500,
    required this.blue600,
    required this.blue700,
    required this.blue800,
    required this.blue900,
    required this.blue950,

    // Background colors
    required this.bgB0,
    required this.bgB1,
    required this.bgB2,
    required this.bgB3,

    // Surface colors
    required this.surface,
    required this.surfaceCard,

    // Button/Interactive colors
    required this.activeButton,
    required this.inactiveButton,
    required this.buttonTertiary,
    required this.buttonSecondary,

    // Icon colors
    required this.iconRed,
    required this.iconBlue,
    required this.textHighlightBlue,

    // Miscellaneous colors
    required this.contrastBlack,
    required this.contrastWhite,
    required this.strokePrimary,
    required this.strokeSecondary,
    required this.fillTertiary,
  });

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textQuaternary;
  final Color textWhite;

  // Brand colors
  final Color brandDefault;
  final Color brandContrast;
  final Color brandHover;
  final Color brandActive;
  final Color brandStroke;
  final Color brandFill;

  // Navy colors
  final Color navy50;
  final Color navy100;
  final Color navy200;
  final Color navy300;
  final Color navy400;
  final Color navy500;
  final Color navy600;
  final Color navy700;
  final Color navy800;
  final Color navy900;
  final Color navy950;

  // Orange colors
  final Color orange50;
  final Color orange100;
  final Color orange200;
  final Color orange300;
  final Color orange400;
  final Color orange500;
  final Color orange600;
  final Color orange700;
  final Color orange800;
  final Color orange900;
  final Color orange950;

  // Pink colors
  final Color pink50;
  final Color pink100;
  final Color pink200;
  final Color pink300;
  final Color pink400;
  final Color pink500;
  final Color pink600;
  final Color pink700;
  final Color pink800;
  final Color pink900;
  final Color pink950;

  // Green colors
  final Color green50;
  final Color green100;
  final Color green200;
  final Color green300;
  final Color green400;
  final Color green500;
  final Color green600;
  final Color green700;
  final Color green800;
  final Color green900;
  final Color green950;

  // Red colors
  final Color red50;
  final Color red100;
  final Color red200;
  final Color red300;
  final Color red400;
  final Color red500;
  final Color red600;
  final Color red700;
  final Color red800;
  final Color red900;
  final Color red950;

  // Gray colors
  final Color gray50;
  final Color gray100;
  final Color gray200;
  final Color gray300;
  final Color gray400;
  final Color gray500;
  final Color gray600;
  final Color gray700;
  final Color gray800;
  final Color gray900;
  final Color gray950;

  // Blue colors
  final Color blue50;
  final Color blue100;
  final Color blue200;
  final Color blue300;
  final Color blue400;
  final Color blue500;
  final Color blue600;
  final Color blue700;
  final Color blue800;
  final Color blue900;
  final Color blue950;

  // Background colors
  final Color bgB0;
  final Color bgB1;
  final Color bgB2;
  final Color bgB3;

  // Surface colors
  final Color surface;
  final Color surfaceCard;

  // Button/Interactive colors
  final Color activeButton;
  final Color inactiveButton;
  final Color buttonTertiary;
  final Color buttonSecondary;

  // Icon colors
  final Color iconRed;
  final Color iconBlue;
  final Color textHighlightBlue;

  // Miscellaneous colors
  final Color contrastBlack;
  final Color contrastWhite;
  final Color strokePrimary;
  final Color strokeSecondary;
  final Color fillTertiary;

  /// Create light theme colors
  factory AppColorExtension.light() {
    return const AppColorExtension(
      // Text colors
      textPrimary: Color(0xFF18181B),
      textSecondary: Color(0xFF060A21),
      textTertiary: Color(0xFFA1A1AA),
      textQuaternary: Color(0xFFD4D4D8),
      textWhite: Color(0xFFFAFAFA),

      // Brand colors
      brandDefault: Color(0xFF6969AF),
      brandContrast: Color(0xFF54548C),
      brandHover: Color(0xFF54548C),
      brandActive: Color(0xFF3F3F69),
      brandStroke: Color(0xFFA5A5CF),
      brandFill: Color(0xFFF0F0F7),

      // Navy colors
      navy50: Color(0xFFF0F0F7),
      navy100: Color(0xFFE1E1EF),
      navy200: Color(0xFFC3C3DF),
      navy300: Color(0xFFA5A5CF),
      navy400: Color(0xFF8787BF),
      navy500: Color(0xFF6969AF),
      navy600: Color(0xFF54548C),
      navy700: Color(0xFF3F3F69),
      navy800: Color(0xFF2A2A46),
      navy900: Color(0xFF151523),
      navy950: Color(0xFF0A0A11),

      // Orange colors
      orange50: Color(0xFFFFF7ED),
      orange100: Color(0xFFFFEDD5),
      orange200: Color(0xFFFED7AA),
      orange300: Color(0xFFFDBB74),
      orange400: Color(0xFFFB923C),
      orange500: Color(0xFFF97316),
      orange600: Color(0xFFEA580C),
      orange700: Color(0xFFC2410C),
      orange800: Color(0xFF9A3412),
      orange900: Color(0xFF7C2D12),
      orange950: Color(0xFF431407),

      // Pink colors
      pink50: Color(0xFFFDF2F8),
      pink100: Color(0xFFFCE7F3),
      pink200: Color(0xFFFBCFE8),
      pink300: Color(0xFFF9A8D4),
      pink400: Color(0xFFF472B6),
      pink500: Color(0xFFEC4899),
      pink600: Color(0xFFDB2777),
      pink700: Color(0xFFBE185D),
      pink800: Color(0xFF9D174D),
      pink900: Color(0xFF831843),
      pink950: Color(0xFF500724),

      // Green colors
      green50: Color(0xFFF0FDF4),
      green100: Color(0xFFDCFCE7),
      green200: Color(0xFFBBF7D0),
      green300: Color(0xFF86EFAC),
      green400: Color(0xFF4ADE80),
      green500: Color(0xFF22C55E),
      green600: Color(0xFF16A34A),
      green700: Color(0xFF15803D),
      green800: Color(0xFF166534),
      green900: Color(0xFF14532D),
      green950: Color(0xFF052E16),

      // Red colors
      red50: Color(0xFFFEF2F2),
      red100: Color(0xFFFEE2E2),
      red200: Color(0xFFFECACA),
      red300: Color(0xFFFCA5A5),
      red400: Color(0xFFF87171),
      red500: Color(0xFFEF4444),
      red600: Color(0xFFDC2626),
      red700: Color(0xFFB91C1C),
      red800: Color(0xFF991B1B),
      red900: Color(0xFF7F1D1D),
      red950: Color(0xFF450A0A),

      // Gray colors
      gray50: Color(0xFFFAFAFA),
      gray100: Color(0xFFF4F4F5),
      gray200: Color(0xFFE4E4E7),
      gray300: Color(0xFFD4D4D8),
      gray400: Color(0xFFA1A1AA),
      gray500: Color(0xFF71717A),
      gray600: Color(0xFF52525B),
      gray700: Color(0xFF3F3F46),
      gray800: Color(0xFF27272A),
      gray900: Color(0xFF18181B),
      gray950: Color(0xFF09090B),

      // Blue colors
      blue50: Color(0xFFEAECFB),
      blue100: Color(0xFFDBEAFE),
      blue200: Color(0xFFBFDBFE),
      blue300: Color(0xFF93C5FD),
      blue400: Color(0xFF60A5FA),
      blue500: Color(0xFF3B82F6),
      blue600: Color(0xFF2563EB),
      blue700: Color(0xFF1D4ED8),
      blue800: Color(0xFF1E40AF),
      blue900: Color(0xFF1E3A8A),
      blue950: Color(0xFF172554),

      // Background colors
      bgB0: Color(0xFFFFFFFF),
      bgB1: Color(0xFFFAFAFA),
      bgB2: Color(0xFFF4F4F5),
      bgB3: Color(0xFFE4E4E7),

      // Surface colors
      surface: Color(0xFFFAFAFA),
      surfaceCard: Color(0xFFFFFFFF),

      // Button/Interactive colors
      activeButton: Color(0xFF2563EB),
      inactiveButton: Color(0xFFD4D4D8),
      buttonTertiary: Color(0xFFF97316),
      buttonSecondary: Color(0xFF27272A),

      // Icon colors
      iconRed: Color(0xFFEF4444),
      iconBlue: Color(0xFF2563EB),
      textHighlightBlue: Color(0xFF2563EB),

      // Miscellaneous colors
      contrastBlack: Color(0xFF18181B),
      contrastWhite: Color(0xFFFFFFFF),
      strokePrimary: Color(0xFFE4E4E7),
      strokeSecondary: Color(0xFFD4D4D8),
      fillTertiary: Color(0xFFF4F4F5),
    );
  }

  /// Create dark theme colors
  factory AppColorExtension.dark() {
    return const AppColorExtension(
      // Text colors
      textPrimary: Color(0xFFFAFAFA),
      textSecondary: Color(0xFFA1A1AA),
      textTertiary: Color(0xFF71717A),
      textQuaternary: Color(0xFF52525B),
      textWhite: Color(0xFF09090B),

      // Brand colors
      brandDefault: Color(0xFF6969AF),
      brandContrast: Color(0xFF8787BF),
      brandHover: Color(0xFF8787BF),
      brandActive: Color(0xFFA5A5CF),
      brandStroke: Color(0xFF3F3F69),
      brandFill: Color(0xFF0A0A11),

      // Navy colors
      navy50: Color(0xFF0A0A11),
      navy100: Color(0xFF151523),
      navy200: Color(0xFF2A2A46),
      navy300: Color(0xFF3F3F69),
      navy400: Color(0xFF54548C),
      navy500: Color(0xFF6969AF),
      navy600: Color(0xFF8787BF),
      navy700: Color(0xFFA5A5CF),
      navy800: Color(0xFFC3C3DF),
      navy900: Color(0xFFE1E1EF),
      navy950: Color(0xFFF0F0F7),

      // Orange colors
      orange50: Color(0xFF431407),
      orange100: Color(0xFF7C2D12),
      orange200: Color(0xFF9A3412),
      orange300: Color(0xFFC2410C),
      orange400: Color(0xFFEA580C),
      orange500: Color(0xFFF97316),
      orange600: Color(0xFFFB923C),
      orange700: Color(0xFFFDBB74),
      orange800: Color(0xFFFED7AA),
      orange900: Color(0xFFFFEDD5),
      orange950: Color(0xFFFFF7ED),

      // Pink colors
      pink50: Color(0xFF500724),
      pink100: Color(0xFF831843),
      pink200: Color(0xFF9D174D),
      pink300: Color(0xFFBE185D),
      pink400: Color(0xFFDB2777),
      pink500: Color(0xFFEC4899),
      pink600: Color(0xFFF472B6),
      pink700: Color(0xFFF9A8D4),
      pink800: Color(0xFFFBCFE8),
      pink900: Color(0xFFFCE7F3),
      pink950: Color(0xFFFDF2F8),

      // Green colors
      green50: Color(0xFF052E16),
      green100: Color(0xFF14532D),
      green200: Color(0xFF166534),
      green300: Color(0xFF15803D),
      green400: Color(0xFF16A34A),
      green500: Color(0xFF22C55E),
      green600: Color(0xFF4ADE80),
      green700: Color(0xFF86EFAC),
      green800: Color(0xFFBBF7D0),
      green900: Color(0xFFDCFCE7),
      green950: Color(0xFFF0FDF4),

      // Red colors
      red50: Color(0xFF450A0A),
      red100: Color(0xFF7F1D1D),
      red200: Color(0xFF991B1B),
      red300: Color(0xFFB91C1C),
      red400: Color(0xFFDC2626),
      red500: Color(0xFFEF4444),
      red600: Color(0xFFF87171),
      red700: Color(0xFFFCA5A5),
      red800: Color(0xFFFECACA),
      red900: Color(0xFFFEE2E2),
      red950: Color(0xFFFEF2F2),

      // Gray colors
      gray50: Color(0xFF09090B),
      gray100: Color(0xFF18181B),
      gray200: Color(0xFF27272A),
      gray300: Color(0xFF3F3F46),
      gray400: Color(0xFF52525B),
      gray500: Color(0xFF71717A),
      gray600: Color(0xFFA1A1AA),
      gray700: Color(0xFFD4D4D8),
      gray800: Color(0xFFE4E4E7),
      gray900: Color(0xFFF4F4F5),
      gray950: Color(0xFFFAFAFA),

      // Blue colors
      blue50: Color(0xFF172554),
      blue100: Color(0xFF1E3A8A),
      blue200: Color(0xFF1E40AF),
      blue300: Color(0xFF1D4ED8),
      blue400: Color(0xFF2563EB),
      blue500: Color(0xFF3B82F6),
      blue600: Color(0xFF60A5FA),
      blue700: Color(0xFF93C5FD),
      blue800: Color(0xFFBFDBFE),
      blue900: Color(0xFFDBEAFE),
      blue950: Color(0xFFEFF6FF),

      // Background colors
      bgB0: Color(0xFF09090B),
      bgB1: Color(0xFF18181B),
      bgB2: Color(0xFF27272A),
      bgB3: Color(0xFF3F3F46),

      // Surface colors
      surface: Color(0xFF18181B),
      surfaceCard: Color(0xFF27272A),

      // Button/Interactive colors
      activeButton: Color(0xFF3B82F6),
      inactiveButton: Color(0xFFA1A1AA),
      buttonTertiary: Color(0xFFF97316),
      buttonSecondary: Color(0xFF27272A),

      // Icon colors
      iconRed: Color(0xFFEF4444),
      iconBlue: Color(0xFF3B82F6),
      textHighlightBlue: Color(0xFF3B82F6),

      // Miscellaneous colors
      contrastBlack: Color(0xFFFFFFFF),
      contrastWhite: Color(0xFF09090B),
      strokePrimary: Color(0xFF3F3F46),
      strokeSecondary: Color(0xFFA1A1AA),
      fillTertiary: Color(0xFFE4E4E7),
    );
  }

  @override
  ThemeExtension<AppColorExtension> copyWith({
    // Text colors
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textQuaternary,
    Color? textWhite,

    // Brand colors
    Color? brandDefault,
    Color? brandContrast,
    Color? brandHover,
    Color? brandActive,
    Color? brandStroke,
    Color? brandFill,

    // Navy colors
    Color? navy50,
    Color? navy100,
    Color? navy200,
    Color? navy300,
    Color? navy400,
    Color? navy500,
    Color? navy600,
    Color? navy700,
    Color? navy800,
    Color? navy900,
    Color? navy950,

    // Orange colors
    Color? orange50,
    Color? orange100,
    Color? orange200,
    Color? orange300,
    Color? orange400,
    Color? orange500,
    Color? orange600,
    Color? orange700,
    Color? orange800,
    Color? orange900,
    Color? orange950,

    // Pink colors
    Color? pink50,
    Color? pink100,
    Color? pink200,
    Color? pink300,
    Color? pink400,
    Color? pink500,
    Color? pink600,
    Color? pink700,
    Color? pink800,
    Color? pink900,
    Color? pink950,

    // Green colors
    Color? green50,
    Color? green100,
    Color? green200,
    Color? green300,
    Color? green400,
    Color? green500,
    Color? green600,
    Color? green700,
    Color? green800,
    Color? green900,
    Color? green950,

    // Red colors
    Color? red50,
    Color? red100,
    Color? red200,
    Color? red300,
    Color? red400,
    Color? red500,
    Color? red600,
    Color? red700,
    Color? red800,
    Color? red900,
    Color? red950,

    // Gray colors
    Color? gray50,
    Color? gray100,
    Color? gray200,
    Color? gray300,
    Color? gray400,
    Color? gray500,
    Color? gray600,
    Color? gray700,
    Color? gray800,
    Color? gray900,
    Color? gray950,

    // Blue colors
    Color? blue50,
    Color? blue100,
    Color? blue200,
    Color? blue300,
    Color? blue400,
    Color? blue500,
    Color? blue600,
    Color? blue700,
    Color? blue800,
    Color? blue900,
    Color? blue950,

    // Background colors
    Color? bgB0,
    Color? bgB1,
    Color? bgB2,
    Color? bgB3,

    // Surface colors
    Color? surface,
    Color? surfaceCard,

    // Button/Interactive colors
    Color? activeButton,
    Color? inactiveButton,
    Color? buttonTertiary,
    Color? buttonSecondary,

    // Icon colors
    Color? iconRed,
    Color? iconBlue,
    Color? textHighlightBlue,

    // Miscellaneous colors
    Color? contrastBlack,
    Color? contrastWhite,
    Color? strokePrimary,
    Color? strokeSecondary,
    Color? fillTertiary,
  }) {
    return AppColorExtension(
      // Text colors
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textQuaternary: textQuaternary ?? this.textQuaternary,
      textWhite: textWhite ?? this.textWhite,

      // Brand colors
      brandDefault: brandDefault ?? this.brandDefault,
      brandContrast: brandContrast ?? this.brandContrast,
      brandHover: brandHover ?? this.brandHover,
      brandActive: brandActive ?? this.brandActive,
      brandStroke: brandStroke ?? this.brandStroke,
      brandFill: brandFill ?? this.brandFill,

      // Navy colors
      navy50: navy50 ?? this.navy50,
      navy100: navy100 ?? this.navy100,
      navy200: navy200 ?? this.navy200,
      navy300: navy300 ?? this.navy300,
      navy400: navy400 ?? this.navy400,
      navy500: navy500 ?? this.navy500,
      navy600: navy600 ?? this.navy600,
      navy700: navy700 ?? this.navy700,
      navy800: navy800 ?? this.navy800,
      navy900: navy900 ?? this.navy900,
      navy950: navy950 ?? this.navy950,

      // Orange colors
      orange50: orange50 ?? this.orange50,
      orange100: orange100 ?? this.orange100,
      orange200: orange200 ?? this.orange200,
      orange300: orange300 ?? this.orange300,
      orange400: orange400 ?? this.orange400,
      orange500: orange500 ?? this.orange500,
      orange600: orange600 ?? this.orange600,
      orange700: orange700 ?? this.orange700,
      orange800: orange800 ?? this.orange800,
      orange900: orange900 ?? this.orange900,
      orange950: orange950 ?? this.orange950,

      // Pink colors
      pink50: pink50 ?? this.pink50,
      pink100: pink100 ?? this.pink100,
      pink200: pink200 ?? this.pink200,
      pink300: pink300 ?? this.pink300,
      pink400: pink400 ?? this.pink400,
      pink500: pink500 ?? this.pink500,
      pink600: pink600 ?? this.pink600,
      pink700: pink700 ?? this.pink700,
      pink800: pink800 ?? this.pink800,
      pink900: pink900 ?? this.pink900,
      pink950: pink950 ?? this.pink950,

      // Green colors
      green50: green50 ?? this.green50,
      green100: green100 ?? this.green100,
      green200: green200 ?? this.green200,
      green300: green300 ?? this.green300,
      green400: green400 ?? this.green400,
      green500: green500 ?? this.green500,
      green600: green600 ?? this.green600,
      green700: green700 ?? this.green700,
      green800: green800 ?? this.green800,
      green900: green900 ?? this.green900,
      green950: green950 ?? this.green950,

      // Red colors
      red50: red50 ?? this.red50,
      red100: red100 ?? this.red100,
      red200: red200 ?? this.red200,
      red300: red300 ?? this.red300,
      red400: red400 ?? this.red400,
      red500: red500 ?? this.red500,
      red600: red600 ?? this.red600,
      red700: red700 ?? this.red700,
      red800: red800 ?? this.red800,
      red900: red900 ?? this.red900,
      red950: red950 ?? this.red950,

      // Gray colors
      gray50: gray50 ?? this.gray50,
      gray100: gray100 ?? this.gray100,
      gray200: gray200 ?? this.gray200,
      gray300: gray300 ?? this.gray300,
      gray400: gray400 ?? this.gray400,
      gray500: gray500 ?? this.gray500,
      gray600: gray600 ?? this.gray600,
      gray700: gray700 ?? this.gray700,
      gray800: gray800 ?? this.gray800,
      gray900: gray900 ?? this.gray900,
      gray950: gray950 ?? this.gray950,

      // Blue colors
      blue50: blue50 ?? this.blue50,
      blue100: blue100 ?? this.blue100,
      blue200: blue200 ?? this.blue200,
      blue300: blue300 ?? this.blue300,
      blue400: blue400 ?? this.blue400,
      blue500: blue500 ?? this.blue500,
      blue600: blue600 ?? this.blue600,
      blue700: blue700 ?? this.blue700,
      blue800: blue800 ?? this.blue800,
      blue900: blue900 ?? this.blue900,
      blue950: blue950 ?? this.blue950,

      // Background colors
      bgB0: bgB0 ?? this.bgB0,
      bgB1: bgB1 ?? this.bgB1,
      bgB2: bgB2 ?? this.bgB2,
      bgB3: bgB3 ?? this.bgB3,

      // Surface colors
      surface: surface ?? this.surface,
      surfaceCard: surfaceCard ?? this.surfaceCard,

      // Button/Interactive colors
      activeButton: activeButton ?? this.activeButton,
      inactiveButton: inactiveButton ?? this.inactiveButton,
      buttonTertiary: buttonTertiary ?? this.buttonTertiary,
      buttonSecondary: buttonSecondary ?? this.buttonSecondary,

      // Icon colors
      iconRed: iconRed ?? this.iconRed,
      iconBlue: iconBlue ?? this.iconBlue,
      textHighlightBlue: textHighlightBlue ?? this.textHighlightBlue,

      // Miscellaneous colors
      contrastBlack: contrastBlack ?? this.contrastBlack,
      contrastWhite: contrastWhite ?? this.contrastWhite,
      strokePrimary: strokePrimary ?? this.strokePrimary,
      strokeSecondary: strokeSecondary ?? this.strokeSecondary,
      fillTertiary: fillTertiary ?? this.fillTertiary,
    );
  }

  @override
  ThemeExtension<AppColorExtension> lerp(
    covariant ThemeExtension<AppColorExtension>? other,
    double t,
  ) {
    if (other is! AppColorExtension) {
      return this;
    }

    return AppColorExtension(
      // Text colors
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textQuaternary: Color.lerp(textQuaternary, other.textQuaternary, t)!,
      textWhite: Color.lerp(textWhite, other.textWhite, t)!,

      // Brand colors
      brandDefault: Color.lerp(brandDefault, other.brandDefault, t)!,
      brandContrast: Color.lerp(brandContrast, other.brandContrast, t)!,
      brandHover: Color.lerp(brandHover, other.brandHover, t)!,
      brandActive: Color.lerp(brandActive, other.brandActive, t)!,
      brandStroke: Color.lerp(brandStroke, other.brandStroke, t)!,
      brandFill: Color.lerp(brandFill, other.brandFill, t)!,

      // Navy colors
      navy50: Color.lerp(navy50, other.navy50, t)!,
      navy100: Color.lerp(navy100, other.navy100, t)!,
      navy200: Color.lerp(navy200, other.navy200, t)!,
      navy300: Color.lerp(navy300, other.navy300, t)!,
      navy400: Color.lerp(navy400, other.navy400, t)!,
      navy500: Color.lerp(navy500, other.navy500, t)!,
      navy600: Color.lerp(navy600, other.navy600, t)!,
      navy700: Color.lerp(navy700, other.navy700, t)!,
      navy800: Color.lerp(navy800, other.navy800, t)!,
      navy900: Color.lerp(navy900, other.navy900, t)!,
      navy950: Color.lerp(navy950, other.navy950, t)!,

      // Orange colors
      orange50: Color.lerp(orange50, other.orange50, t)!,
      orange100: Color.lerp(orange100, other.orange100, t)!,
      orange200: Color.lerp(orange200, other.orange200, t)!,
      orange300: Color.lerp(orange300, other.orange300, t)!,
      orange400: Color.lerp(orange400, other.orange400, t)!,
      orange500: Color.lerp(orange500, other.orange500, t)!,
      orange600: Color.lerp(orange600, other.orange600, t)!,
      orange700: Color.lerp(orange700, other.orange700, t)!,
      orange800: Color.lerp(orange800, other.orange800, t)!,
      orange900: Color.lerp(orange900, other.orange900, t)!,
      orange950: Color.lerp(orange950, other.orange950, t)!,

      // Pink colors
      pink50: Color.lerp(pink50, other.pink50, t)!,
      pink100: Color.lerp(pink100, other.pink100, t)!,
      pink200: Color.lerp(pink200, other.pink200, t)!,
      pink300: Color.lerp(pink300, other.pink300, t)!,
      pink400: Color.lerp(pink400, other.pink400, t)!,
      pink500: Color.lerp(pink500, other.pink500, t)!,
      pink600: Color.lerp(pink600, other.pink600, t)!,
      pink700: Color.lerp(pink700, other.pink700, t)!,
      pink800: Color.lerp(pink800, other.pink800, t)!,
      pink900: Color.lerp(pink900, other.pink900, t)!,
      pink950: Color.lerp(pink950, other.pink950, t)!,

      // Green colors
      green50: Color.lerp(green50, other.green50, t)!,
      green100: Color.lerp(green100, other.green100, t)!,
      green200: Color.lerp(green200, other.green200, t)!,
      green300: Color.lerp(green300, other.green300, t)!,
      green400: Color.lerp(green400, other.green400, t)!,
      green500: Color.lerp(green500, other.green500, t)!,
      green600: Color.lerp(green600, other.green600, t)!,
      green700: Color.lerp(green700, other.green700, t)!,
      green800: Color.lerp(green800, other.green800, t)!,
      green900: Color.lerp(green900, other.green900, t)!,
      green950: Color.lerp(green950, other.green950, t)!,

      // Red colors
      red50: Color.lerp(red50, other.red50, t)!,
      red100: Color.lerp(red100, other.red100, t)!,
      red200: Color.lerp(red200, other.red200, t)!,
      red300: Color.lerp(red300, other.red300, t)!,
      red400: Color.lerp(red400, other.red400, t)!,
      red500: Color.lerp(red500, other.red500, t)!,
      red600: Color.lerp(red600, other.red600, t)!,
      red700: Color.lerp(red700, other.red700, t)!,
      red800: Color.lerp(red800, other.red800, t)!,
      red900: Color.lerp(red900, other.red900, t)!,
      red950: Color.lerp(red950, other.red950, t)!,

      // Gray colors
      gray50: Color.lerp(gray50, other.gray50, t)!,
      gray100: Color.lerp(gray100, other.gray100, t)!,
      gray200: Color.lerp(gray200, other.gray200, t)!,
      gray300: Color.lerp(gray300, other.gray300, t)!,
      gray400: Color.lerp(gray400, other.gray400, t)!,
      gray500: Color.lerp(gray500, other.gray500, t)!,
      gray600: Color.lerp(gray600, other.gray600, t)!,
      gray700: Color.lerp(gray700, other.gray700, t)!,
      gray800: Color.lerp(gray800, other.gray800, t)!,
      gray900: Color.lerp(gray900, other.gray900, t)!,
      gray950: Color.lerp(gray950, other.gray950, t)!,

      // Blue colors
      blue50: Color.lerp(blue50, other.blue50, t)!,
      blue100: Color.lerp(blue100, other.blue100, t)!,
      blue200: Color.lerp(blue200, other.blue200, t)!,
      blue300: Color.lerp(blue300, other.blue300, t)!,
      blue400: Color.lerp(blue400, other.blue400, t)!,
      blue500: Color.lerp(blue500, other.blue500, t)!,
      blue600: Color.lerp(blue600, other.blue600, t)!,
      blue700: Color.lerp(blue700, other.blue700, t)!,
      blue800: Color.lerp(blue800, other.blue800, t)!,
      blue900: Color.lerp(blue900, other.blue900, t)!,
      blue950: Color.lerp(blue950, other.blue950, t)!,

      // Background colors
      bgB0: Color.lerp(bgB0, other.bgB0, t)!,
      bgB1: Color.lerp(bgB1, other.bgB1, t)!,
      bgB2: Color.lerp(bgB2, other.bgB2, t)!,
      bgB3: Color.lerp(bgB3, other.bgB3, t)!,

      // Surface colors
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,

      // Button/Interactive colors
      activeButton: Color.lerp(activeButton, other.activeButton, t)!,
      inactiveButton: Color.lerp(inactiveButton, other.inactiveButton, t)!,
      buttonTertiary: Color.lerp(buttonTertiary, other.buttonTertiary, t)!,
      buttonSecondary: Color.lerp(buttonSecondary, other.buttonSecondary, t)!,

      // Icon colors
      iconRed: Color.lerp(iconRed, other.iconRed, t)!,
      iconBlue: Color.lerp(iconBlue, other.iconBlue, t)!,
      textHighlightBlue:
          Color.lerp(textHighlightBlue, other.textHighlightBlue, t)!,

      // Miscellaneous colors
      contrastBlack: Color.lerp(contrastBlack, other.contrastBlack, t)!,
      contrastWhite: Color.lerp(contrastWhite, other.contrastWhite, t)!,
      strokePrimary: Color.lerp(strokePrimary, other.strokePrimary, t)!,
      strokeSecondary: Color.lerp(strokeSecondary, other.strokeSecondary, t)!,
      fillTertiary: Color.lerp(fillTertiary, other.fillTertiary, t)!,
    );
  }
}

/// Extension to create a ColorScheme from AppColorExtension.
extension ColorSchemeBuilder on AppColorExtension {
  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: blue500,
      onPrimary: textWhite,
      secondary: green500,
      onSecondary: textWhite,
      tertiary: orange500,
      onTertiary: textPrimary,
      error: red500,
      onError: textWhite,
      surface: surface,
      onSurface: textPrimary,
      surfaceTint: blue500.withValues(alpha: 0.05),
    );
  }
}
