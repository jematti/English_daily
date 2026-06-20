import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/domain/models/lesson_model.dart';
import 'package:english_drops_daily/features/word_of_day/widgets/verb_form_card.dart';
import 'package:flutter/material.dart';

class VerbCardsSection extends StatelessWidget {
  const VerbCardsSection({
    super.key,
    required this.lesson,
    this.initiallyExpanded = false,
    this.compact = false,
  });

  final LessonModel lesson;
  final bool initiallyExpanded;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!lesson.isVerb || !_hasAnyVerbData) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return _CompactVerbSummary(lesson: lesson);
    }

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppPalette.ocean.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.auto_stories_outlined, color: AppPalette.ocean),
      ),
      title: Text('Formas del verbo', style: AppTextStyles.cardTitle),
      subtitle: Text(_verbNote, style: Theme.of(context).textTheme.bodySmall),
      children: [
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: _TypePill(label: _verbTypeLabel),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 520
                ? (constraints.maxWidth - 16) / 3
                : constraints.maxWidth;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _verbCards.map((card) {
                return SizedBox(width: cardWidth, child: card);
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  bool get _hasAnyVerbData {
    return _hasText(lesson.verbType) ||
        _hasText(lesson.baseForm) ||
        _hasText(lesson.pastSimple) ||
        _hasText(lesson.pastParticiple);
  }

  List<VerbFormCard> get _verbCards {
    final cards = <VerbFormCard>[];

    if (_hasText(lesson.baseForm)) {
      cards.add(
        VerbFormCard(
          title: 'Base',
          value: lesson.baseForm!.trim(),
          example: lesson.exampleEn,
        ),
      );
    }

    if (_hasText(lesson.pastSimple)) {
      cards.add(
        VerbFormCard(title: 'Past simple', value: lesson.pastSimple!.trim()),
      );
    }

    if (_hasText(lesson.pastParticiple)) {
      cards.add(
        VerbFormCard(
          title: 'Past participle',
          value: lesson.pastParticiple!.trim(),
        ),
      );
    }

    return cards;
  }

  String get _verbTypeLabel {
    final verbType = lesson.verbType?.trim();
    if (verbType == null || verbType.isEmpty) {
      return 'Tipo no especificado';
    }

    return 'Tipo: $verbType';
  }

  String get _verbNote {
    final verbType = lesson.verbType?.toLowerCase().trim();
    if (verbType == 'regular') {
      return 'Verbo regular: normalmente forma pasado con -ed.';
    }

    if (verbType == 'irregular') {
      return 'Verbo irregular: cambia de forma en pasado.';
    }

    return 'Revisa sus formas principales para usarlo mejor.';
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}

class _CompactVerbSummary extends StatelessWidget {
  const _CompactVerbSummary({required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    final forms = [
      lesson.baseForm,
      lesson.pastSimple,
      lesson.pastParticiple,
    ].where((value) => value != null && value.trim().isNotEmpty).join(' / ');

    if (forms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.ocean.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_stories_outlined, color: AppPalette.ocean),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Formas del verbo', style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(
                  forms,
                  style: AppTextStyles.body.copyWith(
                    color: AppPalette.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppPalette.violet.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: AppTextStyles.bodySmall),
    );
  }
}
