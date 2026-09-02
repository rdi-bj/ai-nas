# deploy/scripts/ — 部署 / 烧录脚本

集中存放设备部署相关脚本，例如：

- `build.sh`：本地构建 / 打包；
- `flash.sh`：将镜像写入 eMMC / SD / SPI Flash；
- `firstboot.sh`：首次启动初始化（分区扩容、服务注册）；
- `upgrade.sh`：OTA / 增量升级。

脚本请保持幂等、可重复执行，并在文件头注明用途、依赖与风险。
