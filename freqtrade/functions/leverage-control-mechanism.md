> 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利




# 📘 杠杆用得巧，收益翻几倍！Freqtrade 杠杆策略全攻略

在 Freqtrade 中进行杠杆交易（尤其是在合约市场如 Binance Futures 上），你可以通过配置或策略代码灵活控制杠杆倍数。

本篇将系统介绍：

* 配置文件中的 `leverage`
* 策略函数中的 `leverage()`
* 实战用法与典型示例

---

## ⚙️ 1. 配置项 `leverage`（全局设置）

在 `config.json` 中可以直接设置全局杠杆倍数，例如：

```json
"leverage": 3
```

### ✅ 适用场景：

* 所有交易统一用一个杠杆倍数
* 配合期货模式运行（如 Binance Futures）

### ⚠️ 注意事项：

* 若使用现货交易所（如 Binance Spot），**不允许设置杠杆**
* 若使用期货交易所，务必确保账户已开通杠杆权限

---

## 🧠 2. 函数 `leverage()`（策略内动态控制）

你可以在策略中定义 `leverage()` 函数，用于**动态指定每一笔交易的杠杆倍数**，该函数仅在 Futures 模式下启用。

### 🔧 函数定义：

```python
def leverage(
    self,
    pair: str,
    current_time: datetime,
    current_rate: float,
    proposed_leverage: float,
    max_leverage: float,
    entry_tag: Optional[str],
    side: str,
    **kwargs,
) -> float:
    ...
```

参数说明：

| 参数名                 | 含义               |
| ------------------- | ---------------- |
| `pair`              | 当前交易对名           |
| `current_time`      | 当前时间             |
| `current_rate`      | 当前价格             |
| `proposed_leverage` | 默认建议杠杆值          |
| `max_leverage`      | 该交易对最大支持杠杆       |
| `entry_tag`         | 信号标签，可选          |
| `side`              | 'long' 或 'short' |

---

## 🔍 示例 1：按交易对返回固定杠杆倍数

```python
def leverage(self, pair: str, **kwargs) -> float:
    if "BTC" in pair:
        return 3.0
    elif "ETH" in pair:
        return 4.0
    else:
        return 2.0
```

---

## 📈 示例 2：趋势增强时使用更高杠杆

```python
def leverage(self, pair: str, current_time: datetime, current_rate: float, proposed_leverage: float, max_leverage: float, entry_tag: Optional[str], side: str, **kwargs) -> float:
    def leverage(self, pair: str, **kwargs) -> float:
    """
    动态调整杠杆倍数的示例函数，根据当前价格与20周期均线的比值调整杠杆。
    - pair: 交易对字符串，例如 "BTC/USDT"
    - current_time: 当前时间点，datetime 类型
    - current_rate: 当前价格
    - proposed_leverage: 系统默认建议的杠杆倍数
    - max_leverage: 该交易对允许的最大杠杆倍数
    - entry_tag: 可选的买入标签（用于区分不同信号）
    - side: 交易方向，"long" 或 "short"
    - **kwargs: 其他可选参数

    逻辑说明：
    1. 计算20周期简单移动均线（ma20）
    2. 计算当前价格与ma20的比值 ratio
    3. 如果 ratio > 1.02，说明趋势较强，尝试使用较高杠杆，最高不超过max_leverage，返回5倍杠杆或max_leverage中的较小值
    4. 如果 ratio < 0.98，说明趋势较弱或下跌，保守策略，使用最低1倍杠杆
    5. 否则维持系统默认建议的杠杆倍数

    返回：
    - 一个介于1和max_leverage之间的杠杆倍数
    """
    df = self.dp.get_analyzed_dataframe(pair, self.timeframe)[0]
    df['ma20'] = df['close'].rolling(20).mean()
    ratio = current_rate / df['ma20'].iloc[-1]

    if ratio > 1.02:
        return min(5.0, max_leverage)
    elif ratio < 0.98:
        return 1.0
    else:
        return proposed_leverage
```

---

## ✅ 推荐实践建议

| 项目              | 建议                        |
| --------------- | ------------------------- |
| 配置全局杠杆          | 简单快捷，适合所有交易统一倍数的策略        |
| 使用 `leverage()` | 更灵活，适合动态调整、按交易对/信号/趋势分配杠杆 |
| 回测注意事项          | 回测中不会强制使用真实杠杆交易，请根据结果评估风险 |
| 搭配止损机制          | 杠杆放大收益也放大风险，**务必设置止损**    |

---

## 🎯 实战整合示例

```python
from freqtrade.strategy.interface import IStrategy
from pandas import DataFrame
from datetime import datetime
from typing import Optional

class LeverageStrategy(IStrategy):
    timeframe = '5m'
    leverage = 3  # 默认杠杆（用于回测）

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
    """
    计算指标：添加20周期简单移动均线(ma20)
    """
    dataframe['ma20'] = dataframe['close'].rolling(20).mean()
    return dataframe

    def populate_entry_trend(self, df: DataFrame, metadata: dict) -> DataFrame:
        """
        入场信号：当当前收盘价高于ma20时，标记为多头进场信号
        """
        df['enter_long'] = df['close'] > df['ma20']
        return df

    def populate_exit_trend(self, df: DataFrame, metadata: dict) -> DataFrame:
        """
        出场信号：当当前收盘价低于ma20时，标记为多头退出信号
        """
        df['exit_long'] = df['close'] < df['ma20']
        return df

    def leverage(self, pair: str, current_time: datetime, current_rate: float,
                proposed_leverage: float, max_leverage: float, entry_tag: Optional[str],
                side: str, **kwargs) -> float:
        """
        根据当前价格与ma20均线的关系动态调整杠杆倍数

        逻辑：
        1. 获取分析过的数据框，读取最新的ma20均线值
        2. 计算当前价格与ma20的比值 ratio
        3. 若ratio大于1.02，认为趋势强劲，使用较高杠杆（最高不超过max_leverage，最高5倍）
        4. 若ratio低于0.98，认为趋势弱，保守使用1倍杠杆
        5. 否则使用中间杠杆2倍

        返回：
        - 调整后的杠杆倍数（浮点数）
        """
        df = self.dp.get_analyzed_dataframe(pair, self.timeframe)[0]
        ma = df['ma20'].iloc[-1]
        ratio = current_rate / ma

        if ratio > 1.02:
            return min(5.0, max_leverage)
        elif ratio < 0.98:
            return 1.0
        else:
            return 2.0
```

---

## 🧠 总结

* `leverage` 可在配置或策略函数中定义，实现灵活的杠杆控制
* 函数模式支持按行情、交易对、信号等动态分配杠杆
* **强烈建议设置止损机制**，合理搭配杠杆策略是稳定盈利的关键
