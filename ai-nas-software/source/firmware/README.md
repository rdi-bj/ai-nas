# firmware — 预编译固件（eic7700-ai-nas）

本目录包含 `eic7700-ai-nas` 板卡启动所需的**预编译二进制固件**。

## 内容清单

| 文件 | 用途 | 来源 |
|------|------|------|
| `secboot_eic7700_ai_nas/die0_sec_fw.bin` | 安全启动固件（die0） | 芯片厂商 |
| `secboot_eic7700_ai_nas/die1_sec_fw.bin` | 安全启动固件（die1） | 芯片厂商 |
| `ddr_fw_die0.bin` / `ddr_fw_die1.bin` | DDR 初始化固件 | 芯片厂商 |
| `ddr_fw_die0_nospi.bin` / `ddr_fw_die1_nospi.bin` | DDR 恢复用固件（无 SPI） | 芯片厂商 |
| `d2d.bin` | Die-to-Die 互联固件 | 芯片厂商 |
| `bootchain.config` | 启动链打包配置（文本） | SDK |
| `bootchain_die0.config` / `bootchain_die1.config` | 分 die 启动链配置（文本） | SDK |

## 开源范围说明

原始 SDK 的 `firmware/` 目录共包含 **10 个板卡的 secboot 变体**与 2 组 DDR 固件变体。
本仓库**仅保留 `eic7700-ai-nas` 实际使用**的部分：

- ✅ 保留：`secboot_eic7700_ai_nas/`、上述 4 个 DDR 固件、`d2d.bin`、启动链配置
- ❌ 未包含：其他板卡的 secboot（`secboot_p550`、`secboot_s260`、`secboot_s560`、`secboot_sbc`、
  `secboot_fml13`、`secboot_ce`、`secboot_7702evb`），以及 `ddr_low_freq/`、`ddr_no_logo/` 变体

> 判断依据：`setenv.sh` 中 `board_name=eic7700-ai-nas` 时匹配 `sec_dir=secboot_eic7700_ai_nas`，
> DDR 固件使用脚本默认值（`ddr_fw_die0.bin` 等，仅 `eic7700-sbc` 例外使用 `ddr_low_freq/`）。

## ⚠️ 授权提示

本目录下所有 `.bin` 均为**无源代码的预编译二进制**，原始著作权属于芯片厂商，
其再分发授权**未在交付物中明确声明**。

对外发布前请确认交付合同中是否包含「二进制固件可再分发」条款。
若未获授权，应从公开仓库移除这些文件，改为在文档中说明获取途径。

详见仓库根目录 `NOTICE.md`「二进制固件」一节。
