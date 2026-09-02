# 贡献指南（CONTRIBUTING）

感谢你为 AI NAS 开源软件做出贡献！请按以下流程提交变更。

## 1. 准备工作

- 在 GitHub 上 **Fork** 本仓库到你的账号；
- 从 `main`（或 `master`）分支切出特性分支：`git checkout -b feat/your-topic`；
- 确保已初始化子模块：`git submodule update --init --recursive`。

## 2. 开发与提交

- 自研代码请以 **Mulan PSL v2** 许可发布，并在每个源文件头部添加 NOTICE 中的许可证声明；
- 涉及 **OpenMediaVault 衍生**的插件/补丁，须保持 **GPLv3** 兼容；
- 提交信息建议遵循约定式提交（Conventional Commits）：`feat:` / `fix:` / `docs:` / `refactor:` / `test:`；
- 提交前请运行 `deploy/scripts/build.sh`（或对应构建/测试）确认通过。

## 3. 签署（DCO / CLA）

为保障许可清晰，所有贡献须满足以下之一（请与法务确认后启用）：

- **DCO（Developer Certificate of Origin）**：每个提交添加 `Signed-off-by: Your Name <you@example.com>`（可用 `git commit -s`）；或
- **CLA（Contributor License Agreement）**：组织统一签署。

> 当前状态：`<DCO/CLA 策略待项目方确认后填写>`。

## 4. 提交 Pull Request

- 在 GitHub 发起 PR 到本仓 `main` 分支；
- 填写 PR 模板，说明变更目的、范围与测试情况；
- 至少 1 名维护者 Review 通过后方可合并；
- 合并前请确保 CI（构建 + 许可证扫描）通过。

## 5. 行为准则

参与本仓库即视为同意 [`CODE_OF_CONDUCT.md`](./CODE_OF_CONDUCT.md)。
