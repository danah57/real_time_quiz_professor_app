// lib/screens/course_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../cubit/quiz_cubit.dart';
import '../models/course.dart';
import '../models/quiz.dart';
import '../widgets/quizes_cont.dart';
import 'add_questions_screen.dart';
import 'student_tracking_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;

  const CourseDetailsScreen({super.key, required this.course});

  static const Color mainGreen = Color(0xFF0D4726);
  static const Color beigeLight = Color(0xFFFDF6EE);
  static const Color beigeDark = Color(0xFFF3DEC4);
  static const Color tileFill = Color(0xFFF2E6D1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeLight,
      body: SafeArea(
        child: Column(
          children: [
            // الهيدر بظل خفيف ومسافات أجمل
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              decoration: BoxDecoration(
                color: beigeLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mainGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: mainGreen, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      course.name,
                      style: const TextStyle(
                        color: mainGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // رسالة "No quizzes yet" أجمل شوية
            Expanded(
              child: BlocBuilder<QuizCubit, QuizState>(
                builder: (context, quizState) {
                  final quizzes = quizState.quizzes
                      .where((quiz) => quiz.courseId == course.id)
                      .toList();

                  if ((quizState.status == QuizStatus.loading ||
                          quizState.status == QuizStatus.initial) &&
                      quizState.quizzes.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator(color: mainGreen));
                  }

                  if (quizzes.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 24),
                          Text(
                            "No quizzes yet",
                            style: TextStyle(
                                fontSize: 22,
                                color: mainGreen,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(28, 16, 28, 100),
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      final formattedDate =
                          DateFormat('dd MMM yyyy').format(quiz.date);
                      final durationText = "${quiz.duration.inMinutes} min";

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: quizes_cont(
                          name: quiz.title,
                          date: formattedDate,
                          duration: durationText,
                          questionsCount: quiz.questions.length,
                          showFinalScore: quiz.showFinalScore,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      AddQuestionsScreen(quiz: quiz)),
                            );
                          },
                          onTrackingTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      StudentTrackingScreen(quiz: quiz)),
                            );
                          },
                          onShowFinalScoreChanged: (value) async {
                            final updatedQuiz =
                                quiz.copyWith(showFinalScore: value);
                            await context
                                .read<QuizCubit>()
                                .updateQuiz(updatedQuiz);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB أجمل شوية مع ظل وشكل مدور
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: mainGreen,
        elevation: 8,
        highlightElevation: 16,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () => _showAddQuizDialog(context),
        icon: const Icon(Icons.add, color: tileFill, size: 26),
        label: const Text(
          "New Quiz",
          style: TextStyle(
              color: tileFill, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddQuizDialog(BuildContext context) {
    final titleController = TextEditingController();
    int durationMinutes = 30;
    bool showFinalScore = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: beigeLight,
          elevation: 20,
          shadowColor: Colors.black26,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text(
            "Create New Quiz",
            style: TextStyle(
                color: mainGreen, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Quiz Title",
                  style: TextStyle(fontSize: 16, color: mainGreen)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Quiz Title",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: mainGreen, width: 2.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: mainGreen, width: 3),
                  ),
                ),
                style: const TextStyle(color: mainGreen, fontSize: 18),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Duration:",
                      style: TextStyle(fontSize: 16, color: mainGreen)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: mainGreen, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: durationMinutes,
                        dropdownColor: beigeLight,
                        borderRadius: BorderRadius.circular(18),
                        style: const TextStyle(
                            color: mainGreen,
                            fontSize: 17,
                            fontWeight: FontWeight.w600),
                        icon:
                            const Icon(Icons.timer_outlined, color: mainGreen),
                        items: [10, 20, 30, 45, 60]
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "$m min",
                                    style: const TextStyle(
                                        color: mainGreen,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => durationMinutes = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: beigeLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please enter a quiz title"),
                        backgroundColor: Colors.red),
                  );
                  return;
                }

                final newQuiz = Quiz(
                  id: const Uuid().v4(),
                  courseId: course.id,
                  title: title,
                  date: DateTime.now(),
                  duration: Duration(minutes: durationMinutes),
                  questions: [],
                  showFinalScore: showFinalScore,
                );

                await context.read<QuizCubit>().addQuiz(newQuiz);
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddQuestionsScreen(quiz: newQuiz)),
                );
              },
              child: const Text(
                "Create & Start",
                style: TextStyle(
                    color: mainGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
