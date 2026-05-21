<br/><br/><p align="center">
<img src="assets/icon/pho_icon.png" width="150">
</p>
<h3 align="center">
Pho - 一个用于查看和上传照片的无服务端应用
</h3>
<p align="center">
  <img src="https://github.com/fregie/pho/actions/workflows/go_test.yml/badge.svg">
</p>
<p align="center">
  <a href="README.md">中文</a> | <a href="README_EN.md">English</a>
</p>

### 安装
[下载apk](https://github.com/fregie/pho/releases) 

[Google Play](https://play.google.com/store/apps/details?id=com.fregie.pho)  

[App store](https://apps.apple.com/cn/app/pho-%E5%90%8C%E6%AD%A5%E7%85%A7%E7%89%87%E5%88%B0nas-%E7%BD%91%E7%9B%98/id6451428709)

> 注: Google Play和App store的版本包含专业版功能,专业版功能未开源.

### 本地环境
PS D:\1_project\full\pho> fvm flutter doctor -v
Flutter assets will be downloaded from https://storage.flutter-io.cn. Make sure you trust this source!
[✓] Flutter (Channel stable, 3.7.12, on Microsoft Windows [版本 10.0.19045.6456], locale zh-CN)
• Flutter version 3.7.12 on channel stable at C:\Users\admin\fvm\versions\3.7.12
• Upstream repository https://github.com/flutter/flutter.git
• Framework revision 4d9e56e694 (3 years, 1 month ago), 2023-04-17 21:47:46 -0400
• Engine revision 1a65d409c7
• Dart version 2.19.6
• DevTools version 2.20.1
• Pub download mirror https://pub.flutter-io.cn
• Flutter download mirror https://storage.flutter-io.cn

[✗] Windows Version (Unable to confirm if installed Windows version is 10 or greater)

Checking Android licenses is taking an unexpectedly long time...[✓] Android toolchain - develop for Android devices (Android SDK version 36.1.0)
• Android SDK at C:\Users\admin\AppData\Local\Android\Sdk
• Platform android-36, build-tools 36.1.0
• Java binary at: C:\BasicEnv\Java\openJDK\jdk-17.0.2\bin\java
• Java version OpenJDK Runtime Environment (build 17.0.2+8-86)
• All Android licenses accepted.

[✓] Chrome - develop for the web
• Chrome at C:\Program Files\Google\Chrome\Application\chrome.exe

[✓] Visual Studio - develop for Windows (Visual Studio Community 2022 17.13.2)
• Visual Studio at C:\Software\VS2022\Community
• Visual Studio Community 2022 version 17.13.35825.156
• Windows 10 SDK version 10.0.22621.0

[!] Android Studio (version 2024.1)
• Android Studio at C:\Software\Android\Koala
• Flutter plugin can be installed from:
🔨 https://plugins.jetbrains.com/plugin/9212-flutter
• Dart plugin can be installed from:
🔨 https://plugins.jetbrains.com/plugin/6351-dart
✗ Unable to find bundled Java version.
• Try updating or re-installing Android Studio.

[✓] Connected device (4 available)
• AAK AN00 (mobile) • A6EE6R5C17005478 • android-arm64  • Android 16 (API 36)
• Windows (desktop) • windows          • windows-x64    • Microsoft Windows [版本 10.0.19045.6456]
• Chrome (web)      • chrome           • web-javascript • Google Chrome 148.0.7778.168
• Edge (web)        • edge             • web-javascript • Microsoft Edge 148.0.3967.70

[✓] HTTP Host Availability
• All required HTTP hosts are available

本地运行步骤：
1. 安装fvm
   dart pub global activate fvm
2. 安装并切换到特定版本的flutter
   fvm install 3.7.12
   fvm use 3.7.12
3. 安装依赖
   fvm flutter pub get
4. 安装l10n依赖
   fvm flutter gen-l10n
5. 运行
   fvm flutter run -t .\lib\main.dart

### 介绍
该应用的目的是替代手机上的自带相册应用,并且能够将照片同步到网络储存.  
功能简单,只是用于查看照片以及同步照片到网络储存.试图做到优秀的体验.

### 功能
* 本地照片查看
* 云端照片查看
* 增量同步照片到云端
* 后台定期同步
* 无数据库,无服务端
* 以时间组织云端存储的目录结构

### 支持的网络储存
- [x] Samba
- [x] Webdav
- [x] NFS
- [x] 百度网盘
- [ ] 阿里网盘
- [ ] oneDrive
- [ ] google drive
- [ ] google photo

### Screenshots
<p align="left">
<img src="assets/screenshot/Screenshots.png" >
</p>

### roadmap
- [x] 支持放大/缩小图片
- [x] 支持上传/浏览视频
- [x] 支持NFS
- [x] 支持百度网盘
- [x] 支持IOS端
- [ ] 支持desktop端
- [x] 支持中文

### Contribute
感谢各位的积极反馈

给本项目提需求的还不少,但是我一个人精力有限,如果你有兴趣,欢迎加入.

可以在issue中回复沟通,帮忙一起做一些功能,提出你的pull request.

### 文件储存逻辑
本着尽可能简单的逻辑来储存文件,以时间为目录结构,以文件名为文件名储存源文件.在根目录创建一个`.thumbnail`目录来储存生成的缩略图,缩略图的目录结构与源文件相同.  
你可以随时以其他形式利用你备份上去的照片,而不用依赖此app.
目录结构示意图:
```bash
├── 2022
│   ├── 07
│   │   ├── 02
│   │   │   ├── 20220702_100940.JPG
│   │   │   ├── 20220702_111416.JPG
│   │   │   └── 20220702_111508.JPG
│   │   └── 03
│   │       ├── 20220703_101923.DNG
│   │       ├── 20220703_112336.DNG
│   │       └── 20220703_112338.DNG
├── 2023
│   └── 01
│       └── 03
│           ├── 20230103_112348.JPG
│           ├── 20230103_124634.JPG
│           └── 20230103_124918.DNG
└── .thumbnail
     └── 2022
         └── 07
             ├── 02
             │   ├── 20220702_100940.JPG
             │   ├── 20220702_111416.JPG
             │   └── 20220702_111508.JPG
             └── 03
                 ├── 20220703_101923.DNG
                 ├── 20220703_112336.DNG
                 └── 20220703_112338.DNG
```


### Star History

[![Star History Chart](https://api.star-history.com/svg?repos=fregie/pho&type=Date)](https://star-history.com/#fregie/pho&Date)
