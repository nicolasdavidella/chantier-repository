import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';

class AnimatedStarRating extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;
  final double starSize;
  final bool readOnly;

  const AnimatedStarRating({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.starSize = 36.0,
    this.readOnly = false,
  });

  @override
  State<AnimatedStarRating> createState() => _AnimatedStarRatingState();
}

class _AnimatedStarRatingState extends State<AnimatedStarRating> {
  late int _rating;
  int _lastTappedIndex = -1;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isSelected = index < _rating;
        final isTapped = index == _lastTappedIndex;
        
        Widget star = Icon(
          isSelected ? Icons.star : Icons.star_border,
          color: isSelected ? Colors.amber : Colors.grey.shade400,
          size: widget.starSize,
        );

        if (isTapped && !widget.readOnly) {
          star = star
              .animate(key: ValueKey('$_rating-$index'))
              .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 150.ms, curve: Curves.easeOut)
              .then()
              .scale(begin: const Offset(1.3, 1.3), end: const Offset(1, 1), duration: 150.ms, curve: Curves.elasticOut);
        }

        return GestureDetector(
          onTap: widget.readOnly
              ? null
              : () {
                  setState(() {
                    _rating = index + 1;
                    _lastTappedIndex = index;
                  });
                  widget.onRatingChanged(_rating);
                },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: star,
          ),
        );
      }),
    );
  }
}
