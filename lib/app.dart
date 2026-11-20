import 'package:flutter/material.dart';
import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

class ShaligramApp extends StatelessWidget {
  const ShaligramApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Shaligram',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const AppShell(),
      );
}
