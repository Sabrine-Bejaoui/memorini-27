import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/memorini_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => const _LoginView();
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.login(_emailController.text.trim(), _passwordController.text.trim());
      if (!mounted) return;
      final role = await ApiService.getUserRole();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, role == 'admin' ? '/admin' : '/products');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _adminQuickLogin() async {
    _emailController.text = 'admin@memorini.com';
    _passwordController.text = 'password123';
    await _submit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MemoriniHeader(activeRoute: '/login'),
          Expanded(
            child: Center(
              child: Container(
                width: 500,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.softBorder.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Connexion',
                          style: TextStyle(
                            fontSize: 48,
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Heureux de vous revoir !',
                          style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text('Adresse Email', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            (value == null || !_emailRegex.hasMatch(value.trim())) ? 'Email invalide' : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mot de passe', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Mot de passe oublié'),
                                  content: const Text('Veuillez contacter l\'administrateur ou vérifier vos emails pour réinitialiser votre mot de passe.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
                                  ],
                                ),
                              );
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            child: const Text('Oublié ?', style: TextStyle(color: AppColors.burgundy, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) => (value == null || value.trim().length < 6)
                            ? '6 caractères minimum'
                            : null,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.burgundy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : _adminQuickLogin,
                          icon: const Icon(Icons.admin_panel_settings_outlined, size: 20),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            side: const BorderSide(color: AppColors.softBorder, width: 1.5),
                            foregroundColor: AppColors.textDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          label: const Text('Connexion Admin rapide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                          child: const Text(
                            'Pas encore de compte ? Créer un compte',
                            style: TextStyle(color: AppColors.burgundy, fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
