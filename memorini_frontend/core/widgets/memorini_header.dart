import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MemoriniHeader extends StatelessWidget {
  const MemoriniHeader({super.key});

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
          _navItem(context, 'ACCUEIL', '/'),
          _navItem(context, 'PRODUITS', '/products'),
          _navItem(context, 'MES COMMANDES', '/orders'),
          const Spacer(),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            child: const Text('Panier'),
          ),
          const SizedBox(width: 12),
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