获取源码请访问[https://www.itrade.icu](https://www.itrade.icu)

# 📘 第 7 篇：如何搭建 Freqtrade Web UI？安装与使用指南

在使用 Freqtrade 进行实盘或回测时，你可能希望实时查看当前策略运行状态、持仓、收益等信息。这时，**Web UI**（FreqUI）就派上用场了。

本文介绍如何安装和运行 Web UI，包括命令行与 Docker 两种方式，并介绍常见的使用场景。

![1](https://fastly.jsdelivr.net/gh/bucketio/img18@main/2025/07/19/1752932190240-03fecb1c-526c-4711-baa6-cdc43a05ca6a.png)

---

## 🧩 1. 安装 Web UI 支持组件

在首次使用 Web UI 前，需要执行以下命令安装依赖：

```bash
freqtrade install-ui
```
该命令会自动安装运行 Web 界面所需的依赖模块。

## 🚀 2. 启动 Webserver 服务
Webserver 是 UI 的后端入口，启动后会监听一个端口（默认是 8080）。
```bash
freqtrade webserver \
  --config user_data/config.json
```

默认情况下，你可以通过浏览器访问：
```bash
http://localhost:8080
```

## ⚙️ 3. 常用参数说明
| 参数                          | 说明                  |
| --------------------------- | ------------------- |
| `--config`                  | 指定配置文件路径            |
| `--port`                    | 指定监听端口，默认是 8080     |
| `--username` / `--password` | 设置登录用户与密码           |
| `--api-server`              | 启用 REST API 服务      |
| `--webserver`               | 启动 UI Web 服务（默认即启用） |
🧱 示例：使用指定端口与登录账号

```bash
freqtrade webserver \
  --config user_data/config.json
```
![](https://fastly.jsdelivr.net/gh/bucketio/img15@main/2025/07/19/1752932226796-fee4ad2d-6191-4090-b1bf-7d5e085d1f5f.png)
## 🐳 4. Docker 启动 Web UI 示例
如果你用的是 Docker，可以使用如下配置（docker-compose.yml）：
⚠️⚠️⚠️：如果使用`docker`启动那么`config.json`中的`api_server.listen_port`字段需要和`docker-compose.yaml`中`ports`端口一致，否则无法正常访问.
```json
    "api_server": {
        "enabled": true,
        "listen_ip_address": "127.0.0.1",
        "listen_port": 7777,
        "verbosity": "error",
        "enable_openapi": false,
        "jwt_secret_key": "",
        "ws_token": "",
        "CORS_origins": [],
        "username": "1",
        "password": "1"
    },
```

```yaml
services:
  freqtrade:
    image: freqtradeorg/freqtrade:stable
    volumes:
      - ./user_data:/quants/freqtrade/user_data
    ports:
      - "8888:7777" # 外部访问使用 http://localhost:8888
    command: >
      webserver
      --config /quants/freqtrade/user_data/config.json
      --username admin
      --password 123456
```
启动方式：
```bash
docker compose up -d 
```
你说得对，Freqtrade 的 Web UI 实际上包括两种不同用途的界面，分别服务于实盘交易与策略开发测试场景。以下是更准确的说明，可以直接替换你上面的内容：

---

## 📊 6. Web UI 模块说明

Freqtrade 提供两套 Web UI，用于不同场景：

### ✅ 1. 实盘 Web UI（`freqtrade trade` 时启用）

用于实时监控机器人运行状态：

* 查看当前策略、持仓币种、盈亏情况
* 管理挂单 / 平仓 / 创建手动交易（需启用 API）
* 浏览历史交易记录与盈亏图表

启动方式：

```bash
freqtrade trade --config user_data/config.json
```

### 🧪 2. 回测 Web UI（Backtesting UI）

用于策略回测结果可视化：

* 图形化展示回测盈亏曲线、指标线、买卖点
* 策略性能概览、交易统计分析
* 需先使用 `freqtrade backtesting` 生成结果

启动方式：

```bash
freqtrade webserver --config user_data/config.json 
```

---

## 🔧 7. 注意事项与常见问题

| 问题              | 解决方法                                                    |
| --------------- | ------------------------------------------------------- |
| 无法访问 UI         | 确保已启动对应 webserver 模式，端口是否对外开放                           |
| 页面空白 / 样式错乱     | 运行：`freqtrade install-ui` 安装前端依赖                        |
| Docker 中访问不到 UI | 检查 `docker-compose.yml` 是否有 `ports: 8888:8080` 映射       |
| UI 无法识别策略       | 策略文件名需正确，`config.json` 中 `"strategy"` 字段必须一致            |
| 回测 UI 无数据展示     | 确保已运行 `backtesting` 并生成结果，再启动 `webserver --backtesting` |

---



## 📌 总结
Freqtrade Web UI 是一个轻量、实用的可视化界面，可用于：
- 实时监控交易状态
- 查看回测或实盘表现
- 手动干预交易行为
如果你已熟悉 CLI，但希望更直观地管理策略和资产，强烈推荐开启 Web UI！

