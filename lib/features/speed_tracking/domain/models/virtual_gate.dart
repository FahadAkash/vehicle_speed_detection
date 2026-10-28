import 'package:vehicle_speed_estimator/core/utils/geometry_utils.dart';

/// Represents a virtual timing gate in normalized camera coordinates (0.0 to 1.0).
/// Reference: AGENT.md Section 1 & Section 5 Rule 5.
class VirtualGate {
  const VirtualGate({required this.name, required this.p1, required this.p2});

  final String name;
  final Vec2 p1;
  final Vec2 p2;

  /// Automatically generates midpoint Gate M between Gate A and Gate B.
  /// Formula: GateM.p1 = (GateA.p1 + GateB.p1) / 2, GateM.p2 = (GateA.p2 + GateB.p2) / 2.
  static VirtualGate generateMidpointGate(
    VirtualGate gateA,
    VirtualGate gateB,
  ) {
    final m1 = Vec2(
      (gateA.p1.x + gateB.p1.x) / 2.0,
      (gateA.p1.y + gateB.p1.y) / 2.0,
    );
    final m2 = Vec2(
      (gateA.p2.x + gateB.p2.x) / 2.0,
      (gateA.p2.y + gateB.p2.y) / 2.0,
    );
    return VirtualGate(name: 'Gate M', p1: m1, p2: m2);
  }

  VirtualGate copyWith({String? name, Vec2? p1, Vec2? p2}) {
    return VirtualGate(
      name: name ?? this.name,
      p1: p1 ?? this.p1,
      p2: p2 ?? this.p2,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VirtualGate &&
          other.name == name &&
          other.p1 == p1 &&
          other.p2 == p2);

  @override
  int get hashCode => Object.hash(name, p1, p2);

  @override
  String toString() => 'VirtualGate($name, p1: $p1, p2: $p2)';
}
