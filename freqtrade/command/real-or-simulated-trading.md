> > 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利



# 📘 第 2 篇：《启动实盘还是模拟交易？Freqtrade trade 命令详解》

`freqtrade trade` 是启动实盘或模拟交易机器人的核心命令，也是自动化交易最终落地的关键一步。

本篇文章将带你深入理解 `trade` 命令的用法、常见参数、配置技巧以及 Docker 环境下的启动方式，适合准备实盘部署或刚完成策略回测的你。

---

## 🚀 一、基本语法

```bash
freqtrade trade \
  --config user_data/config.json \
  --strategy MyStrategy \
  --dry-run
```
参数说明
| 参数           | 含义                        |
| ------------ | ------------------------- |
| `--config`   | 指定配置文件路径                  |
| `--strategy` | 启动使用的策略类名                 |
| `--dry-run`  | 开启干跑（模拟交易）模式，**推荐默认启用**   |
| `--logfile`  | 指定日志输出位置                  |
| `--db-url`   | 指定数据库文件或连接（记录交易历史）        |
| `--userdir`  | 设置用户目录路径（默认 `user_data/`） |


## 🧪 二、什么是 Dry-run 干跑模式？
Dry-run 模式 = 不实际下单，只模拟下单并记录日志。

适用于：
+ ✅ 策略验证阶段（确保逻辑无误）
+ ✅ 实盘部署前的测试运行
+ ✅ 避免因参数配置错误造成真实亏损
一旦准备好部署实盘，可关闭该参数：
```bash
freqtrade trade --config user_data/config.json --strategy MyStrategy
```
> ⚠️ 建议在至少 7 天 dry-run 测试后再上线真实交易！

### 🧩 三、支持多策略运行
可以通过命令行参数加载多个策略或策略路径：
```bash
freqtrade trade \
  --config user_data/config.json \
  --strategy-path user_data/strategies \
  --strategy MyStrategyA MyStrategyB
```
或者组合多个 config 文件（适用于多账户 / 多平台）：

```bash
freqtrade trade -c spot_config.json -c futures_config.json
```
注意多策略时：
+ 所有策略需在指定目录中可被导入
+ 可使用 --strategy-path 指定额外路径

## 🐳 四、使用 Docker 启动 trade 命令
在 Docker 容器中运行更安全、更易部署，推荐使用 docker-compose：
```bash
docker compose run --rm freqtrade trade \
  --config /quants/freqtrade/user_data/config.json \
  --strategy MyStrategy \
  --dry-run
```
配套 docker-compose.yml 示例：
```yaml
services:
  freqtrade:
    image: freqtradeorg/freqtrade:stable
    volumes:
      - ./user_data:/quants/freqtrade/user_data
    command: >
      trade
      --config /quants/freqtrade/user_data/config.json
      --strategy MyStrategy
      --logfile /quants/freqtrade/user_data/logs/freqtrade.log
```
启动后访问 Web UI 可实时查看交易情况：
```json
http://localhost:8888
```
## 🧷 五、一些推荐配置项
在 config.json 中推荐启用以下配置项确保安全：
```json
{
  "dry_run_wallet": 1000,
  "dry_run": true,
  "max_open_trades": 3,
  "stake_currency": "USDT",
  "tradable_balance_ratio": 0.9,
  "timeframe": "15m"
}
```
同时建议配置：
+ exchange → key/secret: 实盘需要提供真实 API 密钥
+ logging → logfile: 日志输出
+ db_url: 连接 SQLite/Postgres 等存储交易记录

## ✅ 六、实盘启动前 Checklist
| 检查项                | 建议                    |
| ------------------ | --------------------- |
| 策略是否通过回测           | ✅ 至少覆盖 6 个月以上历史       |
| 是否在 Dry-run 模式下运行过 | ✅ 模拟运行 7 天以上          |
| config.json 配置是否完整 | ✅ 包含风控、币种、杠杆等         |
| 是否设置了 API Key      | ✅ 且建议设置 IP 白名单        |
| 是否观察日志和错误输出        | ✅ 使用 `--logfile` 保存记录 |


## 📌 总结
trade 命令是 Freqtrade 的「最后一步」命令，也是最接近实盘收益的一环。
本篇文章梳理了：
+ trade 命令的基本语法与参数
+ Dry-run 的优势与推荐做法
+ 多策略 / 多 config 的组合方式
+ Docker 启动实盘的全流程
掌握这些技巧后，你就可以从一个策略开发者，迈向真正的自动交易实盘部署者。