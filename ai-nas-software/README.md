# AI NAS 软件开源仓库（ai-nas-software）

基于 RISC-V（EIC7700）的家用开源 AI NAS 的**软件**目录。硬件设计见同仓 [`ai-nas-hardware`](../ai-nas-hardware/README.md)。

## 许可证

各部分许可**不同**，请勿混用：

| 范围                          | 许可               |
| --------------------------- | ---------------- |
| 本仓库自行整理/编写的部分（构建脚本、文档、目录组织） | **Mulan PSL v2** |
| `src/`（自研服务、Web UI）         | **Mulan PSL v2** |
| `board-support/linux/**`    | **GPL-2.0**      |
| `board-support/uboot/**`    | **GPL-2.0+**     |
| `board-support/opensbi/**`  | **BSD-2          |
| 二进制固件（`*.bin`）              | 见 `NOTICE.md`    |

> Mulan PSL v2 是国内首个通过 OSI 认证的开源许可证，中英双语、含显式专利授权与防御性终止条款，宽松无传染性，适合本土企业与法务。

**第三方归属与完整许可声明见 [`NOTICE.md`](./NOTICE.md)。**

## 目录结构

```
ai-nas-software/
├── LICENSE                 # Mulan PSL v2 许可证全文
├── NOTICE.md               # 版权、第三方许可与脱敏声明（重要）
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
├── CODE_OF_CONDUCT.md
├── .gitignore
├── .gitmodules             # 上游源码 submodule 声明（linux / uboot / opensbi）
├── setenv.sh               # SDK 构建入口（已脱敏）
├── board-support/          # 本项目板级配置（保持上游目录结构，便于覆盖）
│   ├── linux/              #   defconfig、设备树、LED 绑定、NPU 固件   [GPL-2.0]
│   ├── uboot/              #   defconfig、board/eswin/eic7700_nas      [GPL-2.0+]
│   └── opensbi/            #   platform/eswin/eic770x                  [BSD-2-Clause]
├── source/                 # 上游与本项目自有内容
│   ├── linux/              #   submodule 挂载点 → torvalds/linux
│   ├── uboot/              #   submodule 挂载点 → u-boot/u-boot
│   ├── opensbi/            #   submodule 挂载点 → riscv-software-src/opensbi
│   ├── firmware/           #   预编译固件（仅 eic7700-ai-nas 使用部分）
│   └── mkimg/              #   镜像打包工具、es-* 服务、rootfs 构建脚本
├── src/                    # 自研源码 [Mulan PSL v2]
│   ├── nas-services/       # NAS 服务（存储/网络/AI 推理/监控）
│   └── web-ui/             # 管理界面前端
├── deploy/                 # 部署脚本与配置模板
└── docs/                   # 文档
```

## 上游源码：以 submodule 引用，不复制

上游源码体积约 **1.5 GB / 10 万文件**，不放入主仓。本仓库通过 `.gitmodules` 声明依赖，
**需要时按需挂载**：

```bash
# 全部挂载（约 1.5 GB，耗时较长）
git submodule update --init --recursive

# 或只挂载需要的组件
git submodule update --init source/linux
git submodule update --init source/uboot
git submodule update --init source/opensbi
```

| 组件      | 版本      | 许可           |
| ------- | ------- | ------------ |
| Linux   | 6.6.138 | GPL-2.0      |
| U-Boot  | 2024.01 | GPL-2.0+     |
| OpenSBI | —       | BSD-2-Clause |

> **重要限制**：上游官方源码**不含芯片厂商的 SoC 支持代码**（驱动、时钟、pinctrl 等私有补丁），
> 这些补丁由厂商提供且未包含在本仓库。因此仅挂载 submodule **无法直接构建出可启动镜像**；
> 需先获取厂商 SDK，再将 `board-support/` 内容覆盖到对应位置。

## 构建说明

```bash
# 1. 配置源码服务器（原 SDK 使用乙方内部 Gerrit，已脱敏为变量）
export GIT_SERVER_BASE="https://your-git-server.com"

# 2. 配置 Debian 软件源（原为乙方私有源，已脱敏为变量）
export DEBIAN_REPO_BASE="https://your-debian-mirror.com/debian"

# 3. 设置 rootfs 用户口令（切勿使用默认的弱口令 eswin）
export USER_PASSWORD="<强口令>"

# 4. 执行构建，交互菜单中选择板卡 eic7700-ai-nas
bash setenv.sh
```

构建环境要求：Debian/Ubuntu，工具链 `riscv64-unknown-linux-gnu-`（默认位于 `/opt/riscv/bin`）。

# 

## ⚠️ 安全提示

`source/mkimg/` 构建出的镜像**默认用户为 `eswin`、密码 `eswin`**，属弱口令。
任何接入同一网络的人都可登录设备。**部署到生产环境前务必修改口令**。

## 关联目录

| 目录                | 内容           | 许可证                         |
| ----------------- | ------------ | --------------------------- |
| `ai-nas-hardware` | 硬件设计         | CERN-OHL-P v2               |
| `ai-nas-software` | 软件、板级配置、构建脚本 | Mulan PSL v2（GPL/BSD 部分见上表） |

## 双平台同步

本仓以 **GitHub 为主仓**，通过 `.github/workflows/mirror-to-gitee.yml` 单向镜像到 **Gitee**（国内加速 + 数据本地化）。
请勿在 Gitee 端直接提交，避免双向同步冲突。
