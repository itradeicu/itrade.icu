> > 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利




## 🔍 第 8 篇：量化交易之tradeUI和webserverUI 区别?
虽然两者常常一起用，但它们的作用和启动逻辑 完全不同，下面为你拆解对比 👇
| 项目          | `freqtrade trade` | `freqtrade webserver`                                  |
| ----------- | ----------------- | ------------------------------------------------------ |
| ✅ 启动内容      | 启动交易机器人（实盘或干跑）    | 启动可视化 UI 服务（用于查看数据）                                    |
| ⚙️ 核心功能     | 执行策略、下单、监控市场      | 图形化展示策略运行/回测结果                                         |
| 🧠 是否运行策略逻辑 | ✅ 是（实时运行策略）       | ❌ 否（仅读取数据展示）                                           |
| 📦 数据来源     | 实时市场数据、订单执行       | 本地 SQLite 数据库（或策略输出）                                   |
| ⏱ 场景用途      | 正式交易运行（模拟/实盘）     | 浏览器查看策略表现/订单信息                                         |
| 🔗 是否连接交易所  | ✅ 是               | ❌ 否                                                    |
| 📈 查看回测结果   | ❌ 否               | ✅ 支持回测可视化                                              |
| 🚀 浏览器访问地址  | 可选 UI，后台运行        | http://1270.0.01:8080（默认） |


✅ 使用场景区分
## 1. trade 是运行机器人
你可以选择 实盘交易 或 模拟交易（dry-run）：
```bash
freqtrade trade \
  --config user_data/config.json \
  --strategy MyStrategy \
  --dry-run
```
- 会不断抓取实时市场数据
- 运行策略逻辑（如买入/卖出信号）
- 连接交易所，记录订单、资金、利润
- 将所有数据写入本地数据库（SQLite）

> 💡 没有它，机器人就不会动！
## 2. webserver 是图形化展示界面
它只是读取数据，并提供一个浏览器页面：
```bash
freqtrade webserver \
  --config user_data/config.json \
  --username admin --password 123456
```
- 显示当前持仓、交易历史、策略名称
- 可以查看实盘运行中的策略
- 也可以用来查看回测结果图表（如使用 backtesting 后）

> ❗ 不会自动运行策略，也不会连接交易所！


![](https://fastly.jsdelivr.net/gh/bucketio/img15@main/2025/07/19/1752933518965-d816f2f1-f828-4207-bcb1-78e8732cfa9a.png)


## 🔄 关系总结
`trade` 是“机器人引擎”，`webserver` 是“图形界面” 
你可以这么理解：
- trade 是真正的执行器
- webserver 是观察窗口

如果你只运行了 webserver，但没有运行 trade，你只能看到之前记录的内容，而没有任何新交易产生。

## 🧩 实战建议（Docker 环境）
```yaml
services:
  trader:
    image: freqtradeorg/freqtrade:stable
    command: >
      trade
      --config /quants/freqtrade/user_data/config.json
      --strategy MyStrategy

  ui:
    image: freqtradeorg/freqtrade:stable
    command: >
      webserver
      --config /quants/freqtrade/user_data/config.json
      --username admin
      --password 123456
    ports:
      - "8080:8080"
```
然后浏览器打开：`http://localhost:8080`即可访问你的交易机器人后台。

  如果觉得有帮助，欢迎`点赞` / `收藏` / `关注我`，我会持续输出优质量化策略与实战技巧。
> 👉 点击`阅读全文`，获取完整策略与回测细节。