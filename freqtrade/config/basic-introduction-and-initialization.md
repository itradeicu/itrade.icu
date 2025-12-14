> > 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利


# config.json 基础入门与初始化

在使用 Freqtrade 进行策略回测、数据下载或实盘交易前，最核心的准备就是创建并配置好 `config.json` 文件。它是整个交易框架的“总指挥”，决定了你连接哪个交易所、如何交易、策略如何运行、使用多少交易资金、如何分配余额等。

本篇将带你系统了解 config.json 的作用、生成方式、文件结构与编辑技巧，帮助你快速上手并少走弯路。

---

## 🧱 config.json 是什么？

`config.json` 是 Freqtrade 的**主配置文件**，用于集中管理整个项目的运行参数。它是一份标准的 JSON 格式文本文件，包含了如下信息：

- 交易所账号信息（API Key/Secret）
- 交易币种与金额设置
- 策略运行规则（如最大持仓数、是否做空等）
- 数据周期、回测设置
- 限价单 / 市价单的控制逻辑
- 风控相关配置（止损、止盈、滑点控制等）
- Webhook / Telegram 等通知渠道（可选）

无论你是做数据分析、回测优化，还是实盘部署，这份配置文件都是不可或缺的基础。

---

## 🆕 如何生成 config.json？

Freqtrade 提供了一个命令行工具，可一键生成默认配置模板，非常适合初学者快速开始。

```bash
freqtrade new-config --config user_data/config.json
```
- --config 后接你的目标路径（推荐使用 user_data/config.json）
- 如果目录不存在会自动创建
- 文件生成后可使用任意文本编辑器进行修改



## 📂 推荐的文件结构
Freqtrade 项目推荐的基本目录结构如下：
```plaintext
freqtrade/
├── user_data/
│   ├── config.json         ← ✅ 主配置文件
│   ├── strategies/         ← 策略文件夹（.py）
│   ├── logs/               ← 日志输出
│   ├── ...
├── freqtrade/              ← 项目本体代码（或虚拟环境）
```
将 config.json 放在 user_data/ 文件夹下是官方推荐做法，有助于路径一致性和备份管理。

## 🐳 Docker 运行下的目录结构
如果你是通过官方推荐方式使用 Docker 启动 Freqtrade（推荐！），那么目录结构是由 Docker 映射 volume（数据卷）控制的，和普通本地运行略有差异。

```plaintext
ft_userdata/
├── user_data/
│   ├── config.json          ← ✅ 主配置文件（用于修改运行参数）
│   ├── strategies/          ← 策略文件夹（.py）
│   ├── hyperopt/            ← 参数优化结果
│   ├── logs/                ← 日志输出
│   ├── ...
├── docker-compose.yml       ← 启动服务的入口配置
```

## 🔍 初学者预览示例
下面是一个最基础版本的 config.json 配置预览（截取前部分）：
```json
{
  "max_open_trades": 3,
  "stake_currency": "USDT",
  "stake_amount": 100,
  "tradable_balance_ratio": 0.95,
  "dry_run": true,
  "exchange": {
    "name": "binance",
    "key": "your_api_key",
    "secret": "your_api_secret",
    "password": "your_api_password"  // 仅部分交易所如 OKX Kraken 需要
  }
}
```
字段解释：
- max_open_trades：最多允许几个仓位同时打开（防止爆仓）
- stake_currency：交易资金使用的基础币种，通常是 USDT
- stake_amount：每次交易使用多少资金
- dry_run：是否开启模拟交易（true 表示不动真金白银）

## 🛠️ 修改配置时的调试技巧
1. ✅ 修改后可用以下命令检查配置的`EXCHANGE API key` 是否有效：
```bash
freqtrade list-markets --config user_data/config.json
```
| 是否配置 API Key | list-markets 能否执行？ | 是否能交易？ | 说明               |
| ------------ | ------------------ | ------ | ---------------- |
| ✅ 已配置         | ✅ 支持              | ✅ 支持  | 可用于实盘交易，支持完整功能   |
| ❌ 未配置        | ✅ 视交易所而定           | ❌ 否    | 仅部分交易所允许匿名查看市场列表 |

2. ✅ 也可以在回测前先跑一次策略初始化看有没有报错：
```bash
freqtrade backtesting --config user_data/config.json
```

## 🧠 小结
| 关键点    | 建议                                    |
| ------ | ------------------------------------- |
| 配置文件名称 | 固定为 `config.json`，推荐放在 `user_data/` 下 |
| 生成命令   | `freqtrade new-config --config 路径`    |
| 出错排查   | 使用 `backtesting` 或 `list-markets` 检查  |
| 是否版本控制 | ✅ 强烈建议将 config.json 纳入 Git 管理         |




