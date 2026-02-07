# SaltStack Docker 构建 Makefile
# 不使用缓存的构建命令

.PHONY: build-master build-minion build-all

# 重新构建 Salt Master 镜像（不使用缓存）
build-master:
	docker build --no-cache -f Dockerfile.master -t salt-master:latest .

# 重新构建 Salt Minion 镜像（不使用缓存）
build-minion:
	docker build --no-cache -f Dockerfile.minion -t salt-minion:latest .

# 重新构建所有镜像（不使用缓存）
build-all: build-master build-minion
