# 水印相机 - Flutter 版

基于 Flutter 的跨平台水印相机应用，支持 iOS 和 Android。

## 功能特性

- 📸 **相机拍照** - 支持前后摄像头切换
- ⏰ **时间水印** - 自动添加拍摄时间
- 📅 **日期水印** - 自动添加日期和星期
- 📍 **位置水印** - 自动获取 GPS 地理位置
- ✏️ **自定义文字** - 支持自定义水印内容
- 🎨 **样式设置** - 颜色、大小、透明度、位置均可调
- 💾 **保存分享** - 一键保存到相册，支持系统分享

## 开发环境搭建（Windows）

### 1. 安装 Flutter

```bash
# 下载 Flutter SDK
# https://docs.flutter.dev/get-started/install/windows

# 解压到 C:\flutter
# 添加环境变量 C:\flutter\bin

# 验证安装
flutter doctor
```

### 2. 安装依赖

```bash
cd watermark_camera
flutter pub get
```

### 3. 本地运行（Android / Windows 调试）

```bash
# Android 模拟器或真机
flutter run

# Windows 桌面（功能有限，相机不可用）
flutter run -d windows
```

> **注意**：Windows 上无法直接编译 iOS，需要通过 Codemagic 云端编译。

## 📱 安装到 iPhone（Windows 用户）

### 前提准备
1. 注册 [GitHub](https://github.com) 账号
2. 注册 [Codemagic](https://codemagic.io) 账号（用 GitHub 登录）
3. 准备一个 Apple ID（免费）

### 步骤一：推送到 GitHub

```bash
cd watermark_camera
git init
git add .
git commit -m "水印相机初始版本"
git remote add origin https://github.com/你的用户名/watermark_camera.git
git push -u origin main
```

### 步骤二：Codemagic 配置

1. 打开 https://codemagic.io
2. 点击 **Add application** → 选择你的 GitHub 仓库
3. 选择 **Flutter App** 项目类型
4. 在 **iOS code signing** 中选择 **Automatic**

### 步骤三：首次编译

1. 点击 **Start new build**
2. 选择 **iOS** 平台
3. 等待编译完成（约 10-15 分钟）
4. 编译成功后，会生成下载链接和二维码
5. 用 iPhone 扫码下载安装

### 步骤四：信任证书（首次安装）

安装后如果打不开，需要信任开发者证书：
1. iPhone 打开 **设置 → 通用 → VPN与设备管理**
2. 找到你的 Apple ID 对应的开发者证书
3. 点击 **信任**

> **注意**：免费 Apple ID 签名的 App 有效期为 7 天，到期后需重新编译安装。

## 项目结构

```
watermark_camera/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── models/
│   │   └── watermark_config.dart    # 水印配置模型
│   ├── pages/
│   │   ├── home_page.dart           # 主页
│   │   ├── camera_page.dart         # 相机拍照页
│   │   ├── preview_page.dart        # 照片预览页
│   │   └── settings_page.dart       # 水印设置页
│   └── services/
│       └── watermark_renderer.dart  # 水印渲染引擎
├── ios/
│   └── Runner/
│       └── Info.plist               # iOS 权限配置
├── pubspec.yaml                     # 依赖配置
└── codemagic.yaml                   # 云端编译配置
```

## 依赖库

| 库 | 用途 |
|----|------|
| camera | 相机控制 |
| permission_handler | 权限管理 |
| geolocator / geocoding | GPS 定位 |
| image_gallery_saver | 保存到相册 |
| share_plus | 系统分享 |
| provider | 状态管理 |
| shared_preferences | 配置持久化 |
