import 'package:flutter/material.dart';
import 'app.dart';
import 'services/backend_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase is optional during first-run setup: the app remains browseable with demo content.
  try {
    await BackendState.initialize();
  } catch (error) {
    debugPrint('Firebase is not configured yet: $error');
  }
  runApp(const ShaligramApp());
}
