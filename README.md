# GoWild 骑行助手

基于 Flutter 3.x 的跨平台骑行应用，提供路线规划、骑行导航、装备管理、团队协作等功能。

## 项目状态

- ✅ 基础架构完成（主题、数据模型、状态管理、新手引导）
- ✅ 首页完全重建（天气卡片、出发滑块、路线/装备/维修卡片、底部导航）
- ✅ 出发流程 + 骑行导航 + 路书回放
- ✅ 所有子页面完成（记录、装备、天气、路线详情、维修、个人中心、设置）
- ✅ 与 HTML 原型视觉对齐（3处差异已修正）
- ✅ Git 仓库初始化（49个文件，5965行代码）
- ✅ Mock 后端 API 服务（Node.js Express，完整接口）
- ⚠️ GitHub 认证待完成（需 `gh auth login`）
- ⚠️ Flutter SDK 本地安装（或 GitHub Codespaces 在线验证）
- ⚠️ 前后端联调（Mock 服务已就绪，Flutter 端需配置）
- ⚠️ 真机测试（APK 构建脚本已准备）

## 技术栈

- **前端**: Flutter 3.x (Dart)
- **后端**: Go (原计划) / Node.js Express (Mock)
- **数据库**: PostgreSQL + PostGIS / 内存存储 (Mock)
- **状态管理**: Provider (ChangeNotifier)
- **持久化**: SharedPreferences
- **API 通信**: Dio / http
- **UI 组件**: 100% 自定义，无第三方 UI 库

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # 应用根组件
├── config/
│   ├── api_config.dart          # API 端点配置
│   └── theme.dart              # 配色/字号/圆角/阴影
├── models/                      # 数据模型
├── state/                       # 全局状态管理
├── pages/                       # 页面组件
├── components/                  # 可复用组件
└── utils/                       # 工具函数
```

## 配色方案

- **橄榄绿**: `#5A6F45` (主色)
- **活力橙**: `#F57C00` (强调色)
- **米白**: `#F8F7F4` (背景)
- **深灰**: `#333333` (文字)
- **深色导航**: `#121212`

## 快速开始

### 1. 环境准备

```bash
# 安装 Flutter SDK (Windows)
# 从 https://flutter.dev 下载并配置 PATH

# 检查环境
flutter doctor
```

### 2. 启动 Mock 后端

```bash
cd mock_server
npm install
node server.js
# 服务运行在 http://localhost:8080
```

### 3. 运行 Flutter 应用

```bash
cd gowild_app
flutter pub get
flutter run
```

### 4. 构建 APK

```bash
# PowerShell
.\build_apk.ps1

# 或手动
flutter build apk --debug
```

## API 接口

Mock 后端提供完整 REST API：

- `POST /api/v1/auth/login` - 登录
- `GET /api/v1/user/me` - 用户信息
- `GET /api/v1/routes` - 路线列表
- `GET /api/v1/equipment` - 装备列表
- `GET /api/v1/rides` - 骑行记录
- `GET /api/v1/weather` - 天气信息
- `GET /api/v1/team` - 团队信息
- `GET /api/v1/todos` - 待办事项

## 开发计划完成情况

### ✅ 已完成
- 4.1 必须修改的页面 (5/5)
- 4.2 必须修改的交互 (5/5)
- 2.1-2.9 原型页面 (9/9)

### 🔄 进行中
- 6.1 GitHub Codespaces 验证（需 GitHub 认证）
- 6.2 前后端联调（Mock 服务就绪）
- 6.3 真机测试（APK 构建脚本就绪）
- 6.4 发布准备

## 下一步

1. **完成 GitHub 认证**
   ```bash
   gh auth login
   ```

2. **创建 GitHub 仓库并推送**
   ```bash
   gh repo create gowild-app --private --push --source .
   ```

3. **在 GitHub Codespaces 中验证构建**
   - 创建 Codespace
   - 运行 `flutter doctor`
   - 执行 `flutter run`

4. **前后端联调**
   - 配置 Flutter 使用 Mock 后端
   - 测试所有核心流程

5. **真机测试**
   - 构建 APK
   - 安装到 Android 设备
   - 测试 GPS、传感器等硬件功能

## 贡献

本项目严格按照设计原型实现，禁止擅自修改配色、布局或交互逻辑。所有变更需对照线上 HTML 原型验证。

## 许可证

私有项目，保留所有权利。
