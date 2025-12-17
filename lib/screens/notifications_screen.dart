import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cubit/notification_cubit.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color mainGreen = Color(0xFF0D4726);
  static const Color beigeLight = Color(0xFFFDF6EE);
  static const Color lightGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beigeLight,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Results & Scores",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: mainGreen),
            );
          }

          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: mainGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: mainGreen.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "No notifications yet",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Quiz results will appear here",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.notifications.length,
            itemBuilder: (context, index) {
              final notif = state.notifications[index];
              final percentage = notif.totalQuestions > 0
                  ? ((notif.score / notif.totalQuestions) * 100).round()
                  : 0;
              final isPassing = percentage >= 60;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPassing
                        ? lightGreen.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isPassing ? lightGreen : Colors.orange)
                          .withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: mainGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: mainGreen,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    notif.studentName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: mainGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _QuizAndCourseName(quizId: notif.quizId),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isPassing ? lightGreen : Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "$percentage%",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        // Score details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ScoreDetail(
                              icon: Icons.check_circle,
                              label: "Correct",
                              value: "${notif.score}",
                              color: lightGreen,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _ScoreDetail(
                              icon: Icons.quiz,
                              label: "Total",
                              value: "${notif.totalQuestions}",
                              color: mainGreen,
                            ),
                            if (notif.timeTakenSeconds != null) ...[
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                              ),
                              _ScoreDetail(
                                icon: Icons.access_time,
                                label: "Time",
                                value: _formatTime(notif.timeTakenSeconds!),
                                color: Colors.purple,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Progress bar
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isPassing ? lightGreen : Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
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
      );
    }
  
    String _formatTime(int seconds) {
      if (seconds < 60) {
        return '${seconds}s';
      } else if (seconds < 3600) {
        final minutes = seconds ~/ 60;
        final secs = seconds % 60;
        return '${minutes}m ${secs}s';
      } else {
        final hours = seconds ~/ 3600;
        final minutes = (seconds % 3600) ~/ 60;
        return '${hours}h ${minutes}m';
      }
    }
  }
  
  class _QuizAndCourseName extends StatelessWidget {
    final String quizId;
  
    const _QuizAndCourseName({required this.quizId});
  
    Future<Map<String, String>> _fetchNames() async {
      try {
        final quizDoc =
            await FirebaseFirestore.instance.collection('quizzes').doc(quizId).get();
        if (!quizDoc.exists) return {'quiz': 'Unknown Quiz', 'course': ''};
  
        final data = quizDoc.data()!;
        final quizTitle = data['title'] as String? ?? 'Unnamed Quiz';
        final courseId = data['courseId'] as String? ?? '';
  
        String courseName = '';
        if (courseId.isNotEmpty) {
          final courseDoc = await FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .get();
          if (courseDoc.exists) {
            courseName = courseDoc.data()?['name'] as String? ?? '';
          }
        }
  
        return {'quiz': quizTitle, 'course': courseName};
      } catch (e) {
        return {'quiz': 'Error loading', 'course': ''};
      }
    }
  
    @override
    Widget build(BuildContext context) {
      return FutureBuilder<Map<String, String>>(
        future: _fetchNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
  
          final quizName = snapshot.data?['quiz'] ?? 'Unknown Quiz';
          final courseName = snapshot.data?['course'] ?? '';
  
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quizName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              if (courseName.isNotEmpty)
                Text(
                  courseName,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          );
        },
      );
    }
  }

class _ScoreDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ScoreDetail({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
