import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:english_drops_daily/domain/models/content_pack_model.dart';
import 'package:flutter/material.dart';

class ContentPackCard extends StatelessWidget {
  const ContentPackCard({
    super.key,
    required this.pack,
    required this.features,
    this.icon = Icons.auto_stories_outlined,
  });

  final ContentPackModel pack;
  final List<String> features;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(18),
      color: AppPalette.surfaceCool.withValues(alpha: 0.82),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppPalette.ocean.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppPalette.ocean),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pack.name, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 4),
                    Text(pack.description),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(label: '${pack.totalLessons} palabras'),
              _Pill(label: pack.level),
              const _Pill(label: 'Disponible'),
            ],
          ),
          const SizedBox(height: 14),
          ...features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppPalette.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(feature)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: AppTextStyles.bodySmall),
    );
  }
}
