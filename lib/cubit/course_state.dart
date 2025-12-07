part of 'course_cubit.dart';

enum CourseStatus { initial, loading, success, failure }

class CourseState extends Equatable {
  const CourseState({
    this.courses = const [],
    this.webImages = const <String, Uint8List>{},
    this.status = CourseStatus.initial,
    this.errorMessage,
  });

  final List<Course> courses;
  final Map<String, Uint8List> webImages;
  final CourseStatus status;
  final String? errorMessage;

  CourseState copyWith({
    List<Course>? courses,
    Map<String, Uint8List>? webImages,
    CourseStatus? status,
    String? errorMessage,
  }) {
    return CourseState(
      courses: courses ?? this.courses,
      webImages: webImages ?? this.webImages,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [courses, webImages, status, errorMessage];
}
