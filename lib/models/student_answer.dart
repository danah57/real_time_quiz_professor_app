class StudentAnswer {
  final String id;
  final String studentId;
  final String quizId;
  final int questionIndex;
  final bool? answer; // null if not answered
  final DateTime? answeredAt;

  StudentAnswer({
    required this.id,
    required this.studentId,
    required this.quizId,
    required this.questionIndex,
    this.answer,
    this.answeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'quizId': quizId,
      'questionIndex': questionIndex,
      'answer': answer,
      'answeredAt': answeredAt?.toIso8601String(),
    };
  }

  factory StudentAnswer.fromJson(Map<String, dynamic> json) {
    return StudentAnswer(
      id: json['id'],
      studentId: json['studentId'],
      quizId: json['quizId'],
      questionIndex: json['questionIndex'],
      answer: json['answer'] as bool?,
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'])
          : null,
    );
  }
}

