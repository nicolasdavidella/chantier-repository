import 'dart:math' as math;
import 'package:flutter/material.dart';

/// L'Orbe holographique animée de NICO IA aux nuances vertes et émeraude
class AuraOrb extends StatefulWidget {
  final double size;
  final bool isListening;

  const AuraOrb({
    super.key,
    this.size = 140,
    this.isListening = false,
  });

  @override
  State<AuraOrb> createState() => _AuraOrbState();
}

class _AuraOrbState extends State<AuraOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
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
        final angle = _controller.value * 2 * math.pi;
        final pulseMultiplier = widget.isListening ? 0.08 : 0.03;
        final pulse = 1.0 + pulseMultiplier * math.sin(angle * 2);

        return Transform.scale(
          scale: pulse,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Halo vert émeraude lumineux
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  blurRadius: widget.size * 0.35,
                  spreadRadius: widget.size * 0.05,
                ),
                // Halo vert forêt subtil
                BoxShadow(
                  color: const Color(0xFF059669).withValues(alpha: 0.25),
                  blurRadius: widget.size * 0.45,
                  spreadRadius: widget.size * 0.03,
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Fond vert forêt profond & obsidienne
                  Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.1, -0.2),
                        radius: 0.9,
                        colors: [
                          Color(0xFF1A3C28),
                          Color(0xFF0F2618),
                          Color(0xFF06150C),
                        ],
                      ),
                    ),
                  ),

                  // 2. Croissant lumineux supérieur (Vert menthe / Émeraude éclatant)
                  Positioned(
                    top: -widget.size * 0.15,
                    left: -widget.size * 0.1,
                    right: -widget.size * 0.1,
                    height: widget.size * 0.65,
                    child: Transform.rotate(
                      angle: math.sin(angle) * 0.2,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(0.0, -0.7),
                            radius: 0.9,
                            colors: [
                              const Color(0xFF34D399),
                              const Color(0xFF059669),
                              Colors.transparent,
                            ],
                            stops: const [0.2, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Croissant lumineux inférieur droit (Doré / Ambre chaud & Vert vif)
                  Positioned(
                    bottom: -widget.size * 0.15,
                    right: -widget.size * 0.15,
                    width: widget.size * 0.85,
                    height: widget.size * 0.85,
                    child: Transform.rotate(
                      angle: -math.cos(angle) * 0.25,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(0.6, 0.6),
                            radius: 0.8,
                            colors: [
                              const Color(0xFFF59E0B),
                              const Color(0xFF10B981),
                              const Color(0xFF047857).withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.1, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 4. Noyau central émeraude profond
                  Center(
                    child: Container(
                      width: widget.size * 0.65,
                      height: widget.size * 0.65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.8,
                          colors: [
                            const Color(0xFF0A1F13).withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 5. Reflet brillant spéculaire sur le dôme
                  Align(
                    alignment: const Alignment(-0.35, -0.4),
                    child: Container(
                      width: widget.size * 0.28,
                      height: widget.size * 0.18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.75),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 6. Contour doux de la sphère
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
