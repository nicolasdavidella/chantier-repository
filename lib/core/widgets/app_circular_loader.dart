import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Widget de chargement circulaire officiel de ChantierTrack
/// Fait tourner le logo de l'application de manière circulaire fluide et élégante.
class AppCircularLoader extends StatefulWidget {
  final double size;
  final String? message;
  final bool isOverlay;

  const AppCircularLoader({
    super.key,
    this.size = 64,
    this.message,
    this.isOverlay = false,
  });

  @override
  State<AppCircularLoader> createState() => _AppCircularLoaderState();
}

class _AppCircularLoaderState extends State<AppCircularLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loaderContent = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Anneau externe en rotation fluide (dégradé vert forêt / émeraude)
            RotationTransition(
              turns: _controller,
              child: Container(
                width: widget.size + 16,
                height: widget.size + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const SweepGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFF81C784),
                      Color(0xFF2E7D32),
                      Color(0xFF1B4D3E),
                    ],
                    stops: [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // Fond blanc intérieur du logo
            Container(
              width: widget.size + 8,
              height: widget.size + 8,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B4D3E).withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Logo officiel ChantierTrack avec rotation continue
            RotationTransition(
              turns: _controller,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.architecture_rounded,
                    size: widget.size * 0.6,
                    color: const Color(0xFF1B4D3E),
                  ),
                ),
              ),
            ),
          ],
        ),

        if (widget.message != null && widget.message!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            widget.message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1B4D3E),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ).animate().fadeIn(duration: 300.ms),
        ],
      ],
    );

    if (widget.isOverlay) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFC8E6C9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4D3E).withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: loaderContent,
      );
    }

    return Center(child: loaderContent);
  }
}

/// Affiche une boîte de dialogue de chargement avec le logo tournant
void showAppLoadingDialog(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (context) => PopScope(
      canPop: false,
      child: Center(
        child: AppCircularLoader(
          size: 72,
          message: message ?? 'Chargement du module...',
          isOverlay: true,
        ),
      ),
    ),
  );
}

/// Ferme la boîte de dialogue de chargement
void hideAppLoadingDialog(BuildContext context) {
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
