// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/course_cubit.dart';
import '../services/firebase_data_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
          "Overview",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: mainGreen, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<CourseCubit, CourseState>(
        builder: (context, state) {
          final courses = state.courses;
          final quizzes = FirebaseDataService.instance.quizzes;
          final students = FirebaseDataService.instance.students;
          final totalQuestions =
              quizzes.fold<int>(0, (sum, quiz) => sum + quiz.questions.length);
          final totalAnswers =
              FirebaseDataService.instance.studentAnswers.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards - 2x2 Grid
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people,
                        title: "Students",
                        value: "${students.length}",
                        color: lightGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.school,
                        title: "Courses",
                        value: "${courses.length}",
                        color: mainGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.quiz,
                        title: "Quizzes",
                        value: "${quizzes.length}",
                        color: mainGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.question_answer,
                        title: "Questions",
                        value: "$totalQuestions",
                        color: lightGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Summary Section
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: mainGreen.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: mainGreen.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: mainGreen,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Summary",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: mainGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SummaryRow(
                        icon: Icons.assignment,
                        label: "Total Submissions",
                        value: "$totalAnswers",
                      ),
                      const SizedBox(height: 14),
                      _SummaryRow(
                        icon: Icons.school,
                        label: "Active Courses",
                        value: "${courses.length}",
                      ),
                      const SizedBox(height: 14),
                      _SummaryRow(
                        icon: Icons.people,
                        label: "Registered Students",
                        value: "${students.length}",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DashboardScreen.mainGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: DashboardScreen.mainGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: DashboardScreen.mainGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: DashboardScreen.mainGreen,
            ),
          ),
        ),
      ],
    );
  }
}
