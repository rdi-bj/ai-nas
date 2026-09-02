# design/ — 设计源文件

本目录存放 AI NAS 板卡的**设计源文件**，按**板卡（board）**分子目录。每个板卡下沿用原交付物命名约定：

- `00-SCH/` 原理图（Allegro `.DSN` + 导出 PDF）
- `01-PCB/` PCB 版图（Allegro `.BRD`）
- `02-BOM/` 物料清单（`.xlsx`）

## 已归集的板卡

| 板卡           | 内容                          | 原理图                                     | PCB                            | BOM                                                                 |
| ------------ | --------------------------- | --------------------------------------- | ------------------------------ | ------------------------------------------------------------------- |
| `MainBoard/` | 主板（AI NAS 核心板，含 RISC-V SoC） | `00-SCH/AI_NAS_MB_A1_0723.DSN` + `.pdf` | `01-PCB/AI_NAS_MB_A2_pcb.brd`  | `02-BOM/SIBPAAINASE-001_V1.0_长鑫4GB 8533MHZ&长鑫64GB eMMC_260724.xlsx` |
| `SATABoard/` | SATA 扩展板                    | `00-SCH/AI_NAS_DB_A1_0723.DSN` + `.pdf` | `01-PCB/AI_NAS_DB__A2_PCB.brd` | `02-BOM/SIBPAAINASC-001_V1.0_260724.xlsx`                           |
| `FPCCable/`  | FPC 排线（扁平软板，无独立子目录）         | `AI_NAS_FPC_A0.DSN` + `.brd` + `.pdf`   | （同目录 `.brd`）                   | `SIBPAAINASD-000_V1.0.xlsx`                                         |

> **关于文件格式**：`.DSN` / `.BRD` 为 Cadence Allegro 专有格式，需 Allegro 授权方可编辑；配套 `.pdf` 为可读版本，便于无 Allegro 许可的社区成员查看。建议后续补充 **PDF 格式的 PCB 丝印/叠层图**，进一步降低阅读门槛。

## 来源

上述文件由`AI_NAS`项目交付物归集而来（版本：主板 A1/A2、SATA 板 A1/A2、FPC A0）。
