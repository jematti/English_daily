import 'package:english_drops_daily/domain/models/spaced_repetition_model.dart';
import 'package:english_drops_daily/services/storage/spaced_repetition_service.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final SpacedRepetitionService _service = const SpacedRepetitionService();
  late List<SpacedRepetitionModel> _items;

  @override
  void initState() {
    super.initState();
    _items = _buildMockReviews();
  }

  @override
  Widget build(BuildContext context) {
    final dueReviews = _service.getDueReviews(_items);

    return Scaffold(
      appBar: AppBar(title: const Text('Repasos pendientes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Repasos pendientes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Cantidad: ${dueReviews.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (dueReviews.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('No hay repasos pendientes por ahora.'),
              ),
            )
          else
            ...dueReviews.map(_buildReviewCard),
        ],
      ),
    );
  }

  Widget _buildReviewCard(SpacedRepetitionModel item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.lessonId,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Nivel: ${item.reviewLevel}'),
            Text('Proxima fecha: ${item.nextReviewDate}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => _markAnswer(item, wasCorrect: true),
                  child: const Text('Marcar correcto'),
                ),
                OutlinedButton(
                  onPressed: () => _markAnswer(item, wasCorrect: false),
                  child: const Text('Marcar incorrecto'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _markAnswer(SpacedRepetitionModel item, {required bool wasCorrect}) {
    final updatedItem = _service.updateAfterAnswer(
      item: item,
      wasCorrect: wasCorrect,
    );

    setState(() {
      _items = _items.map((currentItem) {
        if (currentItem.lessonId == item.lessonId) {
          return updatedItem;
        }

        return currentItem;
      }).toList();
    });
  }

  List<SpacedRepetitionModel> _buildMockReviews() {
    final today = _formatDate(DateTime.now());
    final yesterday = _formatDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final nextWeek = _formatDate(DateTime.now().add(const Duration(days: 7)));

    return [
      SpacedRepetitionModel(
        lessonId: 'lesson_001',
        reviewLevel: 0,
        nextReviewDate: today,
        lastReviewedDate: null,
        correctCount: 0,
        wrongCount: 0,
      ),
      SpacedRepetitionModel(
        lessonId: 'lesson_002',
        reviewLevel: 2,
        nextReviewDate: yesterday,
        lastReviewedDate: yesterday,
        correctCount: 2,
        wrongCount: 1,
      ),
      SpacedRepetitionModel(
        lessonId: 'lesson_003',
        reviewLevel: 3,
        nextReviewDate: nextWeek,
        lastReviewedDate: today,
        correctCount: 3,
        wrongCount: 0,
      ),
    ];
  }

  String _formatDate(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String().split('T').first;
  }
}
