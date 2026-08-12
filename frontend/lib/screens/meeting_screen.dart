import 'package:flutter/material.dart';
import 'dart:math';
import '../theme.dart';
import '../models.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> with TickerProviderStateMixin {
  int _attendedCount = 8;
  final int _requiredCount = 18;
  final int _totalCount = 24;

  late AnimationController _radialController;

  @override
  void initState() {
    super.initState();
    _radialController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _radialController.forward();
  }

  @override
  void dispose() {
    _radialController.dispose();
    super.dispose();
  }

  void _simulateQrScan() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const QrScannerSimDialog();
      },
    ).then((scanned) {
      if (scanned == true) {
        setState(() {
          if (_attendedCount < _totalCount) {
            _attendedCount++;
            // Re-run radial animation
            _radialController.reset();
            _radialController.forward();
          }
        });

        // Add a mock meeting to the top
        final mockMeeting = Meeting(
          title: "7TH KGMEET GOBI (SCANNED)",
          date: DateTime.now().toString().split(" ")[0],
          type: "KG-Meet",
          attended: true,
        );
        MockData.meetings.insert(0, mockMeeting);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("QR Code scan successful! Attendance logged."),
              ],
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double attendancePercent = _attendedCount / _requiredCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Attendance Summary Visuals (Radial progress + metrics)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: Radial indicator card (3rd image box)
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 240, // Match height of right side cards
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _radialController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: AttendanceRadialPainter(
                                  percentage: attendancePercent * _radialController.value,
                                  primaryColor: AppTheme.primary,
                                  accentColor: AppTheme.secondary,
                                  backgroundColor: AppTheme.background,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${(attendancePercent * 100).toInt()}%",
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Attended",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right side: Column of 3 boxes
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 240,
                        child: Column(
                          children: [
                            _buildStatBox(
                              icon: Icons.event,
                              label: "Total Meetings",
                              value: "$_totalCount",
                              color: AppTheme.primary,
                            ),
                            const SizedBox(height: 10),
                            _buildStatBox(
                              icon: Icons.star_border,
                              label: "Compulsary",
                              value: "$_requiredCount",
                              color: AppTheme.secondary,
                            ),
                            const SizedBox(height: 10),
                            _buildStatBox(
                              icon: Icons.check_circle_outline,
                              label: "Attended",
                              value: "$_attendedCount",
                              color: AppTheme.success,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Scan QR Code Action Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: AppTheme.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.secondary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _simulateQrScan,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Scan QR Code to Check-In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
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
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppTheme.border.withOpacity(0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color == AppTheme.success ? AppTheme.success : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}

// Attendance Circular Painter
class AttendanceRadialPainter extends CustomPainter {
  final double percentage;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;

  AttendanceRadialPainter({
    required this.percentage,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 8.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;

    // Draw background track
    Paint paintTrack = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paintTrack);

    // Draw active progress
    Paint paintProgress = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Use gold accent if 100%, otherwise primary blue
    paintProgress.color = percentage >= 1.0 ? accentColor : primaryColor;

    double sweepAngle = 2 * pi * percentage.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant AttendanceRadialPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}

// Simulated QR Camera Scanner Dialog
class QrScannerSimDialog extends StatefulWidget {
  const QrScannerSimDialog({super.key});

  @override
  State<QrScannerSimDialog> createState() => _QrScannerSimDialogState();
}

class _QrScannerSimDialogState extends State<QrScannerSimDialog> with SingleTickerProviderStateMixin {
  late AnimationController _scannerAnimationController;

  @override
  void initState() {
    super.initState();
    _scannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "QR Scanner Camera",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: const Icon(Icons.close, color: Colors.white70, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Scanner camera preview window
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.secondary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
                // Laser beam animation overlay
                AnimatedBuilder(
                  animation: _scannerAnimationController,
                  builder: (context, child) {
                    double topOffset = _scannerAnimationController.value * 190;
                    return Positioned(
                      top: topOffset,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.secondary.withOpacity(0.8),
                              blurRadius: 4,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Point camera at the meeting QR code",
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Fallback simulation button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.flash_on),
            label: const Text("Simulate Successful Scan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
