import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../services/api_service.dart';
import 'app_toast.dart';

class MemoriniHeader extends StatelessWidget {
  final String activeRoute;

  const MemoriniHeader({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ApiService.authStateVersion,
      builder: (context, _, __) {
        return FutureBuilder(
          future: Future.wait([
            ApiService.getToken(),
            ApiService.isAdmin(),
            ApiService.getUserName(),
          ]),
          builder: (context, snapshot) {
            final token = snapshot.data is List
                ? (snapshot.data as List)[0] as String?
                : null;
            final isAdmin = snapshot.data is List
                ? ((snapshot.data as List)[1] as bool? ?? false)
                : false;
            final userName = snapshot.data is List
                ? (snapshot.data as List)[2] as String?
                : null;
            final isLoggedIn = token != null && token.isNotEmpty;
            return LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 1180;
                return Container(
                  height: 88,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _Brand(
                        onTap: () => Navigator.pushNamed(
                          context,
                          isAdmin ? '/admin' : '/',
                        ),
                      ),
                      const Spacer(),
                      if (!compact && !isAdmin) ...[
                        _NavItem(
                          label: 'ACCUEIL',
                          isActive: activeRoute == '/',
                          onTap: () => Navigator.pushNamed(context, '/'),
                        ),
                        _NavItem(
                          label: 'PRODUITS',
                          isActive: activeRoute == '/products',
                          onTap: () =>
                              Navigator.pushNamed(context, '/products'),
                        ),
                        if (isLoggedIn)
                          _NavItem(
                            label: 'PANIER',
                            isActive: activeRoute == '/cart',
                            onTap: () => Navigator.pushNamed(context, '/cart'),
                          ),
                        if (isLoggedIn)
                          _NavItem(
                            label: 'MES COMMANDES',
                            isActive: activeRoute == '/orders',
                            onTap: () =>
                                Navigator.pushNamed(context, '/orders'),
                          ),
                        const Spacer(),
                      ],
                      if (!isLoggedIn)
                        FilledButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.burgundy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                          ),
                          icon: const Icon(Icons.person_outline, size: 18),
                          label: Text(
                            compact ? '' : 'Connexion',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        )
                      else ...[
                        if (userName != null)
                          TextButton.icon(
                            onPressed: () =>
                                _showProfileDialog(context, userName),
                            icon: const Icon(
                              Icons.person,
                              color: AppColors.burgundy,
                            ),
                            label: Text(
                              userName,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () async {
                            await ApiService.logout();
                            if (!context.mounted) return;
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (_) => false,
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.burgundy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                          ),
                          icon: const Icon(Icons.logout, size: 18),
                          label: Text(
                            compact ? '' : 'Déconnexion',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showProfileDialog(
    BuildContext context,
    String currentName,
  ) async {
    final nameCtrl = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mes informations'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requis' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final userId = await ApiService.getUserId();
                if (userId != null) {
                  await ApiService.updateUser(
                    userId: userId,
                    fullName: nameCtrl.text.trim(),
                  );
                }
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                AppToast.show(
                  context,
                  message: 'Profil mis à jour',
                  type: AppToastType.success,
                );
              } catch (e) {
                AppToast.show(
                  context,
                  message: e.toString().replaceFirst('Exception: ', ''),
                  type: AppToastType.error,
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  final VoidCallback onTap;

  const _Brand({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/memorini_logo.png',
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Memorini',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.burgundy : AppColors.textMuted,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
