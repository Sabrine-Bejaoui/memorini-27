import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/memorini_footer.dart';
import '../../core/widgets/memorini_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ApiService.isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/admin');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: Column(
            children: [
              const MemoriniHeader(activeRoute: '/'),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1240),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(32, 72, 32, 24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold.withOpacity(
                                            0.35,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          'CRÉATIONS PERSONNALISÉES',
                                          style: TextStyle(
                                            letterSpacing: 1,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Vos souvenirs,',
                                        style: TextStyle(
                                          fontSize: 52,
                                          color: AppColors.burgundy,
                                          fontWeight: FontWeight.w700,
                                          height: 1.08,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'créés avec amour',
                                        style: TextStyle(
                                          fontSize: 34,
                                          color: AppColors.gold,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Découvrez nos impressions photos, albums souvenirs et cadres personnalisés. '
                                        'Des créations uniques pour garder vos plus beaux moments.',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: AppColors.textMuted,
                                          height: 1.6,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      Wrap(
                                        spacing: 20,
                                        runSpacing: 14,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pushNamed(
                                                  context,
                                                  '/products',
                                                ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.burgundy,
                                              foregroundColor: Colors.white,
                                              elevation: 8,
                                              shadowColor: AppColors.burgundy
                                                  .withValues(alpha: 0.5),
                                              minimumSize: const Size(195, 54),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Découvrir nos produits',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () =>
                                                Navigator.pushNamed(
                                                  context,
                                                  '/products',
                                                ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.burgundy,
                                              side: const BorderSide(
                                                color: AppColors.burgundy,
                                                width: 2,
                                              ),
                                              minimumSize: const Size(160, 54),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'En savoir plus',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 42),
                                Expanded(
                                  child: Container(
                                    height: 380,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: const Color(0xFFF8E8C6),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x15000000),
                                          blurRadius: 22,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        'assets/memorini_logo.png',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 108),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 1240),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Wrap(
                              spacing: 30,
                              runSpacing: 28,
                              alignment: WrapAlignment.center,
                              children: [
                                _FeatureTile(
                                  icon: Icons.photo_camera_outlined,
                                  title: 'Commande simple',
                                  description:
                                      'Choisissez votre produit, ajoutez vos détails et passez commande facilement.',
                                ),
                                _FeatureTile(
                                  icon: Icons.auto_awesome_outlined,
                                  title: 'Personnalisation',
                                  description:
                                      'Chaque création est préparée selon vos goûts, vos photos et vos idées.',
                                ),
                                _FeatureTile(
                                  icon: Icons.local_shipping_outlined,
                                  title: 'Livraison soignée',
                                  description:
                                      'Emballage protecteur élégant, livré à domicile partout en Tunisie.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 110),
                      const _CollectionSection(),
                      const SizedBox(height: 110),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1240),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            padding: const EdgeInsets.symmetric(
                              vertical: 64,
                              horizontal: 38,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.burgundyDark,
                                  AppColors.burgundy,
                                ],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Prêt à commander ?',
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 28,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Donnez vie à vos plus beaux\nsouvenirs',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    height: 1.18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 36),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/products'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gold,
                                    foregroundColor: AppColors.textDark,
                                    elevation: 10,
                                    shadowColor: Colors.black.withValues(
                                      alpha: 0.3,
                                    ),
                                    minimumSize: const Size(220, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Commencer ma commande',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 96),
                      const MemoriniFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.gold.withOpacity(0.5),
            child: Icon(icon, color: AppColors.burgundy),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              color: AppColors.burgundy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionSection extends StatelessWidget {
  final List<Map<String, String>> _items = const [
    {
      'type': 'photos',
      'category': 'PHOTO',
      'name': 'Impression Photos',
      'price': 'À partir de 0.80 DT',
      'image': 'assets/impression_photos.jpg',
    },
    {
      'type': 'album',
      'category': 'SOUVENIRS',
      'name': 'Album Photo',
      'price': 'À partir de 25 DT',
      'image': 'assets/album_photo.jpg',
    },
    {
      'type': 'cadre',
      'category': 'DÉCORATION',
      'name': 'Cadre Personnalisé',
      'price': 'À partir de 18 DT',
      'image': 'assets/cadre_personnalise.jpg',
    },
  ];

  const _CollectionSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'NOTRE COLLECTION',
                  style: TextStyle(
                    fontSize: 42,
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 30,
                  runSpacing: 30,
                  children: _items.map((product) {
                    return Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.softBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.asset(
                              product['image']!,
                              height: 245,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['category']!,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product['name']!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: AppColors.burgundy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          product['price']!,
                                          style: const TextStyle(
                                            fontSize: 26,
                                            color: AppColors.burgundy,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/custom-order',
                                          arguments: product['type'],
                                        );
                                      },
                                      child: const Text('Voir'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
