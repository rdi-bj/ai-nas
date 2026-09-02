# NOTICE — AI NAS 软件

## 版权

- 本仓库**自行整理与编写**的部分（构建脚本脱敏改写、目录组织、文档、`board-support/` 中提取的板级配置）以 **Mulan PSL v2** 发布。
- 首次发表年份：`<待填写>`
- 版权人：`<待填写>`

## 上游组件与许可

本仓库**不复制**上游源代码，以下组件以 git submodule 引用（见 `.gitmodules`）：

| 组件 | 版本 | 许可 | 上游地址 |
|------|------|------|----------|
| Linux 内核 | 6.6.138 | **GPL-2.0** | github.com/torvalds/linux |
| U-Boot | 2024.01 | **GPL-2.0+** | github.com/u-boot/u-boot |
| OpenSBI | — | **BSD-2-Clause** | github.com/riscv-software-src/opensbi |
| OpenMediaVault (OMV) | 7.x | **GPLv3** | github.com/openmediavault/openmediavault |

`board-support/` 下的板级配置（defconfig、设备树 `.dts/.dtsi`、U-Boot 板级目录、OpenSBI 平台代码）
源自上游组件在 **EIC7700 平台上的移植与适配**，其许可遵循**各自上游组件的许可证**：

- `board-support/linux/**` → **GPL-2.0**（Linux 内核衍生作品）
- `board-support/uboot/**` → **GPL-2.0+**（U-Boot 衍生作品）
- `board-support/opensbi/**` → **BSD-2-Clause**（OpenSBI 衍生作品）

> ⚠️ 依据 GPL-2.0 / GPL-2.0+，上述部分的**再分发必须保持相同许可证并开放源代码**，本仓库已满足该要求。

## 二进制固件（重要：授权状态待确认）

以下文件为**预编译二进制**，无对应源代码，其著作权与再分发授权**未在交付物中明确声明**：

| 路径 | 内容 | 状态 |
|------|------|------|
| `source/firmware/secboot_eic7700_ai_nas/*.bin` | 安全启动固件 | ⚠️ 授权待确认 |
| `source/firmware/ddr_fw_*.bin` | DDR 初始化固件 | ⚠️ 授权待确认 |
| `source/firmware/d2d.bin` | Die-to-Die 互联固件 | ⚠️ 授权待确认 |
| `board-support/linux/vendor/eswin/firmware/*.bin` | NPU 固件 | ⚠️ 授权待确认 |
| `source/mkimg/firmware/*.hcd`、`.bin`、`.blob`、`.txt` | Wi-Fi / 蓝牙固件 | ⚠️ 授权待确认 |

**上述固件的原始著作权人应为芯片/模组供应商。在对外发布前，请确认交付合同中是否包含
「二进制固件可再分发」条款；若未获授权，应从公开仓库中移除这些文件，改为在文档中提供获取途径。**

## 脱敏说明

原始 SDK 中的以下信息已在整理过程中**移除或替换为可配置变量**，不随本仓库公开：

| 原内容 | 处理 |
|--------|------|
| 芯片厂商内部 Gerrit 地址（`ibugerrit.*`，3 处） | 替换为 `${GIT_SERVER_BASE}` |
| 芯片厂商私有 Debian 软件源（`archive.*/debian`，10 处） | 替换为 `${DEBIAN_REPO_BASE}` |
| rootfs 默认口令（明文 `eswin`） | 替换为 `${USER_PASSWORD}`，并在 `SECURITY.md` 中警告风险 |

## 关于源码中保留的作者署名

`board-support/` 下源自上游的代码中保留了作者署名与工作邮箱（形如 `xxx@eswincomputing.com`）。

**这些署名予以保留，不作删除或匿名化处理**，理由如下：

- GPL-2.0 / GPL-2.0+ / BSD-2-Clause 等许可证均**要求保留原始版权声明与作者署名**，
  擅自删除或改动构成对许可证的违反；
- 上述邮箱为厂商**公开域名邮箱**，非内网地址或凭证，不构成信息泄露；
- 保留署名也是对原作者贡献的正当承认。

若确需移除，请先行咨询法务并与权利人沟通，勿直接修改。

## 商标

本仓库提及的厂商名称、产品名、商标（含 Eswin、ESWIN、EIC7700、RISC-V 等）归各自权利人所有，
使用仅为描述兼容性，不暗示任何授权或背书。

## 贡献声明

依据 Mulan PSL v2，每个源文件头部应包含如下声明（请补全年份与版权人）：

```
Copyright (c) [Year] [name of copyright holder]
[Software Name] is licensed under Mulan PSL v2.
You can use this software according to the terms and conditions of the Mulan PSL v2.
You may obtain a copy of Mulan PSL v2 at:
         http://license.coscl.org.cn/MulanPSL2
THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, ...
See the Mulan PSL v2 for more details.
```
