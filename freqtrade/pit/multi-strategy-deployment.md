
> > 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利


# 🤖 Freqtrade 多策略部署实战指南（PM2 & Docker 双版本）

> 本文将介绍如何在同一台服务器上，**同时部署多个 Freqtrade 策略**，每个策略独立运行、互不干扰，支持日志追踪、数据库隔离、可复用一套资金或分账户配置。我们将分别以 **PM2 管理方式** 和 **Docker 多容器方式**实现部署。

---

## 💡 为什么要用多策略部署？

在真实交易或多模型回测中，单一策略难以应对多种市场环境。多策略部署的优势：

- ✅ 策略隔离运行，互不影响
- ✅ 可覆盖多种市场风格（趋势、震荡、套利…）
- ✅ 易于扩展、监控和独立调试
    

---

## 🗂️ 项目结构建议（共用模板）

我们建议为每个策略准备一个独立的子目录：

```
user_data/strategies
│   └── user_data/strategies/Test_EMA_Strategy.py
│   └── user_data/strategies/Test_MACD_Strategy.py
│   └── user_data/strategies/Test_RSI_Strategy.py
├── user_data
│   └── spot-macd-config.json
│   └── spot-ema-config.json
│   └── spot-rsi-config.json
```

每个策略目录中：

- `config.json` 是专属配置文件
- `user_data/` 包含数据库、日志等私有文件
- 策略文件 `Test_EMA_Strategy.py`/`Test_MACD_Strategy.py` `Test_RSI_Strategy`
    

---

## 🧰 方式一：使用 PM2 部署多个策略（裸机部署推荐）

### ✅ 1. 安装 PM2

```bash
npm install -g pm2
```

### ✅ 2. 创建多个策略启动命令
> ⚠️：新建`pm2.config.js`文件
```json
// pm2.config.js

module.exports = {
	apps: [
		{
			name: 'freqtrade-macd', // ← 进程名称
			script: 'freqtrade',
			interpreter: 'python3',
			args: [
				'trade', // ← 运行的命令
				'--config', 'user_data/spot-macd-config.json', // ← 配置文件路径
				'--strategy', 'Test_MACD_Strategy' // ← 策略名称
			]
		},
	
		{
			name: 'freqtrade-ema',
			script: 'freqtrade',
			interpreter: 'python3',
			args: [
				'trade',
				'--config', 'user_data/spot-ema-config.json',
				'--strategy', 'Test_EMA_Strategy'
			]
		},
		{
			name: 'freqtrade-rsi',
			script: 'freqtrade',
			interpreter: 'python3',
			args: [
				'trade',
				'--config', 'user_data/spot-rsi-config.json',
				'--strategy', 'Test_RSI_Strategy'
			]
		}
	]
}
```

### ✅ 3. 查看与管理

```text
## 启动多个策略
pm2 start pm2.config.js  # 启动全部任务

## 常用命令
pm2 stop all                   # 停止所有任务
pm2 delete all                 # 删除所有任务
pm2 list                       # 查看所有进程
pm2 mongt                      # 面包查看日志
pm2 logs freqtrade-ema         # 查看日志
pm2 stop freqtrade-ema         # 停止某个策略
pm2 restart freqtrade-rsi      # 重启某个策略
```

### ✅ 4. 设置开机自动启动

```bash
pm2 startup
pm2 save
```

---

## 🐳 方式二：使用 Docker 多容器部署（推荐线上稳定运行）

### ✅ 1. 准备每个策略的挂载目录

以当前路径为例：

```
user_data/strategies
│   └── user_data/strategies/Test_EMA_Strategy.py
│   └── user_data/strategies/Test_MACD_Strategy.py
│   └── user_data/strategies/Test_RSI_Strategy.py

user_data
│   └── spot-macd-config.json
│   └── spot-ema-config.json
│   └── spot-rsi-config.json
```

每个目录中包含：

### config.json
```json
// user_data/spot-macd-config.json
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",	//	需要配置 这样才能通过9999访问
        "listen_port": 9999,
        "verbosity": "error",
        "enable_openapi": false,
        "jwt_secret_key": "",
        "ws_token": "",
        "username": "1",
        "password": "1"
    },
```


