class Course {
  final String id;
  final String name;
  final String imagePath;

  Course({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
    );
  }
}