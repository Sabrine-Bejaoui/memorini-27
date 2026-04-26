import 'package:flutter/material.dart';

import '../constants/colors.dart';

class MemoriniFooter extends StatelessWidget {
  const MemoriniFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.burgundy,
      padding: const EdgeInsets.fromLTRB(80, 40, 80, 20),
      child: Column(
        children: [
          const Wrap(
            spacing: 36,
            runSpacing: 24,
            children: [
              SizedBox(
                width: 260,
                child: _FooterColumn(
                  title: 'Memorini',
                  lines: ['Vos plus beaux souvenirs, imprimés avec amour', 'sur papier de qualité premium.'],
                ),
              ),
              SizedBox(
                width: 220,
                child: _FooterColumn(
                  title: 'Boutique',
                  lines: ['Tirages classiques', 'Format carré', 'Polaroids', 'Posters grand format'],
                ),
              ),
              SizedBox(
                width: 220,
                child: _FooterColumn(
                  title: 'Contact',
                  lines: ['contact@memorini.tn', '+216 00 000 000'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0x66FFFFFF), height: 1),
          const SizedBox(height: 10),
          const Text(
            '© 2026 Memorini by Hmema - Tous droits réservés',
            style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _FooterColumn({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(line, style: const TextStyle(color: Color(0xDEFFFFFF), fontSize: 15)),
          ),
      ],
    );
  }
}
