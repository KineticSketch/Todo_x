import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppTheme {
  static const double _smallFontSize = 12.0;
  static const double _normalFontSize = 14.0;

  static final TextTheme _textTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: _normalFontSize),
    bodyMedium: TextStyle(fontSize: _smallFontSize),
    bodySmall: TextStyle(fontSize: 10.0),
    labelLarge: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
      brightness: Brightness.light,
    ),
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    listTileTheme: const ListTileThemeData(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      minVerticalPadding: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueGrey,
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    listTileTheme: const ListTileThemeData(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      minVerticalPadding: 0,
    ),
  );
}

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: .externalApplication);
  } else {
    print('无法打开链接: $url');
  }
}
