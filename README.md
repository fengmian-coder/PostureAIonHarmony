# PostureAIonHarmony

塑影 Posture.AI：基于 HarmonyOS 与 AIGC 的智能体态检测系统。

## 项目简介

本项目是一个移动应用开发课程设计项目。前端使用 ArkTS + ArkUI 开发 HarmonyOS 应用，后端使用 FastAPI 构建 Web API 服务，结合 MediaPipe 人体骨架识别、SQLite 数据存储与 AIGC 康复建议生成，实现体态检测、检测报告、健康档案、历史详情和记录管理等功能。

## 技术栈

- HarmonyOS
- ArkTS
- ArkUI
- FastAPI
- MediaPipe
- SQLite
- AIGC

## 核心功能

- 图片选择与预览
- AI 体态检测
- 高低肩角度计算
- 检测结果展示
- AI 康复建议
- 检测报告生成
- 健康档案管理
- 历史详情查看
- 删除单条历史记录
- 清空历史记录
- 系统设置与后端连接测试


## 项目结构

```text
PostureAIonHarmony
├── harmony_app                         # HarmonyOS 前端项目
│   └── entry/src/main
│       ├── ets
│       │   ├── entryability
│       │   │   └── EntryAbility.ets    # 应用入口 Ability
│       │   │
│       │   ├── pages                   # View 层：页面展示与用户交互
│       │   │   ├── Index.ets           # 首页
│       │   │   ├── DetectPage.ets      # AI 体态检测页
│       │   │   ├── ResultPage.ets      # 检测结果页
│       │   │   ├── ReportPage.ets      # 检测报告页
│       │   │   ├── HistoryPage.ets     # 健康档案页
│       │   │   ├── HistoryDetailPage.ets # 历史详情页
│       │   │   └── SettingsPage.ets    # 系统设置页
│       │   │
│       │   ├── models                  # Model 层：前端数据模型
│       │   │   └── PostureModels.ets   # 统计结果、趋势数据等模型
│       │   │
│       │   ├── viewmodels              # ViewModel 层：业务逻辑处理
│       │   │   └── HistoryViewModel.ets # 历史统计、评分、趋势处理
│       │   │
│       │   └── services                # Service 层：网络请求封装
│       │       └── ApiService.ets      # FastAPI 接口调用
│       │
│       └── resources                   # 图片、图标、页面配置等资源
│           └── base
│               ├── media               # App 图标、Logo 等资源
│               ├── element             # 字符串等资源
│               └── profile             # 页面路由配置
│
└── backend                             # Python FastAPI 后端项目
    ├── main.py                         # 后端接口、AI 检测、数据库操作
    └── posture_data.db                 # SQLite 历史记录数据库

```

## 后端启动方式

```bash
cd backend
uvicorn main:app --host 0.0.0.0 --port 8000
```

## App 后端地址配置

在 App 的系统设置页中填写当前电脑 WLAN IPv4 地址，例如：

```text
http://192.168.0.xxx:8000
```

## 课程知识点

本项目综合应用了移动端 UI 设计、多页面跳转、HTTP 网络请求、JSON 数据交互、文件与多媒体处理、数据库管理、Web API 服务和 AI 姿态识别等知识。