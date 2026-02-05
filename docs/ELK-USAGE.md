# ELK Stack 日志采集系统使用说明

## 系统架构

本项目已集成 ELK Stack（ElasticSearch + Kibana + Filebeat）用于集中式日志管理。

### 组件说明

| 组件 | 版本 | 端口 | 说明 |
|------|------|------|------|
| ElasticSearch | 8.11.0 | 9200, 9300 | 日志存储和搜索引擎 |
| Kibana | 8.11.0 | 5601 | 日志可视化和分析界面 |
| Filebeat | 8.11.0 | - | 日志采集器（运行在每个 minion 中） |

## 访问地址

- **Kibana**: http://localhost:5601
- **ElasticSearch API**: http://localhost:9200
- **Grafana**: http://localhost:3000
- **Prometheus**: http://localhost:9090

## 日志采集配置

### 采集的日志文件

Filebeat 在每个 salt-minion 容器中采集以下日志：

1. **系统日志**
   - `/var/log/syslog`
   - `/var/log/auth.log`
   - `/var/log/*.log`

2. **Salt Minion 日志**
   - `/var/log/salt/minion`

### 日志字段

每条日志包含以下字段：
- `@timestamp`: 日志时间戳
- `message`: 日志内容
- `log_type`: 日志类型（system 或 salt）
- `service_name`: 服务名称（salt-minion）
- `host.*`: 主机信息（hostname, IP, OS 等）
- `tags`: 标签（salt-minion, docker）

## 使用 Kibana 查看日志

### 1. 首次访问配置

1. 访问 http://localhost:5601
2. 等待 Kibana 启动完成
3. 点击左侧菜单 "Discover"
4. 创建 Data View（数据视图）：
   - 点击 "Create data view"
   - Index pattern: `filebeat-salt-minion-*`
   - Timestamp field: `@timestamp`
   - 点击 "Create data view"

### 2. 查看日志

在 Discover 页面可以：
- 查看实时日志流
- 搜索和过滤日志
- 查看日志详情
- 创建可视化图表

### 3. 常用搜索示例

```
# 搜索特定日志类型
log_type: "system"
log_type: "salt"

# 搜索特定主机
host.hostname: "docker-saltstack-salt-minion-1"

# 搜索包含特定关键词的日志
message: "error"
message: "warning"

# 组合搜索
log_type: "salt" AND message: "error"
```

## 使用 ElasticSearch API 查询日志

### 查看所有索引

```bash
curl "http://localhost:9200/_cat/indices?v"
```

### 查询日志

```bash
# 查询最新的 10 条日志
curl -s "http://localhost:9200/filebeat-salt-minion-*/_search?size=10&sort=@timestamp:desc&pretty"

# 搜索包含 "error" 的日志
curl -s "http://localhost:9200/filebeat-salt-minion-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "message": "error"
    }
  }
}'

# 统计日志数量
curl -s "http://localhost:9200/filebeat-salt-minion-*/_count?pretty"
```

## 扩展多个 Minion

当使用 `./scripts/start.sh N` 启动多个 minion 时，每个 minion 都会独立采集日志并发送到 ElasticSearch。

```bash
# 启动 4 个 minion
./scripts/start.sh 4

# 查看所有 minion 的日志
# 在 Kibana 中可以通过 host.hostname 字段区分不同的 minion
```

## 故障排查

### 检查 Filebeat 状态

```bash
# 查看 filebeat 进程
docker exec docker-saltstack-salt-minion-1 ps aux | grep filebeat

# 查看 filebeat 日志
docker exec docker-saltstack-salt-minion-1 ls -la /var/log/filebeat/
docker exec docker-saltstack-salt-minion-1 tail -f /var/log/filebeat/filebeat-*.ndjson
```

### 检查 ElasticSearch 健康状态

```bash
curl "http://localhost:9200/_cluster/health?pretty"
```

### 重启服务

```bash
# 重启所有服务
docker-compose restart

# 只重启 minion（重新采集日志）
docker-compose restart salt-minion
```

## 配置文件位置

- Filebeat 配置: `config/filebeat/filebeat.yml`
- ElasticSearch 数据: Docker volume `elasticsearch-data`
- Prometheus 配置: `config/prometheus/prometheus.yml`

## 性能优化建议

1. **ElasticSearch 内存**：默认限制为 512MB，如需处理大量日志可在 `docker-compose.yml` 中调整 `ES_JAVA_OPTS`

2. **日志保留策略**：可配置 ElasticSearch ILM（Index Lifecycle Management）自动删除旧日志

3. **Filebeat 采集频率**：可在 `filebeat.yml` 中调整 `scan_frequency` 参数

## 安全建议

当前配置为开发环境，生产环境建议：
1. 启用 ElasticSearch 安全功能（xpack.security.enabled=true）
2. 配置用户认证和授权
3. 使用 HTTPS 加密通信
4. 限制网络访问（不暴露到公网）
