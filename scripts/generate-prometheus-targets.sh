#!/bin/bash
# 动态生成 Prometheus targets 配置文件

echo "生成动态 minion targets 配置..."

# 获取当前运行的所有 minion 容器
MINIONS=$(docker ps --format "{{.Names}}" | grep "salt-minion" | sort)

# 创建 targets 目录
mkdir -p /tmp/prometheus-targets

# 生成 JSON 配置文件
cat > /tmp/prometheus-targets/node-exporter.json << EOF
[
  {
    "targets": [
$(echo "$MINIONS" | sed 's/$/:9100/' | sed 's/^/      "/' | sed 's/$/",/' | sed '$ s/,$//')
    ],
    "labels": {
      "job": "node-exporter",
      "group": "salt-minion",
      "scrape_interval": "30s"
    }
  }
]
EOF

echo "生成的 targets:"
cat /tmp/prometheus-targets/node-exporter.json

# 复制到 Prometheus 配置目录（如果在容器内运行）
if [ -d "/etc/prometheus/targets" ]; then
    cp /tmp/prometheus-targets/node-exporter.json /etc/prometheus/targets/
    echo "配置文件已复制到 /etc/prometheus/targets/"
fi