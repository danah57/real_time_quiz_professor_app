import 'package:flutter/material.dart';

class add_categorey extends StatelessWidget {
  const add_categorey({super.key, required this.text, this.icon, this.onTap});

  final String text;
  final IconData? icon;
  final VoidCallback? onTap;

  static const Color mainGreen = Color(0xFF0D4726);
  static const Color tileFill = Color(0xFFF2E6D1);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: mainGreen,
        highlightColor: const Color.fromARGB(55, 13, 71, 38),
        child: Container(
          decoration: BoxDecoration(
            color: tileFill,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(118, 13, 71, 38),
                blurRadius: 16,
                offset: Offset(2, 4),
              ),
            ],
            border: Border.all(color: mainGreen, width: 5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 32, color: mainGreen),
              const SizedBox(height: 12),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: mainGreen,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
