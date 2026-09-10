import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'viewmodels/login_viewmodel.dart';
import 'views/login/login_screen.dart';

void main() {
  runApp(const MsCitApp());
}

class MsCitApp extends StatelessWidget {
  const MsCitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // LoginViewModel lives at the app root since it's needed before
      // any user exists. Every screen after login gets its own
      // ViewModel scoped inside MainShellScreen instead.
      create: (_) => LoginViewModel(AuthService()),
      child: MaterialApp(
        title: 'MS-CIT Certificate Verification',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const LoginScreen(),
      ),
    );
  }
}
