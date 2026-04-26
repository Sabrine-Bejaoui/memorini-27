import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/memorini_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MemoriniHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 90),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('TIRAGES PHOTO PREMIUM'),
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'Vos souvenirs,',
                                style: TextStyle(
                                  fontSize: 72,
                                  color: AppColors.burgundy,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'imprimés avec amour',
                                style: TextStyle(
                                  fontSize: 50,
                                  color: AppColors.gold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Transformez vos photos numériques en de magnifiques tirages papier. Qualité d’archives, livraison soignée, partout en Tunisie.',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.gold,
                                      foregroundColor: AppColors.burgundy,
                                      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 22),
                                    ),
                                    onPressed: () => Navigator.pushNamed(context, '/products'),
                                    child: const Text('Découvrir nos tirages'),
                                  ),
                                  const SizedBox(width: 16),
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                      child: Text('Comment ça marche'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 60),
                        Expanded(
                          child: Container(
                            height: 350,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9E6BE),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.burgundy.withOpacity(0.15),
                                  blurRadius: 35,
                                  offset: const Offset(0, 20),
                                )
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Image Hero',
                                style: TextStyle(fontSize: 28, color: AppColors.burgundy),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 120),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _Feature(title: 'Upload simple', text: 'Téléversez vos photos en quelques clics.'),
                        _Feature(title: 'Qualité premium', text: 'Papier d’archives, rendu fidèle qui dure.'),
                        _Feature(title: 'Livraison soignée', text: 'Livré à domicile partout en Tunisie.'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final String title;
  final String text;

  const _Feature({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.gold,
            child: Icon(Icons.camera_alt, color: AppColors.burgundy),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              color: AppColors.burgundy,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}