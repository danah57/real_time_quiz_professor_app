// lib/services/firebase_data_service.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/course.dart';
import '../models/quiz.dart';
import '../models/student.dart';
import '../models/student_answer.dart';

class FirebaseDataService {
  static final FirebaseDataService instance = FirebaseDataService._();
  FirebaseDataService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // StreamController to notify listeners of data changes
  final _dataChangeController = StreamController<void>.broadcast();
  Stream<void> get onDataChanged => _dataChangeController.stream;

  // Local cache (RAM storage)
  final List<Course> _courses = [];
  final List<Quiz> _quizzes = [];
  final List<Student> _students = [];
  final List<StudentAnswer> _studentAnswers = [];
  final Map<String, Uint8List> _webImages = {};

  // Flag to track if initial data is loaded
  bool _isInitialized = false;

  List<Course> get courses => List.unmodifiable(_courses);
  List<Quiz> get quizzes => List.unmodifiable(_quizzes);
  List<Student> get students => List.unmodifiable(_students);
  List<StudentAnswer> get studentAnswers => List.unmodifiable(_studentAnswers);
  Map<String, Uint8List> get webImages => Map.unmodifiable(_webImages);

  Future<void> loadFromPrefs() async {
    if (_isInitialized) {
      print(' Already initialized - using RAM cache');
      return;
    }

    print('First time load - Fetching all data from Firebase...');

    try {
      // Load all data ONCE
      await Future.wait([
        _loadCourses(),
        _loadQuizzes(),
        _loadStudents(),
        _loadStudentAnswers(),
      ]);

      _isInitialized = true;
      print(' Initial data loaded! Now listening for real-time updates...');

      // Start real-time listeners AFTER initial load
      _startRealtimeListeners();
    } catch (e) {
      print(' Error loading initial data: $e');
    }
  }

  Future<void> _loadCourses() async {
    final snapshot = await _firestore.collection('courses').get();
    _courses.clear();
    _courses.addAll(
      snapshot.docs.map((doc) => Course.fromJson(doc.data())),
    );
    print(' Loaded ${_courses.length} courses');
  }

  Future<void> _loadQuizzes() async {
    final snapshot = await _firestore.collection('quizzes').get();
    _quizzes.clear();
    _quizzes.addAll(
      snapshot.docs.map((doc) => Quiz.fromJson(doc.data())),
    );
    print(' Loaded ${_quizzes.length} quizzes');
  }

  Future<void> _loadStudents() async {
    final snapshot = await _firestore.collection('users').get();
    _students.clear();
    _students.addAll(
      snapshot.docs.map((doc) => Student.fromJson(doc.data())),
    );
    print(' Loaded ${_students.length} students');
  }

  Future<void> _loadStudentAnswers() async {
    final snapshot = await _firestore.collection('student_answers').get();
    _studentAnswers.clear();
    _studentAnswers.addAll(
      snapshot.docs.map((doc) => StudentAnswer.fromJson(doc.data())),
    );
    print(' Loaded ${_studentAnswers.length} answers');
  }

