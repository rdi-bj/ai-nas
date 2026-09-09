# AI NAS 开源项目

本仓库是北京 RDI 创新中心 AI NAS 项目的完整开源 monorepo，包含硬件设计源文件与自研软件/部署脚本。

```
ai-nas/
├── ai-nas-hardware/   # 硬件设计源文件（CERN-OHL-P v2）
└── ai-nas-software/   # 自研软件、固件、部署脚本（Mulan PSL v2）
```

## 子项目说明

| 目录 | 内容 | 许可证 |
|------|------|--------|
| [`ai-nas-hardware/`](./ai-nas-hardware/README.md) | RISC-V AI NAS 主板、SATA 扩展板、FPC 排线的原理图、PCB 版图与 BOM | CERN-OHL-P v2 |
| [`ai-nas-software/`](./ai-nas-software/README.md) | 板级支持、NAS 服务、Web UI、部署脚本 | Mulan PSL v2（OMV submodule 为 GPLv3） |

## 快速开始

```bash
# 克隆整个 monorepo
git clone git@github.com:rdi-bj/ai-nas.git
cd ai-nas

# 查看硬件设计
cd ai-nas-hardware

# 查看软件与部署
cd ../ai-nas-software
```

## 双平台同步

本仓以 **GitHub 为主仓**，通过 `.github/workflows/mirror-to-gitee.yml` 单向镜像到 **Gitee**，请勿在 Gitee 端直接提交。

## 二进制发布（固件 / 系统镜像）

可烧录 / 部署的二进制资产（引导固件、系统镜像、OMV 安装包、内核 deb 等）通过 **GitHub Releases** 发布，不纳入 git 仓库：

- 最新发布包 `v1.0-sdk-20260722`：[GitHub Releases 下载](https://github.com/rdi-bj/ai-nas/releases/tag/v1.0-sdk-20260722)
- 全部发布历史：[GitHub Releases](https://github.com/rdi-bj/ai-nas/releases)

> 说明：受 Gitee 免费版单文件（≤100 MB）与 LFS 额度限制，本项目的二进制资产集中在 GitHub Releases；Gitee 仅镜像源码，下载请走上述 GitHub 链接。

## 许可证声明

- 硬件设计：CERN Open Hardware Licence v2 - Permissive（见 `ai-nas-hardware/LICENSE`）。
- 自研软件：木兰宽松许可证 v2（见 `ai-nas-software/LICENSE`）。
- 上游 OpenMediaVault（OMV）为 GPLv3，以 git submodule 形式在 `ai-nas-software/src/openmediavault/` 引用，不复制源码到本仓。
