import 'package:flutter/material.dart';

class quizes_cont extends StatelessWidget {
  final String name;
  final String date;
  final String duration;
  final int questionsCount;
  final VoidCallback onTap;
  final VoidCallback? onTrackingTap;
  final bool showFinalScore;
  final ValueChanged<bool>? onShowFinalScoreChanged;

  const quizes_cont({
    super.key,
    required this.name,
    required this.date,
    required this.duration,
    required this.questionsCount,
    required this.onTap,
    this.onTrackingTap,
    this.showFinalScore = true,
    this.onShowFinalScoreChanged,
  });

  static const Color mainGreen = Color(0xFF0D4726);
  static const Color tileFill = Color(0xFFF2E6D1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: tileFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: mainGreen.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainGreen,
                    ),
                  ),
                ),
                if (onTrackingTap != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.people,
                            color: mainGreen, size: 24),
                        onPressed: onTrackingTap,
                        tooltip: "View Student Tracking",
                      ),
                      if (onShowFinalScoreChanged != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.visibility,
                                size: 14, color: mainGreen),
                            const SizedBox(width: 4),
                            Switch(
                              value: showFinalScore,
                              onChanged: onShowFinalScoreChanged,
                              activeColor: mainGreen,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: mainGreen),
                const SizedBox(width: 6),
                Text(
                  duration,
                  style: TextStyle(
                      color: mainGreen.withOpacity(0.9),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.quiz_outlined, size: 18, color: mainGreen),
                const SizedBox(width: 6),
                Text(
                  "$questionsCount ${questionsCount == 1 ? "question" : "questions"}",
                  style: TextStyle(
                      color: mainGreen.withOpacity(0.9),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.brown),
                const SizedBox(width: 6),
                Text(date, style: const TextStyle(color: Colors.brown)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
