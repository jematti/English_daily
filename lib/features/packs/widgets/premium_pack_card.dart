import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/app_button.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:english_drops_daily/domain/models/content_pack_model.dart';
import 'package:flutter/material.dart';

class PremiumPackCard extends StatelessWidget {
  const PremiumPackCard({
    super.key,
    required this.pack,
    required this.onOpenPreview,
  });

  final ContentPackModel pack;
  final VoidCallback onOpenPreview;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      padding: const EdgeInsets.all(18),
      color: AppPalette.surfaceAccent.withValues(alpha: 0.82),
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
                  color: AppPalette.violet.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_outline, color: AppPalette.violet),
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
              _Pill(label: 'Nivel ${pack.level}'),
              _Pill(label: '${_wordCountLabel(pack.totalLessons)} palabras'),
              const _Pill(label: 'Bloqueado'),
            ],
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Proximamente',
            icon: Icons.lock_clock_outlined,
            variant: AppButtonVariant.tonal,
            onPressed: onOpenPreview,
          ),
        ],
      ),
    );
  }

  String _wordCountLabel(int totalLessons) {
    if (totalLessons >= 10000) {
      return '10000+';
    }

    return '$totalLessons';
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
