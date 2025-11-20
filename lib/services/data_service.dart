// lib/services/data_service.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course.dart';
import '../models/quiz.dart';

class DataService {
  static final DataService instance = DataService._();
  DataService._();

  final List<Course> _courses = [];
  final List<Quiz> _quizzes = [];
  final Map<String, Uint8List> _webImages = {};

  final ValueNotifier<List<Course>> coursesNotifier = ValueNotifier([]);

  List<Course> get courses => List.unmodifiable(_courses);
  Map<String, Uint8List> get webImages => Map.unmodifiable(_webImages);
  void addCourse(String name, String imagePath, [Uint8List? webBytes]) {
    final course = Course(
      id: const Uuid().v4(),
      name: name,
      imagePath: imagePath,
    );
    _courses.add(course);
    if (webBytes != null) _webImages[imagePath] = webBytes;
    _updateCourses();
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
    if (imagePath != null) _webImages.remove(imagePath);

    _updateCourses();
  }
  void addQuiz(Quiz quiz) {
    _quizzes.add(quiz);
    _saveToPrefs();
    _updateCourses();
  }
  List<Quiz> getQuizzesForCourse(String courseId) {
    return _quizzes.where((q) => q.courseId == courseId).toList();
  }

  void deleteQuiz(String quizId) {
    _quizzes.removeWhere((q) => q.id == quizId);
    _saveToPrefs();
    _updateCourses();
  }

  void _updateCourses() {
    coursesNotifier.value = List.from(_courses);
  }

  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = _courses.map((c) => c.toJson()).toList();
    final quizzesJson = _quizzes.map((q) => q.toJson()).toList();
    await prefs.setString('courses', jsonEncode(coursesJson));
    await prefs.setString('quizzes', jsonEncode(quizzesJson));
  }
  void updateQuiz(Quiz updatedQuiz) {
    final index = _quizzes.indexWhere((q) => q.id == updatedQuiz.id);
    if (index != -1) {
      _quizzes[index] = updatedQuiz;
      _saveToPrefs();
      _updateCourses();
    }
  }
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesString = prefs.getString('courses');
    final quizzesString = prefs.getString('quizzes');

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

    _updateCourses();
  }
}