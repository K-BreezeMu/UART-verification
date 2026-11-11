# UART-verification

![Status](https://img.shields.io/badge/status-WIP%20%2F%20blocked-orange)
![Methodology](https://img.shields.io/badge/methodology-UVM-blue)
![Simulator](https://img.shields.io/badge/simulator-QuestaSim%2010.7c-lightgrey)
![Language](https://img.shields.io/badge/language-SystemVerilog-informational)

基于 UVM 的 UART 验证环境。当前处于开发中途，**阻塞于 Driver 激励事务与 Monitor 观测事务的匹配问题**，详见 [已知问题](#已知问题driver-与-monitor-包匹配)。

---

## 目录

- [项目简介](#项目简介)
- [当前状态](#当前状态)
- [仓库结构](#仓库结构)
- [环境与工具](#环境与工具)
- [快速开始](#快速开始)
- [验证环境架构](#验证环境架构)
- [已知问题：Driver 与 Monitor 包匹配](#已知问题driver-与-monitor-包匹配)
- [后续计划](#后续计划)
- [贡献](#贡献)
- [License](#license)

---

## 项目简介

本项目为一个标准 UART DUT 搭建 UVM 验证环境，采用 **TX / RX 双路径独立 agent** 的结构：

- `tx_agent` 负责发送路径的激励与观测；
- `rx_agent` 负责接收路径的激励与观测；
- 两条路径各自配有 `driver`、`monitor`、`subscriber`；
- `uart_env` 集成两条 agent 与 scoreboard，`tb_top` 完成 DUT 与 interface 的例化。

当前环境可以启动 `tx_test` / `rx_test`，scoreboard 能够产生 PASS 打印，但 **Driver 侧发出的激励 transaction 与 Monitor 从引脚采集并重建的 observed transaction 存在不稳定的不一致**。在该问题关闭前，scoreboard 的比对结果不作为可信的通过 / 失败判据。

---

## 当前状态

| 模块 | 文件 | 状态 |
|---|---|---|
| UART DUT | `dut/uart.v` 等 | 可用 |
| TX Agent | `component/tx_agent.sv` | 已集成 |
| TX Driver | `component/tx_driver.sv` | 已实现，时序严格性待确认 |
| TX Monitor | `component/tx_monitor.sv` | 已实现，帧重建稳定性待确认 |
| TX Subscriber | `component/tx_subscriber.sv` | 已接入 |
| RX Agent | `component/rx_agent.sv` | 已集成 |
| RX Driver | `component/rx_driver.sv` | 已实现，时序严格性待确认 |
| RX Monitor | `component/rx_monitor.sv` | 已实现，帧重建稳定性待确认 |
| RX Subscriber | `component/rx_subscriber.sv` | 已接入 |
| Environment | `component/uart_env.sv` | 已集成 |
| Testbench Top | `component/tb_top.sv` | 已集成 |
| Scoreboard | `component/uart_env.sv` 内 | 已接入，比对结果暂不可信 |
| 功能覆盖率 | — | 未开始 |
| 随机回归 / 多 seed | — | 未开始 |

**总体结论：环境可运行，driver 可驱动、monitor 可采集，但两侧事务无法稳定对齐。**

---

## 仓库结构

```text
UART-verification/
├── component/                 # UVM 环境组件
│   ├── rx_agent.sv            # RX agent（集成 sequencer / driver / monitor）
│   ├── rx_driver.sv           # RX 路径激励驱动
│   ├── rx_monitor.sv          # RX 路径观测与 transaction 重建
│   ├── rx_subscriber.sv       # RX 路径覆盖率订阅
│   ├── tx_agent.sv            # TX agent
│   ├── tx_driver.sv           # TX 路径激励驱动
│   ├── tx_monitor.sv          # TX 路径观测与 transaction 重建
│   ├── tx_subscriber.sv       # TX 路径覆盖率订阅
│   ├── uart_env.sv            # 环境顶层，集成 TX/RX agent 与 scoreboard
│   └── tb_top.sv              # testbench top，实例化 DUT 与 interface
├── dut/                       # UART RTL
│   ├── baudgen.v              # 波特率发生器
│   ├── uart_tx.v              # UART 发送器
│   ├── uart_rx.v              # UART 接收器
│   └── uart.v                 # UART 顶层
├── sequence_test/             # sequence 与 test
│   ├── tx_sequence.sv
│   ├── tx_test.sv
│   ├── rx_sequence.sv
│   └── rx_test.sv
├── mtiUvm=uvm-1.2/            # QuestaSim UVM 库相关目录（用途待确认）
├── run.sv                     # 编译 / 仿真脚本
├── tx_test.log                # TX 用例仿真日志
└── rx_test.log                # RX 用例仿真日志
```

> 说明：`mtiUvm=uvm-1.2/` 的目录名与日志中显示的 UVM 版本存在不一致，见 [环境与工具](#环境与工具)。

---

## 环境与工具

| 项目 | 说明 |
|---|---|
| 语言 | SystemVerilog |
| 方法学 | UVM |
| 仿真器 | QuestaSim 10.7c（依据 `tx_test.log`） |
| UVM 版本 | 日志显示为 UVM-1.1d；仓库中另有 `mtiUvm=uvm-1.2/` 目录，**版本待统一确认** |
| 操作系统 | 待补充 |
| 其他依赖 | 待补充 |

---

## 快速开始

当前仿真入口为仓库根目录下的 `run.sv`，具体编译选项与运行命令以该文件实际内容为准。

```text
# 占位，待 run.sv 内容确认后补全
```

已有仿真记录：

- `tx_test.log`
- `rx_test.log`

> 在 [已知问题](#已知问题driver-与-monitor-包匹配) 关闭前，日志中的 PASS 打印不足以作为验证通过的结论。

---

## 验证环境架构

```text
tb_top
 ├── uart_if (interface)
 ├── dut/uart.v
 │    ├── baudgen.v
 │    ├── uart_tx.v
 │    └── uart_rx.v
 └── uart_env
      ├── tx_agent
      │    ├── tx_driver
      │    ├── tx_monitor
      │    └── tx_subscriber
      ├── rx_agent
      │    ├── rx_driver
      │    ├── rx_monitor
      │    └── rx_subscriber
      └── scoreboard
```

设计原则：

- TX / RX 两条路径相互独立，便于分别调试与扩展。
- Monitor 负责从引脚活动重建 transaction，并通过 analysis port 发送给 scoreboard。
- Scoreboard 比对 expected（激励侧）与 actual（观测侧）；当前比对稳定性受 [已知问题](#已知问题driver-与-monitor-包匹配) 影响。

---

## 已知问题：Driver 与 Monitor 包匹配

### 现象

- `tx_test` / `rx_test` 可正常跑完，scoreboard 有 PASS 打印。
- **expected（来自 driver / sequence 的激励事务）与 actual（来自 monitor 的观测事务）在多次运行或不同 seed 下并不稳定一致。**
- 不一致并非固定偏移，而是 **时有时无、随时序或 seed 变化**，指向 **采样时机或帧边界判定** 问题，而非单纯的数据通路错误。

### 影响

- scoreboard 的 mismatch 报告在问题关闭前 **不能直接归因于 DUT**。
- 功能覆盖率与随机回归暂不启动，避免在不可信的比对基础上继续叠加结论。

### 背景

UART 是异步串行协议，帧的位周期由 `baudgen` 产生的 baud tick 决定。若 monitor 在系统时钟沿或信号跳变附近采样，而不是在 **每个位的中心** 采样，采到的位值可能落在帧边界或跳变窗口内，导致整字节错位。此类问题的常见归因是：

- **driver 的引脚驱动时序错误**，或
- **monitor 的采集与帧重建逻辑错误**。

二者必居其一，需通过波形对齐定位。

### 排查清单

| # | 排查项 | 说明 | 状态 |
|---|---|---|---|
| 1 | Monitor 采样点是否对齐位中心 | 检测 start 下降沿后偏移半个位周期，再按 baud tick 间隔采样 | 待验证 |
| 2 | Driver 引脚驱动时序 | 每位持续时间是否严格等于 baud tick 周期 | 待验证 |
| 3 | Start bit 判定窗口 | 判定条件是否过宽，导致误判帧头 | 待验证 |
| 4 | Transaction 粒度一致性 | driver 一 item 对应完整帧；monitor 是否也按完整帧发出 | 待验证 |
| 5 | TLM 连接与写入时机 | analysis port 是否重复连接；scoreboard `write` 是否提前触发 | 待验证 |

### 当前处置

问题尚未定位。后续将优先在 monitor 中将采集波形与 driver 驱动波形在时间轴上对齐，确认是“驱动错误”还是“采集错误”，再决定修改侧。

---

## 后续计划

- [ ] **定位并修复 Driver/Monitor 包匹配问题（最高优先级）**
- [ ] 在 `tx_monitor` / `rx_monitor` 中显式实现 half-bit offset + baud tick 对齐的位中心采样
- [ ] 使用已知 pattern（如 `0x55`、`0xAA`）做定向单帧测试
- [ ] 补充 UART 功能覆盖率：baud rate、data width、parity mode、stop bits、帧间隔、错误注入
- [ ] 增加定向用例：单字节收发、背靠背帧、奇偶校验错、帧错误、溢出
- [ ] 随机化回归与多 seed 收敛
- [ ] 补全 `run.sv` 使用说明与复现步骤

---

## 贡献

本项目仍在迭代中，当前主要卡点为 [Driver 与 Monitor 包匹配](#已知问题driver-与-monitor-包匹配)。如果你对 UART 帧同步、monitor 位中心采样或 UVM TLM 连接有经验，欢迎通过 Issue 提供排查思路。

提交前请说明：

- 复现所用的 test 与 seed；
- 波形或日志中 expected / actual 的具体差异；
- 你的判断属于 driver 侧还是 monitor 侧。

---

## License

仓库暂未指定 License。如需开源，建议补充 `LICENSE` 文件。


