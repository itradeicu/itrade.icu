获取源码请访问[https://www.itrade.icu](https://www.itrade.icu)

# 别被旧信号骗了！教你用 Freqtrade 精准把握交易时机

在策略开发中，信号的时效性对交易结果影响巨大。Freqtrade 提供了多种参数帮助你精准控制信号的触发时机和数据处理频率，避免因信号过早或过迟而错失最佳买卖点。

---

## ⏳ ignore_buying_expired_candle_after — 过期K线买入信号忽略时间

```python
ignore_buying_expired_candle_after = 30  # 单位：秒
```
- 控制在当前K线（蜡烛）关闭后，买入信号仍允许生效的最大时间（秒）
- 例如设置为30秒，意味着K线关闭后30秒内依然接受买入信号
- 超过该时间，基于已关闭K线的买入信号将被忽略，防止因信号过时导致错误买入

适用场景
- 对于快速波动的市场，防止基于旧信号频繁交易
- 配合高频策略调整信号响应时间，避免错失最佳入场点

## ⏰ process_only_new_candles — 是否只在新K线生成时执行策略逻辑
`process_only_new_candles` 是 Freqtrade 策略中的一个布尔参数，用于控制 `populate_indicators` 等函数(每根K线都执行的函数)是否只在新的 K 线（蜡烛）生成时运行。默认为`True`
#### 代码示例
```python
class MyStrategy(IStrategy):
    process_only_new_candles = True  # 仅在新K线完成后运行函数

    timeframe = '5m'
    stoploss = -0.1
    minimal_roi = {"0": 0.05}

    def populate_indicators(self, dataframe, metadata):
        # 这里的指标只会在每根5分钟K线结束时计算一次x
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=14)
        return dataframe
```
- 控制策略中的指标计算与信号生成是否只在新的K线完全闭合后执行
- 默认为`True`，即仅在每根K线结束时运行，避免使用未完成K线数据导致的信号噪音
- 设为`False`时，策略会在K线形成过程中频繁计算，适合需要高频数据更新的策略，但可能增加假信号和计算负担

### 行为对比
| 参数值   | 行为表现            |
| ----- | --------------- |
| True  | 只在每根K线闭合后执行信号计算 |
| False | 持续实时计算，信号可能频繁变化 |

## ✅ 总结清单
| 参数名                                  | 功能描述                       | 推荐默认值              |
| ------------------------------------ | -------------------------- | ------------------ |
| `ignore_buying_expired_candle_after` | 设置旧K线买入信号失效时间，防止信号过期导致错误买入 | `0`（关闭此限制）或按策略需求调整 |
| `process_only_new_candles`           | 仅在新K线闭合后执行策略逻辑，避免噪音信号      | `True`（推荐）         |
