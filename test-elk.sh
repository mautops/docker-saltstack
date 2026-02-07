#!/bin/bash

echo "=== ELK 日志收集系统验证 ==="

# 检查配置文件
echo "1. 检查配置文件..."
configs=(
    "./config/elasticsearch/elasticsearch.yml"
    "./config/kibana/kibana.yml" 
    "./config/filebeat/filebeat.yml"
)

for config in "${configs[@]}"; do
    if [ -f "$config" ]; then
        echo "✅ $config 存在"
    else
        echo "❌ $config 不存在"
        exit 1
    fi
done

# 检查 docker-compose 配置
echo "2. 检查 docker-compose 配置..."
services=("elasticsearch" "kibana" "salt-minion")

for service in "${services[@]}"; do
    if grep -q "$service:" ./docker-compose.yml; then
        echo "✅ docker-compose 中包含 $service 服务"
    else
        echo "❌ docker-compose 中缺少 $service 服务"
        exit 1
    fi
done

# 构建并启动服务
echo "3. 构建并启动服务..."
docker-compose build salt-minion
docker-compose up -d

sleep 30

# 检查服务状态
echo "4. 检查服务运行状态..."
services_running=true

if docker ps | grep -q "elasticsearch"; then
    echo "✅ Elasticsearch 容器运行中"
else
    echo "❌ Elasticsearch 容器未运行"
    docker-compose logs elasticsearch
    services_running=false
fi

if docker ps | grep -q "kibana"; then
    echo "✅ Kibana 容器运行中"
else
    echo "❌ Kibana 容器未运行"
    docker-compose logs kibana
    services_running=false
fi

if docker ps | grep -q "salt-minion"; then
    echo "✅ Salt Minion 容器运行中"
else
    echo "❌ Salt Minion 容器未运行"
    docker-compose logs salt-minion
    services_running=false
fi

if [ "$services_running" = false ]; then
    echo "❌ 部分服务启动失败"
    exit 1
fi

# 测试 API 连通性
echo "5. 测试 API 连通性..."
curl -s -f http://localhost:9200 >/dev/null && echo "✅ Elasticsearch API 可访问" || echo "⚠️  Elasticsearch API 暂不可访问"
curl -s -f http://localhost:5601 >/dev/null && echo "✅ Kibana UI 可访问" || echo "⚠️  Kibana UI 暂不可访问"

# 检查 Filebeat 状态
echo "6. 检查 Filebeat 日志收集状态..."
docker-compose exec salt-minion filebeat test config && echo "✅ Filebeat 配置文件有效" || echo "❌ Filebeat 配置文件无效"
docker-compose exec salt-minion filebeat test output && echo "✅ Filebeat 输出配置有效" || echo "❌ Filebeat 输出配置无效"

# 检查索引创建
echo "7. 检查 Elasticsearch 索引..."
indices=$(curl -s http://localhost:9200/_cat/indices?v 2>/dev/null)
if echo "$indices" | grep -q "filebeat"; then
    echo "✅ Filebeat 索引已创建"
    echo "$indices" | grep "filebeat"
else
    echo "⚠️  Filebeat 索引尚未创建（可能需要等待数据收集）"
fi

echo "=== 配置验证完成 ==="
echo "访问地址:"
echo "- Elasticsearch: http://localhost:9200"
echo "- Kibana: http://localhost:5601"
echo "- Salt Master: http://localhost:8000"
echo "- Prometheus: http://localhost:9090"
echo "- Alertmanager: http://localhost:9093"
echo "- Grafana: http://localhost:3000"