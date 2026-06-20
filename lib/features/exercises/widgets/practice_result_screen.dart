import 'package:english_drops_daily/core/constants/app_colors.dart';
import 'package:english_drops_daily/core/constants/app_text_styles.dart';
import 'package:english_drops_daily/core/widgets/app_button.dart';
import 'package:english_drops_daily/core/widgets/primary_card.dart';
import 'package:flutter/material.dart';

class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({
    super.key,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalQuestions,
    required this.onRestart,
    required this.onReturnHome,
  });

  final int correctAnswers;
  final int incorrectAnswers;
  final int totalQuestions;
  final VoidCallback onRestart;
  final VoidCallback onReturnHome;

  @override
  Widget build(BuildContext context) {
    final percent = totalQuestions == 0
        ? 0
        : ((correctAnswers / totalQuestions) * 100).round();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 28),
        PrimaryCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.success,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Resultado',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text('Sesion completada', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Text(_messageFor(percent), textAlign: TextAlign.center),
              const SizedBox(height: 22),
              Text(
                '$percent%',
                style: AppTextStyles.display.copyWith(fontSize: 48),
              ),
              const SizedBox(height: 16),
              _ResultRow(
                icon: Icons.check_circle_outline,
                label: 'Correctas',
                value: correctAnswers,
                color: AppColors.success,
              ),
              const SizedBox(height: 8),
              _ResultRow(
                icon: Icons.cancel_outlined,
                label: 'Incorrectas',
                value: incorrectAnswers,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Practicar otra vez',
                icon: Icons.replay_outlined,
                onPressed: onRestart,
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Volver al inicio',
                icon: Icons.home_outlined,
                variant: AppButtonVariant.outlined,
                onPressed: onReturnHome,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _messageFor(int percent) {
    if (percent >= 80) {
      return 'Muy bien. Esta palabra ya esta tomando forma.';
    }

    if (percent >= 50) {
      return 'Buen avance. Una vuelta mas y queda mas clara.';
    }

    return 'Paso corto, progreso real. Intentalo otra vez.';
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.body)),
        Text(
          '$value',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
