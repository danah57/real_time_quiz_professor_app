// lib/screens/student_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/course_cubit.dart';
import '../models/quiz.dart';
import '../services/data_service.dart';

class StudentTrackingScreen extends StatelessWidget {
  final Quiz quiz;

  const StudentTrackingScreen({super.key, required this.quiz});

  static const Color mainGreen = Color(0xFF0D4726);
  static const Color beigeLight = Color(0xFFFDF6EE);
  static const Color tileFill = Color(0xFFF2E6D1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeLight,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        centerTitle: true,
        title: Text(
          quiz.title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<CourseCubit, CourseState>(
        builder: (context, state) {
          final students = state.students;
          final allQuestions = quiz.questions;
          // Limit to maximum 10 questions for tracking
          final questions = allQuestions.take(10).toList();
          final answersMap = DataService.instance.getStudentAnswersMap(quiz.id);

          if (students.isEmpty || questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    students.isEmpty ? Icons.people_outline : Icons.quiz_outlined,
                    size: 64,
                    color: mainGreen.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    students.isEmpty ? "No students yet" : "No questions in this quiz",
                    style: const TextStyle(fontSize: 18, color: mainGreen, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          final hasMoreThan10Questions = allQuestions.length > 10;

          return Column(
            children: [
              // Warning if more than 10 questions
              if (hasMoreThan10Questions)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.orange.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Showing first 10 questions only (${allQuestions.length} total)",
                          style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              // Header with Question Numbers
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                color: mainGreen,
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: const Text(
                        "Student",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: List.generate(
                            questions.length,
                            (index) => SizedBox(
                              width: 32,
                              child: Center(
                                child: Text(
                                  "Q${index + 1}",
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 50), // Space for score badge
                  ],
                ),
              ),

              // Student Rows
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final studentAnswers = answersMap[student.id] ?? {};

                    // Calculate statistics (only for displayed questions - first 10)
                    int correctCount = 0;
                    int answeredCount = 0;
                    for (int i = 0; i < questions.length; i++) {
                      final answer = studentAnswers[i];
                      if (answer != null) {
                        answeredCount++;
                        if (answer == questions[i].correctAnswer) {
                          correctCount++;
                        }
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: mainGreen.withOpacity(0.2), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: mainGreen.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Student name and score
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                // Student name - fixed width
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: mainGreen,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Question answers - scrollable
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: List.generate(
                                        questions.length,
                                        (qIndex) {
                                          final answer = studentAnswers[qIndex];
                                          final question = questions[qIndex];
                                          final isCorrect = answer != null && answer == question.correctAnswer;
                                          final hasAnswered = answer != null;

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: hasAnswered
                                                    ? (isCorrect 
                                                        ? Colors.green.withOpacity(0.15) 
                                                        : Colors.red.withOpacity(0.15))
                                                    : Colors.grey.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: hasAnswered
                                                      ? (isCorrect ? Colors.green : Colors.red)
                                                      : Colors.grey.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Icon(
                                                hasAnswered
                                                    ? (isCorrect ? Icons.check : Icons.close)
                                                    : Icons.remove,
                                                size: 18,
                                                color: hasAnswered
                                                    ? (isCorrect ? Colors.green : Colors.red)
                                                    : Colors.grey,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Score badge - fixed width
                                SizedBox(
                                  width: 50,
                                  child: Center(
                                    child: answeredCount > 0
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: mainGreen,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              "$correctCount/$answeredCount",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: const Text(
                                              "0/0",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainGreen,
        onPressed: () => _showAddStudentDialog(context),
        child: const Icon(Icons.person_add, color: tileFill),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: beigeLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Add Student",
          style: TextStyle(color: mainGreen, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(fontSize: 16, color: mainGreen),
          decoration: InputDecoration(
            hintText: "Student Name",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: mainGreen, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: mainGreen, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: mainGreen)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: mainGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a student name"), backgroundColor: Colors.red),
                );
                return;
              }
              DataService.instance.addStudent(name);
              context.read<CourseCubit>().loadInitialData();
              Navigator.pop(ctx);
            },
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
