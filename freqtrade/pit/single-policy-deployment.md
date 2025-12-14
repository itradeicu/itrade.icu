
> 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利



# 🚀 Freqtrade 单策略部署实战指南（源码 + Docker）

> 本文将手把手教你如何部署一个**独立运行的 Freqtrade 策略**，支持两种方式：源码部署与 Docker 部署，适用于实盘与模拟交易环境。

---

## 📦 一、什么是单策略部署？

单策略部署指的是：**一个独立的策略类，配合一份独立的配置文件、数据库、运行进程**，独立完成买卖判断与交易执行。相比多策略统一管理，单策略部署更简单、可控，便于调试和运维。

---

## 🧰 二、准备工作

### ✅ 安装依赖（仅源码部署用）

```bash
# 安装 Python 环境
python3.10 -m venv .env
source .env/bin/activate
pip install --upgrade pip

# 安装 Freqtrade
git clone https://github.com/freqtrade/freqtrade.git
cd freqtrade
./setup.sh -i
```

### ✅ 创建策略目录

```bash
mkdir -p ~/freqtrade-bots/ema
cd ~/freqtrade-bots/ema
freqtrade new-config
freqtrade new-strategy --strategy EMAStrategy
```

---

## ⚙️ 三、配置文件说明

打开 `config.json`，根据实际需求修改，重点关注以下字段：

```jsonc
{
  "strategy": "EMAStrategy",
  "timeframe": "5m",
  "stake_currency": "USDT",
  "stake_amount": 100,
  "dry_run": true,
  "db_url": "sqlite:///./user_data/trades_ema.sqlite",
  "exchange": {
    "name": "binance",
    "key": "YOUR_API_KEY",
    "secret": "YOUR_API_SECRET",
    "ccxt_config": {},
    "ccxt_async_config": {},
    "pair_whitelist": ["BTC/USDT", "ETH/USDT"]
  }
}
```

📌 **重要建议：**

- **不要共用数据库文件**，每个策略使用不同路径（`trades_xxx.sqlite`）。
    
- 实盘设置 `"dry_run": false`，注意风险。
    

---

## 🚀 四、部署方式一：源码运行（裸机）

### ✅ 启动策略

```bash
cd ~/freqtrade-bots/ema
freqtrade trade --config config.json --strategy EMAStrategy
```

### ⏱️ 后台运行（可选）

推荐使用 `screen` 或 `tmux`：

```bash
# 启动新会话
screen -S freqtrade-ema

# 启动 bot
freqtrade trade --config config.json --strategy EMAStrategy

# 使用 Ctrl+A+D 可将其挂起后台运行
```

---

## 🐳 五、部署方式二：Docker 单策略部署

### ✅ 第一步：准备目录结构

```bash
mkdir -p ~/freqtrade-docker/ema
cd ~/freqtrade-docker/ema
# 拷贝 config.json、EMAStrategy.py 等文件
```

### ✅ 第二步：运行容器

```bash
docker run -d \
  --name freqtrade-ema \
  -v $PWD:/freqtrade/user_data \
  freqtradeorg/freqtrade:stable \
  trade --config user_data/config.json --strategy EMAStrategy
```

### ✅ 参数说明：

|参数|说明|
|---|---|
|`-v $PWD:/freqtrade/user_data`|将当前目录挂载为容器内 user_data 目录|
|`--strategy`|指定策略类名|
|`--config`|指定配置文件路径（容器内路径）|

### ✅ 查看日志：

```bash
docker logs -f freqtrade-ema
```

---

## ✅ 六、停止与更新

### 停止运行：

- 裸机部署：
    
    ```bash
    Ctrl + C（或关闭 screen / tmux）
    ```
    
- Docker 部署：
    
    ```bash
    docker stop freqtrade-ema
    docker rm freqtrade-ema
    ```
    

### 更新 Freqtrade（Docker）：

```bash
docker pull freqtradeorg/freqtrade:stable
```

---

## 🎯 七、部署建议

|建议项|说明|
|---|---|
|✅ 独立配置|每个策略单独配置文件、数据库|
|✅ 使用模拟模式测试|实盘前先通过 `--dry-run` 测试策略表现|
|✅ 使用 screen/tmux|保证源码部署不会因断网退出|
|✅ 自动重启（可选）|Docker 可配合 `restart: always`，裸机可用 systemd|

---

## 📌 结语

通过本文，你已经掌握了两种部署方式：

- 🐍 **源码部署**：适合开发、调试阶段，灵活方便
    
- 🐳 **Docker 部署**：适合稳定运行，易于迁移与维护
    

无论哪种方式，**策略独立部署能极大提升运行稳定性与可控性**，是构建高可用交易系统的第一步。

---

如果你还需要实现 **多策略并行部署**、**K线数据共享**、**日志统一管理**，欢迎继续关注我们后续的实战系列。

如需完整模板目录或自动部署脚本，也可以告诉我，我可以为你生成。