part of 'quiz_cubit.dart';

enum QuizStatus { initial, loading, success, failure }

class QuizState extends Equatable {
  const QuizState({
    this.quizzes = const [],
    this.status = QuizStatus.initial,
    this.errorMessage,
  });

  final List<Quiz> quizzes;
  final QuizStatus status;
  final String? errorMessage;

  QuizState copyWith({
    List<Quiz>? quizzes,
    QuizStatus? status,
    String? errorMessage,
  }) {
    return QuizState(
      quizzes: quizzes ?? this.quizzes,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [quizzes, status, errorMessage];
}