  // FIXED: Only listen to changes AFTER initial load
  void _startRealtimeListeners() {
    // Courses listener
    _firestore.collection('courses').snapshots().listen((snapshot) {
      bool hasChanges = false;

      for (var change in snapshot.docChanges) {
        final course = Course.fromJson(change.doc.data()!);
        final index = _courses.indexWhere((c) => c.id == course.id);

        switch (change.type) {
          case DocumentChangeType.added:
            // Only add if not already in list (avoid duplicates from initial load)
            if (index == -1) {
              _courses.add(course);
              print(' Course added: ${course.name}');
              hasChanges = true;
            }
            break;

          case DocumentChangeType.modified:
            if (index != -1) {
              _courses[index] = course;
              print(' Course updated: ${course.name}');
              hasChanges = true;
            }
            break;

          case DocumentChangeType.removed:
            if (index != -1) {
              _courses.removeAt(index);
              print(' Course deleted: ${course.name}');
              hasChanges = true;
            }
            break;
        }
      }

      if (hasChanges) {
        _dataChangeController.add(null);
      }
    });

    // Quizzes listener
    _firestore.collection('quizzes').snapshots().listen((snapshot) {
      bool hasChanges = false;

      for (var change in snapshot.docChanges) {
        final quiz = Quiz.fromJson(change.doc.data()!);
        final index = _quizzes.indexWhere((q) => q.id == quiz.id);

        switch (change.type) {
          case DocumentChangeType.added:
            if (index == -1) {
              _quizzes.add(quiz);
              print(' Quiz added: ${quiz.title}');
              hasChanges = true;
            }
            break;

          case DocumentChangeType.modified:
            if (index != -1) {
              _quizzes[index] = quiz;
              print('Quiz updated: ${quiz.title}');
              hasChanges = true;
            }
            break;

          case DocumentChangeType.removed:
            if (index != -1) {
              _quizzes.removeAt(index);
              print(' Quiz deleted: ${quiz.title}');
              hasChanges = true;
            }
            break;
        }
      }

      if (hasChanges) {
        _dataChangeController.add(null);
      }
    });

    // Students listener
    _firestore.collection('users').snapshots().listen((snapshot) {
      bool hasChanges = false;

      for (var change in snapshot.docChanges) {
        final student = Student.fromJson(change.doc.data()!);
        final index = _students.indexWhere((s) => s.id == student.id);

        switch (change.type) {
          case DocumentChangeType.added:
            if (index == -1) {
              _students.add(student);
              print('Student added: ${student.name}');
              hasChanges = true;
            }
            break;

          case DocumentChangeType.modified:
            if (index != -1) {
              _students[index] = student;
              print(' Student updated: ${student.name}');
              hasChanges = true;
            }
            break;

          case DocumentChangeType.removed:
            if (index != -1) {
              _students.removeAt(index);
              print('🗑️ Student deleted: ${student.name}');
              hasChanges = true;
            }
            break;
        }
      }

      if (hasChanges) {
        _dataChangeController.add(null);
      }
    });

    // Student Answers listener
    _firestore.collection('student_answers').snapshots().listen((snapshot) {
      bool hasChanges = false;

      for (var change in snapshot.docChanges) {
        final answer = StudentAnswer.fromJson(change.doc.data()!);
        final index = _studentAnswers.indexWhere((a) => a.id == answer.id);

        switch (change.type) {
          case DocumentChangeType.added:
            if (index == -1) {
              _studentAnswers.add(answer);
              print('Answer added');
              hasChanges = true;
            }
            break;

          case DocumentChangeType.modified:
            if (index != -1) {
              _studentAnswers[index] = answer;
              print(' Answer updated');
              hasChanges = true;
            }
            break;

          case DocumentChangeType.removed:
            if (index != -1) {
              _studentAnswers.removeAt(index);
              print(' Answer deleted');
              hasChanges = true;
            }
            break;
        }
      }

      if (hasChanges) {
        _dataChangeController.add(null);
      }
    });

    print(' Real-time listeners active!');
  }

