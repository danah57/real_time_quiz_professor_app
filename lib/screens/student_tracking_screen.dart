// lib/screens/student_tracking_screen.dart
import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../services/firebase_data_service.dart';

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
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseDataService.instance.monitorActiveStudents(quiz.id),
        builder: (context, activeSessionsSnapshot) {
          final allQuestions = quiz.questions;
          // Limit to maximum 10 questions for tracking
          final questions = allQuestions.take(10).toList();

          if (questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: mainGreen.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No questions in this quiz",
                    style: TextStyle(
                        fontSize: 18,
                        color: mainGreen,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          // Get active sessions data
          final activeSessions = activeSessionsSnapshot.data ?? [];

          if (activeSessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: mainGreen.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No active students",
                    style: TextStyle(
                        fontSize: 18,
                        color: mainGreen,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Students will appear here when they start the quiz",
                    style: TextStyle(
                        fontSize: 14,
                        color: mainGreen.withOpacity(0.6),
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Get all students to match IDs with names
          final allStudents = FirebaseDataService.instance.students;
          final studentsMap = {
            for (var student in allStudents) student.id: student
          };

          final hasMoreThan10Questions = allQuestions.length > 10;

          return Column(
            children: [
              // Active students count indicator
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: mainGreen.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: mainGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${activeSessions.length} active student${activeSessions.length == 1 ? '' : 's'}",
                      style: TextStyle(
                          color: mainGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Warning if more than 10 questions
              if (hasMoreThan10Questions)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: Colors.orange.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Showing first 10 questions only (${allQuestions.length} total)",
                          style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              // Header with Question Numbers
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                color: mainGreen,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        "Student",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
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
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        width:
                            80), // Space for current question and score badge
                  ],
                ),
              ),

              // Student Rows
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: activeSessions.length,
                  itemBuilder: (context, index) {
                    final session = activeSessions[index];
                    final studentId = session['studentId'] as String;
                    final student = studentsMap[studentId];
                    final currentQuestionIndex =
                        session['currentQuestionIndex'] as int? ?? -1;
                    final answers =
                        session['answers'] as Map<String, dynamic>? ?? {};
                    final status = session['status'] as String? ?? 'active';

                    // Convert answers map to questionIndex -> answer format
                    final studentAnswers = <int, bool?>{};
                    answers.forEach((key, value) {
                      final qIndex = int.tryParse(key);
                      if (qIndex != null) {
                        studentAnswers[qIndex] = value as bool?;
                      }
                    });

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

                    // Get student name or use ID if not found
                    final studentName = student?.name ?? 'Unknown Student';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: status == 'finished'
                                ? Colors.blue.withOpacity(0.5)
                                : mainGreen.withOpacity(0.2),
                            width: status == 'finished' ? 2 : 1.5),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                // Student name - fixed width
                                SizedBox(
                                  width: 100,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        studentName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: mainGreen,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (status == 'finished')
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            "Finished",
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Question answers - scrollable
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: List.generate(
                                        questions.length,
                                        (qIndex) {
                                          final answer = studentAnswers[qIndex];
                                          final question = questions[qIndex];
                                          final isCorrect = answer != null &&
                                              answer == question.correctAnswer;
                                          final hasAnswered = answer != null;
                                          final isCurrentQuestion =
                                              qIndex == currentQuestionIndex;

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: isCurrentQuestion
                                                    ? Colors.orange
                                                        .withOpacity(0.3)
                                                    : hasAnswered
                                                        ? (isCorrect
                                                            ? Colors.green
                                                                .withOpacity(
                                                                    0.15)
                                                            : Colors.red
                                                                .withOpacity(
                                                                    0.15))
                                                        : Colors.grey
                                                            .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isCurrentQuestion
                                                      ? Colors.orange
                                                      : hasAnswered
                                                          ? (isCorrect
                                                              ? Colors.green
                                                              : Colors.red)
                                                          : Colors.grey
                                                              .withOpacity(0.3),
                                                  width: isCurrentQuestion
                                                      ? 2.5
                                                      : 1.5,
                                                ),
                                              ),
                                              child: isCurrentQuestion
                                                  ? const Icon(
                                                      Icons
                                                          .radio_button_checked,
                                                      size: 16,
                                                      color: Colors.orange,
                                                    )
                                                  : Icon(
                                                      hasAnswered
                                                          ? (isCorrect
                                                              ? Icons.check
                                                              : Icons.close)
                                                          : Icons.remove,
                                                      size: 18,
                                                      color: hasAnswered
                                                          ? (isCorrect
                                                              ? Colors.green
                                                              : Colors.red)
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
                                // Current question indicator and score badge
                                SizedBox(
                                  width: 80,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (currentQuestionIndex >= 0 &&
                                          currentQuestionIndex <
                                              questions.length)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.orange.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "Q${currentQuestionIndex + 1}",
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      answeredCount > 0
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: mainGreen,
                                                borderRadius:
                                                    BorderRadius.circular(16),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(16),
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
                                    ],
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
          style: TextStyle(
              color: mainGreen, fontSize: 20, fontWeight: FontWeight.bold),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Please enter a student name"),
                      backgroundColor: Colors.red),
                );
                return;
              }
              await FirebaseDataService.instance.addStudent(name);
              Navigator.pop(ctx);
            },
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
