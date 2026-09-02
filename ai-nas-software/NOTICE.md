# NOTICE — AI NAS 软件

## 版权

- 本仓库自研源代码（目录 `src/`、`deploy/`、`docs/`）的著作权归**项目承担单位**所有，以 **Mulan PSL v2** 发布。
- 首次发表年份：`<待填写>`
- 版权人：`<待填写>`

## 第三方依赖与许可

| 组件 | 许可 | 说明 |
|------|------|------|
| OpenMediaVault（OMV） | **GPLv3** | 以 git submodule 引用上游 `github.com/openmediavault/openmediavault`，不复制源码；若本仓代码构成其衍生作品，则该部分须保持 GPLv3 兼容 |
| U-Boot / OpenSBI / Linux 内核 | GPL-2.0 / GPL-2.0+ 等 | 板级适配补丁遵循上游对应许可 |
| 其他第三方库 | 见各子目录 SPDX 声明 | 请在引入依赖时补充 SBOM 与许可证扫描 |

## 商标

本仓库提及的厂商名称、产品名、商标归各自权利人所有，使用仅为描述兼容性，不暗示任何授权或背书。

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
