import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Rang palitrasi ──────────────────────────────────────────────────────
  // To'q yoqut/bordo — qo'lyozmalar, kitoblar rangi
  static const Color primary      = Color(0xFF4A1525);
  static const Color primaryLight = Color(0xFF7B3048);
  static const Color primaryDark  = Color(0xFF2E0D17);

  // Oltin rang — antik bezaklar, sarlavhalar
  static const Color accent       = Color(0xFFD4AF37);
  static const Color accentLight  = Color(0xFFF5ECC7);
  static const Color accentDark   = Color(0xFFB8941F);

  // Fon ranglari — qadimgi qog'oz rangi
  static const Color background   = Color(0xFFFDFBF7);
  static const Color surfaceWarm  = Color(0xFFFAF7F2);
  static const Color surface      = Color(0xFFFFFFFF);

  // Karta chegaralari — iliq beige
  static const Color cardBorder   = Color(0xFFE8DDD0);
  static const Color divider      = Color(0xFFE0D5C8);

  // Matn ranglari — iliq jigarrang ton
  static const Color textDark     = Color(0xFF1C0F0A);
  static const Color textMuted    = Color(0xFF7A6652);
  static const Color textLight    = Color(0xFFAA9580);

  // Xatolik rangi
  static const Color error        = Color(0xFFC0392B);

  // ─── ThemeData ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor:  primary,
          primary:    primary,
          secondary:  accent,
          surface:    surface,
          error:      error,
          onSurface:  textDark,
          onPrimary:  Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor:   primary,
          foregroundColor:   Colors.white,
          elevation:         0,
          centerTitle:       false,
          titleTextStyle:    TextStyle(
            color:        Colors.white,
            fontSize:     17,
            fontWeight:   FontWeight.w700,
            letterSpacing: 0.3,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize:     const Size(double.infinity, 52),
            elevation:       2,
            shadowColor:     const Color(0x664A1525),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize:      16,
              fontWeight:    FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),

        // OutlinedButton
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            minimumSize:     const Size(double.infinity, 52),
            side:            const BorderSide(color: primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize:      16,
              fontWeight:    FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),

        // InputDecoration — explicit dark text so it's always visible
        inputDecorationTheme: InputDecorationTheme(
          filled:      true,
          fillColor:   surfaceWarm,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: error, width: 2),
          ),
          labelStyle:          const TextStyle(color: textMuted, fontSize: 14),
          floatingLabelStyle:  const TextStyle(color: accentDark, fontWeight: FontWeight.w600),
          hintStyle:           const TextStyle(color: textLight, fontSize: 14),
          prefixIconColor:     textMuted,
          suffixIconColor:     textMuted,
        ),

        // Card
        cardTheme: CardThemeData(
          color:       surface,
          elevation:   0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: cardBorder, width: 1),
          ),
        ),

        // FilterChip
        chipTheme: ChipThemeData(
          backgroundColor:       surfaceWarm,
          selectedColor:         primary,
          disabledColor:         surfaceWarm,
          labelPadding:          const EdgeInsets.symmetric(horizontal: 4),
          padding:               const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: cardBorder),
          ),
          labelStyle: const TextStyle(fontSize: 13, color: textDark),
          secondaryLabelStyle: const TextStyle(
              fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
        ),

        // BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor:     surface,
          selectedItemColor:   primary,
          unselectedItemColor: textMuted,
          type:                BottomNavigationBarType.fixed,
          elevation:           8,
          selectedLabelStyle: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: TextStyle(fontSize: 12),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color:     divider,
          thickness: 1,
          space:     1,
        ),

        // FloatingActionButton
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation:       4,
        ),

        // Icon
        iconTheme: const IconThemeData(color: textDark, size: 24),

        // Text
        textTheme: const TextTheme(
          // Sahifa sarlavhalari — qalin, adabiy uslub
          headlineLarge: TextStyle(
            fontSize:      28,
            fontWeight:    FontWeight.w800,
            color:         textDark,
            letterSpacing: -0.3,
            height:        1.2,
          ),
          headlineMedium: TextStyle(
            fontSize:      22,
            fontWeight:    FontWeight.w700,
            color:         textDark,
            letterSpacing: 0,
            height:        1.3,
          ),
          headlineSmall: TextStyle(
            fontSize:      20,
            fontWeight:    FontWeight.w700,
            color:         textDark,
            letterSpacing: 0.1,
          ),
          // Bo'lim sarlavhalari
          titleLarge: TextStyle(
            fontSize:      18,
            fontWeight:    FontWeight.w700,
            color:         textDark,
            letterSpacing: 0.2,
          ),
          titleMedium: TextStyle(
            fontSize:      16,
            fontWeight:    FontWeight.w600,
            color:         textDark,
            letterSpacing: 0.15,
          ),
          titleSmall: TextStyle(
            fontSize:      14,
            fontWeight:    FontWeight.w600,
            color:         textDark,
          ),
          // Asosiy matn
          bodyLarge: TextStyle(
            fontSize: 16,
            color:    textDark,
            height:   1.65,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color:    textMuted,
            height:   1.55,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color:    textMuted,
            height:   1.4,
          ),
          // Yorliqlar
          labelLarge: TextStyle(
            fontSize:   14,
            fontWeight: FontWeight.w600,
            color:      textDark,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            color:    textMuted,
          ),
        ),
      );
}
