import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/watermark_config.dart';

/// 水印渲染引擎 - 使用 Flutter Canvas 绘制水印
class WatermarkRenderer {
  final WatermarkConfig config;

  WatermarkRenderer(this.config);

  /// 获取当前位置描述
  Future<String?> getLocationText() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        List<String> parts = [];
        if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
        if (p.subLocality != null && p.subLocality!.isNotEmpty) parts.add(p.subLocality!);
        if (parts.isEmpty && p.name != null) parts.add(p.name!);
        return parts.isEmpty ? null : parts.join(' · ');
      }
    } catch (_) {}
    return null;
  }

  /// 构建水印文本行
  List<String> buildWatermarkLines({String? locationText}) {
    List<String> lines = [];
    final now = DateTime.now();

    if (config.showTime) {
      final hour = config.use24HourFormat
          ? now.hour.toString().padLeft(2, '0')
          : (now.hour > 12 ? now.hour - 12 : now.hour).toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');
      final second = now.second.toString().padLeft(2, '0');
      final ampm = config.use24HourFormat ? '' : (now.hour >= 12 ? ' PM' : ' AM');
      lines.add('$hour:$minute:$second$ampm');
    }

    if (config.showDate) {
      final weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      lines.add('$dateStr ${weekdays[now.weekday - 1]}');
    }

    if (config.showLocation && locationText != null && locationText.isNotEmpty) {
      lines.add(locationText);
    }

    if (config.showCustomText && config.customText.isNotEmpty) {
      lines.add(config.customText);
    }

    return lines;
  }

  /// 使用 Canvas 在图片上添加水印（效果最好）
  Future<File> addWatermarkToImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final locationText = config.showLocation ? await getLocationText() : null;
    final lines = buildWatermarkLines(locationText: locationText);

    if (lines.isEmpty) return imageFile;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));

    // 绘制原图
    canvas.drawImage(image, Offset.zero, Paint());

    // 构建文本样式
    final textStyle = TextStyle(
      color: config.color.color.withOpacity(config.opacity),
      fontSize: config.fontSize,
      fontWeight: FontWeight.bold,
      fontFamily: 'PingFang SC',
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 2,
          offset: const Offset(1, 1),
        ),
      ],
    );

    final fullText = lines.join('\n');

    // 使用 TextPainter 测量和绘制
    final textPainter = TextPainter(
      text: TextSpan(text: fullText, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: _getTextAlign(),
    );

    textPainter.layout(maxWidth: image.width.toDouble() * 0.85);

    final padding = 16.0;
    final bgWidth = textPainter.width + padding * 2;
    final bgHeight = textPainter.height + padding * 2;

    // 计算位置
    final margin = 24.0;
    double x, y;
    switch (config.position) {
      case WatermarkPosition.topLeft:
        x = margin;
        y = margin + 44;
        break;
      case WatermarkPosition.topRight:
        x = image.width - bgWidth - margin;
        y = margin + 44;
        break;
      case WatermarkPosition.bottomLeft:
        x = margin;
        y = image.height - bgHeight - margin - 80;
        break;
      case WatermarkPosition.bottomRight:
        x = image.width - bgWidth - margin;
        y = image.height - bgHeight - margin - 80;
        break;
      case WatermarkPosition.center:
        x = (image.width - bgWidth) / 2;
        y = (image.height - bgHeight) / 2;
        break;
    }

    // 绘制半透明背景
    if (config.showBackground) {
      final bgPaint = Paint()
        ..color = Colors.black.withOpacity(config.backgroundOpacity)
        ..style = PaintingStyle.fill;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, bgWidth, bgHeight),
        const Radius.circular(10),
      );
      canvas.drawRRect(rrect, bgPaint);
    }

    // 绘制文字
    textPainter.paint(canvas, Offset(x + padding, y + padding));

    // 生成图片
    final picture = recorder.endRecording();
    final resultImage = await picture.toImage(image.width, image.height);
    final pngBytes = await resultImage.toByteData(format: ui.ImageByteFormat.png);
    final pngData = pngBytes!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/watermarked_${DateTime.now().millisecondsSinceEpoch}.png';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(pngData);
    return outputFile;
  }

  TextAlign _getTextAlign() {
    switch (config.position) {
      case WatermarkPosition.topLeft:
      case WatermarkPosition.bottomLeft:
        return TextAlign.left;
      case WatermarkPosition.topRight:
      case WatermarkPosition.bottomRight:
        return TextAlign.right;
      case WatermarkPosition.center:
        return TextAlign.center;
    }
  }
}
