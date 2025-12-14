> 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利



# 🎯 如何精准控制买入卖出价格？entry/exit_pricing 实战配置

在交易中，**挂单价格的高低决定了成交效率与滑点风险**。  
Freqtrade 提供了 `entry_pricing` 和 `exit_pricing` 两组参数，让我们可以控制买入和卖出`限价单`的具体定价逻辑。

本篇详细解析如何通过订单簿设置精细的挂单策略，包括盘口深度过滤，帮助你提高挂单质量与策略稳健性。

---

## 💡 为什么要配置 entry_pricing/exit_pricing？

默认情况下，限价单通常以当前价格或 K线收盘价下单，但这种方式可能会：

- 在**波动剧烈时成交失败或偏离理想价**
- **无法应对流动性差币种**导致挂单卡住
- 增加滑点，影响策略表现

通过配置 `entry_pricing` 和 `exit_pricing`，你可以：

✅ 挂在买一 / 卖一价等真实盘口上  
✅ 控制挂单排位，选择第1档、第2档等  
✅ 启用盘口深度过滤，**避免行情异常时误下单**

---

## 📥 entry_pricing — 买入挂单价格配置

```json
"entry_pricing": {
  "price_side": "same",
  "use_order_book": true,
  "order_book_top": 1,
  "price_last_balance": 0.0,
  "check_depth_of_market": {
    "enabled": false,
    "bids_to_ask_delta": 1
  }
}
```
#### 📋 entry_pricing / exit_pricing 参数说明表（含默认值）
| 参数名                             | 说明                                                                                                                                                                       | 默认值            |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------- |
| `price_side`                    | 下单方向选择，值范围包含：<br>• `bid`：买盘方向（买一价）<br>• `ask`：卖盘方向（卖一价）<br>• `same`：买入时等同 `bid`，卖出时等同 `ask`<br>• `other`：买入时等同 `ask`，卖出时等同 `bid`。<br>常用 `same` 表示挂自己的盘口，`other` 表示挂对手盘口。 | `"same"`       |
| `use_order_book`                | 是否启用订单簿定价：<br>• `true` 使用实时盘口价格；<br>• `false` 使用K线收盘价（不推荐）。                                                                                                              | `true`         |
| `order_book_top`                | 选择盘口第几档报价：<br>• `1` 表示买一 / 卖一，<br>• `2` 表示买二 / 卖二，以此类推。                                                                                                                  | `1`（最快成交）      |
| `price_last_balance`            | 对基础挂单价做偏移：<br>• 负值代表更保守压价，<br>• 正值代表更积极追价。                                                                                                                               | `0.0`（不偏移）     |
| `check_depth_of_market.enabled` | 是否启用盘口深度过滤：<br>防止在买卖盘差距过大的异常行情下下单（如闪崩、流动性差）。                                                                                                                             | `false`        |
| `bids_to_ask_delta`             | 买一 / 卖一最大允许价差，超过该价差不挂单（单位：币价）。<br>仅在启用盘口深度检查后生效。                                                                                                                         | `0.001`（视币种行情） |




## 📤 exit_pricing — 卖出挂单价格配置
```json
"exit_pricing": {
  "price_side": "same",
  "use_order_book": true,
  "order_book_top": 1
}
```
#### 📋 exit_pricing 参数说明表（含默认值）
| 参数名              | 含义                                                                                                | 推荐默认值    |
| ---------------- | ------------------------------------------------------------------------------------------------- | -------- |
| `price_side`     | 卖出挂单方向选择，同 `entry_pricing`，值为 `bid`、`ask`、`same` 或 `other`。通常 `same` 表示挂卖一价，`other` 表示挂买一价（对手盘口）。 | `"same"` |
| `use_order_book` | 是否启用订单簿作为定价来源：<br>• `true` 使用盘口实时价格（推荐）；<br>• `false` 使用K线价格（不推荐）。                                | `true`   |
| `order_book_top` | 盘口档位选择，数字越小优先成交，数字越大价格越优但成交慢。                                                                     | `1`      |



## 📊 挂单行为对比说明
| 场景                         | 挂单方向               | 挂在盘口档位 | 成交速度 | 滑点控制 | 风险     |
| -------------------------- | ------------------ | ------ | ---- | ---- | ------ |
| `same + order_book_top=1`  | 挂自己盘口（买入挂买一，卖出挂卖一） | 1档     | 中    | 低    | 中      |
| `other + order_book_top=1` | 挂对手盘口（买入挂卖一，卖出挂买一） | 1档     | 快    | 中    | 高（滑点大） |
| `same + order_book_top=2`  | 挂自己盘口第二档（买二/卖二）    | 2档     | 慢    | 更低   | 低      |
| `use_order_book=false`     | 不使用订单簿，使用K线价格      | —      | 不稳定  | 无法控制 | 高      |


## ✅ 推荐配置组合（稳定、适合多数策略）
```json
"entry_pricing": {
  "price_side": "same",
  "use_order_book": true,
  "order_book_top": 1,
  "check_depth_of_market": {
    "enabled": true,
    "bids_to_ask_delta": 1
  }
},
"exit_pricing": {
  "price_side": "same",
  "use_order_book": true,
  "order_book_top": 1
}
```
📌 配合` order_types.entry = "limit"` 和 `exit = "limit"` 使用。

