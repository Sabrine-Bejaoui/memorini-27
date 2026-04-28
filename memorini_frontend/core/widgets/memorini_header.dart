import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class MemoriniHeader extends StatefulWidget {
  const MemoriniHeader({super.key});

  @override
  State<MemoriniHeader> createState() => _MemoriniHeaderState();
}

class _MemoriniHeaderState extends State<MemoriniHeader> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null && token.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(
          bottom: BorderSide(color: AppColors.softBorder),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.burgundy,
            child: Text(
              'M',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 28,
                fontFamily: 'Georgia',
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Memorini\nby Hmema',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              height: 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Toujours affichés
          _navItem(context, 'ACCUEIL', '/'),
          _navItem(context, 'PRODUITS', '/products'),
          // Afficher "MES COMMANDES" seulement si connecté
          if (_isLoggedIn) _navItem(context, 'MES COMMANDES', '/orders'),
          const Spacer(),
          // Afficher "Panier" seulement si connecté
          if (_isLoggedIn)
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              child: const Text('Panier'),
            ),
          if (_isLoggedIn) const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('Connexion'),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String text, String route) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}