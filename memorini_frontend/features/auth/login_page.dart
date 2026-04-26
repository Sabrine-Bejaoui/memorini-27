import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/memorini_header.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion réussie')),
      );
      Navigator.pushReplacementNamed(context, '/products');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MemoriniHeader(),
          Expanded(
            child: Center(
              child: Container(
                width: 480,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.softBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.burgundy.withOpacity(0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
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
                            fontSize: 52,
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Email'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        validator: (v) => (v == null || v.isEmpty) ? 'Email requis' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text('Mot de passe'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (v) =>
                            (v == null || v.length < 6) ? '6 caractères minimum' : null,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.burgundy,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'Se connecter',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'Pas encore de compte ? Créer un compte',
                            style: TextStyle(color: AppColors.textDark),
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
