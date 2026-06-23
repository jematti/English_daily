import 'dart:convert';
import 'dart:io';

const packsPath = 'assets/data/packs';
const validLevels = {'A1', 'A2', 'B1', 'B2', 'C1'};
const validVerbTypes = {'regular', 'irregular'};

class LessonRef {
  const LessonRef({required this.file, required this.id, required this.word});

  final String file;
  final String id;
  final String word;
}

class Validator {
  final errors = <String>[];
  final ids = <String, LessonRef>{};
  final words = <String, LessonRef>{};
  var filesReviewed = 0;
  var lessonsReviewed = 0;

  void run() {
    final packsDir = Directory(packsPath);
    if (!packsDir.existsSync()) {
      addError(packsPath, '-', '-', 'No existe la carpeta de packs.');
      printSummary();
      exitCode = 1;
      return;
    }

    final files =
        packsDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      validateFile(file);
    }

    printSummary();
    exitCode = errors.isEmpty ? 0 : 1;
  }

  void validateFile(File file) {
    filesReviewed++;
    final path = normalizePath(file.path);
    final expectedPackId = file.parent.uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .last;

    Object? decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } on FormatException catch (error) {
      addError(path, '-', '-', 'JSON invalido: ${error.message}');
      return;
    } on FileSystemException catch (error) {
      addError(path, '-', '-', 'No se pudo leer el archivo: ${error.message}');
      return;
    }

    if (decoded is! List) {
      addError(
        path,
        '-',
        '-',
        'La raiz del JSON debe ser una lista de lecciones.',
      );
      return;
    }

    for (var index = 0; index < decoded.length; index++) {
      final rawLesson = decoded[index];
      if (rawLesson is! Map<String, dynamic>) {
        addError(path, '#$index', '-', 'La leccion debe ser un objeto JSON.');
        continue;
      }
      lessonsReviewed++;
      validateLesson(path, expectedPackId, index, rawLesson);
    }
  }

  void validateLesson(
    String file,
    String expectedPackId,
    int index,
    Map<String, dynamic> lesson,
  ) {
    final id = stringValue(lesson['id']);
    final word = stringValue(lesson['word']);
    final labelId = id.isEmpty ? '#$index' : id;
    final labelWord = word.isEmpty ? '-' : word;

    requireText(file, labelId, labelWord, lesson, 'id');
    requireText(file, labelId, labelWord, lesson, 'word');
    requireText(file, labelId, labelWord, lesson, 'meaningEs');
    requireText(file, labelId, labelWord, lesson, 'pronunciation');
    requireText(file, labelId, labelWord, lesson, 'exampleEn');
    requireText(file, labelId, labelWord, lesson, 'exampleEs');
    requireText(file, labelId, labelWord, lesson, 'usage');
    requireText(file, labelId, labelWord, lesson, 'grammar');
    requireText(file, labelId, labelWord, lesson, 'category');
    requireText(file, labelId, labelWord, lesson, 'packId');
    requireText(file, labelId, labelWord, lesson, 'shortNotificationText');
    requireText(file, labelId, labelWord, lesson, 'activeRecallPrompt');
    requireText(file, labelId, labelWord, lesson, 'activeRecallAnswer');
    requireText(file, labelId, labelWord, lesson, 'learningTip');

    requireList(file, labelId, labelWord, lesson, 'commonMistakes');
    requireList(file, labelId, labelWord, lesson, 'dailyUse');
    requireList(file, labelId, labelWord, lesson, 'links');

    final exercises = lesson['exercises'];
    if (exercises is! List || exercises.isEmpty) {
      addError(
        file,
        labelId,
        labelWord,
        'exercises debe existir y tener al menos 1 ejercicio.',
      );
    } else {
      for (
        var exerciseIndex = 0;
        exerciseIndex < exercises.length;
        exerciseIndex++
      ) {
        validateExercise(
          file,
          labelId,
          labelWord,
          exerciseIndex,
          exercises[exerciseIndex],
        );
      }
    }

    final level = stringValue(lesson['level']);
    if (!validLevels.contains(level)) {
      addError(
        file,
        labelId,
        labelWord,
        'level invalido: "$level". Debe ser A1, A2, B1, B2 o C1.',
      );
    }

    if (lesson['isPremium'] is! bool) {
      addError(file, labelId, labelWord, 'isPremium debe ser bool.');
    }

    final packId = stringValue(lesson['packId']);
    if (packId.isNotEmpty && packId != expectedPackId) {
      addError(
        file,
        labelId,
        labelWord,
        'packId incorrecto: "$packId". Esperado por carpeta: "$expectedPackId".',
      );
    }

    validateVerbFields(file, labelId, labelWord, lesson);
    validateGlobalDuplicates(file, labelId, labelWord, id, word);
  }

  void validateExercise(
    String file,
    String lessonId,
    String word,
    int exerciseIndex,
    Object? rawExercise,
  ) {
    if (rawExercise is! Map<String, dynamic>) {
      addError(
        file,
        lessonId,
        word,
        'El ejercicio #$exerciseIndex debe ser un objeto JSON.',
      );
      return;
    }

    final exerciseLabel = 'ejercicio #$exerciseIndex';
    requireText(
      file,
      lessonId,
      word,
      rawExercise,
      'id',
      context: exerciseLabel,
    );
    requireText(
      file,
      lessonId,
      word,
      rawExercise,
      'type',
      context: exerciseLabel,
    );
    requireText(
      file,
      lessonId,
      word,
      rawExercise,
      'question',
      context: exerciseLabel,
    );
    requireText(
      file,
      lessonId,
      word,
      rawExercise,
      'correctAnswer',
      context: exerciseLabel,
    );
    requireText(
      file,
      lessonId,
      word,
      rawExercise,
      'explanation',
      context: exerciseLabel,
    );

    final options = rawExercise['options'];
    if (options is! List || options.length < 2) {
      addError(
        file,
        lessonId,
        word,
        '$exerciseLabel: options debe existir y tener minimo 2 opciones.',
      );
      return;
    }

    final optionTexts = options
        .map(stringValue)
        .where((option) => option.isNotEmpty)
        .toList();
    if (optionTexts.length < 2) {
      addError(
        file,
        lessonId,
        word,
        '$exerciseLabel: options debe tener minimo 2 opciones no vacias.',
      );
      return;
    }

    final correctAnswer = stringValue(rawExercise['correctAnswer']);
    if (correctAnswer.isNotEmpty && !optionTexts.contains(correctAnswer)) {
      addError(
        file,
        lessonId,
        word,
        '$exerciseLabel: correctAnswer "$correctAnswer" no esta dentro de options.',
      );
    }
  }

  void validateVerbFields(
    String file,
    String lessonId,
    String word,
    Map<String, dynamic> lesson,
  ) {
    final isVerb = lesson['isVerb'];
    if (isVerb is! bool) {
      addError(file, lessonId, word, 'isVerb debe ser bool.');
      return;
    }

    if (isVerb) {
      final verbType = stringValue(lesson['verbType']);
      if (!validVerbTypes.contains(verbType)) {
        addError(
          file,
          lessonId,
          word,
          'verbType debe ser regular o irregular.',
        );
      }
      requireText(file, lessonId, word, lesson, 'baseForm');
      requireText(file, lessonId, word, lesson, 'pastSimple');
      requireText(file, lessonId, word, lesson, 'pastParticiple');
      return;
    }

    for (final field in [
      'verbType',
      'baseForm',
      'pastSimple',
      'pastParticiple',
    ]) {
      final value = lesson[field];
      if (value != null && value is! String) {
        addError(
          file,
          lessonId,
          word,
          '$field debe ser null, vacio o texto cuando isVerb es false.',
        );
      }
    }
  }

  void validateGlobalDuplicates(
    String file,
    String lessonId,
    String word,
    String id,
    String rawWord,
  ) {
    if (id.isNotEmpty) {
      final previous = ids[id];
      if (previous == null) {
        ids[id] = LessonRef(file: file, id: lessonId, word: word);
      } else {
        addError(
          file,
          lessonId,
          word,
          'ID repetido "$id". Ya existe en ${previous.file} (${previous.id}, ${previous.word}).',
        );
      }
    }

    final normalizedWord = rawWord.trim().toLowerCase();
    if (normalizedWord.isNotEmpty) {
      final previous = words[normalizedWord];
      if (previous == null) {
        words[normalizedWord] = LessonRef(file: file, id: lessonId, word: word);
      } else {
        addError(
          file,
          lessonId,
          word,
          'Word repetida "$rawWord". Ya existe en ${previous.file} (${previous.id}, ${previous.word}).',
        );
      }
    }
  }

  void requireText(
    String file,
    String lessonId,
    String word,
    Map<String, dynamic> object,
    String field, {
    String? context,
  }) {
    if (stringValue(object[field]).isEmpty) {
      final prefix = context == null ? '' : '$context: ';
      addError(file, lessonId, word, '$prefix$field no debe estar vacio.');
    }
  }

  void requireList(
    String file,
    String lessonId,
    String word,
    Map<String, dynamic> object,
    String field,
  ) {
    if (object[field] is! List) {
      addError(file, lessonId, word, '$field debe existir y ser una lista.');
    }
  }

  void addError(String file, String lessonId, String word, String message) {
    errors.add('[$file] lesson=$lessonId word=$word -> $message');
  }

  void printSummary() {
    if (errors.isEmpty) {
      stdout.writeln('Contenido válido');
    } else {
      stdout.writeln('Errores encontrados:');
      for (final error in errors) {
        stdout.writeln('- $error');
      }
    }

    stdout.writeln('');
    stdout.writeln('Resumen:');
    stdout.writeln('- archivos revisados: $filesReviewed');
    stdout.writeln('- lecciones revisadas: $lessonsReviewed');
    stdout.writeln('- errores encontrados: ${errors.length}');
    stdout.writeln('- resultado final: ${errors.isEmpty ? 'OK' : 'ERROR'}');
  }
}

String stringValue(Object? value) {
  if (value is String) {
    return value.trim();
  }
  return '';
}

String normalizePath(String path) {
  return path.replaceAll('\\', '/');
}

void main() {
  Validator().run();
}
