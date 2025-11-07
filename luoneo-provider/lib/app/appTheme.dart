import 'package:flutter/material.dart';

import 'generalImports.dart';

enum AppTheme { dark, light }

final commonThemeData = ThemeData(useMaterial3: true, fontFamily: 'Lexend');

final Map<AppTheme, ThemeData> appThemeData = {
  AppTheme.light: commonThemeData.copyWith(
    scaffoldBackgroundColor: AppColors.lightPrimaryColor,
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimaryColor,
    secondaryHeaderColor: AppColors.lightSubHeadingColor1,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.lightAccentColor,
      selectionHandleColor: AppColors.lightAccentColor,
      selectionColor: AppColors.lightSecondaryColor,
    ),
  ),
  AppTheme.dark: commonThemeData.copyWith(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimaryColor,
    secondaryHeaderColor: AppColors.darkSubHeadingColor1,
    scaffoldBackgroundColor: AppColors.darkPrimaryColor,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.darkAccentColor,
      selectionHandleColor: AppColors.darkAccentColor,
      selectionColor: AppColors.darkSecondaryColor,
    ),
  ),
};