  Future<Course> addCourse(String name, String imageUrl) async {
    // Use the provided imageUrl (could be Firebase Storage URL or asset path)
    final finalImagePath = imageUrl.isNotEmpty ? imageUrl : '';

    final course = Course(
      id: const Uuid().v4(),
      name: name,
      imagePath: finalImagePath,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('courses').doc(course.id).set(course.toJson());

    return course;
  }

  Future<void> deleteCourse(dynamic courseOrId) async {
    String id;
    String? imagePath;

    if (courseOrId is Course) {
      id = courseOrId.id;
      imagePath = courseOrId.imagePath;
    } else if (courseOrId is String) {
      id = courseOrId;
      final course = _courses.firstWhere(
        (c) => c.id == id,
        orElse: () => Course(id: '', name: '', imagePath: ''),
      );
      imagePath = course.imagePath;
    } else {
      return;
    }

    await _firestore.collection('courses').doc(id).delete();

    final quizzesToDelete = _quizzes.where((q) => q.courseId == id).toList();
    for (final quiz in quizzesToDelete) {
      await deleteQuiz(quiz.id);
    }

    if (imagePath != null && imagePath.contains('firebase')) {
      try {
        await _storage.refFromURL(imagePath).delete();
      } catch (e) {
        print('Error deleting image: $e');
      }
    }

    _webImages.remove(imagePath);
  }

  Future<void> addQuiz(Quiz quiz) async {
    await _firestore.collection('quizzes').doc(quiz.id).set(quiz.toJson());
  }

  Future<void> updateQuiz(Quiz updatedQuiz) async {
    await _firestore
        .collection('quizzes')
        .doc(updatedQuiz.id)
        .update(updatedQuiz.toJson());
  }

  Future<void> deleteQuiz(String quizId) async {
    await _firestore.collection('quizzes').doc(quizId).delete();
    await _firestore.collection('active_sessions').doc(quizId).delete();

    final results = await _firestore
        .collection('quiz_results')
        .where('quizId', isEqualTo: quizId)
        .get();

    for (final doc in results.docs) {
      await doc.reference.delete();
    }
  }

  List<Quiz> getQuizzesForCourse(String courseId) {
    return _quizzes.where((q) => q.courseId == courseId).toList();
  }

  Future<Student> addStudent(String name) async {
    final student = Student(
      id: const Uuid().v4(),
      name: name,
    );

    await _firestore.collection('users').doc(student.id).set(student.toJson());
    return student;
  }

  Future<void> deleteStudent(String studentId) async {
    await _firestore.collection('users').doc(studentId).delete();

    final answers = await _firestore
        .collection('student_answers')
        .where('studentId', isEqualTo: studentId)
        .get();

    for (final doc in answers.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> submitStudentAnswer(
    String studentId,
    String quizId,
    int questionIndex,
    bool answer,
  ) async {
    final studentAnswer = StudentAnswer(
      id: const Uuid().v4(),
      studentId: studentId,
      quizId: quizId,
      questionIndex: questionIndex,
      answer: answer,
      answeredAt: DateTime.now(),
    );

    await _firestore
        .collection('student_answers')
        .doc(studentAnswer.id)
        .set(studentAnswer.toJson());
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

  Stream<List<Map<String, dynamic>>> monitorActiveStudents(String quizId) {
    return _firestore
        .collection('active_sessions')
        .doc(quizId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return [];

      final data = snapshot.data() as Map<String, dynamic>;
      final sessions = data['sessions'] as Map<String, dynamic>? ?? {};

      return sessions.entries.map((entry) {
        return {
          'studentId': entry.key,
          'currentQuestionIndex': entry.value['currentQuestionIndex'],
          'answers': entry.value['answers'],
          'status': entry.value['status'],
          'startedAt': entry.value['startedAt'], // Added startedAt
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> listenToQuizResults(String quizId) {
    return _firestore
        .collection('quiz_results')
        .where('quizId', isEqualTo: quizId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // Save quiz result with timeTaken calculation
  Future<void> saveQuizResult({
    required String studentId,
    required String quizId,
    required DateTime startedAt,
    required DateTime completedAt,
    required int correctAnswers,
    required int totalQuestions,
    required int score,
  }) async {
    // Calculate timeTaken in seconds
    final timeTaken = completedAt.difference(startedAt).inSeconds;

    final resultId = '${studentId}_${quizId}';

    await _firestore.collection('quiz_results').doc(resultId).set({
      'id': resultId,
      'studentId': studentId,
      'quizId': quizId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'timeTaken': timeTaken, // in seconds
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'score': score,
    }, SetOptions(merge: true));

    print(
        '✅ Quiz result saved: Student $studentId - Time: ${timeTaken}s - Score: $score/$totalQuestions');
  }

  // Get quiz results for a specific quiz
  Future<List<Map<String, dynamic>>> getQuizResults(String quizId) async {
    final snapshot = await _firestore
        .collection('quiz_results')
        .where('quizId', isEqualTo: quizId)
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
