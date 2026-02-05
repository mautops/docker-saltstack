# Salt API 认证问题说明

## 问题描述

当前 Salt API 的认证功能存在问题，`/login` 端点无法正常工作。

### 症状

1. 使用 `sharedsecret` 认证时，请求超时（503 Service Unavailable）
2. 使用 `auto`, `pam`, `file` 认证时，返回 401 Unauthorized
3. 日志显示：`[INFO] [api_acl] Authentication not checked for user salt`

### 根本原因

Salt 3007.x 版本的 external_auth 配置可能与之前版本有所不同，或者需要额外的配置步骤。

## 临时解决方案

### 方案 1: 使用无认证的端点（仅用于开发/测试）

某些 Salt API 端点可以在没有认证的情况下使用（如果配置允许）：

```bash
# 直接调用命令（需要在 master 上配置允许）
curl -sSk http://localhost:8000/ \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '[{
    "client": "local",
    "tgt": "*",
    "fun": "test.ping"
  }]'
```

### 方案 2: 使用 salt 命令行工具

在 salt-master 容器内直接使用 salt 命令：

```bash
# 进入容器
docker exec -it salt-master bash

# 执行命令
salt '*' test.ping
salt '*' grains.items
salt '*' cmd.run 'uptime'
```

### 方案 3: 修复认证配置（推荐用于生产环境）

需要进一步调查 Salt 3007.x 的正确认证配置方式。可能的方向：

1. 检查 Salt 官方文档关于 external_auth 的最新配置
2. 使用 PAM 认证并正确配置 PAM 模块
3. 使用 LDAP 或其他企业级认证方式

## 当前配置

### master.conf

```yaml
# 当前尝试的配置（未成功）
external_auth:
  auto:
    .*:
      - '.*'
      - '@wheel'
      - '@runner'
      - '@jobs'
```

## 下一步行动

1. 查阅 Salt 3007.x 官方文档
2. 检查是否需要安装额外的 Python 包
3. 尝试使用 Salt 的 token 系统
4. 考虑降级到 Salt 3006.x 版本（如果 3007.x 有 bug）

## 相关链接

- [Salt API 文档](https://docs.saltproject.io/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html)
- [External Auth 文档](https://docs.saltproject.io/en/latest/topics/eauth/index.html)
- [Salt 3007 Release Notes](https://docs.saltproject.io/en/latest/topics/releases/3007.0.html)

## 测试脚本状态

由于认证问题，`./test-api/run-all-tests.sh` 脚本目前无法正常运行。

建议：
1. 先使用 salt 命令行工具验证功能
2. 修复认证问题后再运行 API 测试
3. 或者修改测试脚本使用无认证的方式（如果可能）
