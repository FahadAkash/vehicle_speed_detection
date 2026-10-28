import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

enum MapLayerType {
  openStreetMap('রাস্তা মানচিত্র / OpenStreetMap'),
  esriSatellite('স্যাটেলাইট ছবি / Satellite'),
  cartoVoyager('ল্যান্ডমার্ক / Detailed Landmarks');

  const MapLayerType(this.label);
  final String label;
}

class SatelliteMapLayerWidget extends StatelessWidget {
  const SatelliteMapLayerWidget({
    required this.layerType,
    super.key,
  });

  final MapLayerType layerType;

  @override
  Widget build(BuildContext context) {
    switch (layerType) {
      case MapLayerType.openStreetMap:
        return TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.vehicle_speed_estimator',
          maxZoom: 19,
          maxNativeZoom: 19,
        );
      case MapLayerType.esriSatellite:
        return TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.example.vehicle_speed_estimator',
          maxZoom: 18,
          maxNativeZoom: 18,
        );
      case MapLayerType.cartoVoyager:
        return TileLayer(
          urlTemplate:
              'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.vehicle_speed_estimator',
          maxZoom: 19,
          maxNativeZoom: 19,
        );
    }
  }
}
