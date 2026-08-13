import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class AppTheme {
  static const Color primary = Color(0xFF1E3A8A); // Dark Blue
  static const Color secondary = Color(0xFFF59E0B); // Yellow Gold
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF43A047); // Medium Green (Green 600)
  static const Color error = Color(0xFFE53935); // Medium Red (Red 600)

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softBlueGradient = LinearGradient(
    colors: [Color(0xFFF0F7FF), Color(0xFFE0F2FE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: GoogleFonts.outfit().fontFamily,
      
      // Centralized AppBar theme with premium layout guidelines
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 68.0,
        iconTheme: const IconThemeData(color: Colors.white, size: 22),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 22),
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.bold, // Bold/Semi-Bold modern style
          letterSpacing: -0.3,
        ),
      ),

      // Text Theme matching clear hierarchy using 'Outfit'
      textTheme: baseTextTheme.copyWith(
        // Page titles (Large & prominent)
        headlineLarge: GoogleFonts.outfit(
          textStyle: baseTextTheme.headlineLarge,
          color: textPrimary,
          fontSize: 25,
          fontWeight: FontWeight.w800, // Extra Bold
          letterSpacing: -0.5,
        ),
        // Section titles & big headers
        headlineMedium: GoogleFonts.outfit(
          textStyle: baseTextTheme.headlineMedium,
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold, // Bold
          letterSpacing: -0.3,
        ),
        // Card headers / subheaders
        titleLarge: GoogleFonts.outfit(
          textStyle: baseTextTheme.titleLarge,
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold, // Bold
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.outfit(
          textStyle: baseTextTheme.titleMedium,
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600, // Semi-Bold
        ),
        titleSmall: GoogleFonts.outfit(
          textStyle: baseTextTheme.titleSmall,
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600, // Semi-Bold
        ),
        // Body primary readings
        bodyLarge: GoogleFonts.outfit(
          textStyle: baseTextTheme.bodyLarge,
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500, // Medium
        ),
        // Body secondary / detail entries
        bodyMedium: GoogleFonts.outfit(
          textStyle: baseTextTheme.bodyMedium,
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.normal, // Regular
        ),
        // Buttons and small labels
        labelLarge: GoogleFonts.outfit(
          textStyle: baseTextTheme.labelLarge,
          fontSize: 14,
          fontWeight: FontWeight.w600, // Semi-Bold
          letterSpacing: 0.1,
        ),
      ),

      // Button themes enforcing typography
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600, // Semi-Bold
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600, // Semi-Bold
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class MemberAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final TextStyle? textStyle;
  final String? profileImage;

  const MemberAvatar({
    super.key,
    required this.name,
    this.radius = 30,
    this.textStyle,
    this.profileImage,
  });

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
      return NetworkImage(path);
    } else if (path.startsWith('data:image')) {
      final base64Content = path.split(',').last;
      return MemoryImage(base64Decode(base64Content));
    } else {
      return NetworkImage(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanName = name.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    final parts = cleanName.split(RegExp(r'\s+'));
    String initials = '';
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      initials += parts.first[0].toUpperCase();
    }
    if (parts.length > 1 && parts.last.isNotEmpty) {
      initials += parts.last[0].toUpperCase();
    }
    if (initials.isEmpty) {
      initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    }

    final hasImage = profileImage != null && profileImage!.isNotEmpty;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: hasImage
            ? DecorationImage(
                image: _getImageProvider(profileImage!),
                fit: BoxFit.cover,
              )
            : null,
        gradient: hasImage
            ? null
            : const LinearGradient(
                colors: [AppTheme.primary, Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      alignment: Alignment.center,
      child: hasImage
          ? null
          : Text(
              initials,
              style: textStyle ??
                  GoogleFonts.outfit(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.75,
                  ),
            ),
    );
  }
}
