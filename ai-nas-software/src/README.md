# src/ — 自研源码

本目录存放 AI NAS 的**自研软件源码**（以 Mulan PSL v2 许可）。底层存储管理系统 OpenMediaVault（OMV，GPLv3）以 git submodule 方式引用，见 `src/openmediavault/`（克隆后需 `git submodule update --init`）。

| 子目录 | 内容 | 许可建议 |
|--------|------|----------|
| `board-support/` | 板级支持：设备树（DTS）、驱动适配、U-Boot / OpenSBI 补丁 | 遵循上游（GPL-2.0 等） |
| `nas-services/` | 自研 NAS 服务（存储编排、网络、AI 推理、监控等） | Mulan PSL v2 |
| `web-ui/` | 管理界面前端 | Mulan PSL v2 |

> 判定"衍生作品"时：仅调用 OMV 公开 API / 以独立进程通信的组件可用 Mulan PSL v2；直接修改或链接 OMV 内部、构成其衍生作品的插件须保持 GPLv3 兼容。具体以法务意见为准。
