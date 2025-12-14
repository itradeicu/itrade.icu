> 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利


## 📘 一行代码提升10%收益？教你用 custom_roi 精准止盈
在 Freqtrade 策略中，`custom_roi` 是一个非常实用的函数，允许你根据当前持仓状态、时间和收益率动态调整止盈目标。
相比静态的 minimal_roi，`custom_roi` 更灵活，可以帮助你提升收益率和风险控制能力。

## ⚙️ custom_roi 函数介绍
`custom_roi` 允许用户自定义止盈逻辑，函数会在每个交易周期自动调用，根据实时参数动态返回止盈目标收益率。返回 0 表示立即止盈，返回 None 则继续沿用默认ROI。

#### 函数签名示例
```python
def custom_roi(self, trade, current_profit: float, current_time) -> float | None:
    """
    自定义止盈策略
    参数：
    - trade: 当前交易对象，包含持仓信息
    - current_profit: 当前收益率（浮点数）
    - current_time: 当前时间

    返回：
    - float类型止盈目标收益率，或者 None 表示使用默认ROI
    """
    pass
```

## 🔍 示例：实现基于持仓时间和收益率动态调整止盈
```python
def custom_roi(self, trade, current_profit: float, current_time) -> float | None:
    # 计算持仓时长，单位：分钟
    hold_time = (current_time - trade.open_date_utc).total_seconds() / 60

    # 持仓小于30分钟，设置严格止盈门槛，收益达到5%即止盈
    if hold_time < 30:
        target_roi = 0.05
    else:
        # 持仓超过30分钟，放宽止盈到10%
        target_roi = 0.10

    # 当前收益达到目标止盈点，触发卖出（返回0）
    if current_profit >= target_roi:
        print(f"[custom_roi] 触发止盈，当前收益 {current_profit:.2%} >= 目标 {target_roi:.2%}")
        return 0  # 立即止盈

    # 未达到止盈目标，继续持仓（返回None）
    return None
```

## ❓ 使用 custom_roi 后，minimal_roi 是否还生效？
- 当你实现了 `custom_roi`后， `minimal_roi` 将被忽略，所有止盈逻辑完全由 `custom_roi`控制。
- 如果 `custom_roi` 返回 None，则会回退到使用默认的 `minimal_roi`。
- 推荐在 `custom_roi` 中完全覆盖止盈逻辑，保证行为统一。



## ✅ 实践建议
- 使用 `custom_roi` 灵活定义止盈门槛，结合持仓时间和收益率动态调整
- 配合日志打印方便调试，观察策略在不同市场环境的表现
- 动态止盈策略适合波动大或趋势明显的市场，提升盈利空间和风险管理能力


## 🧠 总结
- `custom_roi` 是 Freqtrade 中止盈管理的重要扩展接口
- 通过 `custom_roi`，你可以实现更智能的动态止盈策略
- 完全替代静态 `minimal_roi`，提升策略灵活度和适应性
- 合理设计止盈逻辑是风险控制和收益提升的关键


