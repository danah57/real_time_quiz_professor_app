
class Question {
  final String questionText;
  final bool correctAnswer;

  Question({
    required this.questionText,
    required this.correctAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'correctAnswer': correctAnswer,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'] as String,
      correctAnswer: json['correctAnswer'] as bool,
    );
  }

  @override
  String toString() {
    return 'Question: $questionText (Answer: ${correctAnswer ? "True" : "False"})';
  }
}