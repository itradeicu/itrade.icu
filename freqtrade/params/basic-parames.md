> > 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利


# Freqtrade策略不跑、跑错、跑飞？那可能是这几个参数没配好

在使用 Freqtrade 编写和运行策略之前，有几个最基础的参数你必须先搞懂。这些参数控制了策略的数据周期、预加载行为、并发交易数、安全校验等，直接影响策略的执行效果和稳定性。

---

## ⏱️ timeframe — 主时间周期

设置策略使用的 K 线周期。例如设置为 `'5m'` 表示使用 5 分钟 K 线作为信号和指标的基础。

```python
timeframe = '5m'  # 每根K线为5分钟
```
⚠️ 注意事项：
- 常见值：`1m`、`5m`、`15m`、`1h`、`4h`、`1d`
- 该参数决定了策略计算频率与信号分辨率
- 回测或实盘数据也必须对应下载匹配时间周期

## 🕐 startup_candle_count — 初始化加载K线数量
策略启动时需要加载的最小K线数量，保证指标计算完整性，避免前几根K线信号失真。

```python
startup_candle_count = 50  # 启动时预加载50根K线
```
⚠️ 注意事项：
- 一般设置为所有用到指标中“最大周期” × 3 ~ 5 倍
- 例如 RSI(14) 通常建议设置至少 50


## 📊 max_open_trades — 最大持仓数
控制策略最多同时持有几个交易对，防止过度分散、爆仓或杠杆使用失控。

```python
max_open_trades = 3  # 最多开3个仓位
```
⚠️ 注意事项：
- 设置为 1 可测试策略对单币种判断能力
- 多币种策略需注意资金分配和风险管理


## 🕛 process_only_new_candles — 是否只在新K线触发逻辑
控制是否只在 K 线闭合时执行策略逻辑。默认为 `True`，可避免重复执行、提升稳定性。

```python
process_only_new_candles = True
```

| 参数值   | 表现            |
| ----- | ------------- |
| True  | 只在每根 K 线闭合后执行 |
| False | 每秒都可能执行（高频波动） |


## 🧱 disable_dataframe_checks — 是否关闭 DataFrame 检查
禁用 pandas `DataFrame` 的一致性检查，以提升性能。但不推荐开发初期关闭。

```python
disable_dataframe_checks = False  # 启用检查（推荐）
```
⚠️ 注意事项：
- 关闭后可能导致隐藏的指标错误不被发现
- 适合性能优化阶段使用


## 📉 can_short — 是否支持做空（只限合约）
控制策略是否允许开空单（做空），现货无法使用，只适用于支持`合约交易`的交易所。

```python
can_short = True
```
⚠️ 注意事项：
- 开启后需同步设置 `minimal_roi`、`stoploss`、`populate_exit_trend` 等支持做空逻辑
- 仅合约模式才能用，现货会报错

## ✅ 总结清单
| 参数名                        | 含义              | 推荐默认值   |
| -------------------------- | --------------- | ------- |
| `timeframe`                | 策略主K线周期         | `'5m'`  |
| `startup_candle_count`     | 启动时加载多少K线       | `50+`   |
| `max_open_trades`          | 最大并发交易数量        | `3~5`   |
| `process_only_new_candles` | 是否只在K线闭合后触发逻辑   | `True`  |
| `disable_dataframe_checks` | 是否关闭DataFrame校验 | `False` |
| `can_short`                | 是否允许做空（限合约）     | `False` |




