import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class MemoryActiveBox extends StatelessWidget {
  const MemoryActiveBox({
    super.key,
    required this.prompt,
    required this.answer,
    this.tip,
  });

  final String prompt;
  final String answer;
  final String? tip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surfaceAccent.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.violet.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.psychology_alt_outlined, color: AppPalette.violet),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reto rapido',
                  style: AppTextStyles.label.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(prompt, style: AppTextStyles.body),
          const SizedBox(height: 10),
          Text(
            answer,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
          ),
          if (tip != null && tip!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(tip!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
