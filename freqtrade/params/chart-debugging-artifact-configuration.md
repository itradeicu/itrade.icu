> 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利



# 图都不会画，还敢说你懂策略？Freqtrade plot_config 详解

在 Freqtrade 策略开发过程中，观察图表是理解信号、调试策略最直观的方式之一。通过 `plot_config` 参数，我们可以将指标、买卖信号、止损点、平仓原因等清晰地展示在图表上，极大提高策略调试效率。

> 本文将详细介绍 `plot_config` 的使用方法与常见配置场景，让你快速掌握图表调试利器！

---

## 🧩 plot_config 是干嘛的？

`plot_config` 是策略类中的一个字典变量，配合命令行工具如：

```bash
freqtrade backtesting --plot
freqtrade plot-dataframe
```
可以自动生成图表，显示你的买卖信号、技术指标、止盈止损位置等。

✅ 常用字段说明
| 字段名                | 类型   | 作用说明                          |
| ------------------ | ---- | ----------------------------- |
| `main_plot`        | list | 主图（价格K线图）上要绘制的指标线，比如 EMA、MA 等 |
| `subplots`         | dict | 子图，如 RSI、MACD 等，在主图下方单独显示     |
| `plot_signals`     | bool | 是否在图上显示买入 / 卖出信号箭头            |
| `plot_trades`      | bool | 是否显示买卖点之间的连线                  |
| `plot_exit_reason` | bool | 是否标记每个平仓点的退出原因（止盈、止损、信号等）     |

## 🔧 示例配置

```python
plot_config = {
    'main_plot': ['ema_20', 'ema_50'],  # 在主图中画出两条 EMA
    'subplots': {
        "rsi": {
            'rsi': {'color': 'blue'}   # RSI 图中显示 RSI 指标
        },
        "macd": {
            'macd': {'color': 'green'},
            'macdsignal': {'color': 'orange'}
        }
    },
    'plot_signals': True,         # 显示买卖箭头
    'plot_trades': True,          # 显示买入卖出连线
    'plot_exit_reason': True      # 标记退出原因
}
```

## 📈 示例图解说明
+ 假设策略中使用了以下指标：
  - EMA20 和 EMA50 用于判断趋势
  - RSI 用于判断超买超卖
  - MACD 判断动能方向
  - 出现 RSI > 70 卖出，RSI < 30 买入
+ 结合 plot_config 设置后，生成的图表会：
  - 主图展示 EMA20 和 EMA50
  - 副图中展示 RSI 曲线（带色彩）
  - 下方再绘出 MACD 与信号线
  - 图上有买入 / 卖出信号箭头
  - 显示交易连线、平仓原因等


## 🔍 调试建议
| 调试目标     | 推荐配置                                    |
| -------- | --------------------------------------- |
| 查看趋势判断指标 | `main_plot` 加入 MA、EMA、布林带等              |
| 调整买入卖出逻辑 | 打开 `plot_signals`，配合 `plot_trades` 看进出点 |
| 判断平仓是否合理 | 开启 `plot_exit_reason`，观察为何止损、止盈或卖出      |
| 多个指标交互验证 | 利用 `subplots` 显示 RSI、MACD、CCI 等指标交集关系   |



## 🚀 如何启动图表生成？
要让 plot_config 生效并生成图表，你需要在命令行运行带有 --plot 参数的命令。以下是几种常用的启动方式：

#### ✅ 1. 回测时绘图
```bash
freqtrade backtesting --strategy YourStrategy --plot
```
- 会在回测结束后，自动弹出可交互图表（或在 Jupyter 中生成图）
- 图中会显示 K 线、指标线、信号箭头、交易轨迹等

#### ✅ 2. 绘制指定币种的指标图（无交易）
```bash
freqtrade plot-dataframe --strategy YourStrategy --pair BTC/USDT --timerange=20220101-20220131
```
- 只显示 populate_indicators() 中绘制的内容
- 不依赖进出场信号，适合指标调试

#### ✅ 3. 导出图表数据为 HTML 文件
```python
freqtrade backtesting --strategy YourStrategy --plot --export-html
```
- 会生成交互式 HTML 文件，方便本地查看或分享到网页
### 💡 小技巧
| 场景              | 推荐命令                                            |
| --------------- | ----------------------------------------------- |
| 快速查看策略执行过程      | `freqtrade backtesting --plot`                  |
| 查看某币种在某时间段的指标表现 | `plot-dataframe` 配合 `--pair` 和 `--timerange` 使用 |
| 保存图表供他人审阅或发布展示  | 添加 `--export-html`，生成可交互 HTML 文件                |



## ⚠️ 注意事项
- main_plot 和 subplots 中的字段名 必须和你 `populate_indicators` 中定义的一致
- 图表命令不会自动保存，需要使用 --export 或 --plot 生成
- 过多指标会使图表混乱，请有选择性绘制

## 🧠 总结
| 参数名                | 控制内容     | 是否必填 | 推荐       |
| ------------------ | -------- | ---- | -------- |
| `main_plot`        | 主图指标显示   | ✅    | EMA、布林带等 |
| `subplots`         | 子图指标展示   | ✅    | RSI、MACD |
| `plot_signals`     | 显示买卖箭头   | ✅    | True     |
| `plot_trades`      | 显示交易连接线  | ✅    | True     |
| `plot_exit_reason` | 显示平仓原因标签 | ✅    | True     |

借助 `plot_config`，你可以从数据中“看见”策略行为，是开发后期调试和优化的好帮手。让策略逻辑变得可视化、清晰化，写策略从此不再是“盲人摸象”！




