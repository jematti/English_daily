import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class DailyUseBox extends StatelessWidget {
  const DailyUseBox({super.key, required this.phrases});

  final List<String> phrases;

  @override
  Widget build(BuildContext context) {
    final visiblePhrases = phrases
        .where((phrase) {
          return phrase.trim().isNotEmpty;
        })
        .take(3)
        .toList();

    if (visiblePhrases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.successSoft.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.success.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: visiblePhrases.map((phrase) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: AppPalette.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phrase,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
