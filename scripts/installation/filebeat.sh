#!/bin/bash
set -e

echo "Installing Filebeat 8.11.3..."

# 检测系统架构
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    FILEBEAT_ARCH="x86_64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    FILEBEAT_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

echo "Detected architecture: $ARCH"

# 下载 Filebeat
FILEBEAT_URL="https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.11.3-linux-${FILEBEAT_ARCH}.tar.gz"
echo "Downloading Filebeat from: $FILEBEAT_URL"

wget -O /tmp/filebeat-8.11.3-linux-${FILEBEAT_ARCH}.tar.gz "$FILEBEAT_URL"

# 解压并安装
cd /tmp
tar xzf filebeat-8.11.3-linux-${FILEBEAT_ARCH}.tar.gz
mv filebeat-8.11.3-linux-${FILEBEAT_ARCH} /opt/filebeat

# 创建软链接
ln -sf /opt/filebeat/filebeat /usr/local/bin/filebeat

# 创建必要的目录
mkdir -p /etc/filebeat /var/log/filebeat /var/lib/filebeat

# 设置权限
chmod +x /opt/filebeat/filebeat
chmod 755 /opt/filebeat

echo "Filebeat 8.11.3 installed successfully!"
echo "Installation path: /opt/filebeat"
echo "Binary path: /usr/local/bin/filebeat"

# 验证安装
if command -v filebeat &> /dev/null; then
    echo "Filebeat version:"
    filebeat version
else
    echo "Error: Filebeat installation failed"
    exit 1
fi