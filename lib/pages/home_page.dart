import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/watermark_config.dart';
import 'camera_page.dart';
import 'settings_page.dart';

/// 主页面 - 水印相机入口
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D26),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            // 图标
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // 标题
            const Text(
              '水印相机',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '拍照自动添加时间、地点水印',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 40),
            // 特性列表
            _buildFeatureItem(Icons.access_time, '自动添加当前时间和日期'),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.location_on_outlined, '自动获取地理位置信息'),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.text_fields, '支持自定义文字水印'),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.palette_outlined, '多种水印样式可调节'),
            const Spacer(flex: 1),
            // 打开相机按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _openCamera(context),
                  icon: const Icon(Icons.camera_alt_rounded, size: 24),
                  label: const Text(
                    '打开相机',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 设置按钮
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              icon: Icon(Icons.settings_outlined, color: Colors.white.withOpacity(0.7)),
              label: Text(
                '水印设置',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  void _openCamera(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CameraPage()),
        );
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('需要相机权限'),
            content: const Text('请在设置中允许水印相机访问您的相机'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  openAppSettings();
                },
                child: const Text('去设置'),
              ),
            ],
          ),
        );
      }
    }
  }
}
