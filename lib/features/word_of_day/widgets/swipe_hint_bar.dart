import 'package:flutter/material.dart';

class SwipeHintBar extends StatelessWidget {
  const SwipeHintBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          _HintItem(icon: Icons.arrow_back, label: 'Pasar'),
          _HintItem(icon: Icons.arrow_upward, label: 'Relacionada'),
          _HintItem(icon: Icons.arrow_forward, label: 'Guardar'),
          _HintItem(icon: Icons.arrow_downward, label: 'Anterior'),
        ],
      ),
    );
  }
}

class _HintItem extends StatelessWidget {
  const _HintItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
