import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../shell/main_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
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
                    ),
                    child: const Icon(Icons.verified_outlined, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'MS-CIT',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.orangeDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Certificate Verification — Admin Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.inkSoft, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 36),

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

                  const SizedBox(height: 22),
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
                    'Hardcoded demo credentials — admin / admin123',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
