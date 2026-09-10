import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MsCitApp());
}

class MsCitApp extends StatelessWidget {
  const MsCitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Each screen (starting with LoginScreen) creates and owns its own
    // ViewModel/Service via a ChangeNotifierProvider inside its own
    // build method, so the app root doesn't need to know about any of
    // them -- see lib/screens/*.dart.
    return MaterialApp(
      title: 'MS-CIT Certificate Verification',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
