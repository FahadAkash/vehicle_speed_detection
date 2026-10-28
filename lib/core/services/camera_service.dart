import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  final service = CameraService();
  ref.onDispose(() => service.dispose());
  return service;
});

class CameraService {
  CameraController? _controller;
  bool _isInitializing = false;
  CameraDescription? _backCamera;

  CameraController? get controller => _controller;
  bool get isReady => _controller != null && _controller!.value.isInitialized;

  Future<CameraController?> initialize() async {
    if (isReady) return _controller;
    if (_isInitializing) {
      while (_isInitializing) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      return _controller;
    }

    _isInitializing = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('[CameraService] No cameras available on device.');
        return null;
      }

      _backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final newController = CameraController(
        _backCamera!,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await newController.initialize();
      _controller = newController;
      return _controller;
    } catch (e) {
      debugPrint('[CameraService] Failed to initialize camera: $e');
      return null;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> startStream(void Function(CameraImage) onFrame) async {
    if (!isReady || _controller == null) return;
    if (_controller!.value.isStreamingImages) return;
    try {
      await _controller!.startImageStream(onFrame);
    } catch (e) {
      debugPrint('[CameraService] startImageStream error: $e');
    }
  }

  Future<void> stopStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      try {
        await _controller!.stopImageStream();
      } catch (e) {
        debugPrint('[CameraService] stopImageStream error: $e');
      }
    }
  }

  Future<void> dispose() async {
    await stopStream();
    await _controller?.dispose();
    _controller = null;
  }
}

