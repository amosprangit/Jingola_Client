import 'package:flutter/material.dart';
import "package:google_fonts/google_fonts.dart";

ThemeData theme() {
  return ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFFf0512a),
      onPrimary: Colors.white,
      secondary: Colors.yellow.shade700,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      surfaceBright: const Color(0xFFFFFFFF),
      // onBackground: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.montserratTextTheme(),
    iconTheme: IconThemeData(
      color: Colors.white,
    )
  );
}
