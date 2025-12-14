> > 本文为 [https://www.itrade.icu](https://www.itrade.icu) 量化交易实验室出品。访问获取更多福利

访问获取更多福利


# Freqtrade 本地调试配置（VS Code）

为了方便在 VS Code 中调试 Freqtrade 策略，可以使用内置的 Python 调试器（`debugpy`）启动回测或实盘模式。以下是一个典型的 `launch.json` 配置示例。

## `launch.json` 配置示例

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Freqtrade",
      "type": "debugpy",
      "request": "launch",
      "program": "${workspaceFolder}/freqtrade",  // Freqtrade 启动文件路径
      "args": [
        "backtesting",                         // 启动模式：回测（trade 为实盘模式）
        "--timerange", "20230101-20240102",    // 回测时间范围
        "--timeframe", "1d",                   // 使用的时间周期

        "--config", "user_data/config.json",   // 配置文件路径
        "--strategy", "VolatilityAlertStrategy"// 策略名称，需与你的策略文件对应
      ],
      "console": "integratedTerminal",         // 使用 VS Code 集成终端
      "cwd": "${workspaceFolder}"              // 工作目录，一般为项目根目录
    }
  ]
}
```