import 'package:flutter/material.dart';

ThemeData createAppThemeWithBrightness(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    brightness: brightness,
    seedColor: const Color(0xFF7287FD),
  );
  return ThemeData(
    colorScheme: colorScheme,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 8,
    ),
    iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
    ),
    // menuTheme: MenuThemeData(
    //   style: MenuStyle(
    //     visualDensity: VisualDensity.compact,
    //     elevation: const WidgetStatePropertyAll(0),
    //     padding: const WidgetStatePropertyAll(
    //       EdgeInsets.symmetric(vertical: 16),
    //     ),
    //     side: WidgetStatePropertyAll(
    //       BorderSide(color: colorScheme.outlineVariant),
    //     ),
    //     shape: const WidgetStatePropertyAll(
    //       RoundedRectangleBorder(
    //         borderRadius: BorderRadius.all(Radius.circular(6)),
    //       ),
    //     ),
    //   ),
    // ),
    // menuButtonTheme: MenuButtonThemeData(
    //   style: MenuItemButton.styleFrom(
    //     shape: const RoundedRectangleBorder(
    //       borderRadius: BorderRadius.all(Radius.circular(6)),
    //     ),
    //     visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
    //     iconSize: 20,
    //     textStyle: const TextStyle(fontSize: 14),
    //   ),
    // ),
  );
}
