# GoWild APK 构建脚本
# 前置要求：Flutter SDK 已安装并配置环境变量
# 运行方式：PowerShell -ExecutionPolicy Bypass -File build_apk.ps1

Write-Host "GoWild APK 构建脚本" -ForegroundColor Cyan
Write-Host "======================"

# 检查 Flutter
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterPath) {
    Write-Host "❌ Flutter 未找到，请先安装 Flutter SDK 并配置 PATH" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Flutter 版本：" -NoNewline
flutter --version

# 清理并获取依赖
Write-Host "`n1. 清理旧构建..." -ForegroundColor Yellow
flutter clean

Write-Host "2. 获取依赖..." -ForegroundColor Yellow
flutter pub get

# 检查 Android 环境
Write-Host "3. 检查 Android 环境..." -ForegroundColor Yellow
flutter doctor --android-licenses

# 构建 APK
Write-Host "4. 构建 APK (debug)..." -ForegroundColor Yellow
flutter build apk --debug

# 检查 APK 文件
$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length / 1MB
    Write-Host "`n✅ APK 构建成功！" -ForegroundColor Green
    Write-Host "   APK 路径: $apkPath"
    Write-Host "   文件大小: $([math]::Round($apkSize, 2)) MB"
    Write-Host "`n📱 安装到已连接的 Android 设备：" -ForegroundColor Cyan
    Write-Host "   flutter install"
} else {
    Write-Host "❌ APK 构建失败，请检查错误" -ForegroundColor Red
    exit 1
}
