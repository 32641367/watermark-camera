import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../models/watermark_config.dart';
import '../services/watermark_renderer.dart';
import 'preview_page.dart';

/// 相机拍照页面
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isTakingPhoto = false;
  int _currentCameraIndex = 0;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) return;

      _controller = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _controller?.dispose();

    _controller = CameraController(
      _cameras![_currentCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPhoto) return;

    setState(() => _isTakingPhoto = true);

    try {
      final XFile photo = await _controller!.takePicture();
      final imageFile = File(photo.path);

      if (!mounted) return;

      // 加载配置并渲染水印
      final config = context.read<WatermarkConfigModel>().config;
      final renderer = WatermarkRenderer(config);
      final watermarkedFile = await renderer.addWatermarkToImage(imageFile);

      if (!mounted) return;

      setState(() => _isTakingPhoto = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewPage(imageFile: watermarkedFile),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isTakingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 相机预览
          if (_isInitialized && _controller != null)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // 水印预览
          Positioned(
            right: 20,
            bottom: 140,
            child: Consumer<WatermarkConfigModel>(
              builder: (context, model, _) {
                return _buildWatermarkPreview(model.config);
              },
            ),
          ),

          // 顶部栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 56,
                color: Colors.black.withOpacity(0.3),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    // 闪光灯按钮
                    if (_cameras != null && _currentCameraIndex == 0)
                      IconButton(
                        icon: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: _isFlashOn ? Colors.amber : Colors.white,
                        ),
                        onPressed: () {
                          setState(() => _isFlashOn = !_isFlashOn);
                        },
                      ),
                    // 设置按钮
                    IconButton(
                      icon: const Icon(Icons.tune, color: Colors.white),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 底部拍照栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 110,
                color: Colors.black.withOpacity(0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 切换摄像头
                    IconButton(
                      icon: const Icon(
                        Icons.flip_camera_android_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _switchCamera,
                    ),
                    const SizedBox(width: 40),
                    // 快门按钮
                    GestureDetector(
                      onTap: _takePhoto,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                          color: _isTakingPhoto ? Colors.white38 : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 72),
                  ],
                ),
              ),
            ),
          ),

          // 拍照闪光动画
          if (_isTakingPhoto)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _isTakingPhoto ? 0.7 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWatermarkPreview(WatermarkConfig config) {
    final renderer = WatermarkRenderer(config);
    final lines = renderer.buildWatermarkLines(locationText: '📍 定位中...');

    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '水印预览',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          ...lines.map((line) => Text(
                line,
                style: TextStyle(
                  color: config.color.color.withOpacity(config.opacity),
                  fontSize: config.fontSize * 0.5,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 1,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
