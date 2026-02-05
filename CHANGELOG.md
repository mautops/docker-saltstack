# 更新日志

本项目的所有重要变更都将记录在此文件中.

本格式基于 [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
本项目遵循 [语义化版本](https://semver.org/spec/v2.0.0.html).

## [未发布]

### 新增
- Salt API (rest_cherrypy) 支持, 提供外部访问和认证功能
- 全面的 API 测试套件, 包含 25+ 个独立测试脚本
- REST API 端点, 用于 minion 管理, 任务跟踪和密钥管理
- 通过 Server-Sent Events (SSE) 实现实时事件流
- WebSocket 支持双向通信
- Webhook 接收端点, 用于外部集成
- API 统计端点, 用于性能监控
- 支持异步任务执行和状态跟踪
- 改进了 API 脚本的错误处理和进程监控
- AGENTS.md 配置文件, 用于 Cursor 编辑器技能系统

### 变更
- 升级到 Salt 3007.11 (2026 年 1 月最新稳定版本)
- 更新基础镜像为 Ubuntu 24.04 LTS
- 从已弃用的 `repo.saltstack.com` 仓库迁移到 PyPI 安装
- 切换到使用 Python 虚拟环境的现代 "onedir-style" 打包方式
- 遵循最佳实践简化了 Dockerfiles, docker-compose 和脚本
- 改进了安全文档和配置指南

### 修复
- 修复了 Dockerfiles 中缺失的依赖项 (looseversion, psutil, jmespath)
- 解决了 salt-master 和 salt-minion 启动问题
- 修复了依赖安装顺序和兼容性问题
- 移除了已弃用的 looseversion 依赖

### 安全
- 更新到包含安全补丁的最新 Salt 版本
- 改进了生产环境部署的安全文档
- 添加了 SSL/TLS 配置和安全认证的指导

[未发布]: https://github.com/cvtestorg/docker-saltstack/compare/v1.0.0...HEAD
