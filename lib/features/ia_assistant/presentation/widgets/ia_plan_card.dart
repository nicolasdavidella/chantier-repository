import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class IaPlanCard extends StatefulWidget {
  final Map<String, dynamic> plan;
  final VoidCallback onValider;

  const IaPlanCard({
    Key? key,
    required this.plan,
    required this.onValider,
  }) : super(key: key);

  @override
  State<IaPlanCard> createState() => _IaPlanCardState();
}

class _IaPlanCardState extends State<IaPlanCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nom = widget.plan['nom'] ?? 'Plan Variante';
    final surface = widget.plan['surfaceHabitable'] ?? 0;
    final budget = widget.plan['estimationBudget'] ?? 0;
    final pointsForts = widget.plan['pointsForts'] as List<dynamic>? ?? [];
    final pieces = widget.plan['pieces'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            width: double.infinity,
            child: Column(
              children: [
                Text(nom, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('$surface m² - $budget FCFA', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Esquisse indicative, ne remplace pas un plan d\'architecte.', 
                    style: TextStyle(color: AppColors.warning, fontSize: 12, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  
                  // Plan Drawing
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        color: Colors.grey[50],
                      ),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _PlanPainter(pieces: pieces, progress: _controller.value),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  if (pointsForts.isNotEmpty)
                    Text('Points forts: ${pointsForts.join(", ")}', 
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Valider cette coquille',
                      onPressed: widget.onValider,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _PlanPainter extends CustomPainter {
  final List<dynamic> pieces;
  final double progress;

  _PlanPainter({required this.pieces, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (pieces.isEmpty) return;

    // Simple grid layout logic based on positionX, positionY, width, height
    // To make it fit the canvas, we need to find max X and Y
    int maxX = 1;
    int maxY = 1;
    for (var p in pieces) {
      int px = (p['positionX'] is num) ? (p['positionX'] as num).toInt() : 0;
      int py = (p['positionY'] is num) ? (p['positionY'] as num).toInt() : 0;
      int pw = (p['width'] is num) ? (p['width'] as num).toInt() : 1;
      int ph = (p['height'] is num) ? (p['height'] as num).toInt() : 1;
      if (px + pw > maxX) maxX = px + pw;
      if (py + ph > maxY) maxY = py + ph;
    }

    double cellWidth = size.width / maxX;
    double cellHeight = size.height / maxY;

    final paintLine = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < pieces.length; i++) {
      // Cascade animation based on index
      double start = (i / pieces.length) * 0.5;
      double end = start + 0.5;
      double itemProgress = (progress - start) / (end - start);
      itemProgress = itemProgress.clamp(0.0, 1.0);
      
      if (itemProgress == 0) continue;

      var p = pieces[i];
      int px = (p['positionX'] is num) ? (p['positionX'] as num).toInt() : 0;
      int py = (p['positionY'] is num) ? (p['positionY'] as num).toInt() : 0;
      int pw = (p['width'] is num) ? (p['width'] as num).toInt() : 1;
      int ph = (p['height'] is num) ? (p['height'] as num).toInt() : 1;
      String nom = p['nom'] ?? '';
      var surf = p['surface'] ?? 0;

      Rect rect = Rect.fromLTWH(
        px * cellWidth, 
        py * cellHeight, 
        pw * cellWidth * itemProgress, 
        ph * cellHeight * itemProgress
      );

      // Fill
      final paintFill = Paint()
        ..color = _getColorForRoom(nom).withValues(alpha: 0.5 * itemProgress)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(rect, paintFill);
      canvas.drawRect(rect, paintLine);

      if (itemProgress > 0.8) {
        textPainter.text = TextSpan(
          text: '$nom\n$surf m²',
          style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
        );
        textPainter.textAlign = TextAlign.center;
        textPainter.layout(minWidth: 0, maxWidth: rect.width);
        
        final offset = Offset(
          rect.left + (rect.width - textPainter.width) / 2,
          rect.top + (rect.height - textPainter.height) / 2,
        );
        textPainter.paint(canvas, offset);
      }
    }
  }

  Color _getColorForRoom(String name) {
    name = name.toLowerCase();
    if (name.contains('séjour') || name.contains('salon')) return Colors.blue[200]!;
    if (name.contains('chambre')) return Colors.orange[200]!;
    if (name.contains('bain') || name.contains('eau') || name.contains('wc')) return Colors.cyan[200]!;
    if (name.contains('cuisine')) return Colors.yellow[200]!;
    return Colors.grey[300]!;
  }

  @override
  bool shouldRepaint(covariant _PlanPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
