import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../models/user_model.dart';
import 'shell_screen.dart';

// ============================================================================
// SERVICE — Login screen's own data source. Today it's hardcoded; swap the
// body of login()/logout() for a real HTTP call later and nothing above
// this class (ViewModel/View) needs to change.
// ============================================================================

class LoginService {
  static const String _hardcodedUsername = 'admin';
  static const String _hardcodedPassword = 'admin123';

  static const UserModel _hardcodedUser = UserModel(
    username: 'admin',
    displayName: 'Admin User',
    role: 'Desk Administrator',
    zone: 'PCMC Zone',
  );

  Future<UserModel> login(String username, String password) async {
    // Simulate network latency so the loading state has something real
    // to show.
    await Future.delayed(const Duration(milliseconds: 700));

    if (username.trim() == _hardcodedUsername && password == _hardcodedPassword) {
      return _hardcodedUser;
    }
    throw AuthException('Invalid username or password.');
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

// ============================================================================
// VIEWMODEL — all state the LoginScreen needs to render, plus the intents
// (login()) the View can call. No Flutter widget code here.
// ============================================================================

enum LoginStatus { idle, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._service);

  final LoginService _service;

  LoginStatus status = LoginStatus.idle;
  String? errorMessage;
  bool obscurePassword = true;
  UserModel? loggedInUser;

  bool get isLoading => status == LoginStatus.loading;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      status = LoginStatus.error;
      errorMessage = 'Enter both username and password.';
      notifyListeners();
      return false;
    }

    status = LoginStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _service.login(username, password);
      loggedInUser = user;
      status = LoginStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      status = LoginStatus.error;
      errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      status = LoginStatus.error;
      errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }
}

// ============================================================================
// VIEW
// ============================================================================

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(LoginService()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(LoginViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await vm.login(_usernameController.text, _passwordController.text);
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainShellScreen(user: vm.loggedInUser!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: AppDecorations.card(radius: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.orange, AppColors.orangeDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.verified_outlined, color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'MS-CIT',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: AppColors.orangeDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Certificate Verification — Admin Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 34),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your username' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: vm.obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(vm.obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: vm.toggleObscurePassword,
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
                      onFieldSubmitted: (_) => _submit(vm),
                    ),
                    if (vm.status == LoginStatus.error && vm.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.redSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 16, color: AppColors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(vm.errorMessage!, style: const TextStyle(color: AppColors.red, fontSize: 12.5, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: vm.isLoading ? null : () => _submit(vm),
                      child: vm.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                            )
                          : const Text('Log In'),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Demo credentials — admin / admin123',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
