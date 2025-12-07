// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/course_cubit.dart';
import '../services/firebase_data_service.dart';
import '../models/quiz.dart';
import '../models/student.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color mainGreen = Color(0xFF0D4726);
  static const Color beigeLight = Color(0xFFFDF6EE);
  static const Color lightGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeLight,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Results & Scores",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: beigeLight, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<CourseCubit, CourseState>(
        builder: (context, state) {
          final quizzes = FirebaseDataService.instance.quizzes;
          final students = FirebaseDataService.instance.students;

          if (quizzes.isEmpty || students.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: mainGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: mainGreen.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No results yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Quiz results will appear here",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<List<_QuizResult>>(
            future: _loadQuizResults(quizzes, students),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: mainGreen,
                  ),
                );
              }

              final results = snapshot.data ?? [];

              if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: mainGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: mainGreen.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No completed quizzes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Students need to complete quizzes first",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

              // Sort by date (newest first)
              results.sort((a, b) => b.quiz.date.compareTo(a.quiz.date));

              return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final isPassing = result.percentage >= 60;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPassing
                        ? lightGreen.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isPassing ? lightGreen : Colors.orange)
                          .withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with student and quiz info
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: mainGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person,
                                color: mainGreen, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.student.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: mainGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  result.quiz.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isPassing ? lightGreen : Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${result.percentage}%",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      // Score details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ScoreDetail(
                            icon: Icons.check_circle,
                            label: "Correct",
                            value: "${result.correct}",
                            color: lightGreen,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _ScoreDetail(
                            icon: Icons.quiz,
                            label: "Total",
                            value: "${result.total}",
                            color: mainGreen,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _ScoreDetail(
                            icon: Icons.calendar_today,
                            label: "Date",
                            value:
                                DateFormat('MMM dd').format(result.quiz.date),
                            color: Colors.blue,
                          ),
                          if (result.timeTakenSeconds != null) ...[
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _ScoreDetail(
                              icon: Icons.access_time,
                              label: "Time",
                              value: _formatTime(result.timeTakenSeconds!),
                              color: Colors.purple,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: result.percentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isPassing ? lightGreen : Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              },
            );
            },
          );
        },
      ),
    );
  }

  Future<List<_QuizResult>> _loadQuizResults(
      List<Quiz> quizzes, List<Student> students) async {
    final List<_QuizResult> results = [];

    // First, try to get results from quiz_results collection
    for (final quiz in quizzes) {
      if (quiz.questions.isEmpty) continue;

      try {
        // Get quiz results from Firestore
        final quizResults =
            await FirebaseDataService.instance.getQuizResults(quiz.id);

        for (final resultData in quizResults) {
          final studentId = resultData['studentId'] as String?;
          if (studentId == null) continue;

          final student = students.firstWhere(
            (s) => s.id == studentId,
            orElse: () => Student(id: studentId, name: 'Unknown Student'),
          );

          final correct = resultData['correctAnswers'] as int? ?? 0;
          final total = resultData['totalQuestions'] as int? ?? 1;
          final percentage = total > 0 ? ((correct / total) * 100).round() : 0;
          final timeTakenSeconds = resultData['timeTaken'] as int?;

          results.add(_QuizResult(
            student: student,
            quiz: quiz,
            correct: correct,
            total: total,
            percentage: percentage,
            timeTakenSeconds: timeTakenSeconds,
          ));
        }
      } catch (e) {
        print('Error loading quiz results for ${quiz.id}: $e');
      }
    }

    // If no results from quiz_results, fall back to calculating from student_answers
    if (results.isEmpty) {
      for (final quiz in quizzes) {
        if (quiz.questions.isEmpty) continue;

        for (final student in students) {
          final answersMap =
              FirebaseDataService.instance.getStudentAnswersMap(quiz.id);
          final studentAnswers = answersMap[student.id] ?? {};

          int correctCount = 0;
          int answeredCount = 0;
          for (int i = 0; i < quiz.questions.length && i < 10; i++) {
            final answer = studentAnswers[i];
            if (answer != null) {
              answeredCount++;
              if (answer == quiz.questions[i].correctAnswer) {
                correctCount++;
              }
            }
          }

          if (answeredCount > 0) {
            final percentage = (correctCount / answeredCount * 100).round();
            results.add(_QuizResult(
              student: student,
              quiz: quiz,
              correct: correctCount,
              total: answeredCount,
              percentage: percentage,
              timeTakenSeconds: null,
            ));
          }
        }
      }
    }

    return results;
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes}m ${secs}s';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    }
  }
}

class _QuizResult {
  final Student student;
  final Quiz quiz;
  final int correct;
  final int total;
  final int percentage;
  final int? timeTakenSeconds; // Time taken in seconds

  _QuizResult({
    required this.student,
    required this.quiz,
    required this.correct,
    required this.total,
    required this.percentage,
    this.timeTakenSeconds,
  });
}

class _ScoreDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ScoreDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
