> 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利


# 📘 聪明人只止必要的损：一文搞懂 Freqtrade 动态止损

在自动交易系统中，止损策略是控制亏损、保护本金的核心机制之一。  
相比固定止损，`Freqtrade` 提供的 `custom_stoploss` 方法支持更加灵活、动态的止损设计，帮助你在盈利中保护利润，在亏损中及时撤退。

---

## ✳️ custom_stoploss

`custom_stoploss` 允许你根据持仓状态、时间、市场行情等因素，**动态计算并返回一个止损价格**。  
返回值类型：`float`，表示新的止损价；也可以返回 `-1` 表示继续使用默认止损机制。

> **注意：**该函数主要用于**止损**，**不支持止盈**逻辑。如果你想控制止盈，应该使用 `custom_exit`。
---

### 📌 典型用途：

- 跟踪止损（trailing stop）
- 多阶动态止损（随着利润增长不断提升止损线）
- 高位止盈保护（防回撤）
- 阶梯止损（先宽后紧）

---

## 🧪 实战案例 1：跟踪止损逻辑（经典方式）

随着价格上涨，我们动态上移止损位，始终保持 2% 下跌空间。

```python
def custom_stoploss(self, trade, current_time, current_rate, current_profit, **kwargs) -> float:
    """
    动态止损逻辑：
    - 初始止损为 -2%
    - 每上涨 5%，止损上移至当前价下方 2%
    """
    entry_price = trade.open_rate

    if current_profit < 0.05:
        # 未到盈利区，使用初始止损（2%）
        return entry_price * 0.98

    # 一旦盈利超过 5%，止损跟随上涨
    return current_rate * 0.98
```

> ✅ 优点：止损位永远跟着当前价格上移，不回撤。  
> ⚠️ 注意：止损只会“提高”，不会下调！

---

## 🧪 实战案例 2：利润分级止损（多档收益）

如果你想更精细化管理止损：

- 盈利 0~5% → 止损 -2%
- 盈利 5~10% → 止损 0%（保本）
- 盈利 >10% → 止损锁定 5% 盈利

```python
def custom_stoploss(self, trade, current_time, current_rate, current_profit, **kwargs) -> float:
    entry_price = trade.open_rate

    if current_profit < 0.05:
        return entry_price * 0.98  # 止损 -2%

    elif current_profit < 0.10:
        return entry_price  # 保本止损

    else:
        return entry_price * 1.05  # 锁定 5% 收益
```

---

## 🧪 实战案例 3：防洗单小幅浮亏止损

一些币种容易“冲高回落”洗掉止损。  
这时我们可以设置**动态耐受浮亏**：只有在亏损超过 -3%，才触发止损。

```python
def custom_stoploss(self, trade, current_time, current_rate, current_profit, **kwargs) -> float:
    if current_profit < -0.03:
        return current_rate  # 当前价直接止损
    return -1  # 默认止损
```

---

## 📊 止盈 vs 止损：对比概览

| 项目         | 止盈（custom_exit）        | 止损（custom_stoploss）     |
|--------------|-----------------------------|------------------------------|
| 函数名       | `custom_exit`               | `custom_stoploss`            |
| 是否触发平仓 | ✅ 直接卖出                  | ✅ 设置新的止损价格          |
| 调用频率     | 每个周期评估                 | 每个周期评估                 |
| 使用目的     | 获利退出                     | 控制亏损，保护本金           |
| 返回值       | True / False / float        | 止损价（float）或 `-1`      |
| 搭配机制     | 可以和 `custom_exit_price`  | 可以和 `trailing_stop` 配合 |

---

## 🧰 和 trailing_stop 配合建议

如果你已启用：

```json
"trailing_stop": true,  //   启用追踪止损功能，当价格达到一定盈利后，止损价会自动上移，锁定利润。
"trailing_stop_positive": 0.02, //  追踪止损启动的盈利阈值（2%），价格盈利超过此值后，开始跟踪止损。
"trailing_stop_positive_offset": 0.04   //  追踪止损的偏移量（4%），表示止损价将会比当前最高价低4%，防止止损过早触发。
```

那么建议将 `custom_stoploss` 只用于**前期控制（初始阶段）**，  
后期由 `trailing_stop` 进行利润保护，两者配合更稳健。

---

## 🧭 配置建议（启用 custom_stoploss）

在策略文件中定义函数后，无需额外启用。系统默认会调用。  
但建议配合以下设置：

```json
"stoploss": -0.99,  // 足够大，避免默认止损生效
"trailing_stop": false // 如果使用 trailing_stop，请协调两者逻辑
```


---
## 追踪止损示意表
| <font style="color:rgb(102, 102, 102);">阶段</font> | <font style="color:rgb(102, 102, 102);">价格</font> | <font style="color:rgb(102, 102, 102);">止损价</font> | <font style="color:rgb(102, 102, 102);">说明</font> |
| --- | --- | --- | --- |
| <font style="color:rgb(102, 102, 102);">开仓初始</font> | <font style="color:rgb(102, 102, 102);">100</font> | <font style="color:rgb(102, 102, 102);">100 × (1 - 2%) = 98</font> | <font style="color:rgb(102, 102, 102);">初始止损，防止立刻亏损</font> |
| <font style="color:rgb(102, 102, 102);">第1次上涨</font> | <font style="color:rgb(102, 102, 102);">105</font> | <font style="color:rgb(102, 102, 102);">105 × (1 - 2%) = 102.9</font> | <font style="color:rgb(102, 102, 102);">止损价上移，锁定部分利润</font> |
| <font style="color:rgb(102, 102, 102);">第2次上涨</font> | <font style="color:rgb(102, 102, 102);">110.25</font> | <font style="color:rgb(102, 102, 102);">110.25 × (1 - 2%) = 107.945</font> | <font style="color:rgb(102, 102, 102);">继续跟踪止损，保护利润更进一步</font> |
| <font style="color:rgb(102, 102, 102);">第3次上涨</font> | <font style="color:rgb(102, 102, 102);">115.76</font> | <font style="color:rgb(102, 102, 102);">115.76 × (1 - 2%) = 113.45</font> | <font style="color:rgb(102, 102, 102);">持续追踪止损</font> |

说明：随着价格上涨，止损价自动跟进，防止回落导致利润回吐。

---

## 📌 重要提醒

- 返回值是“**止损价格**”，不是百分比。例如当前价格为 100，你返回 95 就表示“跌到 95 就卖出”。
- 返回 `-1` 表示放弃修改，系统会用 `stoploss` 参数定义的默认值。

## 📦 小结

+ `custom_stoploss` 是 Freqtrade 中最强大的风险控制工具之一。
+ 它能实现跟踪止损、浮盈保护、多级逻辑等复杂止损系统。
+ 配合 `trailing_stop` 和 `custom_exit`，能构建出完整的**资金防御体系**。

---
