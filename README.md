# Power Controller for macOS / 电源控制

中文与 English 双语的 macOS 电源控制工具，用于“合盖保持唤醒 + 定时自动睡眠”。

A bilingual macOS power utility for lid-closed wake control and scheduled sleep.

## Features / 功能

- In-app Chinese and English switching / 应用内中英文切换
- Lid-closed stay-awake toggle / 合盖保持唤醒开关
- Automatic sleep countdown / 定时自动睡眠
- Menu bar quick controls / 菜单栏快捷控制
- Local reminder 1 minute before sleep / 睡眠前 1 分钟本地通知
- SwiftUI + MVVM + Services architecture / SwiftUI + MVVM + Services 架构

## Project Structure / 项目结构

```text
Sources/MacOSAppTemplate
├── App
├── Core
│   ├── Models
│   └── Services
├── Features
│   └── Dashboard
└── Shared
    └── Components
```

## Run / 运行

```bash
swift run
```

Build a double-clickable app bundle / 生成可双击启动的 `.app`：

```bash
./scripts/build_app_bundle.sh
open MacOSAppTemplate.app
```

## Test / 测试

```bash
swift test
```

## How It Works / 工作方式

- Uses `pmset disablesleep` to control lid-close sleep behavior / 使用 `pmset disablesleep` 控制合盖睡眠
- Uses `pmset sleepnow` to trigger sleep at the scheduled time / 使用 `pmset sleepnow` 触发定时睡眠
- Requests administrator approval only when changing system power settings / 仅在修改系统电源策略时请求管理员授权

## Notes / 说明

1. macOS may prompt for administrator permission when toggling lid-close stay awake.  
   切换“合盖保持唤醒”时，macOS 可能弹出管理员授权。

2. A local notification is sent 1 minute before the scheduled sleep time.  
   睡眠计时超过 1 分钟时，会在到点前 1 分钟发送本地通知。

3. The app provides both a main window and a menu bar control panel.  
   应用同时提供主窗口和菜单栏快捷控制。

## GitHub-Friendly Highlights / 适合放 GitHub 的点

- Source code and app bundle can both be generated locally / 源码与 `.app` 都可本地生成
- Clean architecture that is easy to extend / 分层清晰，便于继续扩展
- Includes a packaging script for demos and releases / 已包含打包脚本，方便演示和发布
