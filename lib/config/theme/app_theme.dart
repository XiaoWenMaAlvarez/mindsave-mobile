import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  final bool isDarkMode;

  const AppTheme({this.isDarkMode = false});

  ThemeData getTheme() {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00A6A7),
      brightness: brightness,
    );
    final colorScheme = baseScheme.copyWith(
      primary: isDarkMode ? const Color(0xFF73D7D6) : const Color(0xFF006D6F),
      onPrimary: isDarkMode ? const Color(0xFF003738) : const Color(0xFFFFFFFF),
      primaryContainer: isDarkMode
          ? const Color(0xFF004F51)
          : const Color(0xFFC7F0EF),
      onPrimaryContainer: isDarkMode
          ? const Color(0xFFA6F0EF)
          : const Color(0xFF002021),
      secondary: isDarkMode ? const Color(0xFFB4CCC7) : const Color(0xFF4E635F),
      secondaryContainer: isDarkMode
          ? const Color(0xFF354A46)
          : const Color(0xFFD1E8E3),
      tertiary: isDarkMode ? const Color(0xFFFFB68F) : const Color(0xFF8C4A2F),
      surface: isDarkMode ? const Color(0xFF111918) : const Color(0xFFFCFAF7),
      surfaceContainerLowest: isDarkMode
          ? const Color(0xFF0C1211)
          : const Color(0xFFFFFFFF),
      surfaceContainerLow: isDarkMode
          ? const Color(0xFF182220)
          : const Color(0xFFF7F4F0),
      surfaceContainer: isDarkMode
          ? const Color(0xFF1C2725)
          : const Color(0xFFF1EEEA),
      surfaceContainerHigh: isDarkMode
          ? const Color(0xFF26312F)
          : const Color(0xFFEAE7E3),
      surfaceContainerHighest: isDarkMode
          ? const Color(0xFF303B39)
          : const Color(0xFFE4E1DD),
      outline: isDarkMode ? const Color(0xFF87918E) : const Color(0xFF737976),
      outlineVariant: isDarkMode
          ? const Color(0xFF3E4946)
          : const Color(0xFFC2C9C5),
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
    );

    final inter = GoogleFonts.interTextTheme(baseTheme.textTheme);
    final textTheme = inter.copyWith(
      displayLarge: GoogleFonts.lora(
        textStyle: inter.displayLarge,
        fontWeight: FontWeight.w600,
        height: 1.08,
      ),
      displayMedium: GoogleFonts.lora(
        textStyle: inter.displayMedium,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
      displaySmall: GoogleFonts.lora(
        textStyle: inter.displaySmall,
        fontWeight: FontWeight.w600,
        height: 1.14,
      ),
      headlineLarge: GoogleFonts.lora(
        textStyle: inter.headlineLarge,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.lora(
        textStyle: inter.headlineMedium,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.lora(
        textStyle: inter.headlineSmall,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.lora(
        textStyle: inter.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: inter.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: inter.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );

    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: roundedShape.copyWith(
          side: BorderSide(color: colorScheme.outlineVariant.withAlpha(140)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        tileHeight: 56,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withAlpha(150),
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    );
  }

  AppTheme copyWith({bool? isDarkMode}) {
    return AppTheme(isDarkMode: isDarkMode ?? this.isDarkMode);
  }
}
