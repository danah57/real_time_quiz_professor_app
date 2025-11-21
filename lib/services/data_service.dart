// lib/services/data_service.dart
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course.dart';
import '../models/quiz.dart';
import '../models/student.dart';
import '../models/student_answer.dart';

class DataService {
  static final DataService instance = DataService._();
  DataService._();

  final List<Course> _courses = [];
  final List<Quiz> _quizzes = [];
  final List<Student> _students = [];
  final List<StudentAnswer> _studentAnswers = [];
  final Map<String, Uint8List> _webImages = {};

  List<Course> get courses => List.unmodifiable(_courses);
  List<Quiz> get quizzes => List.unmodifiable(_quizzes);
  List<Student> get students => List.unmodifiable(_students);
  List<StudentAnswer> get studentAnswers => List.unmodifiable(_studentAnswers);
  Map<String, Uint8List> get webImages => Map.unmodifiable(_webImages);

  Course addCourse(String name, String imagePath, [Uint8List? webBytes]) {
    final course = Course(
      id: const Uuid().v4(),
      name: name,
      imagePath: imagePath,
    );
    _courses.add(course);
    if (webBytes != null) _webImages[imagePath] = webBytes;
    _saveToPrefs();
    return course;
  }
  void deleteCourse(dynamic courseOrId) {
    String id;
    String? imagePath;

    if (courseOrId is Course) {
      id = courseOrId.id;
      imagePath = courseOrId.imagePath;
    } else if (courseOrId is String) {
      id = courseOrId;
      final course = _courses.firstWhere((c) => c.id == id, orElse: () => Course(id: '', name: '', imagePath: ''));
      imagePath = course.imagePath;
    } else {
      return;
    }

    _courses.removeWhere((c) => c.id == id);
    _quizzes.removeWhere((q) => q.courseId == id);
    _webImages.remove(imagePath);

    _saveToPrefs();
  }
  void addQuiz(Quiz quiz) {
    _quizzes.add(quiz);
    _saveToPrefs();
  }
  List<Quiz> getQuizzesForCourse(String courseId) {
    return _quizzes.where((q) => q.courseId == courseId).toList();
  }

  void deleteQuiz(String quizId) {
    _quizzes.removeWhere((q) => q.id == quizId);
    _saveToPrefs();
  }

  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = _courses.map((c) => c.toJson()).toList();
    final quizzesJson = _quizzes.map((q) => q.toJson()).toList();
    final studentsJson = _students.map((s) => s.toJson()).toList();
    final answersJson = _studentAnswers.map((a) => a.toJson()).toList();
    await prefs.setString('courses', jsonEncode(coursesJson));
    await prefs.setString('quizzes', jsonEncode(quizzesJson));
    await prefs.setString('students', jsonEncode(studentsJson));
    await prefs.setString('studentAnswers', jsonEncode(answersJson));
  }
  void updateQuiz(Quiz updatedQuiz) {
    final index = _quizzes.indexWhere((q) => q.id == updatedQuiz.id);
    if (index != -1) {
      _quizzes[index] = updatedQuiz;
      _saveToPrefs();
    }
  }
  
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesString = prefs.getString('courses');
    final quizzesString = prefs.getString('quizzes');
    final studentsString = prefs.getString('students');
    final answersString = prefs.getString('studentAnswers');

    if (coursesString != null) {
      final List<dynamic> coursesList = jsonDecode(coursesString);
      _courses.clear();
      _courses.addAll(coursesList.map((c) => Course.fromJson(c)));
    }

    if (quizzesString != null) {
      final List<dynamic> quizzesList = jsonDecode(quizzesString);
      _quizzes.clear();
      _quizzes.addAll(quizzesList.map((q) => Quiz.fromJson(q)));
    }

    if (studentsString != null) {
      final List<dynamic> studentsList = jsonDecode(studentsString);
      _students.clear();
      _students.addAll(studentsList.map((s) => Student.fromJson(s)));
    }

    if (answersString != null) {
      final List<dynamic> answersList = jsonDecode(answersString);
      _studentAnswers.clear();
      _studentAnswers.addAll(answersList.map((a) => StudentAnswer.fromJson(a)));
    }
  }

  // Student management
  Student addStudent(String name) {
    final student = Student(
      id: const Uuid().v4(),
      name: name,
    );
    _students.add(student);
    _saveToPrefs();
    return student;
  }

  void deleteStudent(String studentId) {
    _students.removeWhere((s) => s.id == studentId);
    _studentAnswers.removeWhere((a) => a.studentId == studentId);
    _saveToPrefs();
  }

  // Student answer management
  void submitStudentAnswer(String studentId, String quizId, int questionIndex, bool answer) {
    final existingIndex = _studentAnswers.indexWhere(
      (a) => a.studentId == studentId && a.quizId == quizId && a.questionIndex == questionIndex,
    );

    final studentAnswer = StudentAnswer(
      id: existingIndex != -1 ? _studentAnswers[existingIndex].id : const Uuid().v4(),
      studentId: studentId,
      quizId: quizId,
      questionIndex: questionIndex,
      answer: answer,
      answeredAt: DateTime.now(),
    );

    if (existingIndex != -1) {
      _studentAnswers[existingIndex] = studentAnswer;
    } else {
      _studentAnswers.add(studentAnswer);
    }
    _saveToPrefs();
  }

  List<StudentAnswer> getAnswersForQuiz(String quizId) {
    return _studentAnswers.where((a) => a.quizId == quizId).toList();
  }

  Map<String, Map<int, bool?>> getStudentAnswersMap(String quizId) {
    final answers = getAnswersForQuiz(quizId);
    final Map<String, Map<int, bool?>> result = {};
    
    for (final answer in answers) {
      if (!result.containsKey(answer.studentId)) {
        result[answer.studentId] = {};
      }
      result[answer.studentId]![answer.questionIndex] = answer.answer;
    }
    
    return result;
  }
}