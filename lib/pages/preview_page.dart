import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// 照片预览页面 - 预览、保存、分享
class PreviewPage extends StatelessWidget {
  final File imageFile;

  const PreviewPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 全屏预览图片
          Positioned.fill(
            child: InteractiveViewer(
              child: Center(
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                ),
              ),
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
                color: Colors.black.withOpacity(0.4),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      '照片预览',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text(
                        '完成',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 底部操作栏
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 100,
                color: Colors.black.withOpacity(0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 重拍
                    _ActionButton(
                      icon: Icons.replay_rounded,
                      label: '重拍',
                      onTap: () => Navigator.pop(context),
                    ),
                    // 保存
                    _ActionButton(
                      icon: Icons.save_alt_rounded,
                      label: '保存',
                      onTap: () => _saveToGallery(context),
                    ),
                    // 分享
                    _ActionButton(
                      icon: Icons.share_rounded,
                      label: '分享',
                      onTap: () => _share(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToGallery(BuildContext context) async {
    // iOS 相册权限
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (context.mounted) {
        _showSnackBar(context, '需要相册权限才能保存照片');
      }
      return;
    }

    try {
      final result = await ImageGallerySaver.saveFile(
        imageFile.path,
        name: 'watermark_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (context.mounted) {
        if (result != null && result['isSuccess'] == true) {
          _showSuccessDialog(context);
        } else {
          _showSnackBar(context, '保存失败，请重试');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, '保存失败: $e');
      }
    }
  }

  Future<void> _share(BuildContext context) async {
    try {
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: '水印相机拍摄',
      );
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, '分享失败');
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 56),
            SizedBox(height: 16),
            Text(
              '已保存到相册',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// 底部操作按钮
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
