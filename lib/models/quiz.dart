import 'question.dart';

class Quiz {
  final String id;
  final String courseId;
  final String title;
  final DateTime date;
  final Duration duration;
  final List<Question> questions;
  final bool showFinalScore;

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.date,
    required this.duration,
    this.questions = const [],
    this.showFinalScore = true,
  });

  Quiz copyWith({
    List<Question>? questions,
    bool? showFinalScore,
  }) {
    return Quiz(
      id: id,
      courseId: courseId,
      title: title,
      date: date,
      duration: duration,
      questions: questions ?? this.questions,
      showFinalScore: showFinalScore ?? this.showFinalScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'date': date.toIso8601String(),
      'duration': duration.inMinutes,
      'questions': questions.map((q) => q.toJson()).toList(),
      'showFinalScore': showFinalScore,
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      duration: Duration(minutes: json['duration'] as int? ?? 0),
      questions: (json['questions'] as List<dynamic>?)
              ?.where((item) =>
                  item is Map<String, dynamic>) // Ensure item is a Map
              .map((item) => Question.fromJson(
                  item as Map<String, dynamic>)) // Cast and parse
              .toList() ??
          [], // Default to empty list if null
      showFinalScore:
          json['showFinalScore'] as bool? ?? true, // Default to true
    );
  }
}
