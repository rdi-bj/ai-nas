# board-support — 板级支持（EIC7700 AI NAS）

本目录保存本项目针对 `eic7700-ai-nas` 板卡，对上游 Linux / U-Boot / OpenSBI 所做的**板级配置与适配**。

> **目录结构刻意保持与上游源码树一致**，便于直接将文件覆盖（或打补丁）到 submodule 挂载点。
> 例如 `board-support/linux/arch/riscv/configs/xxx` 对应 `source/linux/arch/riscv/configs/xxx`。

## 目录与许可

| 子目录 | 内容 | 许可 | 对应 submodule |
|--------|------|------|----------------|
| `linux/` | 内核 defconfig、设备树、LED 绑定头、NPU 固件 | **GPL-2.0** | `source/linux` |
| `uboot/` | U-Boot defconfig、板级目录 `board/eswin/eic7700_nas` | **GPL-2.0+** | `source/uboot` |
| `opensbi/` | OpenSBI `platform/eswin/eic770x` 平台支持 | **BSD-2-Clause** | `source/opensbi` |

## 内容清单

### linux/
| 文件 | 说明 |
|------|------|
| `arch/riscv/configs/eic7700_ai_nas_defconfig` | 内核构建配置 |
| `arch/riscv/boot/dts/eswin/eic7700-ai-nas.dts` | 板卡主设备树 |
| `arch/riscv/boot/dts/eswin/eic7700-opptable.dtsi` | 工作点/调频表 |
| `arch/riscv/boot/dts/eswin/eic7700-pinctrl.dtsi` | 引脚复用定义 |
| `arch/riscv/boot/dts/eswin/eswin-win2030-die0-soc.dtsi` | SoC 级定义（die0） |
| `arch/riscv/boot/dts/eswin/eswin-win2030-die0-noc.dtsi` | NoC 互联定义（die0） |
| `arch/riscv/boot/dts/eswin/eswin-win2030-arch.dtsi` | 架构级公共定义 |
| `include/dt-bindings/leds/leds-ainas.h` | **本项目特有**：AI NAS 指示灯 LED 绑定宏 |
| `vendor/eswin/firmware/*.bin` | NPU 固件（二进制，授权见根目录 `NOTICE.md`） |

> 设备树依赖链已完整递归解析：修改 `eic7700-ai-nas.dts` 时，上述 `.dtsi` 均为其传递依赖，缺一不可编译。

### uboot/
| 文件 | 说明 |
|------|------|
| `configs/eic7700_ai_nas_defconfig` | U-Boot 构建配置 |
| `board/eswin/eic7700_nas/{Kconfig,Makefile,MAINTAINERS,eic7700_nas.c}` | 板级初始化代码 |

### opensbi/
| 文件 | 说明 |
|------|------|
| `platform/eswin/eic770x/` | EIC770x 平台支持（DRAM、mailbox、UART、platform） |

## 使用方式

```bash
# 1. 挂载上游源码
git submodule update --init source/linux source/uboot source/opensbi

# 2. 将板级配置覆盖到上游源码树（以 Linux 为例）
cp -r board-support/linux/* source/linux/

# 3. 编译（详见仓库根目录 setenv.sh）
make ARCH=riscv eic7700_ai_nas_defconfig
make ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- -j$(nproc)
```

## 重要限制

上游官方 Linux / U-Boot / OpenSBI **不包含芯片厂商的 SoC 支持代码**（驱动、时钟、pinctrl 等私有补丁），
这些补丁由芯片厂商提供且未包含在本仓库中。因此：

- 仅挂载上游 submodule **无法直接完成可启动的构建**；
- 本目录提供的板级配置需配合厂商 SDK 方能生效；
- 若要构建可运行的镜像，请先获取厂商 SDK，再将本目录内容覆盖到对应位置。
