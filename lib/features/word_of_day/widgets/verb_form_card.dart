import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class VerbFormCard extends StatelessWidget {
  const VerbFormCard({
    super.key,
    required this.title,
    required this.value,
    this.example,
  });

  final String title;
  final String value;
  final String? example;

  @override
  Widget build(BuildContext context) {
    final exampleText = example?.trim();

    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.surfaceCool.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.ocean.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppPalette.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(
              color: AppPalette.textPrimary,
            ),
          ),
          if (exampleText != null && exampleText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              exampleText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
