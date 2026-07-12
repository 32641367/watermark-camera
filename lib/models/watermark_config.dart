import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 水印位置
enum WatermarkPosition {
  topLeft('左上角'),
  topRight('右上角'),
  bottomLeft('左下角'),
  bottomRight('右下角'),
  center('居中');

  final String label;
  const WatermarkPosition(this.label);
}

/// 水印颜色
enum WatermarkColor {
  white('白色', Colors.white),
  black('黑色', Colors.black),
  yellow('黄色', Colors.amber),
  orange('橙色', Colors.orange),
  blue('蓝色', Colors.lightBlue);

  final String label;
  final Color color;
  const WatermarkColor(this.label, this.color);
}

/// 水印配置模型
class WatermarkConfig {
  // 显示开关
  bool showTime;
  bool showDate;
  bool showLocation;
  bool showCustomText;

  // 自定义文字
  String customText;

  // 水印位置
  WatermarkPosition position;

  // 样式
  double fontSize;
  WatermarkColor color;
  double opacity;
  bool showBackground;
  double backgroundOpacity;

  // 时间格式
  bool use24HourFormat;

  WatermarkConfig({
    this.showTime = true,
    this.showDate = true,
    this.showLocation = true,
    this.showCustomText = false,
    this.customText = '',
    this.position = WatermarkPosition.bottomRight,
    this.fontSize = 28.0,
    this.color = WatermarkColor.white,
    this.opacity = 0.85,
    this.showBackground = true,
    this.backgroundOpacity = 0.4,
    this.use24HourFormat = true,
  });

  Map<String, dynamic> toJson() => {
        'showTime': showTime,
        'showDate': showDate,
        'showLocation': showLocation,
        'showCustomText': showCustomText,
        'customText': customText,
        'position': position.index,
        'fontSize': fontSize,
        'color': color.index,
        'opacity': opacity,
        'showBackground': showBackground,
        'backgroundOpacity': backgroundOpacity,
        'use24HourFormat': use24HourFormat,
      };

  factory WatermarkConfig.fromJson(Map<String, dynamic> json) {
    return WatermarkConfig(
      showTime: json['showTime'] ?? true,
      showDate: json['showDate'] ?? true,
      showLocation: json['showLocation'] ?? true,
      showCustomText: json['showCustomText'] ?? false,
      customText: json['customText'] ?? '',
      position: WatermarkPosition.values[json['position'] ?? 3],
      fontSize: (json['fontSize'] ?? 28).toDouble(),
      color: WatermarkColor.values[json['color'] ?? 0],
      opacity: (json['opacity'] ?? 0.85).toDouble(),
      showBackground: json['showBackground'] ?? true,
      backgroundOpacity: (json['backgroundOpacity'] ?? 0.4).toDouble(),
      use24HourFormat: json['use24HourFormat'] ?? true,
    );
  }
}

/// 配置管理（Provider）
class WatermarkConfigModel extends ChangeNotifier {
  WatermarkConfig _config = WatermarkConfig();
  WatermarkConfig get config => _config;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('watermark_config');
    if (jsonStr != null) {
      _config = WatermarkConfig.fromJson(jsonDecode(jsonStr));
      notifyListeners();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('watermark_config', jsonEncode(_config.toJson()));
    notifyListeners();
  }

  void updateConfig(WatermarkConfig newConfig) {
    _config = newConfig;
    save();
  }
}
