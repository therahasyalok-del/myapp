import 'package:flutter/material.dart';

class AppTheme {
  static const saffron = Color(0xFFB95724);
  static const deepSaffron = Color(0xFF8F3519);
  static const cream = Color(0xFFFFF8EE);
  static const gold = Color(0xFFD8A94F);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: saffron, brightness: Brightness.light)
            .copyWith(primary: saffron, secondary: gold, surface: Colors.white),
        scaffoldBackgroundColor: cream,
        appBarTheme: const AppBarTheme(backgroundColor: cream, foregroundColor: Color(0xFF30231D), elevation: 0),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: saffron, width: 1.4)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: saffron.withValues(alpha: .12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                fontSize: 11,
                fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
              )),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: saffron, brightness: Brightness.dark)
            .copyWith(primary: const Color(0xFFF0A06D), secondary: gold),
        scaffoldBackgroundColor: const Color(0xFF171411),
        cardTheme: CardTheme(color: const Color(0xFF24201B), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      );
}

class ShaligramMark extends StatelessWidget {
  const ShaligramMark({super.key, this.size = 46});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFFE6A347), Color(0xFF9E3C20)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: AppTheme.saffron.withValues(alpha: .22), blurRadius: 16, offset: const Offset(0, 5))],
        ),
        child: Stack(alignment: Alignment.center, children: [
          Icon(Icons.spa_rounded, color: Colors.white, size: size * .62),
          Positioned(bottom: size * .22, child: Container(width: size * .11, height: size * .11, decoration: const BoxDecoration(color: AppTheme.gold, shape: BoxShape.circle))),
        ]),
      );
}
