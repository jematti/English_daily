import 'package:english_drops_daily/core/constants/app_palette.dart';
import 'package:flutter/material.dart';

class WordOfDayFab extends StatelessWidget {
  const WordOfDayFab({super.key, required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onOpen,
      backgroundColor: AppPalette.sunshine,
      foregroundColor: AppPalette.textPrimary,
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Gota del dia'),
    );
  }
}
