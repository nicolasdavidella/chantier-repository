import 'package:flutter/material.dart';
import 'dart:math' as math;

// Shared colors
const Color primaryGreen = Color(0xFF0F6E56);
const Color secondaryTerracotta = Color(0xFFD85A30);
const Color lightGreen = Color(0xFFE2F0EC);
const Color paleGrey = Color(0xFFF5F7FA);

// ---------------------------------------------------------
// Illustration 1: Construction & Tracking
// ---------------------------------------------------------
class ConstructionIllustration extends StatefulWidget {
  const ConstructionIllustration({super.key});

  @override
  State<ConstructionIllustration> createState() => _ConstructionIllustrationState();
}

class _ConstructionIllustrationState extends State<ConstructionIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: ConstructionPainter(_controller.value),
        );
      },
    );
  }
}

class ConstructionPainter extends CustomPainter {
  final double animationValue;

  ConstructionPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Basic flat geometric style
    final bgPaint = Paint()..color = paleGrey..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(10, 60, size.width - 20, size.height - 60), const Radius.circular(32)), bgPaint);

    // Crane (oscillating)
    final craneOscillation = math.sin(animationValue * 2 * math.pi) * 0.05; 
    canvas.save();
    canvas.translate(90, 260); // Base of crane
    canvas.rotate(craneOscillation);
    final cranePaint = Paint()..color = primaryGreen..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round;
    // vertical
    canvas.drawLine(const Offset(0, 0), const Offset(0, -160), cranePaint);
    // horizontal arm
    canvas.drawLine(const Offset(-30, -140), const Offset(100, -140), cranePaint);
    // wire
    final wirePaint = Paint()..color = Colors.grey.shade400..strokeWidth = 2;
    canvas.drawLine(const Offset(80, -140), const Offset(80, -50), wirePaint);
    // payload (moving up and down slightly)
    final payloadOffset = math.cos(animationValue * 2 * math.pi) * 15;
    canvas.drawRect(Rect.fromCenter(center: Offset(80, -45 + payloadOffset), width: 30, height: 30), Paint()..color = secondaryTerracotta);
    canvas.restore();

    // Small House
    final housePaint = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30, 200, 80, 60), const Radius.circular(8)), housePaint);
    final roofPaint = Paint()..color = secondaryTerracotta;
    final path = Path()
      ..moveTo(15, 200)
      ..lineTo(70, 150)
      ..lineTo(125, 200)
      ..close();
    canvas.drawPath(path, roofPaint);
    // window
    canvas.drawRect(const Rect.fromLTWH(55, 215, 30, 30), Paint()..color = lightGreen);

    // Floating Smartphone
    canvas.save();
    // Floating effect
    canvas.translate(size.width - 140, 80 + math.sin(animationValue * 2 * math.pi) * 12); 
    final phoneBg = Paint()..color = Colors.white;
    final phoneShadow = Paint()..color = Colors.black.withOpacity(0.08)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    final phoneRect = RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 110, 200), const Radius.circular(20));
    canvas.drawRRect(phoneRect.shift(const Offset(0, 15)), phoneShadow);
    canvas.drawRRect(phoneRect, phoneBg);
    
    // Phone UI (checklist / progress)
    final uiPaint = Paint()..color = paleGrey;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(15, 25, 80, 50), const Radius.circular(10)), uiPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(15, 90, 80, 12), const Radius.circular(6)), uiPaint);
    
    // Animated progress bar
    final progressPaint = Paint()..color = primaryGreen;
    final progressWidth = 80.0 * (0.2 + 0.8 * ((animationValue * 2) % 1.0)); // Loops twice per animation cycle
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(15, 90, progressWidth, 12), const Radius.circular(6)), progressPaint);
    
    // Checkboxes
    canvas.drawRect(const Rect.fromLTWH(15, 120, 16, 16), Paint()..color = primaryGreen);
    canvas.drawRect(const Rect.fromLTWH(40, 124, 55, 8), uiPaint);
    
    canvas.drawRect(const Rect.fromLTWH(15, 145, 16, 16), uiPaint);
    canvas.drawRect(const Rect.fromLTWH(40, 149, 55, 8), uiPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ConstructionPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}

// ---------------------------------------------------------
// Illustration 2: Expenses & Transparency
// ---------------------------------------------------------
class ExpensesIllustration extends StatefulWidget {
  const ExpensesIllustration({super.key});

  @override
  State<ExpensesIllustration> createState() => _ExpensesIllustrationState();
}

class _ExpensesIllustrationState extends State<ExpensesIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: ExpensesPainter(_controller.value),
        );
      },
    );
  }
}

class ExpensesPainter extends CustomPainter {
  final double animationValue;

  ExpensesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Flat circular background
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 120, Paint()..color = lightGreen);

    // Floating Receipts
    _drawReceipt(canvas, size, Offset(size.width / 2 - 80, size.height / 2 - 40), animationValue, 0.0);
    _drawReceipt(canvas, size, Offset(size.width / 2 + 40, size.height / 2 - 80), animationValue, 0.33);
    _drawReceipt(canvas, size, Offset(size.width / 2 - 20, size.height / 2 + 10), animationValue, 0.66);

    // Main Folder/Wallet at bottom
    final walletPaint = Paint()..color = primaryGreen;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width/2 - 90, size.height - 90, 180, 80), const Radius.circular(16)), walletPaint);
    final walletCover = Paint()..color = const Color(0xFF0C5A46);
    final path = Path()
      ..moveTo(size.width/2 - 90, size.height - 50)
      ..lineTo(size.width/2 + 90, size.height - 90)
      ..lineTo(size.width/2 + 90, size.height - 10)
      ..lineTo(size.width/2 - 90, size.height - 10)
      ..close();
    canvas.drawPath(path, walletCover);
  }

  void _drawReceipt(Canvas canvas, Size size, Offset baseOffset, double time, double offsetTime) {
    canvas.save();
    final localTime = (time + offsetTime) % 1.0;
    // Float up and fade
    final yOffset = -50 * localTime;
    final opacity = math.sin(localTime * math.pi); // Fade in and out
    
    canvas.translate(baseOffset.dx, baseOffset.dy + yOffset);
    
    final receiptBg = Paint()..color = Colors.white.withOpacity(opacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final rect = Rect.fromLTWH(0, 0, 70, 100);
    canvas.drawRect(rect.shift(const Offset(0, 8)), receiptBg);
    canvas.drawRect(rect, Paint()..color = Colors.white.withOpacity(opacity));
    
    // Receipt lines
    final linePaint = Paint()..color = paleGrey.withOpacity(opacity);
    canvas.drawRect(const Rect.fromLTWH(10, 20, 25, 8), linePaint);
    canvas.drawRect(const Rect.fromLTWH(45, 20, 15, 8), Paint()..color = secondaryTerracotta.withOpacity(opacity));
    
    canvas.drawRect(const Rect.fromLTWH(10, 40, 30, 8), linePaint);
    canvas.drawRect(const Rect.fromLTWH(45, 40, 15, 8), Paint()..color = secondaryTerracotta.withOpacity(opacity));
    
    canvas.drawRect(const Rect.fromLTWH(10, 75, 50, 10), Paint()..color = primaryGreen.withOpacity(opacity));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ExpensesPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}

// ---------------------------------------------------------
// Illustration 3: AI Alerts
// ---------------------------------------------------------
class AILlustration extends StatefulWidget {
  const AILlustration({super.key});

  @override
  State<AILlustration> createState() => _AILlustrationState();
}

class _AILlustrationState extends State<AILlustration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: AIPainter(_controller.value),
        );
      },
    );
  }
}

class AIPainter extends CustomPainter {
  final double animationValue;

  AIPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glowing background
    final glowRadius = 100 + 15 * math.sin(animationValue * 2 * math.pi);
    final glowPaint = Paint()
      ..color = lightGreen.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawCircle(Offset(cx, cy), glowRadius, glowPaint);
    canvas.drawCircle(Offset(cx, cy), 85, Paint()..color = paleGrey);

    // AI Sparkles
    _drawSparkle(canvas, Offset(cx - 80, cy - 60), animationValue, 0.0);
    _drawSparkle(canvas, Offset(cx + 90, cy - 30), animationValue, 0.3);
    _drawSparkle(canvas, Offset(cx - 60, cy + 70), animationValue, 0.6);

    // Ringing Bell
    canvas.save();
    canvas.translate(cx, cy);
    // Ring effect: quick shakes then pause
    double ringAngle = 0.0;
    if (animationValue < 0.2) {
      ringAngle = math.sin(animationValue * 50) * 0.15;
    }
    canvas.rotate(ringAngle);

    final bellPaint = Paint()..color = primaryGreen..style = PaintingStyle.fill;
    
    // Bell body
    final path = Path()
      ..moveTo(0, -50)
      ..quadraticBezierTo(45, -50, 45, 15)
      ..lineTo(55, 40)
      ..lineTo(-55, 40)
      ..lineTo(-45, 15)
      ..quadraticBezierTo(-45, -50, 0, -50)
      ..close();
    canvas.drawPath(path, bellPaint);
    
    // Bell top
    canvas.drawCircle(const Offset(0, -50), 10, bellPaint);
    
    // Bell clapper
    final clapperPaint = Paint()..color = secondaryTerracotta;
    canvas.drawCircle(const Offset(0, 50), 12, clapperPaint);

    canvas.restore();

    // Shield overlay
    canvas.save();
    canvas.translate(cx + 40, cy + 30);
    final shieldPaint = Paint()..color = secondaryTerracotta;
    final shieldPath = Path()
      ..moveTo(0, 0)
      ..lineTo(20, -8)
      ..lineTo(40, 0)
      ..lineTo(40, 20)
      ..quadraticBezierTo(20, 45, 0, 55)
      ..quadraticBezierTo(-20, 45, -40, 20)
      ..lineTo(-40, 0)
      ..lineTo(-20, -8)
      ..close();
    // scale shield slightly
    canvas.scale(0.8);
    canvas.drawPath(shieldPath, shieldPaint);
    final checkPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-12, 15), const Offset(-2, 25), checkPaint);
    canvas.drawLine(const Offset(-2, 25), const Offset(15, 0), checkPaint);
    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Offset offset, double time, double offsetTime) {
    final localTime = (time + offsetTime) % 1.0;
    final scale = math.sin(localTime * math.pi); // 0 -> 1 -> 0
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);
    
    final path = Path()
      ..moveTo(0, -20)
      ..quadraticBezierTo(0, 0, 20, 0)
      ..quadraticBezierTo(0, 0, 0, 20)
      ..quadraticBezierTo(0, 0, -20, 0)
      ..quadraticBezierTo(0, 0, 0, -20)
      ..close();
      
    canvas.drawPath(path, Paint()..color = secondaryTerracotta);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AIPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}
