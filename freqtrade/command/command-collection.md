> 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利




# 📘 第 1 篇：《Freqtrade 常用命令大全，一文掌握量化交易机器人操作》

`一文掌握量化交易机器人从入门到实盘的关键命令！`

Freqtrade 是一个强大且开源的加密货币自动交易框架，它支持策略开发、历史回测、参数优化、数据分析和实盘交易。  
但对于初学者来说，`各类命令的功能和用途可能不太直观`。本文将对 Freqtrade 所有核心命令进行分类、解释，并给出常用场景和命令行示例。



## 🎯 命令结构总览

Freqtrade 的命令行工具以 `freqtrade` 为主命令，通过不同子命令完成不同任务：

```bash
freqtrade <subcommand> [options]
```

你可以通过 freqtrade -h 查看主命令帮助，或 freqtrade `<subcommand>-h` 查看某个子命令的详细参数。
## 📦 命令分类速查表
  | 分类      | 命令示例                                      | 用途概览                |
| ------- | ----------------------------------------- | ------------------- |
| 数据处理    | `download-data`, `convert-data`           | 下载 / 处理历史市场数据       |
| 策略开发与测试 | `new-strategy`, `backtesting`, `hyperopt` | 创建和测试交易策略           |
| 实盘交易    | `trade`, `webserver`                      | 启动机器人，执行交易或 Dry-run |
| 系统配置    | `new-config`, `create-userdir`            | 初始化配置和项目结构          |
| 查询与诊断   | `show-trades`, `list-data`, `list-pairs`  | 查询策略、数据、交易记录        |
| 可视化分析   | `plot-dataframe`                          | 图表可视化策略行为           |

  
  
## 🚀 1. 实盘与模拟交易命令
####  trade - 启动交易机器人（实盘或干跑）

```bash
  freqtrade trade \
  --config user_data/config.json \
  --strategy MyStrategy \
  --dry-run
--dry-run：模拟交易，不真实下单（默认建议开启）
```
+ --db-url：指定数据库（用于存储交易历史）
+ --logfile：保存日志输出位置
> ⚠️ 启动前请确保策略已通过回测，且 config.json 设置正确！

  
## 📥 2. 数据下载与处理命令
#### download-data - 下载历史行情数据
```bash
freqtrade download-data \
  --exchange binance \
  --pairs BTC/USDT \
  --timeframes 1h \
  --timerange 20230101-20230301
--exchange: 支持如 binance、bybit 等多个交易所
```
+ --pairs: 可一次指定多个币对
+ --timeframes: 可下载 1m, 5m, 15m, 1h, 1d 等周期数据

#### convert-data - 转换数据格式（CSV → JSON）
如果使用外部数据源（如 CCXT、Kaggle），可先转换为 Freqtrade 格式。

  
 ## 🧪 3. 策略开发与回测命令
#### new-strategy - 创建策略模板
```bash
  freqtrade new-strategy --strategy MyNewStrategy
```
  会在 user_data/strategies/ 下生成一个带结构注释的 .py 文件。

#### backtesting - 回测策略表现
```bash
  freqtrade backtesting \
  --config user_data/config.json \
  --strategy MyStrategy \
  --timeframe 15m \
  --timerange 20220101-20230101
  ```
+ 模拟历史交易，评估策略盈亏
+ 可设置时间周期、币种等
+ 建议配合 backtesting-show 查看图表结果

#### hyperopt - 参数优化
```bash
  freqtrade hyperopt \
  --config user_data/config.json \
  --strategy MyStrategy \
  --hyperopt-loss SharpeHyperOptLoss
  ````
+ 自动搜索最优参数组合（如 RSI 阈值、止盈比例等）
+ 支持多种评估指标（Sharpe、Sortino、纯收益等）
```
## 📊 4. 数据可视化命令
#### plot-dataframe - 策略行为图表可视化
```bash
  freqtrade plot-dataframe \
  --config user_data/config.json \
  --strategy MyStrategy \
  --timerange 20230101-20230201
```
+ 生成 HTML 图，展示买卖点、K线、指标等
+ 图表保存在 user_data/plot/ 目录下

## ⚙️ 5. 配置与项目初始化命令
#### new-config - 创建配置文件
```bash
  freqtrade new-config --config user_data/config.json
  ```
包含交易对、策略名、风控设置、资金管理等基础内容。

  ## create-userdir - 初始化项目结构
```bash
  freqtrade create-userdir --userdir user_data
```
  会创建常用目录结构（logs、data、strategies、configs）

## 🔍 6. 查询与工具类命令
  | 命令                | 功能说明                  |
| ----------------- | --------------------- |
| `show-trades`     | 显示交易记录 / 回测记录         |
| `list-data`       | 查看本地有哪些历史数据           |
| `list-pairs`      | 显示当前配置下支持的币对          |
| `list-exchanges`  | 查看 Freqtrade 支持的交易所   |
| `list-strategies` | 显示 strategies 目录下的策略类 |
| `list-timeframes` | 查看支持的时间周期格式           |

  
## ✅ 日常建议重点掌握的命令：
```bash
  freqtrade download-data
  freqtrade backtesting
  freqtrade hyperopt
  freqtrade trade
  freqtrade show-trades
```
  
## 🐳 使用 Docker 的建议
大多数命令在 Docker 下也可运行：
```bash
  docker compose run --rm freqtrade trade \
  --config /quants/freqtrade/user_data/config.json \
  --strategy MyStrategy
```
确保 docker-compose.yml 中挂载路径正确。

## 📌 总结
Freqtrade 命令行覆盖了整个量化流程：从数据 → 回测 → 优化 → 实盘，非常适合开发者和策略研究者使用。

建议你从如下步骤入手：
+ 1.下载数据（download-data）
以通过 freqtrade -h 查看主命令帮助，或 freqtrade `<subcommand> -h` 查看某个子命令的详细参数。+ 2.编写策略（new-strategy）
+ 3.回测调试（backtesting + hyperopt）
+ 4.实盘运行（trade + Web UI）
+ 5.可视化分析（plot-dataframe）
掌握这些命令，你就能完全独立驾驭一套加密货币自动交易系统！
  

  
  
  
  
  
  
  
  
  