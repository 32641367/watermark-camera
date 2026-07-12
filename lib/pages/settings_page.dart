import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/watermark_config.dart';

/// 水印设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text('水印设置'),
        backgroundColor: const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<WatermarkConfigModel>(
        builder: (context, model, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 水印内容
              _SectionTitle(title: '水印内容'),
              _SwitchTile(
                icon: Icons.access_time,
                title: '显示时间',
                subtitle: '拍摄时的时间戳',
                value: model.config.showTime,
                onChanged: (v) {
                  model.config.showTime = v;
                  model.save();
                },
              ),
              _SwitchTile(
                icon: Icons.calendar_today,
                title: '显示日期',
                subtitle: '拍摄日期和星期',
                value: model.config.showDate,
                onChanged: (v) {
                  model.config.showDate = v;
                  model.save();
                },
              ),
              _SwitchTile(
                icon: Icons.location_on_outlined,
                title: '显示位置',
                subtitle: '当前城市和区域',
                value: model.config.showLocation,
                onChanged: (v) {
                  model.config.showLocation = v;
                  model.save();
                },
              ),
              _SwitchTile(
                icon: Icons.text_fields,
                title: '自定义文字',
                subtitle: '添加自定义水印文字',
                value: model.config.showCustomText,
                onChanged: (v) {
                  model.config.showCustomText = v;
                  model.save();
                },
              ),
              if (model.config.showCustomText) ...[
                const SizedBox(height: 8),
                _TextFieldTile(
                  controller: TextEditingController(text: model.config.customText),
                  hint: '输入自定义水印文字',
                  onChanged: (v) {
                    model.config.customText = v;
                    model.save();
                  },
                ),
              ],

              const SizedBox(height: 24),

              // 样式设置
              _SectionTitle(title: '样式设置'),
              _SliderTile(
                icon: Icons.format_size,
                title: '字体大小',
                value: model.config.fontSize,
                min: 16,
                max: 48,
                divisions: 32,
                displayValue: '${model.config.fontSize.toInt()}',
                onChanged: (v) {
                  model.config.fontSize = v;
                  model.save();
                },
              ),
              _ColorSelector(
                selectedColor: model.config.color,
                onChanged: (color) {
                  model.config.color = color;
                  model.save();
                },
              ),
              _SliderTile(
                icon: Icons.opacity,
                title: '文字透明度',
                value: model.config.opacity,
                min: 0.2,
                max: 1.0,
                displayValue: '${(model.config.opacity * 100).toInt()}%',
                onChanged: (v) {
                  model.config.opacity = v;
                  model.save();
                },
              ),
              _SwitchTile(
                icon: Icons.crop_square,
                title: '半透明背景',
                subtitle: '文字下方显示暗色背景',
                value: model.config.showBackground,
                onChanged: (v) {
                  model.config.showBackground = v;
                  model.save();
                },
              ),

              const SizedBox(height: 24),

              // 水印位置
              _SectionTitle(title: '水印位置'),
              _PositionSelector(
                selectedPosition: model.config.position,
                onChanged: (pos) {
                  model.config.position = pos;
                  model.save();
                },
              ),

              const SizedBox(height: 24),

              // 时间格式
              _SectionTitle(title: '时间格式'),
              _SwitchTile(
                icon: Icons.schedule,
                title: '24小时制',
                subtitle: model.config.use24HourFormat ? '当前: 14:30:00' : '当前: 02:30:00 PM',
                value: model.config.use24HourFormat,
                onChanged: (v) {
                  model.config.use24HourFormat = v;
                  model.save();
                },
              ),

              const SizedBox(height: 40),

              // 实时预览
              _SectionTitle(title: '水印预览'),
              _WatermarkPreview(config: model.config),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

// ============ 子组件 ============

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade300,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))
            : null,
        value: value,
        activeColor: Colors.blue,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
              const Spacer(),
              Text(
                displayValue,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.white.withOpacity(0.15),
              thumbColor: Colors.blue,
              overlayColor: Colors.blue.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSelector extends StatelessWidget {
  final WatermarkColor selectedColor;
  final ValueChanged<WatermarkColor> onChanged;

  const _ColorSelector({
    required this.selectedColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.palette_outlined, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          const Text('文字颜色', style: TextStyle(color: Colors.white, fontSize: 15)),
          const Spacer(),
          ...WatermarkColor.values.map((color) {
            final isSelected = color == selectedColor;
            return GestureDetector(
              onTap: () => onChanged(color),
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: color.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.white24,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.color.withOpacity(0.5), blurRadius: 6)]
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PositionSelector extends StatelessWidget {
  final WatermarkPosition selectedPosition;
  final ValueChanged<WatermarkPosition> onChanged;

  const _PositionSelector({
    required this.selectedPosition,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: WatermarkPosition.values.map((pos) {
          final isSelected = pos == selectedPosition;
          return GestureDetector(
            onTap: () => onChanged(pos),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.transparent,
                ),
              ),
              child: Text(
                pos.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TextFieldTile extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _TextFieldTile({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<_TextFieldTile> createState() => _TextFieldTileState();
}

class _TextFieldTileState extends State<_TextFieldTile> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      widget.onChanged(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: widget.controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: const Icon(Icons.edit, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}

class _WatermarkPreview extends StatelessWidget {
  final WatermarkConfig config;

  const _WatermarkPreview({required this.config});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    List<String> lines = [];

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
      lines.add(
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${weekdays[now.weekday - 1]}');
    }

    if (config.showLocation) lines.add('北京市 · 朝阳区');
    if (config.showCustomText && config.customText.isNotEmpty) lines.add(config.customText);

    if (lines.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('请至少开启一项水印内容', style: TextStyle(color: Colors.white38)),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/preview_bg.jpg'),
          fit: BoxFit.cover,
          opacity: 0.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: lines.map((line) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              line,
              style: TextStyle(
                color: config.color.color.withOpacity(config.opacity),
                fontSize: config.fontSize * 0.6,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
