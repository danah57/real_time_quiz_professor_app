import 'question.dart';
class Quiz {
  final String id;
  final String courseId;
  final String title;
  final DateTime date;
  final Duration duration;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.date,
    required this.duration,
    this.questions = const [],
  });

  Quiz copyWith({List<Question>? questions}) {
    return Quiz(
      id: id,
      courseId: courseId,
      title: title,
      date: date,
      duration: duration,
      questions: questions ?? this.questions,
    );
  }

  // لازم نضيف دول
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'date': date.toIso8601String(),
      'duration': duration.inMinutes,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      courseId: json['courseId'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      duration: Duration(minutes: json['duration']),
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}