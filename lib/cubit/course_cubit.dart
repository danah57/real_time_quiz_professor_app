// lib/cubit/course_cubit.dart
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/course.dart';
import '../services/firebase_data_service.dart';

part 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit(this._firebaseDataService) : super(const CourseState()) {
    _dataSubscription = _firebaseDataService.onDataChanged.listen((_) {
      _emitFromService();
    });
  }

  final FirebaseDataService _firebaseDataService;
  late final StreamSubscription _dataSubscription;

  Future<void> loadInitialData() async {
    emit(state.copyWith(status: CourseStatus.loading, errorMessage: null));
    try {
      await _firebaseDataService.loadFromPrefs();
      _emitFromService(status: CourseStatus.success);
    } catch (error) {
      emit(state.copyWith(
        status: CourseStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> addCourse(
      String name, String imagePath, Uint8List? webBytes) async {
    try {
      emit(state.copyWith(status: CourseStatus.loading));

      String finalImagePath = '';
      if (webBytes != null) {
        finalImagePath = base64Encode(webBytes);
        print('Image converted to Base64 (length: ${finalImagePath.length})');
      } else if (imagePath.startsWith('assets/')) {
        // If it's a local asset, use it as is
        finalImagePath = imagePath;
      }

      // Step 2: Add course to Firestore collection with Base64 string in imagePath
      await _firebaseDataService.addCourse(name, finalImagePath);

      // Real-time listener will trigger _emitFromService() automatically
      // But we can also emit immediately with current state
      _emitFromService(status: CourseStatus.success);

      print('✅ Course added successfully: $name');
    } catch (e) {
      print('❌ Error adding course: $e');
      emit(state.copyWith(
        status: CourseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // FIXED: Now properly awaits and emits state after deleting course
  Future<void> deleteCourse(Course course) async {
    try {
      // Show loading state
      emit(state.copyWith(status: CourseStatus.loading));

      // Delete course from Firebase
      await _firebaseDataService.deleteCourse(course);

      // Real-time listener will trigger _emitFromService() automatically
      _emitFromService(status: CourseStatus.success);

      print(' Course deleted successfully: ${course.name}');
    } catch (e) {
      print(' Error deleting course: $e');
      emit(state.copyWith(
        status: CourseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Uint8List? getWebImage(String path) => state.webImages[path];

  void _emitFromService({CourseStatus status = CourseStatus.success}) {
    emit(
      state.copyWith(
        courses: _firebaseDataService.courses,
        webImages: _firebaseDataService.webImages,
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
