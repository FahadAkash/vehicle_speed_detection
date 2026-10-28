import 'package:flutter/material.dart';

/// Draggable gate endpoint handle.
/// 20 dp visual circle, 48 dp hit area, color + outline.
/// Reference: AGENT.md Section 11.
class GateHandle extends StatelessWidget {
  const GateHandle({super.key, required this.color, required this.onPanUpdate});

  final Color color;
  final ValueChanged<Offset> onPanUpdate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) => onPanUpdate(details.delta),
      child: Container(
        width: 48.0,
        height: 48.0,
        alignment: Alignment.center,
        color: Colors.transparent, // Expands hit test area
        child: Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 4.0,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
