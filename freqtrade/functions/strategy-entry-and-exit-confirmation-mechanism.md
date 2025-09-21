获取源码请访问[https://www.itrade.icu](https://www.itrade.icu)

# 💹 不是信号就要下单！教你用 confirm_trade_entry 拒绝亏损买入

在量化策略中，生成买入或卖出信号只是交易的第一步，真正执行交易还需要再经过多重检验。  
Freqtrade 框架中提供了两个关键函数：

- `confirm_trade_entry`
- `confirm_trade_exit`

它们负责在策略判定买卖信号后，做“最终确认”，决定是否真的执行这笔交易。相当于“交易的安全阀”，防止因为信号误判、行情异常或仓位风险带来损失。

---

## 📈 1. confirm_trade_entry：买入信号的终极过滤器

### 功能

`confirm_trade_entry` 是在策略产生买入信号后，实际执行买单前调用的函数。  
它接收当前交易环境信息，返回是否确认下单。

这个函数主要用途：

- **风险控制**：比如防止高价买入、控制最大持仓数量。  
- **信号再验证**：用更严格的条件确认买入合理性。  
- **动态策略调整**：结合资金状况或行情，动态拒绝买入。

### 参数详解

```python
def confirm_trade_entry(self, pair: str, trade: Trade, order_type: str, amount: float, price: float,
                        current_time: datetime, **kwargs) -> bool:
    """
    pair: 交易对名称，如 BTC/USDT
    trade: 当前交易对象，包含开仓价格、状态等
    order_type: 订单类型，limit 或 market
    amount: 拟买入数量
    price: 拟买入价格
    current_time: 当前时间
    kwargs: 其他参数
    返回：True 允许买入，False 拒绝买入
    """
```

---

## 📉 2. confirm_trade_exit：卖出信号的最后关卡

### 功能

`confirm_trade_exit` 是策略生成卖出信号后，实际执行卖单前的二次确认。  

主要用于：

- **避免盲目止损**：如只允许盈利时卖出，防止亏损被锁定。  
- **过滤异常行情**：例如突发跳水时，暂停卖出。  
- **资金管理**：如限制卖出时间窗口，避免盘中频繁出入。

### 参数详解

```python
def confirm_trade_exit(self, pair: str, trade: Trade, order_type: str, amount: float, price: float,
                       current_time: datetime, **kwargs) -> bool:
    """
    参数同 confirm_trade_entry
    返回：True 允许卖出，False 拒绝卖出
    """
```

---

## 📊 3. 代码案例：从理论到实战

### 3.1 限价买入：防止高价追涨

```python
def confirm_trade_entry(self, pair, trade, order_type, amount, price, current_time, **kwargs) -> bool:
    # ma20 = self.dp.get_indicator(pair, 'sma', timeframe='1h', length=20).iloc[-1]
    if price > ma20 * 1.5:
        self.log(f"拒绝买入 {pair}，买价 {price} 高于均线1.5倍 {ma20 * 1.5}")
        return False
    return True
```

> **解析**：此策略限制买入价格不得超过20小时均线的1.5倍，避免追高。

---

### 3.2 只在盈利时卖出：防止亏损止损

```python
def confirm_trade_exit(self, pair, trade, order_type, amount, price, current_time, **kwargs) -> bool:
    if price <= trade.open_rate:
        self.log(f"拒绝卖出 {pair}，卖价 {price} 不高于开仓价 {trade.open_rate}")
        return False
    return True
```

> **解析**：只有当当前价格高于开仓价时，才允许卖出，避免亏损卖出。

---

### 3.3 最大持仓数限制：控制风险暴露

```python
def confirm_trade_entry(self, pair, trade, order_type, amount, price, current_time, **kwargs) -> bool:
    open_trades = len(self.wallets.get_trades_open())
    max_positions = 3
    if open_trades >= max_positions:
        self.log(f"拒绝买入 {pair}，已持仓 {open_trades} 超过最大允许 {max_positions}")
        return False
    return True
```

> **解析**：限制同时持仓最多3个币种，防止过度分散或爆仓风险。

---

## ⚙️ 4. 使用建议与注意事项

- **结合多维数据**：可以结合波动率、成交量、资金占用等指标做综合判断。  
- **日志详尽**：在拒绝交易时务必记录详细日志，方便调试和后期优化。  
- **实时性要求**：函数调用频繁，务必保持高效，避免策略延迟。  
- **谨慎返回 False**：过度拒绝交易会影响策略表现，建议保留一定宽松度。

---

## 🚀 5. 总结

`confirm_trade_entry` 和 `confirm_trade_exit` 是 Freqtrade 策略中不可或缺的“安全卫士”。  

通过它们，可以让策略在信号发出后“再三斟酌”，过滤掉不合时宜的买卖操作，显著提高交易的安全性和稳定性。  

灵活应用这些函数，你的策略将更具实战韧性，助力长线盈利。

---

> 现在就动手试试这些函数，把你的策略安全网织得更密吧！
