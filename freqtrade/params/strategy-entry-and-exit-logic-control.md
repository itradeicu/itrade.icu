获取源码请访问[https://www.itrade.icu](https://www.itrade.icu)
# 涨了就卖？亏了就砍？Freqtrade 进出场逻辑全解锁！

在 `Freqtrade` 策略中，进出场规则的配置是交易表现的关键。合理设置止盈、止损及卖出信号，可以有效提升策略的收益和风险控制能力。本篇重点讲解控制开仓、平仓、止盈的核心参数。

---

## 🎯 minimal_roi — 最小收益率止盈

`minimal_roi` 用于设置不同持仓时间对应的最小收益率目标，达到目标时自动触发止盈。

```python
minimal_roi = {
    "30": 0.01,  # 持仓30分钟后，利润达到1%立即止盈
    "20": 0.02,  # 持仓20分钟后，利润达到2%立即止盈
    "0": 0.04    # 持仓初期即达到4%立即止盈
}
```
- ROI 的时间单位为分钟
- ROI 定义了不同时间段的止盈利润门槛
- 达到对应收益率，策略自动卖出，优先级高于自定义退出信号

## 🛑 stoploss — 固定止损比例
设置固定的亏损比例，当亏损达到该值时强制止损平仓。

```python
stoploss = -0.10  # 亏损10%时止损
```
- 止损是保护本金的底线，防止亏损扩大
- 支持市价单快速止损，保障风险管理
- 与 `trailing_stop` 配合使用时，止损作为最后的兜底保护


## 🚪 use_exit_signal — 启用自定义退出信号
控制是否启用 `populate_exit_trend` 中的自定义退出信号（卖出信号）。设置为`False`将禁用`populate_exit_trend`函数中的 `exit_long` 和 `exit_short` 列的使用（不会发出退出信号）。对其他退出方法（止损、ROI、回调）没有影响。

```python
use_exit_signal = True
```
- 设置为 `True` 时，策略会根据自定义退出信号执行卖出
- 设置为 `False` 时，忽略自定义退出信号，只通过 `minimal_roi` 和 `stoploss` 出场
- 适用于需要细化卖出条件的策略


## 💰 exit_profit_only — 仅盈利状态下允许卖出
 `exit_profit_only`用于限制卖出信号只能在盈利状态下生效，避免策略因误判而在亏损状态下平仓。默认值为`False`。
+ exit_profit_only 只对 `populate_exit_trend`生效。
+ 盈利：只要出现退出信号（exit=1），就会执行卖出，不管盈利多少（哪怕是0.1%都卖出）。
+ 亏损：不管是否出现退出信号，都不会因为 `populate_exit_trend` 卖出（但仍会受止损、自动止盈等其他机制影响）。
+ 不会阻止：
    - custom_exit() 手动退出逻辑
    - stoploss 强制止损
    - minimal_roi 自动退出
+ 如果你使用 custom_exit()，则需在函数内手动实现类似判断逻辑。
#### 代码示例
```python
class MyStrategy(IStrategy):
    use_exit_signal = True
    exit_profit_only = True # 关注点
    timeframe = '1h'
    stoploss = -0.1
    minimal_roi = {"0": 0.02}   # 盈利达到2%

    def populate_indicators(self, dataframe, metadata):
        dataframe['rsi'] = ta.RSI(dataframe, timeperiod=14)
        return dataframe

    def populate_exit_trend(self, dataframe, metadata):
        dataframe['exit'] = 0
        # RSI 高于 70 时准备卖出
        dataframe.loc[dataframe['rsi'] > 70, 'exit'] = 1
        return dataframe
```
| 当前收益率 | RSI > 70（触发 exit） | 是否卖出   |
| --------- | --------------------- | ---------- |
| +5%       | ✅                     | ✅ 卖出    |
| +1%       | ✅                     | ✅ 卖出    |
| -3%       | ✅                     | ❌ 不卖    |
| -10%      | ❌                     | ❌ 不卖    |




## 🎚️ exit_profit_offset — 退出利润偏移阈值
定义触发卖出时的最小利润偏移量，配合 exit_profit_only 使用，确保卖出时利润达到设定门槛。

```python
exit_profit_offset = 0.01  # 仅当利润超过1%时，退出信号才生效
```
- 结合 exit_profit_only，避免微小盈利就退出
- 设置越大，卖出信号触发门槛越高
- 有利于防止过早平仓，提升盈利空间


## 🧠 示例策略片段
```python
from freqtrade.strategy.interface import IStrategy
import talib.abstract as ta
import pandas as pd

class MyStrategy(IStrategy):
    # 设置使用的主时间周期，这里使用的是 15 分钟 K 线
    timeframe = '15m'

    # 设置最小收益率规则（ROI），这里表示：
    # 无论持仓多久，只要达到 3% 盈利就可以卖出
    minimal_roi = {"0": 0.03}

    # 固定止损，当亏损达到 10% 时，强制止损卖出
    stoploss = -0.10

    # 启用退出信号函数 populate_exit_trend() 中定义的 exit 列来判断是否卖出
    use_exit_signal = True

    # 仅在盈利状态下才允许触发退出信号（即使 exit=1，也必须盈利才会卖出）
    exit_profit_only = True

    # 要求盈利至少达到 1% 才会触发退出（exit=1 时才判断这个）
    exit_profit_offset = 0.01

    def populate_indicators(self, df: pd.DataFrame, metadata: dict) -> pd.DataFrame:
        """
        用于添加技术指标到 dataframe 中。
        这里我们添加了 RSI 指标，作为后续判断是否退出的依据。
        """
        df['rsi'] = ta.RSI(df, timeperiod=14)  # 计算 14 周期的 RSI 指标
        return df

    def populate_exit_trend(self, df: pd.DataFrame, metadata: dict) -> pd.DataFrame:
        """
        用于定义退出信号。
        如果 RSI 超过 70（超买），我们设置 exit=1，表示准备卖出。
        """
        df['exit'] = 0  # 默认不退出
        df.loc[df['rsi'] > 70, 'exit'] = 1  # 当 RSI > 70 时，标记为卖出信号
        return df

```




## ⚙️ use_custom_stoploss — 启用自定义动态止损
开启后可通过重写 `custom_stoploss()` 方法实现动态止损，替代固定止损。

```python
use_custom_stoploss = True

def custom_stoploss(self, pair, trade, current_time, current_rate, current_profit, **kwargs) -> float:
    # 示例：利润超过5%时收紧止损至-1%，否则保持-5%
    if current_profit > 0.05:
        return -0.01
    return -0.05
```
### 🚫 注意事项
+ `custom_stoploss()` 只影响止损行为，不能用于止盈
+ 启用后系统忽略 stoploss = -0.1 这类固定设置
+ 返回值仍需是负值，如 -0.05 表示亏损 5% 止损




## ✅ 总结清单
| 参数名                   | 功能描述           | 推荐默认值 / 说明              |
| --------------------- | -------------- | ----------------------- |
| `minimal_roi`         | 不同持仓时间的止盈收益率阈值 | 根据策略灵活设定                |
| `stoploss`            | 固定止损比例         | 通常设置 -0.10 (10%)        |
| `use_exit_signal`     | 是否启用自定义退出信号    | `True` 启用               |
| `exit_profit_only`    | 卖出信号仅在盈利时生效    | `False` 或 `True` 根据策略调整 |
| `exit_profit_offset`  | 退出时最小盈利偏移量     | 可选，常用 0.01 (1%)         |
| `use_custom_stoploss` | 是否启用自定义动态止损    | `False` 默认，启用需重写函数      |


