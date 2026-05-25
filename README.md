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
├── harmony_app   # HarmonyOS 前端项目
└── backend       # FastAPI 后端项目
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