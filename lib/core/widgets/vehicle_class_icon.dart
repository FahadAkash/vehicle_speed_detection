import 'package:flutter/material.dart';
import 'package:vehicle_speed_estimator/core/constants/vehicle_classes.dart';

/// Semantic vehicle class glyph mapper.
/// Reference: AGENT.md Section 7.7 & Section 11.
class VehicleClassIcon extends StatelessWidget {
  const VehicleClassIcon({
    super.key,
    required this.vehicleClass,
    this.size = 24.0,
    this.color,
  });

  final VehicleClass vehicleClass;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconData = switch (vehicleClass) {
      VehicleClass.car => Icons.directions_car_rounded,
      VehicleClass.bus => Icons.directions_bus_rounded,
      VehicleClass.truck => Icons.local_shipping_rounded,
      VehicleClass.cng => Icons.electric_rickshaw_rounded,
      VehicleClass.motorcycle => Icons.two_wheeler_rounded,
      VehicleClass.leguna => Icons.airport_shuttle_rounded,
    };

    return Semantics(
      label: vehicleClass.banglaLabel,
      child: Icon(iconData, size: size, color: color),
    );
  }
}
