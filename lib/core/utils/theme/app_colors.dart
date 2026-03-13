import 'package:flutter/material.dart';

/// App color palette constants for light mode
/// Based on the design system color palette
class AppColors {
  // Text Colors
  static const Color textPrimary = Color(0xFF18181B);
  static const Color textSecondary = Color(0xFF71717A);
  static const Color textTertiary = Color(0xFFA1A1AA);
  static const Color textQuaternary = Color(0xFFD4D4D8);
  static const Color textWhite = Color(0xFFFAFAFA);

  // Navy/Dark Blue Colors (from leftmost column)
  static const Color navy50 = Color(0xFFF0F0F7);
  static const Color navy100 = Color(0xFFE1E1EF);
  static const Color navy200 = Color(0xFFC3C3DF);
  static const Color navy300 = Color(0xFFA5A5CF);
  static const Color navy400 = Color(0xFF8787BF);
  static const Color navy500 = Color(0xFF6969AF); // Default navy
  static const Color navy600 = Color(0xFF54548C);
  static const Color navy700 = Color(0xFF3F3F69);
  static const Color navy800 = Color(0xFF2A2A46);
  static const Color navy900 = Color(0xFF151523);
  static const Color navy950 = Color(0xFF0A0A11);

  // Orange Colors (second column)
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange200 = Color(0xFFFED7AA);
  static const Color orange300 = Color(0xFFFDBB74);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange500 = Color(0xFFF97316); // Default orange
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange700 = Color(0xFFC2410C);
  static const Color orange800 = Color(0xFF9A3412);
  static const Color orange900 = Color(0xFF7C2D12);
  static const Color orange950 = Color(0xFF431407);

  // Pink/Magenta Colors (third column)
  static const Color pink50 = Color(0xFFFDF2F8);
  static const Color pink100 = Color(0xFFFCE7F3);
  static const Color pink200 = Color(0xFFFBCFE8);
  static const Color pink300 = Color(0xFFF9A8D4);
  static const Color pink400 = Color(0xFFF472B6);
  static const Color pink500 = Color(0xFFEC4899); // Default pink
  static const Color pink600 = Color(0xFFDB2777);
  static const Color pink700 = Color(0xFFBE185D);
  static const Color pink800 = Color(0xFF9D174D);
  static const Color pink900 = Color(0xFF831843);
  static const Color pink950 = Color(0xFF500724);

  // Green Colors (fourth column)
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E); // Default green
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color green900 = Color(0xFF14532D);
  static const Color green950 = Color(0xFF052E16);

  // Red Colors (fifth column)
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444); // Default red
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red900 = Color(0xFF7F1D1D);
  static const Color red950 = Color(0xFF450A0A);

  // Gray Colors (sixth column)
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF4F4F5);
  static const Color gray200 = Color(0xFFE4E4E7);
  static const Color gray300 = Color(0xFFD4D4D8);
  static const Color gray400 = Color(0xFFA1A1AA);
  static const Color gray500 = Color(0xFF71717A); // Default gray
  static const Color gray600 = Color(0xFF52525B);
  static const Color gray700 = Color(0xFF3F3F46);
  static const Color gray800 = Color(0xFF27272A);
  static const Color gray900 = Color(0xFF18181B);
  static const Color gray950 = Color(0xFF09090B);

  // Blue Colors (seventh column)
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6); // Default blue
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color blue950 = Color(0xFF172554);

  // Brand Colors (using navy as primary brand)
  static const Color brandDefault = navy500;
  static const Color brandContrast = navy600;
  static const Color brandHover = navy600;
  static const Color brandActive = navy700;
  static const Color brandStroke = navy300;
  static const Color brandFill = navy50;

  // Background Colors
  static const Color bgB0 = Color(0xFFFFFFFF);
  static const Color bgB1 = gray50;
  static const Color bgB2 = gray100;
  static const Color bgB3 = gray200;

  // Surface Colors
  static const Color surface = gray50;
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // Button/Interactive Colors
  static const Color activeButton = blue600;
  static const Color inactiveButton = gray300;
  static const Color buttonTertiary = orange500;
  static const Color buttonSecondary = gray800;

  // Icon Colors
  static const Color iconBlue = blue600;
  static const Color iconRed = red500;
  static const Color textHighlightBlue = blue600;

  // Miscellaneous colors
  static const Color contrastBlack = gray900;
  static const Color contrastWhite = Color(0xFFFFFFFF);
  static const Color strokePrimary = gray200;
  static const Color strokeSecondary = gray300;
  static const Color fillTertiary = gray100;

  // Legacy colors for backward compatibility
  static const Color primaryColor = gray900;
  static const Color secondaryColor = blue500;
  static const Color errorColor = red500;
  static const Color successColor = green500;
  static const Color warningColor = orange500;
  static const Color transparent = Colors.transparent;
}

