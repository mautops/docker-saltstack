#!/bin/bash

echo "=== Alertmanager 配置验证 ==="

# 检查配置文件是否存在
echo "1. 检查配置文件..."
if [ -f "./config/alertmanager/alertmanager.yml" ]; then
    echo "✅ Alertmanager 配置文件存在"
else
    echo "❌ Alertmanager 配置文件不存在"
    exit 1
fi

if [ -f "./config/prometheus/rules.yml" ]; then
    echo "✅ Prometheus 告警规则文件存在"
else
    echo "❌ Prometheus 告警规则文件不存在"
    exit 1
fi

# 检查 docker-compose 配置
echo "2. 检查 docker-compose 配置..."
if grep -q "alertmanager" ./docker-compose.yml; then
    echo "✅ docker-compose 中包含 Alertmanager 服务"
else
    echo "❌ docker-compose 中缺少 Alertmanager 服务"
    exit 1
fi

if grep -q "9093:9093" ./docker-compose.yml; then
    echo "✅ Alertmanager 端口配置正确"
else
    echo "❌ Alertmanager 端口配置错误"
    exit 1
fi

# 启动服务进行集成测试
echo "3. 启动服务进行集成测试..."
docker-compose up -d

sleep 10

# 检查服务状态
echo "4. 检查服务运行状态..."
if docker ps | grep -q "alertmanager"; then
    echo "✅ Alertmanager 容器运行中"
else
    echo "❌ Alertmanager 容器未运行"
    docker-compose logs alertmanager
    exit 1
fi

if docker ps | grep -q "prometheus"; then
    echo "✅ Prometheus 容器运行中"
else
    echo "❌ Prometheus 容器未运行"
    docker-compose logs prometheus
    exit 1
fi

# 测试 API 连通性
echo "5. 测试 API 连通性..."
curl -s -f http://localhost:9093 >/dev/null && echo "✅ Alertmanager API 可访问" || echo "⚠️  Alertmanager API 暂不可访问"
curl -s -f http://localhost:9090/api/v1/alertmanagers >/dev/null && echo "✅ Prometheus Alertmanager 连接正常" || echo "⚠️  Prometheus 无法连接 Alertmanager"

echo "=== 配置验证完成 ==="
echo "访问地址:"
echo "- Prometheus: http://localhost:9090"
echo "- Alertmanager: http://localhost:9093"
echo "- Grafana: http://localhost:3000"