import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/course.dart';
import '../models/quiz.dart';
import '../models/student.dart';
import '../services/data_service.dart';

part 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit(this._dataService) : super(const CourseState());

  final DataService _dataService;

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: CourseStatus.loading, errorMessage: null));
    try {
      await _dataService.loadFromPrefs();
      _emitFromService(status: CourseStatus.success);
    } catch (error) {
      emit(state.copyWith(status: CourseStatus.failure, errorMessage: error.toString()));
    }
  }

  void addCourse(String name, String imagePath, Uint8List? webBytes) {
    _dataService.addCourse(name, imagePath, webBytes);
    _emitFromService();
  }

  void deleteCourse(Course course) {
    _dataService.deleteCourse(course);
    _emitFromService();
  }

  void addQuiz(Quiz quiz) {
    _dataService.addQuiz(quiz);
    _emitFromService();
  }

  void updateQuiz(Quiz quiz) {
    _dataService.updateQuiz(quiz);
    _emitFromService();
  }

  void deleteQuiz(String quizId) {
    _dataService.deleteQuiz(quizId);
    _emitFromService();
  }

  List<Quiz> quizzesForCourse(String courseId) {
    return state.quizzes.where((quiz) => quiz.courseId == courseId).toList();
  }

  Uint8List? getWebImage(String path) => state.webImages[path];

  void _emitFromService({CourseStatus status = CourseStatus.success}) {
    emit(
      state.copyWith(
        courses: _dataService.courses,
        quizzes: _dataService.quizzes,
        students: _dataService.students,
        webImages: _dataService.webImages,
        status: status,
        errorMessage: null,
      ),
    );
  }
}

