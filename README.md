UART-verification
基于 UVM 的 UART 验证环境（进行中）—— TX / RX 双路径独立 agent，当前阻塞于 Driver 与 Monitor 的包匹配问题

状态：WIP / Blocked
最后更新：2026-11-11
仿真环境：QuestaSim 10.7c + UVM-1.1d（tx_test.log 实测）

项目简介
本项目为一个标准 UART DUT 搭建 UVM 验证环境，采用 TX / RX 双路径独立 agent 的结构：tx_agent 负责发送路径的激励与观测，rx_agent 负责接收路径，两条路径各自配有 driver、monitor、subscriber，并通过 uart_env 集成到 tb_top 中。当前环境可以启动 tx_test / rx_test 并产生 scoreboard 的 PASS 打印，但 Driver 发出的激励 transaction 与 Monitor 从引脚采集重建的 observed transaction 之间存在不稳定的不一致，scoreboard 的比对结果尚不能作为可信的通过/失败判据。该问题记录在 Known Issue 中。

仓库结构
text
UART-verification/
├── component/                 # UVM 环境组件
│   ├── rx_agent.sv            # RX agent（sequencer + driver + monitor）
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
├── mtiUvm=uvm-1.2/            # QuestaSim UVM 库信息
├── run.sv                     # 编译/仿真脚本
├── rx_test.log                # RX 用例仿真日志
└── tx_test.log                # TX 用例仿真日志
已实现部分
DUT：dut/ 下为拆分后的 UART RTL，baudgen 生成波特率 tick，uart_tx / uart_rx 分别实现发送与接收，uart.v 为顶层封装。

UVM 环境：component/ 中已经完成了 TX 与 RX 两条 agent 的搭建，每条路径都有独立的 driver、monitor、subscriber，uart_env 负责集成，tb_top 完成 DUT 与 interface 的例化。

Sequence / Test：sequence_test/ 下已有 tx_sequence.sv / tx_test.sv 与 rx_sequence.sv / rx_test.sv，可以分别启动 TX 和 RX 用例。

仿真入口：run.sv 提供编译与仿真脚本；tx_test.log 显示当前使用 QuestaSim 10.7c + UVM-1.1d，仿真日志中可以观察到 scoreboard 的 [scb_tx] [PASS] exp=0x0 act=0x0 打印。

Known Issue: Driver 包与 Monitor 包难以匹配
现象
tx_test / rx_test 能够跑完，scoreboard 也有 PASS 打印，但 expected（来自 driver / sequence 的激励侧 transaction）与 actual（来自 monitor 的观测侧 transaction）在多次运行或不同 seed 下并不稳定一致。

不一致不是固定偏移，而是 时有时无、随时序或 seed 变化，指向 采样时机或帧边界判定 问题，而不是单纯的数据通路错误。

为什么在 UART 中尤其容易发生
UART 是 异步、无独立时钟 的串行协议，帧的位周期由 baud_tick 决定。如果 monitor 仍然按照系统时钟在信号跳变沿附近采样，而不是在 每个位的中心 采样，采到的位值就可能落在帧边界或信号跳变窗口内，导致整个字节错位。UVM 社区中一条反复出现的经验是：driver 和 monitor 的包不匹配， 要么是 driver 的 pin wiggle 驱动错了，要么是 monitor 从引脚采集重建的逻辑错了，二者必居其一。

当前排查方向（尚未定论）
Monitor 采样点是否对齐到位中心：UART monitor 应在检测到 start bit 的下降沿后，偏移 半个位周期 再开始按 baud_tick 间隔采样，以保证每个采样点落在位的中心，而不是边沿。需要确认 tx_monitor.sv / rx_monitor.sv 中是否已经实现了这个 half-bit offset。

Driver 的 pin wiggle 时序：tx_driver.sv 驱动每一位的持续时间是否严格等于 baud_tick 周期？如果 driver 侧已经存在时序偏差，monitor 采到的会是“正确的错误”，scoreboard 却把责任算到 monitor 头上。

帧起始判定窗口：start bit 的检测条件是否过宽？在 UART 中，start 的下降沿判定如果引入滤波或毛刺容忍，可能把噪声或上一帧的 stop 位尾部误判为新帧头。

Transaction 粒度一致性：driver 侧一个 sequence item 对应完整一帧（start + data + parity + stop），monitor 是否也按 完整帧 发出 transaction，而不是逐位或半帧 write 到 analysis port。

TLM 连接与写入时机：monitor 的 analysis port 是否只连接了一次？scoreboard 的 write 是否在正确的 phase 被触发，而不是在 monitor 尚未完成一帧重建时就提前发出。

后续计划（解决阻塞后）
定位并修复 Driver/Monitor 包匹配问题（当前最高优先级）。建议先在 monitor 中把采集到的原始波形与 driver 驱动的波形在时间轴上对齐，确认是“驱动错了”还是“采错了”。

在 tx_monitor / rx_monitor 中显式实现 half-bit offset + baud_tick 对齐的位中心采样，并用已知 pattern（如 0x55、0xAA）做定向单帧测试。

补充 UART 功能覆盖率：baud rate、data width、parity mode、stop bits、连续帧间隔、错误注入（parity error / frame error）。

添加定向用例：单字节收发、背靠背帧、奇偶校验错、帧错误、溢出。

随机化回归 + 多 seed 收敛。

如何参与 / 跟进
本项目仍在迭代中，Driver 与 Monitor 的包匹配问题 是当前的主要卡点。在阻塞问题关闭之前，scoreboard 的 mismatch 报告 不应被直接视为 DUT bug。如果你对 UART 帧同步、monitor 位中心采样或 UVM TLM 连接有经验，欢迎通过 Issue 提供排查思路。

运行方式（待补全）
run.sv 为当前仿真入口，tx_test.log / rx_test.log 为已有仿真记录。具体编译选项、UVM 库路径和运行命令待阻塞问题解决后补全到 README 中。