```json
// user_data/spot-ema-config.json
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",	//	需要配置 这样才能通过9998访问
        "listen_port": 9998,
        "verbosity": "error",
        "enable_openapi": false,
        "jwt_secret_key": "",
        "ws_token": "",
        "username": "1",
        "password": "1"
    },
```

```json
// user_data/spot-rsi-config.json
    "api_server": {
        "enabled": true,
        "listen_ip_address": "0.0.0.0",	//	需要配置 这样才能通过9997访问
        "listen_port": 9997,
        "verbosity": "error",
        "enable_openapi": false,
        "jwt_secret_key": "",
        "ws_token": "",
        "username": "1",
        "password": "1"
    },
```
### ✅ 2. 编写 docker-compose.yml（推荐）

```yaml

version: "3.8"

services:
  freqtrade-macd:
    image: freqtradeorg/freqtrade:stable
    container_name: freqtrade-macd # 策略名称
    restart: unless-stopped 
    volumes:
      - ./user_data:/freqtrade/user_data
    ports:
      - "127.0.0.1:9999:9999" # docker端口映射到本地
    command: >
      trade
      --logfile /freqtrade/user_data/logs/macd.log
      --db-url sqlite:////freqtrade/user_data/trades_macd.sqlite
      --config /freqtrade/user_data/spot-macd-config.json
      --strategy Test_MACD_Strategy

  freqtrade-ema:
    image: freqtradeorg/freqtrade:stable
    container_name: freqtrade-ema
    restart: unless-stopped
    volumes:
      - ./user_data:/freqtrade/user_data
    ports:
      - "127.0.0.1:9998:9998"
    command: >
      trade
      --logfile /freqtrade/user_data/logs/ema.log
      --db-url sqlite:////freqtrade/user_data/trades_ema.sqlite
      --config /freqtrade/user_data/spot-ema-config.json
      --strategy Test_EMA_Strategy

  freqtrade-rsi:
    image: freqtradeorg/freqtrade:stable
    container_name: freqtrade-rsi
    restart: unless-stopped
    volumes:
      - ./user_data:/freqtrade/user_data
    ports:
      - "127.0.0.1:9997:9997"
    command: >
      trade
      --logfile /freqtrade/user_data/logs/rsi.log
      --db-url sqlite:////freqtrade/user_data/trades_rsi.sqlite
      --config /freqtrade/user_data/spot-rsi-config.json
      --strategy Test_RSI_Strategy

```



### ✅ 3. 启动多策略容器

```bash
docker-compose up -d
```

### ✅ 4. 管理命令

```bash
docker ps
docker logs -f freqtrade-macd
docker stop freqtrade-macd
docker-compose restart
```

### 其他
如果无法正常访问，请配置[服务代理](./003.proxy.md)

---

## 🔐 部署安全与稳定建议

|项目|建议|
|---|---|
|配置隔离|每个策略配置单独维护，包括数据库、日志|
|交易对限制|避免多个策略同时交易同一币种，造成冲突|
|dry-run 限制|实盘前务必 dry-run 多次验证|
|API 权限控制|使用只读子账户或限制交易额度|
|自动更新|可以定时拉取策略/行情更新脚本|

---

## 🧠 FAQ：常见问题解答

### ❓多个策略可以共用一个钱包或资金账户吗？

可以，但不推荐。建议为不同策略使用：
- 不同 dry-run 钱包（模拟）
- 不同子账户或现货地址（实盘）
- 或者在 config 中限制每个策略最多使用多少资金

---

## ✅ 总结

|模式|适合人群|优点|缺点|
|---|---|---|---|
|PM2 多策略|本地裸机部署者|灵活、方便|手动管理依赖|
|Docker 多容器|生产环境部署|稳定、可迁移|初学者略难配置|

---

## 📌 推荐组合
- 本地开发、测试：使用裸机 + PM2 快速部署多策略
- 正式上线、远程服务器：使用 Docker 多容器部署策略 + Nginx + Grafana 监控

