// lib/models/course.dart

class Course {
  final String id;
  final String name;
  final String imagePath;
  final DateTime? createdAt;

  Course({
    required this.id,
    required this.name,
    required this.imagePath,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
  Course copyWith({
    String? id,
    String? name,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
