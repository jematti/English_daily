import 'package:english_drops_daily/features/home/screens/home_microlesson_screen.dart';
import 'package:flutter/material.dart';

class WordOfDayScreen extends StatelessWidget {
  const WordOfDayScreen({super.key, this.initialLessonId});

  final String? initialLessonId;

  @override
  Widget build(BuildContext context) {
    return HomeMicrolessonScreen(
      initialLessonId: initialLessonId,
      showAppBar: true,
    );
  }
}
