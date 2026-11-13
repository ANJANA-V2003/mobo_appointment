import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Common colors
  static const Color primaryColor = Color(0xffC03355);
  static const Color secondaryColor = Color(0xffFFFFFF);

  // Status colors
  static const Color attendedColor = Color(0xff00A63E);
  static const Color bookedColor = Color(0xff3B82F6);
  static const Color pendingColor = Color(0xffF97316);
  static const Color cancelledColor = Color(0xffEF4444);
  static const Color unknownColor = Color(0xff6B7280);

  //Text colors
  static const Color primaryText = Color(0xff101010);
  static const Color secondaryText = Color(0xff666666);

  static const Color black = Colors.black;
  static const Color white = Colors.white;

  // Theme : Light
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.manrope().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
    ),

    scaffoldBackgroundColor: Color(0xffFAFAFA),
    appBarTheme: AppBarTheme(
      backgroundColor: secondaryColor,
      foregroundColor: black,
      elevation: 0,
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor:  Colors.black12,
      selectionHandleColor: Colors.black,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: secondaryColor,
      ),
    ),

  );

  // Theme : Dark
  static ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.manrope().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
    ),

    scaffoldBackgroundColor: Color(0xff181A20),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xff181A20),
      foregroundColor: white,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: secondaryColor,
      ),
    ),
  );
}
