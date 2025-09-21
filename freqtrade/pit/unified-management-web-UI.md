
获取源码请访问[https://www.itrade.icu](https://www.itrade.icu)


# 🖥️ 统一管理多个 Freqtrade 策略的 WebUI 页面实战指南

> 本文将详细讲解如何通过一个主端口统一访问多个 Freqtrade 策略实例的 Web UI 页面，提升多策略部署的可视化管理效率。

---

## ✳️ 背景说明

在使用 Freqtrade 多策略部署时，通常我们会：
- 为每个策略设置独立的配置文件（`config.json`）；
- 分别运行多个实例（进程）；
- 每个实例监听独立的 Web UI 端口。

例如，默认可能会这样设置：

| 策略名称                 | 配置文件名                     | Web UI 端口 |
| -------------------- | ------------------------- | --------- |
| `Test_MACD_Strategy` | `spot-macd-config.json` | `9999`    |
| `Test_EMA_Strategy`  | `spot-ema-config.json`    | `9998`    |
| `Test_RSI_Strategy`  | `spot-rsi-config.json`    | `9997`    |

这样做虽然清晰，但带来了一个问题：**访问管理界面时必须记住多个端口**，不利于统一控制和查看。

---

## ✅ 目标

我们希望实现：

> **只通过一个统一端口（如 `localhost:9999`），即可访问所有策略实例的 WebUI 页面。**

---

## 🧩 原理：通过 CORS 跨域授权访问

Freqtrade 的 Web UI 是基于 FastAPI 开发的，支持 [CORS 跨域配置](https://fastapi.tiangolo.com/tutorial/cors/)，允许来自其他端口或源的访问。

只要我们：

- 在子策略实例的配置中设置 `CORS_origins: ["http://localhost:9999"]`
- 并保持主控策略运行在 9999 端口上

即可实现：**9999 作为统一入口，控制和访问其他端口实例的 WebUI 页面**。

---

## 🛠 配置步骤详解

---

### ① 主控策略（如 `Test_MACD_Strategy`）

```json
// user_data/spot-macd-config.json
"api_server": {
  "enabled": true,
  "listen_ip_address": "127.0.0.1",        // 本地访问；如需远程，改成 "0.0.0.0"
  "listen_port": 9999,                     // 主控端口
  "verbosity": "error",
  "enable_openapi": false,
  "jwt_secret_key": "your_master_secret",  // 可自定义
  "ws_token": "master_ws_token",           // 可自定义
  "CORS_origins": ["http://localhost:9999"],
  "username": "admin",
  "password": "admin"
}
```
![](https://fastly.jsdelivr.net/gh/bucketio/img18@main/2025/08/02/1754107112282-7c26b8ba-ebec-47f4-9746-19ab39076323.png)

---

### ② 子策略（如 `Test_EMA_Strategy`）

```json
// user_data/spot-ema-config.json
"api_server": {
  "enabled": true,
  "listen_ip_address": "127.0.0.1",
  "listen_port": 9998,                        // 与主控不同端口
  "verbosity": "error",
  "enable_openapi": false,
  "jwt_secret_key": "ema_secret",            // 可以不同
  "ws_token": "ema_ws_token",
  "CORS_origins": ["http://localhost:9999"], // 授权主控访问
  "username": "ema",
  "password": "ema"
}
```
![](https://fastly.jsdelivr.net/gh/bucketio/img3@main/2025/08/02/1754107097305-52d8bea4-02c2-48a4-90eb-a48f6a1f8490.png)
---

### ③ 子策略（如 `Test_RSI_Strategy`）

```json
// user_data/spot-rsi-config.json
"api_server": {
  "enabled": true,
  "listen_ip_address": "127.0.0.1",
  "listen_port": 9997,
  "verbosity": "error",
  "enable_openapi": false,
  "jwt_secret_key": "rsi_secret",
  "ws_token": "rsi_ws_token",
  "CORS_origins": ["http://localhost:9999"],
  "username": "rsi",
  "password": "rsi"
}
```
![](https://fastly.jsdelivr.net/gh/bucketio/img17@main/2025/08/02/1754107118107-5cd39930-1838-4ce1-b538-55ed20805f17.png)
---
> 这样就能看到同时多个策略在运行啦

![](https://fastly.jsdelivr.net/gh/bucketio/img2@main/2025/08/02/1754107123406-d3f8e349-15b1-4a65-bded-6a7beaad19b2.png)

### ✅ 所有实例都配置了：

- 独立端口（避免冲突）
- 主控 WebUI 授权访问子策略端口（通过 `CORS_origins`）
- 自定义用户和密码（支持不同登录权限）
- 支持本地或远程访问（可设置 本地访问设置`127.0.0.1`远程访问设置`0.0.0.0`）

---

## 🚀 启动命令

```bash
# 启动主控策略（WebUI 入口）
freqtrade trade \
  --config user_data/spot-macd-config.json \
  --strategy Test_MACD_Strategy

# 启动 EMA 子策略
freqtrade trade \
  --config user_data/spot-ema-config.json \
  --strategy Test_EMA_Strategy

# 启动 RSI 子策略
freqtrade trade \
  --config user_data/spot-rsi-config.json \
  --strategy Test_RSI_Strategy
```

> ✅ 每条命令需在不同终端窗口运行，或用 `tmux` / `screen` / `nohup` 保持后台运行。

---

### ✅ 访问 WebUI 页面

打开浏览器，统一访问：

```
http://localhost:9999
```

你将看到一个 Web 控制面板，能管理并切换不同策略实例。


## 🌐 【重要】远程访问配置说明

默认情况下：

```json
"listen_ip_address": "127.0.0.1"
```

代表 **仅允许本机访问**，也就是说：
- 你只能在部署 Freqtrade 的那台机器本地打开 WebUI；
- 浏览器地址栏只能访问 `http://localhost:端口`，远程 IP 无法访问。


---

### ✅ 若你需要从其他设备远程访问 WebUI（如服务器部署 + 本地浏览器查看），需进行如下修改：

```json
"listen_ip_address": "0.0.0.0"
```

这表示：

> **监听所有网卡地址，支持任何来源访问**（包括公网 IP、本地局域网 IP 等）。

---

### 示例修改：

```jsonc
"api_server": {
  "enabled": true,
  "listen_ip_address": "0.0.0.0",  // ← 开启远程访问
  "listen_port": 9999,
  ...
}
```

---

### 🚨 安全提醒

如果你开启了 `0.0.0.0`：

- 强烈建议启用 `username` / `password` 登录保护；
- 或者使用防火墙（如 UFW、iptables）限制 IP 访问；
- 或部署反向代理（如 nginx）做访问控制与 HTTPS 加密；

---

### 🧪 示例远程访问方式

服务器地址为 `192.168.1.100`，配置为 `listen_ip_address: 0.0.0.0` 后：

浏览器访问地址为：

```
http://192.168.1.100:9999
```

即可访问主控 Web UI 页面 ✅

---

## 🌐 补充说明

|项目|说明|
|---|---|
|`CORS_origins`|子策略必须授权主控端口访问|
|统一登录入口|每个实例可自定义登录名与密码|
|多策略独立配置|每个策略运行、K线数据、交易记录完全隔离|
|本地 vs 远程|若需远程访问，设置 `listen_ip_address = "0.0.0.0"` 并开放防火墙端口|

---

## ✅ 总结

通过简单的配置与跨域授权机制，我们可以：

- 🚀 同时运行多个策略实例（独立运行、互不干扰）
- 🧠 用一个 WebUI 入口（如 `9999`）统一管理所有策略
- 🔐 为每个策略设置独立登录权限与端口
- 🔧 支持远程或本地部署
    

这让多策略部署不再混乱，为**策略量化管理和实盘监控**带来极大便利。

