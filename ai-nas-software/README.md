# AI NAS 软件开源仓库（ai-nas-software）

基于 RISC-V 的家用开源 AI NAS 的**自研软件**目录。硬件设计见同仓 [`ai-nas-hardware`](../ai-nas-hardware/README.md)。

## 许可证

本仓库自研代码以 **木兰宽松许可证 v2（Mulan PSL v2）** 发布。许可证全文见 [`LICENSE`](./LICENSE)。

> Mulan PSL v2 是国内首个通过 OSI 认证的开源许可证，中英双语、含显式专利授权与防御性终止条款，宽松无传染性，适合本土企业与法务。

## 第三方组件：OpenMediaVault（OMV）

底层存储管理系统 **OpenMediaVault（OMV）** 为上游 **GPLv3** 项目（Copyright OpenMediaVault GmbH），**不在此仓内复制其源码**，而是以 **git submodule** 方式引用上游：

```
src/openmediavault/   # git submodule -> https://github.com/openmediavault/openmediavault (GPLv3)
```

克隆本仓库后请执行：

```bash
git submodule update --init --recursive
```

> 若本仓新增的 OMV 插件被判定为 OMV 的"衍生作品（derivative work）"，则该部分须保持 **GPLv3** 兼容许可；纯独立工具/服务可用本仓的 Mulan PSL v2。具体划分见各子目录 README 与 NOTICE。

## 目录结构

```
ai-nas-software/
├── LICENSE                 # Mulan PSL v2 许可证全文
├── NOTICE.md               # 版权与第三方依赖声明
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
├── CODE_OF_CONDUCT.md
├── .gitignore
├── src/                   # 自研源码
│   ├── board-support/     # 板级支持：设备树、驱动适配、U-Boot/OpenSBI 补丁
│   ├── nas-services/      # 自研 NAS 服务（存储/网络/AI 推理等）
│   └── web-ui/            # 管理界面（前端）
├── deploy/                # 部署
│   ├── scripts/           # 烧录 / 部署 / 升级脚本
│   └── configs/           # 配置模板
├── docs/                  # 文档
│   ├── architecture/      # 架构设计文档
│   └── api/               # API 文档
└── .github/               # GitHub 协作模板与 CI
    ├── workflows/         # CI / 镜像到 Gitee
    ├── ISSUE_TEMPLATE/
    └── PULL_REQUEST_TEMPLATE.md
```

## 快速开始

```bash
# 1. 克隆（含 OMV 子模块）
git clone --recurse-submodules <this-repo-url>
cd ai-nas-software

# 2. 初始化子模块
git submodule update --init --recursive

# 3. 构建 / 部署（示例，按实际脚本调整）
bash deploy/scripts/build.sh
```

## 关联目录

| 目录 | 内容 | 许可证 |
|------|------|--------|
| `ai-nas-hardware` | 硬件设计 | CERN-OHL-P v2 |
| `ai-nas-software` | 自研软件 / 固件 / 部署 | Mulan PSL v2（OMV 部分为 GPLv3） |

## 双平台同步

本仓以 **GitHub 为主仓**，通过 `.github/workflows/mirror-to-gitee.yml` 单向镜像到 **Gitee**（国内加速 + 数据本地化）。请勿在 Gitee 端直接提交，避免双向同步冲突。
