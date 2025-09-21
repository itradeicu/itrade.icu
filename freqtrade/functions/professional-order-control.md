获取源码请访问[https://www.itrade.icu](https://www.itrade.icu)



# 📘 让下单更聪明！Freqtrade量化交易 专业挂单控制函数使用全解

Freqtrade 在挂单模型中提供了两个关键功能：

* `adjust_entry_price`：仅在新建订单（首次买入）时，用于修改挂单价格。
* `adjust_order_price`：用于控制 **所有挂单** 的价格，包括出场、加仓、减仓

合理使用这些控制点，可以最大化降低滑点，控制分段进场，进而提升策略维度和强度。

> 挂单细节决定胜负：Freqtrade 自定义价格策略完全指南

---

## 🎯函数作用概览

| 函数名              | 作用描述                               | 使用时机           |
|-------------------|------------------------------------|------------------|
| `adjust_entry_price` | 修改首次建仓时挂单价格（只调用一次）        | ✅ **首次买入**      |
| `adjust_order_price` | 对所有订单（买入、卖出）统一调整价格          | ✅ **每次下单都调用** |

---

## 🧠 adjust_entry_price - 首次建仓专用

该函数**只在策略首次生成交易信号并准备下单建仓时被调用一次**，你可以在这里动态调整挂单价格，例如控制滑点、下浮买入价等。

### ✅ 使用场景

- 想让首次买入价格更“谨慎”，例如：
  - 向下压一点点再挂单（防止追涨）
  - 基于盘口价做微调

### 🧪 示例代码

```python
def adjust_entry_price(self, pair: str, order_type: str, current_rate: float, proposed_rate: float, **kwargs) -> float:
    # 往下调整 0.5% 挂单价格
    adjusted_price = proposed_rate * 0.995
    print(f"[adjust_entry_price] 原始挂单价: {proposed_rate}，调整后: {adjusted_price}")
    return adjusted_price
```

### ⚠️ 注意

- **只在首次建仓时触发**，不适用于加仓/减仓
- 返回的是你希望挂出的价格

---

## 🛠 adjust_order_price - 全局挂单价格钩子

这是一个更强大的挂单控制函数，**无论是买入还是卖出，都会经过它**。

### ✅ 使用场景

- 所有挂单统一加/减价格，例如：
  - 所有买入挂低一点（滑点保护）
  - 所有卖出挂高一点（套利空间）
- 卖出时根据当前盘口价动态挂单

### 🧪 示例代码

```python
def adjust_order_price(self, pair: str, is_buy: bool, current_price: float, proposed_price: float, **kwargs) -> float:
    if is_buy:
        # 买入时往下压0.3%
        return proposed_price * 0.997
    else:
        # 卖出时往上抬0.3%
        return proposed_price * 1.003
```

---

## 🔍 两个函数的区别与联系

| 比较项             | `adjust_entry_price`                 | `adjust_order_price`                      |
|------------------|------------------------------------|----------------------------------------|
| 被调用时机         | 仅首次建仓买入                             | 所有订单（包括买入和卖出）                     |
| 可控制方向         | 仅限买入                                  | 买入 + 卖出                              |
| 控制范围           | 建仓价                                     | 全部订单价格                              |
| 推荐组合使用方式     | ✔ 首次建仓时：用 `adjust_entry_price` 控制更细致的入场价格 | ✔ 所有订单：用 `adjust_order_price` 做统一价格控制 |

---

## 📌 补充说明：你可能以为能用，实际不能的地方

| 场景 | 是否会调用 `adjust_entry_price`？ | 推荐做法 |
|------|------------------------------|--------|
| 第一次买入建仓 | ✅ 会调用 | 用来调整初始挂单价 |
| 加仓（已有仓位再买） | ❌ 不会调用 | 使用 `adjust_trade_position` |
| 卖出止盈/止损 | ❌ 不会调用 | 使用 `custom_exit_price` 或 `adjust_order_price` |

---

## ✅ 最佳实践建议

- **用 `adjust_entry_price` 控制首次建仓挂单价**
- **用 `adjust_order_price` 控制所有订单滑点保护**
- **结合 `custom_exit_price` 精准控制卖出价格**
- **不要试图在 `adjust_entry_price` 中实现加仓逻辑，Freqtrade 不会再调用它**


### 📘 最简动量策略案例（适合入门）

这是一个**基于价格动量的入门策略**，策略核心逻辑：

> 📈 当前K线的收盘价高于前一根K线 → 生成买入信号  
> 📉 当前K线的收盘价低于前一根K线 → 生成卖出信号

同时结合了 Freqtrade 提供的订单价格控制功能：

- `adjust_entry_price`：首次建仓时挂单价下调 0.5%
- `adjust_order_price`：统一滑点控制（买入 -0.3%，卖出 +0.3%）
- `custom_exit_price`：卖出挂比当前价格高 0.2%

---

```python
from freqtrade.strategy.interface import IStrategy
import pandas as pd
from pandas import DataFrame

class ExampleStrategy(IStrategy):
    """
    示例策略：基于收盘价是否上涨来决定是否买入。
    """
    timeframe = '5m'

    order_types = {
        'entry': 'limit',
        'exit': 'limit',
        'stoploss': 'market',
    }

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # 没有使用额外指标
        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        当当前K线收盘价高于上一根K线 → 生成买入信号
        """
        dataframe['enter_long'] = dataframe['close'] > dataframe['close'].shift(1)
        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """
        当当前K线收盘价低于上一根K线 → 生成卖出信号
        """
        dataframe['exit_long'] = dataframe['close'] < dataframe['close'].shift(1)
        return dataframe

    def adjust_entry_price(self, pair: str, order_type: str, current_rate: float,proposed_rate: float, **kwargs) -> float:
        """
        首次建仓时，挂单价格下调 0.5%
        """
        return proposed_rate * 0.995

    def adjust_order_price(self, pair: str, is_buy: bool, current_price: float,proposed_price: float, **kwargs) -> float:
        """
        所有订单统一滑点保护：买入 -0.3%，卖出 +0.3%
        """
        return proposed_price * (0.997 if is_buy else 1.003)

    def custom_exit_price(self, pair: str, trade, current_time, current_rate, **kwargs) -> float:
        """
        卖出挂单价格比当前价格高 0.2%
        """
        return current_rate * 1.002
```
---



## 🧾 总结
+ `adjust_entry_price` 和 `adjust_order_price` 是 Freqtrade 在限价挂单机制中最关键的两个控制钩子：
  - `adjust_entry_price`：只会在首次建仓时调用一次，用于精细控制第一次买入挂单价。
- `adjust_order_price`：每次下单都会调用，适用于买入、卖出、加仓、减仓、止盈、止损等所有订单。
+ 通过合理组合使用这两个函数，你可以：
  - 避免在高位追单、有效防止滑点；
  - 动态挂单、让策略更智能；
  - 精准控制卖出价，提升利润空间。
+ 📌 实战建议：
  - 想控制首次入场更稳健：使用 `adjust_entry_price`
  - 想控制所有订单滑点：使用 adjust_order_price
  - 想控制卖出时的目标价格：再配合 `custom_exit_price` 更完美
  - 当你能熟练运用这三者组合，一个专业级的挂单策略就已具备雏形。

