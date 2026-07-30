import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors (Talab qilingan ranglar palitrasi)
  static const Color primaryDark = Color(0xFF1E293B);      // To'q ko'k (#1E293B)
  static const Color accentGold = Color(0xFFF59E0B);       // Oltinsimon taksi rangi (#F59E0B)
  static const Color accentGoldLight = Color(0xFFFEF3C7);  // Yengil oltin (100 shade)
  static const Color bgLight = Color(0xFFF8FAFC);          // Yorug' va toza fon (#F8FAFC)
  static const Color cardBg = Color(0xFFFFFFFF);           // Sof oq kartochka foni
  
  // Secondary Colors
  static const Color textDark = Color(0xFF0F172A);         // Asosiy matn
  static const Color textMuted = Color(0xFF64748B);        // Qo'shimcha xira matn
  static const Color borderLight = Color(0xFFE2E8F0);      // Chegara rangi
  static const Color successGreen = Color(0xFF10B981);     // Muvaffaqiyatli / Onlayn holat
  static const Color errorRed = Color(0xFFEF4444);         // Rad etish / Xato rangi

  // Radii & Shadows (Border radius 16px va chiroyli soyalar)
  static const double borderRadiusValue = 16.0;
  static final BorderRadius borderRadius = BorderRadius.circular(borderRadiusValue);

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF1E293B).withOpacity(0.06),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: accentGold.withOpacity(0.35),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  // ThemeData Definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        primary: primaryDark,
        secondary: accentGold,
        background: bgLight,
        surface: cardBg,
        error: errorRed,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.bold, fontSize: 28),
        headlineMedium: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w700, fontSize: 20),
        titleLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: GoogleFonts.inter(color: textDark, fontSize: 15, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(color: textMuted, fontSize: 14, fontWeight: FontWeight.w400),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textDark, fontSize: 14, fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: accentGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: const BorderSide(color: borderLight, width: 0.5),
        ),
      ),
    );
  }
}
