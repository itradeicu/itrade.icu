> > 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利


# ⚔️ 现货 vs 合约？交易模式与杠杆配置全解析

在使用 Freqtrade 时，交易模式的选择将直接影响你的策略逻辑、风控方式和下单行为。你可以选择**现货交易（spot）**，也可以使用支持杠杆的**合约交易（futures）**。不同模式下，相关配置项也有所不同，如 `margin_mode`、`leverage`、`liquidation_buffer` 等。

本篇将系统讲解这些配置参数的作用、适用场景和实战注意事项，帮助你合理构建风控体系。

---

## 💱 trading_mode — 交易模式设置

```json
"trading_mode": "spot"
```

+ 控制 Freqtrade 是运行在现货市场还是合约市场。
+ 可选值有：
    - "spot"：现货模式，只能买入后等待涨价卖出，不支持做空
    - "futures"：合约模式，支持杠杆、做多、做空等操作，更灵活但风险更高

#### 🟢 spot 模式特点
- 只能买涨（低买高卖），适合牛市行情
- 交易逻辑简单，无需杠杆管理
- 更适合新手或稳定策略

#### 🔴 futures 模式特点
- 可做多做空，适合震荡或熊市行情
- 支持杠杆放大收益/亏损
- 需要更多风控措施，如仓位、清算缓冲、逐仓等配置

✅ 实战建议：
- 初学者建议从 "spot" 开始；
- 熟悉后可切换到 "futures"，并开启配套的风险控制参数。

## 🧮 margin_mode — 合约保证金模式
`margin_mode` 仅在 `trading_mode: "futures"` 时有效，对`现货模式无任何作用`，即使配置也会被忽略。用于设置每笔合约交易的`保证金类型`。
```json
"trading_mode": "futures",  //  合约模式
"margin_mode": "isolated"
```
可选值：
| 值            | 含义       | 说明                                     |
| ------------ | -------- | -------------------------------------- |
| `"isolated"` | 逐仓模式（推荐） | 每笔交易仓位独立承担风险，一笔爆仓不会影响其他仓位，**推荐合约新手使用** |
| `"cross"`    | 全仓模式     | 所有仓位共享账户余额，风险集中，**操作不当可能导致爆仓波及全账户**    |

✅ 推荐配置：
- 设置为 "isolated"，即使某个仓位爆仓也不会牵连整个账户，是更稳健的选择。

## 💥 leverage — 杠杆倍数设置
Freqtrade 支持在策略中动态设置杠杆倍数, 当然也可以根据不同交易对设置不同杠杆。

#### 📌 示例策略中配置：
```python
def leverage(self, pair: str, current_time: datetime, current_rate: float,
             current_profit: float, current_cost: float, **kwargs) -> float:
    return 3.0  # 设置为3倍杠杆
```
#### ⚠️ 注意事项
- 杠杆只能在 `trading_mode = futures` 时使用；
- 返回值必须是浮点数；
- 若策略未实现 `leverage()` 方法，Freqtrade 不会主动设置杠杆，默认使用交易所账户中的设置。
- 某些交易所有最大杠杆限制，如 Binance 最大 20~125 倍。

✅ 实战建议：
- 建议使用 2~5 倍杠杆作为起步；
- 杠杆放大收益的同时也放大风险，务必结合止损、缓冲等机制。


## 🛡️ liquidation_buffer — 清算缓冲区
```json
"liquidation_buffer": 0.05
```
- 仅适用于 `futures` 模式；
- `liquidation_buffer` 会减少可用于交易的余额，避免因余额全用导致无法追加保证金，从而间接减少爆仓风险。
- 设定为 5%，表示保留账户余额中的 5% ，控制“可用资金”范围。

#### 📌 举个例子：
| 账户总资产     | `liquidation_buffer` | 最大可用资金   |
| --------- | -------------------- | -------- |
| 1000 USDT | 0.05（5%）             | 950 USDT |
| 1000 USDT | 0.2（20%）             | 800 USDT |

✅ 推荐值：
- 初学者建议设置为 0.05 ~ 0.1；
- 使用高杠杆策略时建议设置更高，例如 0.2。

## ✅ 推荐配置组合
```json
"trading_mode": "futures",
"margin_mode": "isolated",
"liquidation_buffer": 0.05
```
📌 搭配策略中添加：
```python
def leverage(self, pair, current_time, current_rate, current_profit, current_cost, **kwargs):
    return 3.0  # 设置3倍杠杆
```

## 📊 模式对比总结
| 配置项                       | 现货模式（spot） | 合约模式（futures）    |
| ------------------------- | ---------- | ---------------- |
| 是否支持做空                    | ❌ 不支持      | ✅ 支持             |
| 是否支持杠杆                    | ❌ 不支持      | ✅ 支持             |
| 风险管理要求                    | 低          | 高（需止损、仓位控制等）     |
| 推荐保证金模式                   | -          | `"isolated"`（逐仓） |
| 是否需配置杠杆逻辑                 | ❌ 无需       | ✅ 建议动态设置         |
| 是否支持 `liquidation_buffer` | ❌ 无效       | ✅ 强烈建议启用         |


## 🔐 实盘风险防控建议
| 控制项                  | 推荐做法                                   |
| -------------------- | -------------------------------------- |
| `margin_mode`        | 设置为 `"isolated"`，防止爆仓波及全账户             |
| `leverage`           | 初期建议 2\~3 倍，回测与实盘对比后再放大                |
| `liquidation_buffer` | 设置为 0.05\~0.2，避免账户全部资金暴露风险             |
| 止损配置                 | 配置 `stoploss` 或 `custom_stoploss` 强制止损 |
| 限仓配置                 | 配合 `max_open_trades` 限制持仓数量            |

## 🧠 小结清单
| 参数名                  | 描述              | 推荐值                    |
| -------------------- | --------------- | ---------------------- |
| `trading_mode`       | 设置交易模式（现货/合约）   | `"spot"` 或 `"futures"` |
| `margin_mode`        | 设置保证金模式（仅合约模式下） | `"isolated"`           |
| `liquidation_buffer` | 合约账户预留保证金百分比    | `0.05 ~ 0.2`           |
| `leverage()`         | 策略函数内动态设置杠杆倍数   | `2.0 ~ 5.0`            |

