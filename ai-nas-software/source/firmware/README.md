# firmware — 预编译固件（eic7700-ai-nas）

本目录包含 `eic7700-ai-nas` 板卡启动所需的**预编译二进制固件**。

## 内容清单

| 文件                                                | 用途               | 来源   |
| ------------------------------------------------- | ---------------- | ---- |
| `secboot_eic7700_ai_nas/die0_sec_fw.bin`          | 安全启动固件（die0）     | 芯片厂商 |
| `secboot_eic7700_ai_nas/die1_sec_fw.bin`          | 安全启动固件（die1）     | 芯片厂商 |
| `ddr_fw_die0.bin` / `ddr_fw_die1.bin`             | DDR 初始化固件        | 芯片厂商 |
| `ddr_fw_die0_nospi.bin` / `ddr_fw_die1_nospi.bin` | DDR 恢复用固件（无 SPI） | 芯片厂商 |
| `d2d.bin`                                         | Die-to-Die 互联固件  | 芯片厂商 |
| `bootchain.config`                                | 启动链打包配置（文本）      | SDK  |
| `bootchain_die0.config` / `bootchain_die1.config` | 分 die 启动链配置（文本）  | SDK  |

# 
