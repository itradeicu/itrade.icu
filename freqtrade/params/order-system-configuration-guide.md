> 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利


# 限价挂不上、市价又滑点？一文搞懂 Freqtrade 下单机制

在 Freqtrade 策略执行中，如何下单、订单有效期多久、是否使用交易所原生止损单，都会直接影响策略执行效率与资金安全。订单系统配置可以说是策略实盘稳定运行的“最后一公里”，本篇将全面解读和示例这些关键参数。

---

## 📦 order_types — 控制下单方式

```python
order_types = {
    "entry": "limit",      # 入场为限价单
    "exit": "limit",       # 出场为限价单
    "stoploss": "market"   # 止损为市价单
}
```
#### 支持的下单类型：
- `limit`：限价单（默认），挂单等待成交，滑点更小，但可能错过机会。
- `market`：市价单，立即成交，适用于快速进出，但可能有滑点。

#### 推荐组合：
| 使用场景   | entry  | exit   | stoploss |
| ------ | ------ | ------ | -------- |
| 稳健挂单策略 | limit  | limit  | market   |
| 高频交易策略 | market | market | market   |
| 快速止损策略 | limit  | limit  | market   |

---


## 🕓 order_time_in_force — 设置订单有效期策略
```python
order_time_in_force = {
    "entry": "GTC",
    "exit": "GTC"
}
```
#### 含义解释：
- GTC (Good Till Canceled)：订单一直有效，直到成交或被程序取消。
- IOC (Immediate Or Cancel)：订单会立即成交尽可能多的部分，剩余部分立即取消。
- FOK (Fill Or Kill)：订单必须立即完全成交，否则完全取消。

#### 使用建议：
- GTC 适用于限价单，挂着等。
- IOC/FOK 适用于追求高执行效率的市价单。

---



## 🔒 stoploss_on_exchange — 交易所级别止损单（挂单式止损）
```python
order_types = {
    "stoploss_on_exchange": True,
    "stoploss_on_exchange_interval": 60,
    "stoploss_on_exchange_limit_ratio": 0.99
}
```
#### 含义说明：
| 参数                                 | 作用说明                    |
| ---------------------------------- | ----------------------- |
| `stoploss_on_exchange`             | 是否使用交易所的止损限价单（默认 False） |
| `stoploss_on_exchange_interval`    | 检查止损单状态的频率（单位：秒）        |
| `stoploss_on_exchange_limit_ratio` | 止损单挂单时限价为：触发价 × 该比例     |

例如：
- 当前价格 100 USDT，止损设置为 -5%（即触发价 95 USDT）
- limit_ratio = 0.99 → 止损单挂出价为 95 × 0.99 = 94.05 USDT

---



## ✅ 为什么要开启交易所止损？
| 类型       | 是否依赖机器人运行 | 速度 | 宕机保护 | 滑点控制 |
| -------- | --------- | -- | ---- | ---- |
| 本地止损（默认） | 是         | 慢  | ❌    | 较差   |
| 交易所止损    | 否（挂在交易所）  | 快  | ✅    | ✅    |
> 开启交易所止损后，即使你的机器人崩溃、断网，也能由交易所自动执行止损，大大增强了实盘安全性。

## ⚠️ 止损单的两个核心概念
#### ✅ 触发价（Trigger Price）
- 是`挂单的条件`，只有市场价格达到这个值，止损单才挂到市场上。
- 例：设置止损 -5%，当前买入价 100 → 触发价 95
#### ✅ 限价（Limit Price）
- 是止损单挂出时的报价（由 limit_ratio 控制）
- 用来限制滑点和成交价格的下限
- 例：95（触发价）× 0.99 = 94.05（限价）

---




## 📌 示例配置（推荐组合）

```python
order_types = {
    "entry": "limit",
    "exit": "limit",
    "stoploss": "market",
    "stoploss_on_exchange": True,
    "stoploss_on_exchange_interval": 60,
    "stoploss_on_exchange_limit_ratio": 0.985
}

order_time_in_force = {
    "entry": "GTC",
    "exit": "GTC"
}
```
---

## 🧠 总结建议
| 参数项                                | 功能说明            | 推荐设置              |
| ---------------------------------- | --------------- | ----------------- |
| `order_types.entry`                | 买入下单方式          | `"limit"`（默认）     |
| `order_types.exit`                 | 卖出下单方式          | `"limit"`         |
| `order_types.stoploss`             | 止损下单方式          | `"market"`        |
| `stoploss_on_exchange`             | 是否使用交易所止损挂单机制   | `True`（推荐）        |
| `stoploss_on_exchange_limit_ratio` | 设置止损单限价距离触发价的比例 | `0.99` \~ `0.985` |
| `order_time_in_force`              | 订单有效性策略         | `"GTC"`（默认）       |
