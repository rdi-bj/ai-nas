#!/bin/bash
# SPDX-License-Identifier: MulanPSL-2.0
#
# AI NAS (eic7700-ai-nas) SDK 构建脚本
#
# >>> 脱敏说明 <<<
# 原始 SDK 从乙方内部 Gerrit 服务器拉取 U-Boot / OpenSBI / Linux 源码，
# 该内部地址（不对外公开）已统一替换为变量 ${GIT_SERVER_BASE}。
# 使用前请通过环境变量或直接在下方修改为可访问的源码镜像地址，例如：
#     export GIT_SERVER_BASE=https://your-git-server.com
# 或将上游源码手动放置于 source/ 目录并跳过 clone 步骤。
#
# ==================== 源码服务器配置 ====================
export GIT_SERVER_BASE="${GIT_SERVER_BASE:-<YOUR_GIT_SERVER_BASE>}"
# ======================================================
export WORK_DIR=`pwd`
export PATH="/opt/riscv/bin:$PATH"
export ARCH=riscv
export CROSS_COMPILE=riscv64-unknown-linux-gnu-
export RELEASE_TAG=NAS-AI-20260521
function make_bootchain()
{
    echo "start compile bootchain"
    echo "dts name:$board_name"
    mkdir -p ${WORK_DIR}/$board_name
    rm -rf ${WORK_DIR}/$board_name/uboot-eswin${FEATURE}
    rm -rf ${WORK_DIR}/$board_name/opensbi-eswin${FEATURE}
    rm -rf ${WORK_DIR}/$board_name/firmware-eswin${FEATURE}
    if [ ! -d $WORK_DIR/source/uboot-eswin${FEATURE} ];then
        git clone -b ${RELEASE_TAG} ${GIT_SERVER_BASE}/uboot $WORK_DIR/source/uboot-eswin${FEATURE}
    fi
    rsync -au --chmod=u=rwX,go=rX  --exclude .git --exclude .hg --exclude .bzr --exclude CVS $WORK_DIR/source/uboot-eswin${FEATURE} ${WORK_DIR}/${board_name}/
    if [ ! -d $WORK_DIR/source/opensbi-eswin${FEATURE} ];then
        git clone -b ${RELEASE_TAG} ${GIT_SERVER_BASE}/opensbi $WORK_DIR/source/opensbi-eswin${FEATURE}
    fi
    rsync -au --chmod=u=rwX,go=rX  --exclude .git --exclude .hg --exclude .bzr --exclude CVS $WORK_DIR/source/opensbi-eswin${FEATURE} ${WORK_DIR}/${board_name}/
    rsync -au --chmod=u=rwX,go=rX  --exclude .git --exclude .hg --exclude .bzr --exclude CVS $WORK_DIR/source/firmware-eswin ${WORK_DIR}/${board_name}/
    #uboot
    cd ${WORK_DIR}/${board_name}/uboot-eswin${FEATURE}/
    make ${uboot_config}
    sed -i "s#\(CONFIG_DEFAULT_FDT_FILE=\)\"[^\"]*\"#\1\"eswin/${board_name}.dtb\"#" .config
    make -j$(nproc)
    mkdir -p ${WORK_DIR}/${board_name}/output/
    cp -av u-boot.bin ${WORK_DIR}/${board_name}/output/
    cp -av u-boot.dtb ${WORK_DIR}/${board_name}/output/
    #opensbi
    cd ${WORK_DIR}/${board_name}/opensbi-eswin${FEATURE}
    chiplet=BR2_CHIPLET_1
    chiplet_die=BR2_CHIPLET_1_DIE0_AVAILABLE
    mem_mode=BR2_MEMMODE_FLAT
    if [[ "$board_name" =~ "7702" ]] || [[ "$board_name" =~ "fml13v03" ]];then
        chiplet=BR2_CHIPLET_2
	chiplet_die=BR2_CHIPLET_1_DIE1_AVAILABLE
    fi
    if [[ "$board_name" =~ "interleave" ]];then
        mem_mode=BR2_MEMMODE_INTERLEAVE
    fi
    make PLATFORM=eswin/eic770x FW_PAYLOAD=y \
     FW_FDT_PATH=${WORK_DIR}/${board_name}/output/u-boot.dtb \
     FW_PAYLOAD_PATH=${WORK_DIR}/${board_name}/output/u-boot.bin \
     CHIPLET="${chiplet}" \
     CHIPLET_DIE_AVAILABLE="${chiplet_die}" \
     MEM_MODE="${mem_mode}" \
     PLATFORM_CLUSTER_X_CORE="BR2_CLUSTER_4_CORE" \
     ENABLE_VPU_SDK=0 \
     ENABLE_ECC=0 \
     -j $(nproc)
    cp -v build/platform/eswin/eic770x/firmware/fw_payload.bin ../output/fw_payload.bin
    if [[ "$board_name" =~ "eic7702-evb" ]];then
        sec_dir=secboot_7702evb
    elif [[ "$board_name" =~ "d560" ]];then
        sec_dir=secboot_s560
    elif [[ "$board_name" =~ "eic7700-ce1" ]];then
        sec_dir=secboot_ce
    elif [[ "$board_name" =~ "eic7700-sbc" ]];then
        sec_dir=secboot_sbc
    elif [[ "$board_name" =~ "fml13v03" ]];then
        sec_dir=secboot_fml13
    elif [[ "$board_name" =~ "eic7700-z530" ]]||[[ "$board_name" =~ "eic7700-vela" ]];then
        sec_dir=secboot_s260
    elif [[ "$board_name" =~ "p550" ]];then
	sec_dir=secboot_p550
    elif [[ "$board_name" =~ "ai-nas" ]];then
        sec_dir=secboot_eic7700_ai_nas
    fi
    if [[ "$board_name" =~ "interleave" ]];then
	rm -rf ${WORK_DIR}/$board_name/inter-eswin
        rsync -au --chmod=u=rwX,go=rX  --exclude .git --exclude .hg --exclude .bzr --exclude CVS $WORK_DIR/source/inter-eswin ${WORK_DIR}/${board_name}/
        sed -i "1s#.*# RISCV_GCC_PREFIX=/opt/riscv-elf/bin/riscv64-unknown-elf-#" ${WORK_DIR}/${board_name}/inter-eswin/Makefile
	sed -i 's/-march=rv64imafd_zifencei//g' ${WORK_DIR}/${board_name}/inter-eswin/Makefile
	sed -i  "s#../build/opensbi#opensbi-eswin${FEATURE}#g" ${WORK_DIR}/${board_name}/inter-eswin/Makefile
        sed -i  "s#../images#output#g" ${WORK_DIR}/${board_name}/inter-eswin/Makefile
	cd ${WORK_DIR}/${board_name}/inter-eswin
	make
	cp -v build/*.bin ${WORK_DIR}/${board_name}/output/
    fi
    #nsign
    cd ${WORK_DIR}/${board_name}/firmware-eswin
    if [[ "$board_name" == "eic7702-evb" ]] || [ "$board_name" == "eic7702-deepcomputing-fml13v03" ] || [ "$board_name" == "eic7702-d560a"  ] || [ "$board_name" == "eic7702-d560" ];then
        sed -i "s|out=.*|out=${WORK_DIR}/${board_name}/output/bootloader_${board_name}_die0.bin|" bootchain_die0.config
        sed -i "s|out=.*|out=${WORK_DIR}/${board_name}/output/bootloader_${board_name}_die1.bin|" bootchain_die1.config
        secboot_line=`cat -n bootchain_die0.config | grep in= | awk -F " " 'NR==1{print$1}'`
        ddr_line=`cat -n bootchain_die0.config | grep in= | awk -F " " 'NR==2{print$1}'`
        d2d_die0_line=`cat -n bootchain_die0.config | grep in= | awk -F " " 'NR==3{print$1}'`
        d2d_die1_line=`cat -n bootchain_die1.config | grep in= | awk -F " " 'NR==3{print$1}'`
        uboot_line=`cat -n bootchain_die0.config | grep in= | awk -F " " 'NR==4{print$1}'`
        #die0
        sed -i "${secboot_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${sec_dir}/die0_sec_fw.bin#" bootchain_die0.config
        sed -i "${ddr_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${die0_ddr_name}#" bootchain_die0.config
        sed -i "${d2d_die0_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/d2d.bin#" bootchain_die0.config
        sed -i "${uboot_line}s#.*# in=${WORK_DIR}/${board_name}/output/fw_payload.bin#" bootchain_die0.config
        #die1
        sed -i "${secboot_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${sec_dir}/die1_sec_fw.bin#" bootchain_die1.config
        sed -i "${ddr_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${die1_ddr_name}#" bootchain_die1.config
        sed -i "${d2d_die1_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/die1_d2d_init.bin#" bootchain_die1.config
        ./nsign bootchain_die0.config
        ./nsign bootchain_die1.config
        
        source source.sh die0_autoboot.bin ${WORK_DIR}/${board_name}/output/bootloader_${board_name}_die0.bin recovery_fw_die0.bin
        source source.sh die1_autoboot.bin ${WORK_DIR}/${board_name}/output/bootloader_${board_name}_die1.bin recovery_fw_die1.bin
        cp bootchain.config bootchain_recovery_die0.config
        cp bootchain.config bootchain_recovery_die1.config
        sed -i "5s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${sec_dir}/die0_sec_fw.bin#" bootchain_recovery_die0.config
        sed -i "5s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${sec_dir}/die1_sec_fw.bin#" bootchain_recovery_die1.config
        sed -i "s/59000000/79000000/g" bootchain_recovery_die1.config
        sed -i "s/80000000/79000000/g" bootchain_recovery_die1.config
        sed -i "32s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${die0_recover_ddr_name}#" bootchain_recovery_die0.config
	sed -i "32s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${die1_recover_ddr_name}#" bootchain_recovery_die1.config
        sed -i "59s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/recovery_fw_die0.bin#" bootchain_recovery_die0.config
        sed -i "59s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/recovery_fw_die1.bin#" bootchain_recovery_die1.config
        sed -i "s|out=.*|out=${WORK_DIR}/${board_name}/output/recovery_bootloader_${board_name}_die0.bin|" bootchain_recovery_die0.config
        sed -i "s|out=.*|out=${WORK_DIR}/${board_name}/output/recovery_bootloader_${board_name}_die1.bin|" bootchain_recovery_die1.config
        ./nsign bootchain_recovery_die0.config
        ./nsign bootchain_recovery_die1.config
    elif [[ "$board_name" =~ "interleave" ]];then
        #interleave
        sed -i "s|out=.*|out=${WORK_DIR}/${board_name}/output/bootloader_${board_name}_inter.bin|" bootchain_interleave.config
        ddr_line=`cat -n bootchain_interleave.config | grep in= | awk -F " " 'NR==1{print$1}'`
        d2d_die0_line=`cat -n bootchain_interleave.config | grep in= | awk -F " " 'NR==2{print$1}'`
        uboot_line=`cat -n bootchain_interleave.config | grep in= | awk -F " " 'NR==3{print$1}'`
        sed -i "${ddr_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${die0_ddr_name}#" bootchain_interleave.config
        sed -i "${d2d_die0_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/d2d.bin#" bootchain_interleave.config
        sed -i "${uboot_line}s#.*# in=${WORK_DIR}/${board_name}/output/load_interleave.bin#" bootchain_interleave.config
        
	    #die1
        sed -i "s|out=.*|out=${WORK_DIR}/${board_name}/output/bootloader_${board_name}_die1.bin|" bootchain_die1.config
        ddr_line=`cat -n bootchain_die1.config | grep in= | awk -F " " 'NR==2{print$1}'`
        d2d_die1_line=`cat -n bootchain_die1.config | grep in= | awk -F " " 'NR==3{print$1}'`
        secboot_line=`cat -n bootchain_die1.config | grep in= | awk -F " " 'NR==1{print$1}'`

        sed -i "${secboot_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${sec_dir}/die1_sec_fw.bin#" bootchain_die1.config
        sed -i "${ddr_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${die1_ddr_name}#" bootchain_die1.config
        sed -i "${d2d_die1_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/die1_d2d_init.bin#" bootchain_die1.config
        ./nsign bootchain_interleave.config
        ./nsign bootchain_die1.config

        source source.sh die0_autoboot.bin ${WORK_DIR}/${board_name}/output/bootloader_${board_name}_inter.bin recovery_fw_inter.bin
        source source.sh die1_autoboot.bin ${WORK_DIR}/${board_name}/output/bootloader_${board_name}_die1.bin recovery_fw_die1.bin
        cp bootchain_interleave_recovery.config bootchain_recovery_inter.config
        cp bootchain.config bootchain_recovery_die1.config
        # sed -i "5s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/die0_sec_fw.bin#" bootchain_recovery_inter.config
        sed -i "5s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${sec_dir}/die1_sec_fw.bin#" bootchain_recovery_die1.config
        sed -i "s/59000000/79000000/g" bootchain_recovery_die1.config
        sed -i "s/80000000/79000000/g" bootchain_recovery_die1.config
        # sed -i "32s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${ddr_name}#" bootchain_recovery_inter.config
        sed -i "5s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${die0_recover_ddr_name}#" bootchain_recovery_inter.config
        sed -i "32s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${die1_recover_ddr_name}#" bootchain_recovery_die1.config
        # sed -i "59s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/recovery_fw_inter.bin#" bootchain_recovery_inter.config
        sed -i "32s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/recovery_fw_inter.bin#" bootchain_recovery_inter.config
        sed -i "59s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/recovery_fw_die1.bin#" bootchain_recovery_die1.config
        sed -i "s|out=.*|out=${WORK_DIR}/${board_name}/output/recovery_bootloader_${board_name}_inter.bin|" bootchain_recovery_inter.config
        sed -i "s|out=.*|out=${WORK_DIR}/${board_name}/output/recovery_bootloader_${board_name}_die1.bin|" bootchain_recovery_die1.config
        ./nsign bootchain_recovery_inter.config
        ./nsign bootchain_recovery_die1.config
    else
        sed -i "s|out=.*|out=${WORK_DIR}/${board_name}/output/bootloader_${board_name}.bin|" bootchain_lpcpu.config
        secboot_line=`cat -n bootchain_lpcpu.config | grep in= | awk -F " " 'NR==1{print$1}'`
        ddr_line=`cat -n bootchain_lpcpu.config | grep in= | awk -F " " 'NR==2{print$1}'`
        lpcpu_line=`cat -n bootchain_lpcpu.config | grep in= | awk -F " " 'NR==3{print$1}'`
	uboot_line=`cat -n bootchain_lpcpu.config | grep in= | awk -F " " 'NR==4{print$1}'`
        sed -i "${secboot_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${sec_dir}/die0_sec_fw.bin#" bootchain_lpcpu.config
        sed -i "${ddr_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${die0_ddr_name}#"  bootchain_lpcpu.config
        sed -i "${lpcpu_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/die0_lpcpu_load_fw.bin#"  bootchain_lpcpu.config
	sed -i "${uboot_line}s#.*# in=${WORK_DIR}/${board_name}/output/fw_payload.bin#"  bootchain_lpcpu.config
        ./nsign bootchain_lpcpu.config
	source source.sh die0_autoboot.bin ${WORK_DIR}/${board_name}/output/bootloader_${board_name}.bin recovery_fw_die0.bin
        cp -vf bootchain.config bootchain_recover.config
        line_in=`cat -n bootchain_recover.config  | grep in=|awk '{print$1}' |tail -n 1`
        sed -i "${line_in}s|in=.*|in=${WORK_DIR}/${board_name}/firmware-eswin/recovery_fw_die0.bin|" bootchain_recover.config
	secboot_line=`cat -n bootchain_recover.config | grep in= | awk -F " " 'NR==1{print$1}'`
        ddr_line=`cat -n bootchain_recover.config | grep in= | awk -F " " 'NR==2{print$1}'`
	sed -i "${secboot_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${sec_dir}/die0_sec_fw.bin#" bootchain_recover.config
        sed -i "${ddr_line}s#.*# in=${WORK_DIR}/${board_name}/firmware-eswin/${die0_recover_ddr_name}#"  bootchain_recover.config
	sed -i "2s|out=.*|out=${WORK_DIR}/${board_name}/output/recovery_bootloader_${board_name}.bin|" bootchain_recover.config
	./nsign bootchain_recover.config
    fi
    cd ${WORK_DIR}/${board_name}/output
    ls -l
}

function make_images()
{
    if [ ! -f ${WORK_DIR}/${board_name}/output/linux-image-*.deb ];then
        make_kernel
    fi
    echo "start compile debian_mkimg"
    local desktop_image=$1
    local kdump=$2
    mkdir -p ${WORK_DIR}/$board_name;rm -rf ${WORK_DIR}/$board_name/mkimg-eswin
    if [ -d $WORK_DIR/source/mkimg-eswin ];then
        rsync -au --chmod=u=rwX,go=rX  --exclude .git --exclude .hg --exclude .bzr --exclude CVS $WORK_DIR/source/mkimg-eswin ${WORK_DIR}/${board_name}/
    else
        tar -xf $WORK_DIR/source/mkimg-eswin.tar.gz -C ${WORK_DIR}/${board_name}
    fi
    cd ${WORK_DIR}/$board_name/mkimg-eswin
    chmod +x *.sh

    echo "start compile debian_mkimg ${desktop_image} ${kdump}"
    if [[ -n "${desktop_image}" && "${desktop_image}" == "desktop" ]];then
        if [[ -n "${kdump}" && "${kdump}" == "kdump" ]]; then
            sudo ./mkrootfs.sh ${board_name} ${RELEASE_TAG} "kdump"
        else
            sudo ./mkrootfs.sh ${board_name} ${RELEASE_TAG}
        fi
    else
        if [[ -n "${kdump}" && "${kdump}" == "kdump" ]]; then
            sudo ./mkrootfs_minimal.sh ${board_name} ${RELEASE_TAG} "kdump"
        else
            sudo ./mkrootfs_minimal.sh ${board_name} ${RELEASE_TAG}
        fi
    fi
    mkdir -p ${WORK_DIR}/${board_name}/output/
    mv *.ext4 ${WORK_DIR}/${board_name}/output/
    #if [[ "$board_name" =~ "FML13V03" ]];then
    #    rsync -au --chmod=u=rwX,go=rX  --exclude .git --exclude .hg --exclude .bzr --exclude CVS $WORK_DIR/source/deepcomputing ${WORK_DIR}/${board_name}/
    #    cd ${WORK_DIR}/${board_name}/deepcomputing
    #    source ./make_os_image.sh
    #    mv *.img ${WORK_DIR}/${board_name}/output/
    #fi
    cd ${WORK_DIR}/${board_name}/output
    ls -l
}

function make_desktop_images()
{
    local kdump=$1
    if [[ -n "${kdump}" && "${kdump}" == "kdump" ]]; then
        make_images "desktop" "kdump"
    else
        make_images "desktop"
    fi
}

function make_kernel()
{
    echo "start compile kernel"
    mkdir -p ${WORK_DIR}/$board_name
    rm -rf ${WORK_DIR}/${board_name}/linux-eswin${FEATURE}
    if [ ! -d $WORK_DIR/source/linux-eswin${FEATURE} ];then
	git clone --depth=1 -b ${RELEASE_TAG}    ${GIT_SERVER_BASE}/linux-6.6   $WORK_DIR/source/linux-eswin${FEATURE}
    fi
    rsync -au --chmod=u=rwX,go=rX  --exclude .git --exclude .hg --exclude .bzr --exclude CVS $WORK_DIR/source/linux-eswin${FEATURE} ${WORK_DIR}/${board_name}/
    cd ${WORK_DIR}/${board_name}/linux-eswin${FEATURE}
    export KDEB_PKGVERSION="$(make kernelversion)-$(date "+%Y.%m.%d.%H.%M")+"
    if [[ "$board_name" =~ "7702" ]];then
        if [ ! -z $1 ];then
            linux_defconfig=eic7702_dbg_defconfig
        else
	    if [ -f ${WORK_DIR}/${board_name}/linux-eswin${FEATURE}/arch/riscv/configs/eic7702_pm_defconfig ];then
		linux_defconfig=eic7702_pm_defconfig
	    else
                linux_defconfig=eic7702_defconfig
            fi
        fi
    elif [[ "$board_name" =~ "fml13v03" ]]; then
        if [ ! -z $1 ];then
            linux_defconfig=fml13v03_dbg_defconfig
            echo "FML13V03 does not support compiling debug kernel at this time!"
            exit 0
        else
            linux_defconfig=fml13v03_defconfig
        fi
    elif [[ "$board_name" =~ "ai-nas" ]]; then
            linux_defconfig=eic7700_ai_nas_defconfig
    else
        if [ ! -z $1 ];then
            linux_defconfig=eic7700_dbg_defconfig
        else
	    if [ -f ${WORK_DIR}/${board_name}/linux-eswin${FEATURE}/arch/riscv/configs/eic7700_pm_defconfig ];then
	        linux_defconfig=eic7700_pm_defconfig
            else
                linux_defconfig=eic7700_defconfig
	    fi
        fi
    fi
    blk_dev_initrd=`cat ${WORK_DIR}/${board_name}/linux-eswin${FEATURE}/arch/riscv/configs/$linux_defconfig | grep 'CONFIG_BLK_DEV_INITRD=y'`
    if [ "$blk_dev_initrd" == "" ];then
        echo CONFIG_BLK_DEV_INITRD=y >>${WORK_DIR}/${board_name}/linux-eswin${FEATURE}/arch/riscv/configs/$linux_defconfig
    fi
    kernel_ver1=`cat ${WORK_DIR}/${board_name}/linux-eswin${FEATURE}/arch/riscv/configs/$linux_defconfig | grep CONFIG_LOCALVERSION= |cut -d "=" -f 2|xargs`
    if [ -z $kernel_ver1 ];then
        kernel_ver1="-eic7x"
    fi
    kernel_ver2=`echo $RELEASE_TAG | cut -d "-" -f 2| tr "A-Z" "a-z"`
    kernel_ver=${kernel_ver1}-${kernel_ver2}
    sed -i "/CONFIG_LOCALVERSION/d" ${WORK_DIR}/${board_name}/linux-eswin${FEATURE}/arch/riscv/configs/$linux_defconfig
    rm -rf /opt/debian_gcc14.flag
    if [ -f /opt/debian_gcc14.flag ];then
	cd /opt/
	if [ -d /opt/rootfs ];then
            umount -l /opt/rootfs ||true
            rm -rf rootfs/
	fi
	mkdir -p rootfs
        mount minimal_rootfs.ext4 rootfs/
	mkdir /opt/rootfs/home/eswin/linux-eswin${FEATURE}
	rm -rf /opt/rootfs/home/eswin/*.deb
        mount --bind ${WORK_DIR}/${board_name}/linux-eswin${FEATURE}  /opt/rootfs/home/eswin/linux-eswin${FEATURE}
	chroot rootfs/ sh -c "cd /home/eswin/linux-eswin${FEATURE};export CROSS_COMPILE=;make $linux_defconfig;make -j$(nproc) bindeb-pkg"
	cp /opt/rootfs/home/eswin/*.deb ${WORK_DIR}/${board_name}/
        cd ${WORK_DIR}/${board_name}/linux-eswin${FEATURE}	
    else
        make $linux_defconfig
        make -j$(nproc) bindeb-pkg LOCALVERSION="$kernel_ver"
        make ARCH=riscv CROSS_COMPILE=${CROSS_COMPILE} scripts
    fi
    mkdir -p ${WORK_DIR}/${board_name}/output/
    rm -rf ${WORK_DIR}/${board_name}/output/linux*.deb
    mv -v ../*.deb ${WORK_DIR}/${board_name}/output/
    cd ${WORK_DIR}/${board_name}/output
    ls -l
}

function make_debug_kernel()
{
    make_kernel "debug"
}

function make_all()
{
    local kdump=$1
    echo "start make all"
    make_bootchain
    if [[ -n "${kdump}" && "${kdump}" == "kdump" ]]; then
        make_debug_kernel
        make_desktop_images "nodesk" "kdump"
    else
        make_kernel
        make_desktop_images
    fi
}

print_comple_method()
{
    echo "you chose $board_name"
    echo "Use the following method to start compiling:"
    echo "    make_bootchain"
    echo "    make_kernel"
    echo "    make_debug_kernel"
    echo "    make_desktop_images"
    echo "    make_images:build minimal image"
    echo "    make_all:bootchain kernel desktop_images"
    echo "    make_desktop_images \"kdump\""
    echo "    make_all \"kdump\":bootchain kernel kdump desktop_images"
}



#menu
echo "board list:"
echo [1] eic7700-ai-nas
echo [0] Exit
while true; do
    read -p "please select[0-1]:" -n 1 CHOICE
    echo 
    if [[ "$CHOICE" =~ ^[0-9]+$ ]] && (( CHOICE >= 0 && CHOICE <= 1 )); then
        break
    else
        echo "Invalid selection. Please enter a number between 0 and 1!"
    fi
done
echo 
export die0_ddr_name=ddr_fw_die0.bin
export die1_ddr_name=ddr_fw_die1.bin
export die0_recover_ddr_name=ddr_fw_die0_nospi.bin
export die1_recover_ddr_name=ddr_fw_die1_nospi.bin
export FEATURE=
while [ 0 -eq 0 ];
do
    if [ "$CHOICE" == "12" ];then
        export board_name=eic7700-evb
        export uboot_config=eic7700_evb_defconfig
        break
    elif [ "$CHOICE" == "2" ];then
        export board_name=eic7700-hifive-premier-p550
        export uboot_config=hifive_premier_p550_defconfig
        break
    elif [ "$CHOICE" == "4" ];then
        export board_name=eic7702-evb-a1-interleave
        export uboot_config=eic7702_evb_a1_interleave_defconfig
        #export FEATURE=-inter
        break
    elif [ "$CHOICE" == "6" ];then
        export board_name=eic7702-d560-interleave
        export uboot_config=eic7702_d560_interleave_defconfig
        #export FEATURE=-inter
        break
    elif [ "$CHOICE" == "3" ];then
        export board_name=eic7702-d560
        export uboot_config=eic7702_d560_defconfig
        break
    elif [ "$CHOICE" == "7" ];then
        export board_name=eic7702-deepcomputing-fml13v03
        export uboot_config=deepcomputing-fml13v03_defconfig
        break
    elif [ "$CHOICE" == "5" ];then
        export board_name=eic7700-sbc
        export uboot_config=eic7700_sbc_defconfig
	export die0_ddr_name=ddr_low_freq/ddr_fw_die0.bin
        export die0_recover_ddr_name=ddr_low_freq/ddr_fw_die0_nospi.bin
        break
    elif [ "$CHOICE" == "8" ];then
        export board_name=eic7700-z530
        export uboot_config=eic7700_z530_defconfig
        break
    elif [ "$CHOICE" == "9" ];then
        export board_name=eic7700-ce1
        export uboot_config=eic7700_ce1_defconfig
        break
    elif [ "$CHOICE" == "10" ];then
        export board_name=eic7702-d560a
        export uboot_config=eic7702_d560a_defconfig
        break
    elif [ "$CHOICE" == "11" ];then
        export board_name=eic7700-vela
        export uboot_config=eic7700_vela_defconfig
        break
    elif [ "$CHOICE" == "1" ];then
        export board_name=eic7700-ai-nas
        export uboot_config=eic7700_ai_nas_defconfig
        break
    elif [ "$CHOICE" == "0" ];then
        echo "Exiting..."
        break
    else
        echo "Invalid option"
        read -p "please select[0-1]:" -n 1 CHOICE
        echo
    fi
done
print_comple_method
