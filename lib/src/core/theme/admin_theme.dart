import 'package:flutter/material.dart';

import 'admin_tokens.dart';

class AdminTheme {
  const AdminTheme._();
  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AdminTokens.brandBlue,
          surface: AdminTokens.surface,
        ).copyWith(
          primary: AdminTokens.brandBlue,
          onPrimary: Colors.white,
          secondary: AdminTokens.brandBlueDark,
          surface: AdminTokens.surface,
          onSurface: AdminTokens.ink,
          error: AdminTokens.danger,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AdminTokens.page,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AdminTokens.surface,
        foregroundColor: AdminTokens.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AdminTokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AdminTokens.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AdminTokens.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminTokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminTokens.brandBlue, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 44),
          side: const BorderSide(color: AdminTokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: const WidgetStatePropertyAll(
          AdminTokens.brandBlueTint,
        ),
        headingTextStyle: const TextStyle(
          color: AdminTokens.brandBlueDark,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: const TextStyle(color: AdminTokens.ink, fontSize: 14),
        horizontalMargin: 20,
        columnSpacing: 28,
        dividerThickness: 0.7,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selectedTileColor: AdminTokens.brandBlueTint,
        selectedColor: AdminTokens.brandBlueDark,
        iconColor: AdminTokens.muted,
        minVerticalPadding: 10,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
