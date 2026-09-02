# src/board-support/ — 板级支持

板级适配相关源码，包括：

- 设备树（`*.dts` / `*.dtsi`）：SoC 与板载外设描述；
- 驱动适配补丁（如网卡、电源管理、散热风扇、LED 等）；
- U-Boot / OpenSBI 补丁与构建片段；
- 启动相关配置。

> 本目录内的 U-Boot / OpenSBI / Linux 部分须遵循各自上游许可（多为 GPL-2.0 / GPL-2.0+），请勿以 Mulan PSL v2 重新许可上游代码；仅"自研新增"部分以 Mulan PSL v2 发布。