/// App color palette constants for dark mode
class AppColorDark {
  // Text Colors
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);
  static const Color textQuaternary = Color(0xFF52525B);
  static const Color textWhite = Color(0xFF09090B);

  // Navy/Dark Blue Colors (adjusted for dark mode)
  static const Color navy50 = Color(0xFF0A0A11);
  static const Color navy100 = Color(0xFF151523);
  static const Color navy200 = Color(0xFF2A2A46);
  static const Color navy300 = Color(0xFF3F3F69);
  static const Color navy400 = Color(0xFF54548C);
  static const Color navy500 = Color(0xFF6969AF); // Default navy
  static const Color navy600 = Color(0xFF8787BF);
  static const Color navy700 = Color(0xFFA5A5CF);
  static const Color navy800 = Color(0xFFC3C3DF);
  static const Color navy900 = Color(0xFFE1E1EF);
  static const Color navy950 = Color(0xFFF0F0F7);

  // Orange Colors (adjusted for dark mode)
  static const Color orange50 = Color(0xFF431407);
  static const Color orange100 = Color(0xFF7C2D12);
  static const Color orange200 = Color(0xFF9A3412);
  static const Color orange300 = Color(0xFFC2410C);
  static const Color orange400 = Color(0xFFEA580C);
  static const Color orange500 = Color(0xFFF97316); // Default orange
  static const Color orange600 = Color(0xFFFB923C);
  static const Color orange700 = Color(0xFFFDBB74);
  static const Color orange800 = Color(0xFFFED7AA);
  static const Color orange900 = Color(0xFFFFEDD5);
  static const Color orange950 = Color(0xFFFFF7ED);

  // Pink/Magenta Colors (adjusted for dark mode)
  static const Color pink50 = Color(0xFF500724);
  static const Color pink100 = Color(0xFF831843);
  static const Color pink200 = Color(0xFF9D174D);
  static const Color pink300 = Color(0xFFBE185D);
  static const Color pink400 = Color(0xFFDB2777);
  static const Color pink500 = Color(0xFFEC4899); // Default pink
  static const Color pink600 = Color(0xFFF472B6);
  static const Color pink700 = Color(0xFFF9A8D4);
  static const Color pink800 = Color(0xFFFBCFE8);
  static const Color pink900 = Color(0xFFFCE7F3);
  static const Color pink950 = Color(0xFFFDF2F8);

  // Green Colors (adjusted for dark mode)
  static const Color green50 = Color(0xFF052E16);
  static const Color green100 = Color(0xFF14532D);
  static const Color green200 = Color(0xFF166534);
  static const Color green300 = Color(0xFF15803D);
  static const Color green400 = Color(0xFF16A34A);
  static const Color green500 = Color(0xFF22C55E); // Default green
  static const Color green600 = Color(0xFF4ADE80);
  static const Color green700 = Color(0xFF86EFAC);
  static const Color green800 = Color(0xFFBBF7D0);
  static const Color green900 = Color(0xFFDCFCE7);
  static const Color green950 = Color(0xFFF0FDF4);

  // Red Colors (adjusted for dark mode)
  static const Color red50 = Color(0xFF450A0A);
  static const Color red100 = Color(0xFF7F1D1D);
  static const Color red200 = Color(0xFF991B1B);
  static const Color red300 = Color(0xFFB91C1C);
  static const Color red400 = Color(0xFFDC2626);
  static const Color red500 = Color(0xFFEF4444); // Default red
  static const Color red600 = Color(0xFFF87171);
  static const Color red700 = Color(0xFFFCA5A5);
  static const Color red800 = Color(0xFFFECACA);
  static const Color red900 = Color(0xFFFEE2E2);
  static const Color red950 = Color(0xFFFEF2F2);

  // Gray Colors (adjusted for dark mode)
  static const Color gray50 = Color(0xFF09090B);
  static const Color gray100 = Color(0xFF18181B);
  static const Color gray200 = Color(0xFF27272A);
  static const Color gray300 = Color(0xFF3F3F46);
  static const Color gray400 = Color(0xFF52525B);
  static const Color gray500 = Color(0xFF71717A); // Default gray
  static const Color gray600 = Color(0xFFA1A1AA);
  static const Color gray700 = Color(0xFFD4D4D8);
  static const Color gray800 = Color(0xFFE4E4E7);
  static const Color gray900 = Color(0xFFF4F4F5);
  static const Color gray950 = Color(0xFFFAFAFA);

  // Blue Colors (adjusted for dark mode)
  static const Color blue50 = Color(0xFF172554);
  static const Color blue100 = Color(0xFF1E3A8A);
  static const Color blue200 = Color(0xFF1E40AF);
  static const Color blue300 = Color(0xFF1D4ED8);
  static const Color blue400 = Color(0xFF2563EB);
  static const Color blue500 = Color(0xFF3B82F6); // Default blue
  static const Color blue600 = Color(0xFF60A5FA);
  static const Color blue700 = Color(0xFF93C5FD);
  static const Color blue800 = Color(0xFFBFDBFE);
  static const Color blue900 = Color(0xFFDBEAFE);
  static const Color blue950 = Color(0xFFEFF6FF);

  // Brand Colors (using navy as primary brand)
  static const Color brandDefault = navy500;
  static const Color brandContrast = navy400;
  static const Color brandHover = navy400;
  static const Color brandActive = navy300;
  static const Color brandStroke = navy700;
  static const Color brandFill = navy950;

  // Background Colors
  static const Color bgB0 = gray50;
  static const Color bgB1 = gray100;
  static const Color bgB2 = gray200;
  static const Color bgB3 = gray300;

  // Surface Colors
  static const Color surface = gray100;
  static const Color surfaceCard = gray200;

  // Button/Interactive Colors
  static const Color activeButton = blue500;
  static const Color inactiveButton = gray600;
  static const Color buttonTertiary = orange500;
  static const Color buttonSecondary = gray200;

  // Icon Colors
  static const Color iconBlue = blue500;
  static const Color iconRed = red500;
  static const Color textHighlightBlue = blue500;

  // Miscellaneous colors
  static const Color contrastBlack = Color(0xFFFFFFFF);
  static const Color contrastWhite = gray50;
  static const Color strokePrimary = gray700;
  static const Color strokeSecondary = gray600;
  static const Color fillTertiary = gray800;

  // Legacy colors for backward compatibility
  static const Color primaryColor = gray100;
  static const Color secondaryColor = blue500;
  static const Color errorColor = red500;
  static const Color successColor = green500;
  static const Color warningColor = orange500;
  static const Color transparent = Colors.transparent;
}
