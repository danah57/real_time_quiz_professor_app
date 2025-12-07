// lib/cubit/quiz_cubit.dart
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/quiz.dart';
import '../services/firebase_data_service.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this._firebaseDataService) : super(const QuizState()) {
    _dataSubscription = _firebaseDataService.onDataChanged.listen((_) {
      _emitFromService();
    });
    // Emit initial state if data is already loaded
    if (_firebaseDataService.quizzes.isNotEmpty) {
      _emitFromService();
    }
  }

  final FirebaseDataService _firebaseDataService;
  late final StreamSubscription _dataSubscription;

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: QuizStatus.loading, errorMessage: null));
    try {
      // Load data from Firebase (will only load once due to _isInitialized flag)
      // If already loaded by CourseCubit, this will return immediately
      await _firebaseDataService.loadFromPrefs();
      // Always emit current quizzes from service (even if already loaded)
      _emitFromService(status: QuizStatus.success);
      print(
          '✅ QuizCubit: Loaded ${_firebaseDataService.quizzes.length} quizzes');
    } catch (error) {
      print('❌ QuizCubit: Error loading quizzes: $error');
      emit(state.copyWith(
        status: QuizStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> addQuiz(Quiz quiz) async {
    try {
      emit(state.copyWith(status: QuizStatus.loading));
      await _firebaseDataService.addQuiz(quiz);
      _emitFromService(status: QuizStatus.success);
      print(' Quiz added successfully: ${quiz.title}');
    } catch (e) {
      print(' Error adding quiz: $e');
      emit(state.copyWith(
        status: QuizStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateQuiz(Quiz quiz) async {
    try {
      emit(state.copyWith(status: QuizStatus.loading));
      await _firebaseDataService.updateQuiz(quiz);
      _emitFromService(status: QuizStatus.success);
      print(' Quiz updated successfully: ${quiz.title}');
    } catch (e) {
      print('Error updating quiz: $e');
      emit(state.copyWith(
        status: QuizStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    try {
      emit(state.copyWith(status: QuizStatus.loading));
      await _firebaseDataService.deleteQuiz(quizId);
      _emitFromService(status: QuizStatus.success);
      print(' Quiz deleted successfully');
    } catch (e) {
      print(' Error deleting quiz: $e');
      emit(state.copyWith(
        status: QuizStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _emitFromService({QuizStatus status = QuizStatus.success}) {
    emit(
      state.copyWith(
        quizzes: _firebaseDataService.quizzes,
        status: status,
        errorMessage: null,
      ),
    );
  }

  @override
  Future<void> close() {
    _dataSubscription.cancel();
    return super.close();
  }
}
