import 'package:flutter/material.dart';

/// Custom widget untuk logo Gemini AI
/// Menggunakan asset image logo Gemini resmi
class GeminiLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;

  const GeminiLogo({super.key, this.size = 24.0, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo/google-gemini-icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback jika image tidak ditemukan
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFEA4335), // Red
                Color(0xFFFBBC04), // Yellow
                Color(0xFF34A853), // Green
                Color(0xFF4285F4), // Blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
