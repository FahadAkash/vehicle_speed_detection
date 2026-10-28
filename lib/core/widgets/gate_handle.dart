import 'package:flutter/material.dart';

/// Draggable gate endpoint handle with 48 dp hit area and 24 dp high-contrast disc.
/// Reference: AGENT.md Section 9.4 & Section 11.
class GateHandle extends StatelessWidget {
  const GateHandle({
    required this.color,
    required this.onPanUpdate,
    this.label,
    super.key,
  });

  final Color color;
  final ValueChanged<Offset> onPanUpdate;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) => onPanUpdate(details.delta),
      child: Container(
        width: 48.0,
        height: 48.0,
        alignment: Alignment.center,
        child: Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 4.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 6.0,
              height: 6.0,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
