import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Carte animée d'attente de modélisation 3D reproduisant fidèlement l'effet de matrice
/// de points ondulante (style ChatGPT DALL-E) avec compteur de progression en pourcentage.
class AiGenerationMatrixCard extends StatefulWidget {
  final String title;

  const AiGenerationMatrixCard({
    super.key,
    this.title = 'Votre idée prend forme...',
  });

  @override
  State<AiGenerationMatrixCard> createState() => _AiGenerationMatrixCardState();
}

class _AiGenerationMatrixCardState extends State<AiGenerationMatrixCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  Timer? _progressTimer;
  int _progressPercent = 12;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Progression graduelle et réaliste du pourcentage (style DALL-E)
    _progressTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progressPercent < 85) {
          _progressPercent += math.Random().nextInt(6) + 3;
        } else if (_progressPercent < 98) {
          _progressPercent += 1;
        }
      });
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC8E6C9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4D3E).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre élégant au-dessus de la matrice
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.3, 1.3),
                    duration: 900.ms,
                  ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFF1B4D3E),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Cadre contenant la matrice de points animée + Badge de pourcentage
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Matrice de points ondulante CustomPaint
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _DotMatrixWavePainter(
                          animationValue: _waveController.value,
                        ),
                      );
                    },
                  ),
                ),

                // Badge de progression (ex: "18 %") en bas à droite
                Positioned(
                  bottom: 12,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF81C784).withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B4D3E).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$_progressPercent %',
                      style: const TextStyle(
                        color: Color(0xFF1B4D3E),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);
  }
}

/// Painter reproduisant la matrice de points avec vague diagonale lumineuse
class _DotMatrixWavePainter extends CustomPainter {
  final double animationValue;

  _DotMatrixWavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    const int cols = 15;
    const int rows = 18;

    final double stepX = size.width / (cols + 1);
    final double stepY = size.height / (rows + 1);

    final Paint dotPaint = Paint()..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final double x = stepX * (c + 1);
        final double y = stepY * (r + 1);

        // Position normalisée pour propager une vague diagonale (haut-gauche -> bas-droite)
        final double diagPos = (c.toDouble() / cols * 0.5) + (r.toDouble() / rows * 0.5);
        final double wave = (diagPos - animationValue) % 1.0;
        final double distFromWave = (wave < 0 ? wave + 1.0 : wave);

        // Calcul de l'intensité de lumière du point
        double intensity;
        if (distFromWave < 0.25) {
          intensity = math.sin((distFromWave / 0.25) * math.pi);
        } else {
          intensity = 0.0;
        }

        // Rayon et couleur du point
        final double radius = 1.8 + (intensity * 2.2);

        if (intensity > 0.05) {
          // Point illuminé en vert émeraude / cyan lumineux
          dotPaint.color = Color.lerp(
            const Color(0xFF81C784).withValues(alpha: 0.35),
            const Color(0xFF10B981),
            intensity,
          )!
              .withValues(alpha: 0.3 + (intensity * 0.7));
        } else {
          // Point au repos (vert sauge très doux)
          dotPaint.color = const Color(0xFF64748B).withValues(alpha: 0.18);
        }

        canvas.drawCircle(Offset(x, y), radius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotMatrixWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
