import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Fullscreen camera preview fitting landscape display smoothly.
class LiveCameraPreview extends StatelessWidget {
  const LiveCameraPreview({
    required this.controller,
    super.key,
  });

  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container(
        color: const Color(0xFF0A1020),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white70),
              SizedBox(height: 16),
              Text(
                'ক্যামেরা চালু হচ্ছে... / Initializing camera...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final previewSize = controller!.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller!);
    }

    // In landscape mode on Android, previewSize.width is the long side (e.g. 1920)
    // and previewSize.height is the short side (e.g. 1080).
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final aspect = isLandscape
        ? previewSize.width / previewSize.height
        : previewSize.height / previewSize.width;

    return RepaintBoundary(
      child: SizedBox.expand(
        child: ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: isLandscape ? previewSize.width : previewSize.height,
              height: isLandscape ? previewSize.height : previewSize.width,
              child: AspectRatio(
                aspectRatio: aspect,
                child: CameraPreview(controller!),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

