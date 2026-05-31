import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Colores principales pastel
  static const Color morado = Color(0xFF7B5EA7);
  static const Color moradoClaro = Color(0xFFB39DDB);
  static const Color moradoSuave = Color(0xFFEDE7F6);

  static const Color rosa = Color(0xFFE8A0C8);
  static const Color rosaSuave = Color(0xFFFCE4EC);

  static const Color azul = Color(0xFFA0C8E8);
  static const Color azulSuave = Color(0xFFE3F2FD);

  static const Color amarillo = Color(0xFFF5E6A0);
  static const Color amarilloSuave = Color(0xFFFFFDE7);

  // Fondos y neutros
  static const Color fondoPrincipal = Color(0xFFF9F5FF);
  static const Color fondoTarjeta = Color(0xFFFFFFFF);
  static const Color textoOscuro = Color(0xFF3D2B6B);
  static const Color textoGris = Color(0xFF757575);
  static const Color divisor = Color(0xFFE0D7F0);

  // Estados
  static const Color exito = Color(0xFF81C784);
  static const Color error = Color(0xFFE57373);
  static const Color advertencia = Color(0xFFFFB74D);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
  seedColor: AppColors.morado,
  primary: AppColors.morado,
  secondary: AppColors.rosa,
  tertiary: AppColors.azul,
  surface: AppColors.fondoPrincipal,
),
      scaffoldBackgroundColor: AppColors.fondoPrincipal,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textoOscuro,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textoOscuro,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textoOscuro,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textoOscuro,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColors.textoOscuro,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: AppColors.textoGris,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.morado,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.morado,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.morado,
          side: const BorderSide(color: AppColors.morado, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divisor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divisor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.morado, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textoGris,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.morado,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.fondoTarjeta,
        elevation: 2,
        shadowColor: AppColors.morado.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.moradoSuave,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.morado,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.morado,
        unselectedItemColor: AppColors.textoGris,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textoOscuro,
        contentTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}