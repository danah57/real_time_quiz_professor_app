// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/course_cubit.dart';
import '../models/quiz.dart';
import '../models/student.dart';
import '../services/data_service.dart';

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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        leading: IconButton(
          icon:  const Icon(Icons.arrow_back_ios_new_rounded, color: beigeLight, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<CourseCubit, CourseState>(
        builder: (context, state) {
          final quizzes = state.quizzes;
          final students = state.students;

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
                  Text(
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

          // Get all quiz results
          final List<_QuizResult> results = [];
          for (final quiz in quizzes) {
            if (quiz.questions.isEmpty) continue;
            
            for (final student in students) {
              final answersMap = DataService.instance.getStudentAnswersMap(quiz.id);
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
                ));
              }
            }
          }

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
                  Text(
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
                    color: isPassing ? lightGreen.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isPassing ? lightGreen : Colors.orange).withOpacity(0.1),
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
                            child: const Icon(Icons.person, color: mainGreen, size: 24),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            value: DateFormat('MMM dd').format(result.quiz.date),
                            color: Colors.blue,
                          ),
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
      ),
    );
  }
}

class _QuizResult {
  final Student student;
  final Quiz quiz;
  final int correct;
  final int total;
  final int percentage;

  _QuizResult({
    required this.student,
    required this.quiz,
    required this.correct,
    required this.total,
    required this.percentage,
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

