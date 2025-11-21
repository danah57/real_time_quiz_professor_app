// lib/screens/prof_home.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../cubit/course_cubit.dart';
import '../models/course.dart';
import '../screens/course_details_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/notifications_screen.dart';
import '../services/data_service.dart';

class ProfessorHome extends StatelessWidget {
  const ProfessorHome({super.key});

  static const Color mainGreen = Color(0xFF0D4726);
  static const Color beigeLight = Color(0xFFFDF6EE);
  static const Color beigeDark = Color(0xFFF3DEC4);
  static const Color tileFill = Color(0xFFF2E6D1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [beigeLight, beigeDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 20),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.asset('assets/images/innovation.png',
                            fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome Professor',
                              style: TextStyle(
                                  color: mainGreen,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text('Manage quizzes & monitor students.',
                              style: TextStyle(
                                  fontSize: 15, color: Color(0xCC0D4726))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.dashboard, color: mainGreen, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DashboardScreen()),
                        );
                      },
                      tooltip: "Overview",
                    ),
                    IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.notifications, color: mainGreen, size: 28),
                          // Notification badge
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                      tooltip: "Results & Scores",
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Courses',
                      style: TextStyle(
                          color: mainGreen,
                          fontSize: 24,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<CourseCubit, CourseState>(
                  builder: (context, state) {
                    if (state.status == CourseStatus.loading) {
                      return const Center(
                          child: CircularProgressIndicator(color: mainGreen));
                    }
                    if (state.status == CourseStatus.failure) {
                      return Center(
                        child: Text(
                          state.errorMessage ?? 'Something went wrong.',
                          style:
                              const TextStyle(fontSize: 16, color: mainGreen),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final courses = state.courses;
                    if (courses.isEmpty) {
                      return const Center(
                        child: Text('No courses yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: mainGreen)),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        final webImage = state.webImages[course.imagePath];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      CourseDetailsScreen(course: course))),
                          onLongPress: () => _showDeleteDialog(context, course),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(24)),
                                    child: kIsWeb && webImage != null
                                        ? Image.memory(webImage,
                                            fit: BoxFit.cover,
                                            width: double.infinity)
                                        : Image.asset(
                                            course.imagePath,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.broken_image,
                                                    size: 50),
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  height: 56,
                                  child: Center(
                                    child: Text(course.name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: mainGreen),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: mainGreen,
        onPressed: () => _showAddCourseDialog(context),
        icon: const Icon(Icons.add, color: tileFill),
        label: const Text('New Course',
            style: TextStyle(color: tileFill, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: beigeLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        title: const Text("Delete Course?",
            style: TextStyle(color: mainGreen, fontWeight: FontWeight.bold)),
        content: Text("Delete \"${course.name}\" permanently?",
            style: const TextStyle(color: mainGreen)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(color:mainGreen, fontSize: 18),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<CourseCubit>().deleteCourse(course);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    XFile? pickedImage;
    Uint8List? webImageBytes;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: beigeLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 20,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Text("Add New Course",
              style: TextStyle(
                  color: mainGreen, fontSize: 25, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: mainGreen.withOpacity(0.5), width: 3),
                  ),
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 17, color: mainGreen ),
                    decoration: InputDecoration(
                      hintText: "Course Name",
                      hintStyle: TextStyle(color: mainGreen.withOpacity(0.6)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library,
                      color: tileFill, size: 28),
                  label: const Text("Choose from Gallery",
                      style: TextStyle(color: tileFill, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () async {
                    final image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      pickedImage = image;
                      webImageBytes = await image.readAsBytes();
                      setStateDialog(() {});
                    }
                  },
                ),
                const SizedBox(height: 20),
                if (pickedImage != null)
                  Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: mainGreen, width: 5)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(webImageBytes!, fit: BoxFit.cover)),
                  )
                else
                  Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: mainGreen.withOpacity(0.5), width: 4),
                    ),
                    child: Icon(Icons.image,
                        size: 80, color: mainGreen.withOpacity(0.4)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.red, fontSize: 18))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty || pickedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please enter name and choose image"),
                        backgroundColor: Colors.red),
                  );
                  return;
                }
                final fakePath = "web_${DateTime.now().millisecondsSinceEpoch}";
                context
                    .read<CourseCubit>()
                    .addCourse(name, fakePath, webImageBytes);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("'$name' added successfully!"),
                      backgroundColor: mainGreen),
                );
              },
              child: const Text("Add Course",
                  style: TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      color: tileFill)),
            ),
          ],
        ),
      ),
    );
  }
}