## 🧪 实战建议
| 策略类型   | 推荐设置举例                                         |
| ------ | ---------------------------------------------- |
| 稳健挂单   | `same + top=1`，启用盘口过滤，控制成交效率与滑点                |
| 高频套利   | `opposite + top=1`，提高成交率，适度容忍滑点                |
| 流动性差币种 | `top=1~2` + `depth check`，防止挂到异常价              |
| 激进低价买入 | `same + top=2~3`，搭配 `price_last_balance` 做压价挂单 |



## 🧪 案例场景：低价买入 + 稳健卖出
假设你正在运行一个现货交易策略，在 Binance 上交易 PEPE/USDT，该币种波动较快，订单簿流动性适中。你希望：
- 买入时：尽量压价挂单，抢到便宜货（但不影响成交率）
- 卖出时：稳妥挂在卖一价，快速出货，防止回调损失
#### ✅ 设置配置如下：
```json
"order_types": {
  "entry": "limit",
  "exit": "limit"
},

"entry_pricing": {
  "price_side": "same",              // 买入方向使用买盘（Bids）价格作为挂单基准
  "use_order_book": true,            // 使用订单簿数据（不是K线）进行挂单定价
  "order_book_top": 2,               // 选择盘口第二档（买二）价格挂单，降低买入成本
  "price_last_balance": -0.000001,   // 在买二价格基础上再稍微压一点价，更保守
  "check_depth_of_market": {
    "enabled": true,                 // 启用盘口深度过滤逻辑
    "bids_to_ask_delta": 0.0005      // 如果买一与卖一价差超过 0.0005，就不下单（防止滑点或市场异常）
  }
},

"exit_pricing": {
  "price_side": "same",      // 卖出方向使用卖盘（Asks）价格作为挂单基准
  "use_order_book": true,    // 使用订单簿进行定价（而不是K线收盘价等）
  "order_book_top": 1        // 挂在盘口第一档（卖一）上，追求更快成交速度
}

```

## 🔍 模拟盘口快照
当前 PEPE/USDT 订单簿如下：
| 买盘（<span style="color:green">Bids</span>）                  | 卖盘（<span style="color:red">Asks</span>）                  |
| ---------------------------------------------------------- | -------------------------------------------------------- |
| <span style="color:green">0.00011300</span> <br>（盘口1 - 买一） | <span style="color:red">0.00011320</span> <br>（盘口1 - 卖一） |
| <span style="color:green">0.00011280</span> <br>（盘口2 - 买二） | <span style="color:red">0.00011330</span> <br>（盘口2 - 卖二） |
| <span style="color:green">0.00011270</span> <br>（盘口3 - 买三） | <span style="color:red">0.00011340</span> <br>（盘口3 - 卖三） |



### 📥 进入逻辑（entry）
你的策略生成了买入信号：
- `order_book_top = 2` → 使用买二价格：`0.00011280`
- `price_last_balance = -0.000001` → 调整为`0.00011279`
- 如果买卖差价（0.00011320 - 0.00011300 = 0.00020）小于 `bids_to_ask_delta`，则允许下单

✅ 最终挂单价格：`0.00011279`：
- → 比买一价还低一点，有机会捡到便宜筹码

### 📤 出场逻辑（exit）
当价格上涨，你的策略触发卖出：
- `order_book_top = 1` + `price_side = same`： → 卖出价设置为卖一：`0.00011320`

✅ 最终卖出挂单：
- `0.00011320` → 优先成交，减少滑点


### ✅ 使用建议
| 策略目的   | entry\_pricing                                | exit\_pricing    |
| ------ | --------------------------------------------- | ---------------- |
| 想便宜买入  | `same` + `top=2~3` + `price_last_balance < 0` | -                |
| 想快速成交  | `same` + `top=1`                              | `same` + `top=1` |
| 避免异常挂单 | `check_depth_of_market.enabled = true`        | -                |

## 📌 小结
| 配置项                 | 控制内容      | 建议默认值              |
| ------------------- | --------- | ------------------ |
| `entry_pricing`     | 买入挂单策略    | 使用盘口 same/1 档 + 过滤 |
| `exit_pricing`      | 卖出挂单策略    | 使用盘口 same/1 档      |
| `order_book_top`    | 使用盘口第几档价格 | `1`（稳健）、`2+`（更低价）  |
| `bids_to_ask_delta` | 最大盘口价差过滤  | 1（单位视币种行情而定）       |
| `check_depth_of_market` | 避免在行情剧烈波动时误挂单（比如突然出现闪崩的盘口价差） |





## ⚠️ 注意事项
- 这些配置只在限价单时生效（即：`order_types.entry = "limit"`）；
- 如果设为 "market"，则完全忽略这些定价参数；
- 使用订单簿的频率过高可能会遇到交易所限速，请合理配置 enableRateLimit；
- 某些交易所（如 HTX）可能订单簿数据较慢，适配时请注意成交延迟。



挂单也是策略的一部分，好的挂单价格既能控制滑点，也能提高成交效率。
学会用好 `entry_pricing` `和 exit_pricing`，让你的策略更智能、更可靠！

