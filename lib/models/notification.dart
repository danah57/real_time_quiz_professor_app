class NotificationModel {
  final String quizId;
  final String studentId;
  final String studentName;
  final int score;
  final int totalQuestions;
  final int timeTakenSeconds;
  final DateTime createdAt;

  NotificationModel({
    required this.quizId,
    required this.studentId,
    required this.studentName,
    required this.score,
    required this.totalQuestions,
    required this.timeTakenSeconds,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'studentId': studentId,
      'studentName': studentName,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeTakenSeconds': timeTakenSeconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      quizId: map['quizId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
