#!/bin/bash
# 停止所有容器并删除相关的卷
docker compose down -v
# 强制删除 salt-master 容器（如果存在）
docker compose rm salt-master -f
# 强制删除 salt-minion 容器（如果存在）
docker compose rm salt-minion -f
