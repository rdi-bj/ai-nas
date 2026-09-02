# AI NAS 硬件开源仓库（ai-nas-hardware）

基于 RISC-V 的家用开源 AI NAS 硬件设计目录。本目录只包含**硬件设计文件**，软件部分见同仓 [`ai-nas-software`](../ai-nas-software/README.md)。

## 许可证

本仓库所有硬件设计文件以 **CERN Open Hardware Licence v2 - Permissive（CERN-OHL-P v2）** 发布。许可证全文见 [`LICENSE`](./LICENSE)。

> CERN-OHL-P v2 是最宽松的硬件开源许可证，允许任何人自由使用、研究、修改、制造与分发基于本设计的硬件产品，无"传染性"义务，仅要求保留声明（Notices）。

## 目录结构

```
ai-nas-hardware/
├── LICENSE                 # CERN-OHL-P v2 许可证全文
├── NOTICE.md               # 版权、软著与第三方归属声明
├── README.md
├── .gitignore
├── design/                # 设计源文件（按板卡分子目录）
│   ├── MainBoard/          # 主板（00-SCH 原理图 / 01-PCB 版图 / 02-BOM 物料）
│   ├── SATABoard/          # SATA 扩展板
│   └── FPCCable/           # FPC 排线（扁平软板）
└── docs/                  # 文档
    └── user-manual/       # 用户手册
```

> 各板卡的 `.DSN` / `.BRD` 为 Cadence Allegro 专有格式（需 Allegro 授权编辑），配套 `.pdf` 为可读版本；BOM 见各板卡 `02-BOM/`。详细的文件清单见 [`design/README.md`](./design/README.md)。

## 如何获取与组装本硬件

1. 各板卡 `02-BOM/` 提供元器件清单，可据此采购；
2. 软件固件与系统镜像见同仓 [`ai-nas-software`](../ai-nas-software/README.md)。

> 本仓库仅包含硬件**设计源文件**（原理图、PCB 版图、BOM）。Gerber 制板文件、结构件（3D 模型 / 2D 图纸）与制板工艺说明（fab-notes）**不纳入开源范围**，不随仓库公开。

## 声明

- 本仓库所含板级设计归项目承担单位所有，并已在 `NOTICE.md` 中声明。
- SoC（EIC7700）、内存、电源管理芯片等核心器件分别由其原厂所有，遵循各自厂商许可，不在本仓库许可范围内。
- 本仓库不含任何固件二进制或系统镜像；此类文件通过 Releases 分发。

## 关联目录

| 目录                | 内容             | 许可证           |
| ----------------- | -------------- | ------------- |
| `ai-nas-hardware` | 硬件设计           | CERN-OHL-P v2 |
| `ai-nas-software` | 自研软件 / 固件 / 部署 | Mulan PSL v2  |
