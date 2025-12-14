> > 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利



# 📘 只在该卖的时候卖！Freqtrade量化 自定义平仓全攻略 精准平仓，只赚不亏！

在自动交易中，平仓比开仓更重要。  
`Freqtrade` 提供两个函数帮助我们构建**更聪明的卖出策略**：

- `custom_exit`: 市价平仓控制逻辑
- `custom_exit_price`: 限价平仓价格控制

---

## ✳️ 函数一：`custom_exit` - 控制是否卖出（市价）

### 功能简介

`custom_exit()` 用于判断是否**立即以市价平仓**。当你想要：

- 达到某利润就卖出（止盈）
- 亏损达到阈值就撤退（止损）
- 根据时间、外部信号自定义退出逻辑

都可以用它来控制是否平仓。

---

### 🧪 实战案例 1：10% 止盈、5% 止损

我们创建一个最常见的平仓策略：  
**盈利超过10%就卖出；亏损超过5%就止损；其他情况继续持仓。**

```python
def custom_exit(self, trade, current_time, current_rate, current_profit, **kwargs) -> float | bool:
    """
    逻辑：
    - 当前利润 > 10%，立即按市价卖出（止盈）
    - 当前利润 < -5%，立即市价止损
    - 否则继续持仓
    """
    if current_profit > 0.10:
        return True
    if current_profit < -0.05:
        return True
    return False
```

> ✅ 注意：返回 `True` 表示“现在就卖”，返回 `False` 表示“继续拿着”。

---

## ✳️ 函数二：`custom_exit_price` - 设置卖出限价单

### 功能简介

`custom_exit_price()` 不判断是否卖出，而是让你设定**希望成交的价格**（限价单）。适用于：

- 想在当前价基础上挂高一点等吃单
- 实现自定义挂单卖出策略
- 限价比市价更好，但可能成交慢

---

### 🧪 实战案例 2：盈利时限价高挂 1%

```python
def custom_exit_price(self, pair, trade, current_time, current_rate, current_profit, exit_tag, **kwargs) -> float | None:
    """
    如果当前盈利超过 5%，尝试限价高挂 1% 获得更多收益。
    否则不设置限价（返回 None）
    """
    if current_profit > 0.05:
        return current_rate * 1.01  # 高于当前价 1%
    return None
```

### ⚠️ 注意事项  
使用这个函数时，必须设置 `order_types`中`"exit": "limit"` 否则不会生效！
```json
// 使用这两个函数需要设置限价单
"order_types": {
  "entry": "limit",
  "exit": "limit"
}
```
---

## 🔄 两个函数能同时用吗？

当然可以，而且效果很好：

- `custom_exit_price`：先设置一个限价挂单
- 如果价格长时间没成交，或者市场波动剧烈……
- 触发 `custom_exit`，**立刻市价止盈或止损**

---

## 🧪 实战案例 3：限价 + 超额收益强制退出

```python
def custom_exit_price(self, pair, trade, current_time, current_rate, current_profit, exit_tag, **kwargs) -> float | None:
    # 盈利超过5%，挂一个高 1% 的价格
    if current_profit > 0.05:
        return current_rate * 1.01
    return None

def custom_exit(self, trade, current_time, current_rate, current_profit, **kwargs) -> float | bool:
    # 如果收益已经高达15%，不等限价了，直接市价卖出
    if current_profit > 0.15:
        return True
    # 如果亏损超过6%，也立即止损
    if current_profit < -0.06:
        return True
    return False
```

---

## 🔍 使用说明与配置要求

为了使这两个函数都能正确执行，你需要：

```json
// config.json 中设置：
"order_types": {
  "entry": "limit",
  "exit": "limit"
},
"use_exit_signal": true
```

---

## 📊 对比表：custom_exit vs custom_exit_price

| 项目 | `custom_exit` | `custom_exit_price` |
|------|----------------|---------------------|
| 平仓方式 | 市价单（立即成交） | 限价单（等待成交） |
| 是否立即退出 | ✅ 是 | ❌ 不是 |
| 成交速度 | 快（但可能滑点大） | 慢（但价格好） |
| 返回值 | True / False / float | float 或 None |
| 使用前提 | 无需特别配置 | 需开启限价订单模式 |
| 推荐用途 | 止损、快速止盈 | 等高价卖出、缓慢套利 |

---

## 🎯 总结建议

- 想卖得快？用 `custom_exit`
- 想卖得巧？用 `custom_exit_price`
- 两者结合：既挂单，也设退出底线

---



📍下一篇预告：  
👉 第3篇：智能止损机制：`custom_stoploss` + `trailing_stop` 联动用法  
我们将讲解如何实现跟踪止损、保本平仓、自动保护利润！

> 如果觉得有用，请点赞 + 收藏支持我们继续更新 🙌
