// lib/screens/add_questions_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import '../services/data_service.dart';

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

  @override
  void initState() {
    super.initState();
    questions.addAll(widget.quiz.questions);
  }

  void _addQuestion() {
    final text = questionController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      questions.add(Question(
        questionText: text,
        correctAnswer: correctAnswer,
      ));
      questionController.clear();
      correctAnswer = true;
    });
  }

  void _saveAndExit() {
    final updatedQuiz = widget.quiz.copyWith(questions: questions);
    DataService.instance.updateQuiz(updatedQuiz);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${questions.length} questions saved!"),
        backgroundColor: mainGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeLight,
      appBar: AppBar(
        backgroundColor: mainGreen,
        title: Text("Edit Questions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (questions.isNotEmpty)
            TextButton(
              onPressed: _saveAndExit,
              child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          // حقل إضافة سؤال جديد
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    hintText: "Write your question here...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: mainGreen, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add_circle, color: mainGreen, size: 32),
                      onPressed: _addQuestion,
                    ),
                  ),
                  maxLines: 3,
                  style: TextStyle(fontSize: 17),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addQuestion(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Correct answer:", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: correctAnswer ? mainGreen : Colors.grey[400],
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => setState(() => correctAnswer = true),
                      child: Text("TRUE", style: TextStyle(color: correctAnswer ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !correctAnswer ? mainGreen : Colors.grey[400],
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => setState(() => correctAnswer = false),
                      child: Text("FALSE", style: TextStyle(color: !correctAnswer ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: mainGreen),
          Expanded(
            child: questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_outline, size: 80, color: mainGreen.withOpacity(0.5)),
                        SizedBox(height: 16),
                        Text("No questions added yet", style: TextStyle(fontSize: 18, color: mainGreen)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: Icon(
                            q.correctAnswer ? Icons.check_circle : Icons.cancel,
                            color: q.correctAnswer ? Colors.green : Colors.red,
                            size: 32,
                          ),
                          title: Text(q.questionText, style: TextStyle(fontSize: 17)),
                          subtitle: Text(q.correctAnswer ? "Correct: True" : "Correct: False", style: TextStyle(color: mainGreen)),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red[400]),
                            onPressed: () => setState(() => questions.removeAt(index)),
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