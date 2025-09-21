获取源码请访问[https://www.itrade.icu](https://www.itrade.icu)

# 📘 第 6 篇：《看图说话！plot-dataframe 图表可视化教程》

在策略开发过程中，回测结果常常以表格形式呈现，难以快速定位问题。而 `plot-dataframe` 命令可以将回测的买卖点、指标线、价格走势可视化为图表，助你一眼看出策略表现。

---

## 🎯 1. 基础用法：绘制图表

```bash
freqtrade plot-dataframe \
  --config user_data/config.json \
  --strategy MyStrategy \
  --timerange 20230101-20230201
```
执行后会在 `user_data/plot/` 下生成一个 .html 文件，可直接双击浏览器查看，包含以下内容：
- K线价格走势
- 买卖点（Buy/Sell 箭头）
- 技术指标（如 EMA、MACD 等）
## 🧾 2. 参数详解
| 参数                 | 含义                              |
| ------------------ | ------------------------------- |
| `--config`         | 配置文件路径，需包含交易对、时间周期等             |
| `--strategy`       | 策略类名（如 `MyStrategy`）            |
| `--timerange`      | 指定绘图时间段，格式如 `20230101-20230201` |
| `--indicators1`    | 绘制在主图上的指标（如 EMA、close）          |
| `--indicators2`    | 副图指标（如 RSI、MACD）                |
| `--exportfilename` | 导出文件路径（支持 `.html` 或 `.png`）     |
| `--userdir`        | 自定义 user\_data 路径（默认即可）         |

## 📐 3. 添加自定义指标
你可以在图表中加入额外的指标，以验证信号逻辑：

代码示例：
```python
def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
    dataframe['ema'] = ta.EMA(dataframe['close'], timeperiod=20)
    dataframe['fast_ema'] = ta.EMA(dataframe['close'], timeperiod=10)
    dataframe['slow_ema'] = ta.EMA(dataframe['close'], timeperiod=50)
    dataframe['rsi'] = ta.RSI(dataframe['close'], timeperiod=14)
    macd, macdsignal, macdhist = ta.MACD(dataframe['close'])
    dataframe['macd'] = macd
    return dataframe
```
- --indicators1 会绘制在主图（价格图）上，比如 EMA 线。
- --indicators2 会绘制在副图中，比如 RSI、MACD。

完整示例：
```bash
freqtrade plot-dataframe \
  --config user_data/config.json \
  --strategy MyStrategy \
  --timerange 20230101-20230201 \
  --indicators1 close ema fast_ema slow_ema \
  --indicators2 rsi macd
```
#### ❗注意：
这些指标名称必须是你在策略类的 `populate_indicators()` 方法中通过 ta 或自定义计算出来并添加进 `dataframe` 的列名（即 `DataFrame` 的列名）。否则，它们不会显示在图表上。
+ 这些名称必须和你 dataframe 中的列名完全一致。
+ 否则运行不会报错，但图表不会显示你想看的线。
+ 指标需先在策略的 `populate_indicators()` 中定义，否则不会生效。


## 💾 4. 导出为 HTML / PNG
默认输出为 HTML 文件，如需指定：
```bash
--exportfilename user_data/plot/myplot.html
```

如需导出 PNG（静态图）：
```bash
--exportfilename user_data/plot/myplot.png
```

> 📌 注意：导出 PNG 需要额外安装如 Puppeteer 或 headless Chrome，初学者建议使用 HTML 格式查看。

## 🐳 5. Docker 环境运行示例
在 Docker 中使用该命令如下：

```bash 
docker compose run --rm freqtrade plot-dataframe \
  --config /quants/freqtrade/user_data/config.json \
  --strategy MyStrategy \
  --timerange 20230101-20230201
```
确保 docker-compose.yml 中正确挂载了 /quants/freqtrade/user_data 目录。

## ✅ 6. 使用建议
| 用途         | 方法                 |
| ---------- | ------------------ |
| 检查策略逻辑是否合理 | 查看买卖点是否在合适位置       |
| 辅助调试       | 比对指标与信号关系          |
| 策略分享       | 生成图表后输出为 HTML，方便演示 |
| 评估指标表现     | 同时绘制多个指标看是否冗余      |


## 📌 总结
plot-dataframe 是 Freqtrade 提供的可视化利器，尤其适合调试复杂策略和验证买卖逻辑。

#### 推荐使用流程：
1. 回测策略：
```bash
freqtrade backtesting \
  --config user_data/config.json \
  --strategy MyStrategy \
  --timeframe 15m \
  --timerange 20220101-20230101
```
2. 绘制图表：
````bash
freqtrade plot-dataframe \
  --config user_data/config.json \
  --strategy MyStrategy \
  --timerange 20250601-20250626
````

3. 分析图表：
- 判断策略买入是否太早/太晚？
- 是否频繁误报信号？
- 各种指标是否有效？
掌握 `plot-dataframe`，从此策略优化有据可依、调优更高效！





