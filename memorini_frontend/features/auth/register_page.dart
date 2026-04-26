import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/memorini_header.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.register(
        _fullNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé, connecte-toi maintenant')),
      );
      Navigator.pushReplacementNamed(context, '/login');
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
                width: 500,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.softBorder),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Créer un compte',
                          style: TextStyle(
                            fontSize: 48,
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Nom complet'),
                      TextFormField(
                        controller: _fullNameController,
                        validator: (v) => (v == null || v.isEmpty) ? 'Nom requis' : null,
                      ),
                      const SizedBox(height: 14),
                      const Text('Email'),
                      TextFormField(
                        controller: _emailController,
                        validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                      ),
                      const SizedBox(height: 14),
                      const Text('Téléphone'),
                      TextFormField(controller: _phoneController),
                      const SizedBox(height: 14),
                      const Text('Mot de passe'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (v) =>
                            (v == null || v.length < 6) ? '6 caractères minimum' : null,
                      ),
                      const SizedBox(height: 20),
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
                              : const Text('Créer mon compte'),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text('Déjà inscrit ? Se connecter'),
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
