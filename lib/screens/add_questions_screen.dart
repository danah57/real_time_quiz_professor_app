// lib/screens/add_questions_screen.dart
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import '../services/firebase_data_service.dart';

class AddQuestionsScreen extends StatefulWidget {
  final Quiz quiz;
  const AddQuestionsScreen({super.key, required this.quiz});

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  final List<Question> questions = [];
  final TextEditingController questionController = TextEditingController();
  bool correctAnswer = true;

  static const Color mainGreen = Color(0xFF0D4726);
  static const Color beigeLight = Color(0xFFFDF6EE);
  static const Color lightGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    questions.addAll(widget.quiz.questions);
  }

  void _addQuestion() {
    final text = questionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a question"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      questions.add(Question(
        questionText: text,
        correctAnswer: correctAnswer,
      ));
      questionController.clear();
      correctAnswer = true;
    });

    // Success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Question added successfully!"),
          ],
        ),
        backgroundColor: lightGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _saveAndExit() async {
    final updatedQuiz = widget.quiz.copyWith(questions: questions);
    await FirebaseDataService.instance.updateQuiz(updatedQuiz);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text("${questions.length} questions saved successfully!"),
          ],
        ),
        backgroundColor: mainGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
          child: AppBar(
            backgroundColor: mainGreen,
            elevation: 0,
            title: Text(
              "Edit Questions (${questions.length})",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            actions: [
              if (questions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _saveAndExit,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text(
                        "Save",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: mainGreen,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(20),
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(20),
            //   border: Border.all(color: mainGreen.withOpacity(0.3), width: 2),
            //   boxShadow: [
            //     BoxShadow(
            //       color: mainGreen.withOpacity(0.1),
            //       blurRadius: 10,
            //       offset: const Offset(0, 4),
            //     ),
            //   ],
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mainGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_circle_outline,
                          color: mainGreen, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Add New Question",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    hintText: "Write your question here...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: beigeLight,
                    prefixIcon: const Icon(Icons.quiz, color: mainGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: mainGreen.withOpacity(0.3), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: mainGreen.withOpacity(0.3), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: mainGreen, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: mainGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 20),
                      ),
                      onPressed: _addQuestion,
                    ),
                  ),
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addQuestion(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      "Correct Answer:",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: mainGreen),
                    ),
                    const Spacer(),
                    _AnswerButton(
                      label: "TRUE",
                      isSelected: correctAnswer,
                      onTap: () => setState(() => correctAnswer = true),
                    ),
                    const SizedBox(width: 12),
                    _AnswerButton(
                      label: "FALSE",
                      isSelected: !correctAnswer,
                      onTap: () => setState(() => correctAnswer = false),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Questions List Header
          if (questions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: mainGreen.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.list, color: mainGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Questions (${questions.length})",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: mainGreen,
                    ),
                  ),
                ],
              ),
            ),

          // Questions List
          Expanded(
            child: questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: mainGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.quiz_outlined,
                              size: 64, color: mainGreen.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "No questions yet",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: mainGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start adding questions to your quiz",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: q.correctAnswer
                                ? lightGreen.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (q.correctAnswer ? lightGreen : Colors.red)
                                  .withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: q.correctAnswer
                                  ? lightGreen.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              q.correctAnswer
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: q.correctAnswer ? lightGreen : Colors.red,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            q.questionText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    (q.correctAnswer ? lightGreen : Colors.red)
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Answer: ${q.correctAnswer ? 'True' : 'False'}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      q.correctAnswer ? lightGreen : Colors.red,
                                ),
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                            ),
                            onPressed: () {
                              setState(() {
                                questions.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D4726) : Colors.grey[300],
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D4726).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
