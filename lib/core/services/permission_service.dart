import 'package:permission_handler/permission_handler.dart';

/// Manages runtime permissions with rationale tracking.
/// Reference: AGENT.md Section 6.5.
class PermissionService {
  Future<bool> checkCameraPermission() async {
    return (await Permission.camera.status).isGranted;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> isCameraPermanentlyDenied() async {
    return (await Permission.camera.status).isPermanentlyDenied;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
