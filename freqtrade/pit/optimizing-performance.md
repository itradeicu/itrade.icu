> > 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利



## ✅ 一图总结：减少 Freqtrade 内存占用的方法

|分类|方法|是否推荐|说明|
|---|---|---|---|
|🧹 精简策略|减少用到的技术指标 / pandas 操作|✅ 强烈推荐|每个指标都会产生历史缓存和多列数据|
|📉 减少交易对数量|配置里精简 `pair_whitelist`|✅ 推荐|每个交易对都会加载历史 K 线 + 分析缓存|
|⏱ 减少历史数据长度|设置 `startup_candles` 数量更少|✅ 推荐|默认是 1000，改成 300 就能省下很多内存|
|📦 使用轻量策略模式|使用 `MinimalStrategy` 模式进行测试|✅ 可选|用最轻的模板策略进行调试或开发|
|📁 减少 `cached` 数据保存|关闭 `dry-run-wallet`, `edge`, `trade_models` 等多余模块|✅ 仅在非 dry-run 实盘使用||
|🚫 禁用某些功能|禁用 Plot、Telegram、Webserver、TradeModel 等模块|✅ 推荐（尤其是 dry-run 不需要）||
|🔧 改用 PostgreSQL|避免 SQLite 的文件锁 / 缓存机制|✅ 推荐|SQLite 会占内存缓存，Postgres 更稳定|
|🐍 不用 pandas 变量保留历史值|不在策略中 `self.df = dataframe`|✅ 很重要|避免内存残留历史 DataFrame|

---

## 🧠 实用技巧详解：

---

### ✅ 1. 减少 `startup_candles`

在 `config.json` 或 CLI 添加：

```json
"startup_candle_count": 300
```

或命令行参数：

```bash
--startup-candle-count 300
```

默认是 1000，代表每个交易对启动时加载 1000 根 K 线，如果你策略只用到最近的 100 根，那么没必要加载那么多。

---

### ✅ 2. 精简 `pair_whitelist`

每个交易对会：

- 下载历史数据
    
- 每分钟跑一遍 `populate_indicators`、`populate_entry_trend`
    
- 占一份策略缓存空间
    

如果你部署杠杆策略，但 whitelist 里有 20 个币对，那么内存很快就突破 500MB。

只保留你需要的核心交易对，比如：

```json
"pair_whitelist": ["BTC/USDT", "ETH/USDT", "SOL/USDT"]
```

---

### ✅ 3. 精简策略中指标数量和变量

- 避免无用的指标，比如加了 MACD、RSI、EMA 但策略实际没用；
    
- 避免写：
    

```python
self.df = dataframe  # ❌ 这样会在每轮tick中缓存整个DataFrame
```

会导致旧数据常驻在内存中，改为：

```python
# 仅在函数内用 dataframe，避免保留在 self 上
```

---

### ✅ 4. 关闭用不到的组件（适合 dry-run 或轻量实盘）

在 config 中关闭以下内容：

```json
"telegram": {
  "enabled": false
},
"webserver": {
  "enabled": false
},
"dry_run_wallet": {
  "enabled": false
},
"trade_models": {
  "enabled": false
}
```

这些组件虽然实用，但会启用后台线程和内存缓冲区，实盘中可以开启，测试阶段建议关闭。

---

### ✅ 5. 启用 swap 或限制内存上限（不减占用但防止崩）

- 启用系统 swap 分区
    
- 或用 PM2 加参数限制：
    

```bash
--max-memory-restart 500M
```

---

## 🛠 可选进阶：换用 PostgreSQL 数据库

SQLite 虽然方便，但会在本地占用缓存，且写入时锁文件，适合轻量单策略。如果你部署多个策略实例：

```json
"db_url": "postgresql://user:password@localhost/freqtrade"
```

PostgreSQL 会更稳定，CPU/内存占用都更好控制。

---

## ✅ 总结建议（快速执行版）

### 推荐立即做的操作：

- ✅ 设置 `"startup_candle_count": 300`
    
- ✅ 限制 `pair_whitelist` 数量到 3～5 个
    
- ✅ 删除策略中未用的指标
    
- ✅ 不要在策略中使用 `self.df = dataframe`
    
- ✅ 关闭 telegram / webserver / trade_models
    
- ✅ 添加 `--max-memory-restart 500M` 保护机制
    
