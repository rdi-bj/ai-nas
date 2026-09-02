# 执行过gpt_partition 就可以flash分区
-> in uboot
fastboot usb 0

-> host
fastboot flash boot boot*.ext4
fastboot flash root root*.ext4

-> in boot
boot

就可以进系统了 用户eswin 密码eswin

> ⚠️ **安全提示**：默认口令 `eswin/eswin` 为弱口令，任何接入同一网络的人都可登录设备。
> 构建前请通过环境变量设置强口令：
>   export USER_PASSWORD="<你的强口令>"
> 首次登录后也请立即执行 `passwd` 修改。

# mkrootfs.sh
需要在debian环境下运行 

> 注意：脚本中的软件源地址已改为变量 `${DEBIAN_REPO_BASE}`，
> 原乙方私有源不随本项目发布，请先配置可用的镜像源地址。

依赖：
sudo apt install -y gdisk dosfstools build-essential autoconf automake autotools-dev ninja-build make \
                                  libncurses-dev gawk flex bison openssl libssl-dev tree \
                                  gcc-riscv64-linux-gnu gfortran-riscv64-linux-gnu libgomp1-riscv64-cross \
                                  qemu-user-static binfmt-support mmdebstrap 
