#!/usr/bin/env bash

# ==== 可配置项（原脚本硬编码了乙方内部地址与默认口令，已改为变量）====
# Debian 软件源根地址：原为乙方私有源，该地址不随本项目公开发布，
#   请替换为贵司镜像源地址，例如 https://mirror.example.com/debian
export DEBIAN_REPO_BASE="${DEBIAN_REPO_BASE:-<YOUR_DEBIAN_REPO_BASE>}"
# rootfs 默认用户 eswin 的密码：默认为 eswin，属弱口令，
#   建议在构建前通过环境变量指定强密码，构建完成后立即修改。
export USER_PASSWORD="${USER_PASSWORD:-eswin}"
# ===================================================================


BOOT_SIZE=500M
BOOT_IMG=""
ROOT_SIZE=7G
ROOT_IMG=""
CHROOT_TARGET=rootfs
#BOOT_UUID="44b7cb94-f58c-4ba6-bfa4-7d2dce09a3a5"
#ROOT_UUID="80a5a8e9-c744-491a-93c1-4f4194fd690a"
BOARD=$1
RELEASE_TAG=$2
KDUMP=$3
ker_ver=`echo $RELEASE_TAG | tr "A-Z" "a-z"`

if [ -f ../output/linux-image-*-dbg*.deb ];then
    echo debug kernel
    #KER=$(ls ../output/ | grep "linux-image" |cut -d "-" -f 3)
    #DEBUG_KERNEL_DEB="linux-image-${KER}-${ker_ver}-dbg"
    ROOT_SIZE=9G
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
echo $TIMESTAMP  >../TIMESTAMP

make_imagefile()
{
    if [[ -n "${KDUMP}" && "${KDUMP}" == "kdump" ]]; then
        BOOT_IMG="boot-$BOARD-$TIMESTAMP-kdump.ext4"
        ROOT_IMG="root-$BOARD-$TIMESTAMP-kdump.ext4"
    else
        BOOT_IMG="boot-$BOARD-$TIMESTAMP.ext4"
        ROOT_IMG="root-$BOARD-$TIMESTAMP.ext4"
    fi
    truncate -s "$BOOT_SIZE" "$BOOT_IMG"
    truncate -s "$ROOT_SIZE" "$ROOT_IMG"

    # Format partitions
    mkfs.ext4 -F -O ^metadata_csum "$BOOT_IMG"
    mkfs.ext4 -F -O ^metadata_csum "$ROOT_IMG"

    export BOOT_UUID=$(blkid $BOOT_IMG| awk -F'UUID="|"' '{print $2}')
    export ROOT_UUID=$(blkid $ROOT_IMG| awk -F'UUID="|"' '{print $2}')
    # UUID
    #tune2fs -U $BOOT_UUID $BOOT_IMG
    #tune2fs -U $ROOT_UUID $ROOT_IMG
}

pre_mkrootfs()
{
    # Mount loop device
    mkdir "$CHROOT_TARGET"
    mount "$ROOT_IMG" "$CHROOT_TARGET"
}

unmount_image()
{
	echo "Finished and cleaning..."
	if mount | grep "$CHROOT_TARGET" > /dev/null; then
		umount -l "$CHROOT_TARGET"
	fi
	if [ "$(ls -A $CHROOT_TARGET)" ]; then
		echo "folder not empty! umount may fail!"
		exit 2
	else
		echo "Deleting chroot temp folder..."
		if [ -d "$CHROOT_TARGET" ]; then
			rmdir -v "$CHROOT_TARGET"
		fi
		echo "Done."
	fi
}

make_rootfs_tarball()
{
    # use $1
#    PACKAGE_LIST="$KEYRINGS $GPU_DRIVER $BASE_TOOLS $GRAPHIC_TOOLS $XFCE_DESKTOP $BENCHMARK_TOOLS $FONTS $INCLUDE_APPS $EXTRA_TOOLS $LIBREOFFICE"
    PACKAGE_LIST="ca-certificates cloud-guest-utils neofetch network-manager rockos-keyring debian-archive-keyring esos-archive-keyring u-boot-menu sudo initramfs-tools locales bluez blueman mpv chromium systemd-timesyncd"
    mmdebstrap --architectures=riscv64 \
        --include="$PACKAGE_LIST" \
        esos-base $1 \
        "deb [trusted=yes] ${DEBIAN_REPO_BASE}/esos-gles/ esos-gles main" \
        "deb [trusted=yes] ${DEBIAN_REPO_BASE}/esos-kernels/ esos-kernels main" \
        "deb [trusted=yes] ${DEBIAN_REPO_BASE}/esos-addons/ esos-addons main" \
        "deb [trusted=yes] ${DEBIAN_REPO_BASE}/esos-base/ esos-base main contrib non-free non-free-firmware" \
        "deb [trusted=yes] ${DEBIAN_REPO_BASE}/esos-core/ esos-core main"
}

make_rootfs()
{
    make_rootfs_tarball $CHROOT_TARGET
    if [ ! -z "$(ls -A "$CHROOT_TARGET"/boot/)" ]; then
        mkdir "$CHROOT_TARGET"/mnt/boot
        mv -v "$CHROOT_TARGET"/boot/* "$CHROOT_TARGET"/mnt/boot/
    fi

    # Mount chroot path
    mflag=1
    while [ $mflag != 0 ];
    do
        mount "$BOOT_IMG" "$CHROOT_TARGET"/boot
        mountpoint -q "$CHROOT_TARGET"/boot
        mflag=$?
        if [ $mflag != 0 ];then
            echo "Mount failure"
            echo "The system has reached the upper limit of available loop devices."
            echo "You can run the 'losetup -a' command to view the current loop devices on the host."
            echo "You can do this by 'sudo losetup -d /dev/loopX' (replacing X with the actual loop device number)Try to uninstall a device that is no longer in use."
            echo "Automatically remount after 60 seconds."
            sleep 60
        fi
    done

    mount -t proc /proc "$CHROOT_TARGET"/proc
    mount -B /sys "$CHROOT_TARGET"/sys
    mount -B /run "$CHROOT_TARGET"/run
    mount -B /dev "$CHROOT_TARGET"/dev
    mount -B /dev/pts "$CHROOT_TARGET"/dev/pts
    mount -t tmpfs tmpfs "$CHROOT_TARGET"/tmp
    mount -t tmpfs tmpfs "$CHROOT_TARGET"/var/tmp
    mount -t tmpfs tmpfs "$CHROOT_TARGET"/var/cache/apt/archives/

    # move boot contents back to /boot
    if [ ! -z "$(ls -A "$CHROOT_TARGET"/mnt/boot/)" ]; then
        mv -v "$CHROOT_TARGET"/mnt/boot/* "$CHROOT_TARGET"/boot/
        rmdir "$CHROOT_TARGET"/mnt/boot
    fi

    # apt update
    chroot "$CHROOT_TARGET" sh -c "apt update"
}

make_bootable()
{
    # Install kernel
    deb_package=$(ls -l ../output/ | grep "riscv64.deb")
    if [ "$deb_package" != "" ];then
	#KER=$(ls ../output/ | grep "linux-image" |cut -d "-" -f 3)
        cp -v ../output/*.deb $CHROOT_TARGET/root/
        chroot "$CHROOT_TARGET" sh -c 'dpkg -i /root/*.deb'
        chroot "$CHROOT_TARGET" sh -c 'apt install -f'
	#chroot "$CHROOT_TARGET" sh -c "apt update && apt install -y linux-image-${KER}-${ker_ver} ${DEBUG_KERNEL_DEB} linux-headers-${KER}-${ker_ver}"
    fi

    # Add update-u-boot config
    if [[ -n "${KDUMP}" && "${KDUMP}" == "kdump" ]]; then
    cat > $CHROOT_TARGET/etc/default/u-boot << EOF
U_BOOT_PROMPT="2"
U_BOOT_MENU_LABEL="RockOS GNU/Linux"
U_BOOT_PARAMETERS="console=tty0 console=ttyS0,115200 rootwait rw earlycon selinux=0 panic=5 reboot=warm crashkernel=512M crash_kexec_post_notifiers=1 LANG=en_US.UTF-8 audit=0"
U_BOOT_ROOT="root=UUID=${ROOT_UUID}"
U_BOOT_FDT_DIR="/dtbs/linux-image-"
EOF
    else
    cat > $CHROOT_TARGET/etc/default/u-boot << EOF
U_BOOT_PROMPT="2"
U_BOOT_MENU_LABEL="RockOS GNU/Linux"
U_BOOT_PARAMETERS="console=ttyS0,115200 rootwait rw earlycon selinux=0 panic=5 reboot=warm LANG=en_US.UTF-8 audit=0"
U_BOOT_ROOT="root=UUID=${ROOT_UUID}"
U_BOOT_FDT_DIR="/dtbs/linux-image-"
EOF
    fi

    # Update extlinux config
    sed -i "s/single/bootmode=recovery single/g" "$CHROOT_TARGET"/usr/sbin/u-boot-update
    chroot "$CHROOT_TARGET" sh -c "u-boot-update"
}

after_mkrootfs()
{

    # Set locale to en_US.UTF-8 UTF-8
    chroot "$CHROOT_TARGET" sh -c "echo 'locales locales/default_environment_locale select en_US.UTF-8' | debconf-set-selections"
    chroot "$CHROOT_TARGET" sh -c "echo 'locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8' | debconf-set-selections"
    chroot "$CHROOT_TARGET" sh -c "rm /etc/locale.gen"
    chroot "$CHROOT_TARGET" sh -c "dpkg-reconfigure --frontend noninteractive locales"

    # Set default timezone to Asia/Shanghai
    chroot "$CHROOT_TARGET" sh -c "ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime"
    echo "Asia/Shanghai" > $CHROOT_TARGET/etc/timezone

    # Set up fstab
    chroot $CHROOT_TARGET /bin/bash << EOF
echo 'UUID=${ROOT_UUID} /   auto    defaults,x-systemd.growfs    1 1' >> /etc/fstab
echo 'UUID=${BOOT_UUID} /boot   auto    defaults,x-systemd.growfs    0 0' >> /etc/fstab

exit
EOF

    # Add user
    chroot "$CHROOT_TARGET" sh -c "useradd -m -s /bin/bash -G adm,cdrom,floppy,sudo,input,audio,dip,video,plugdev,netdev,bluetooth,lp eswin"
    chroot "$CHROOT_TARGET" sh -c "echo "eswin:${USER_PASSWORD}" | chpasswd"

    # Copy kvm
    #cp -v kvm/* $CHROOT_TARGET/home/debian/
    chroot "$CHROOT_TARGET" sh -c 'chown eswin:eswin /home/eswin/*'

    # Change hostname
    chroot $CHROOT_TARGET /bin/bash << EOF
echo eswin > /etc/hostname
echo "127.0.1.1 eswin" >> /etc/hosts
exit
EOF

    # xfce desktop
    chroot $CHROOT_TARGET /bin/bash << EOF
export DEBIAN_FRONTEND=noninteractive
apt install -y task-xfce-desktop
apt install -y qemu-system
apt install -y bash-completion
apt install -y firmware-amd-graphics
apt install -y mesa-vulkan-drivers mesa-va-drivers mesa-vdpau-drivers
apt install -y ssh
apt install -y glmark2-es2 mesa-utils vulkan-tools
apt install -y supertuxkart
exit
EOF

    # fix pulseaudio
    chroot $CHROOT_TARGET /bin/bash << EOF
echo "default-sample-format = s32le" >> /etc/pulse/daemon.conf
echo "default-sample-rate = 48000" >> /etc/pulse/daemon.conf
echo "alternate-sample-rate = 96000" >> /etc/pulse/daemon.conf
echo "default-fragments = 4" >> /etc/pulse/daemon.conf
echo "default-fragment-size-msec = 10" >> /etc/pulse/daemon.conf

sed -i 's/load-module module-udev-detect/load-module module-udev-detect tsched=1 tsched_buffer_size=8192/' /etc/pulse/system.pa
sed -i 's/load-module module-udev-detect/load-module module-udev-detect tsched=1 tsched_buffer_size=8192/' /etc/pulse/default.pa
exit
EOF

    # copy kernel module
#    mkdir -p $CHROOT_TARGET/lib/modules/5.17.0-rc7-win2030/extra/
#    cp -vf ko/*.ko $CHROOT_TARGET/lib/modules/5.17.0-rc7-win2030/extra/
#    cp -vf ko/vdec_driver_load.sh $CHROOT_TARGET/sbin/
#    chroot $CHROOT_TARGET /bin/bash -c 'depmod 5.17.0-rc7-win2030 -a'

    # media desktop
    chroot $CHROOT_TARGET /bin/bash << EOF
export DEBIAN_FRONTEND=noninteractive
apt install -y mpv ffmpeg
exit
EOF

    # gles/media desktop
    chroot $CHROOT_TARGET /bin/bash << EOF
export DEBIAN_FRONTEND=noninteractive
apt install -y eswin-eic7x-gpu gstreamer1.0-plugins-es
apt install -y libqt5gui5-gles python3-opencv
exit
EOF

     cat << EOF > "$CHROOT_TARGET"/usr/share/X11/xorg.conf.d/10-pvr.conf
Section "Device"
	Identifier "Card1"
	Driver "modesetting"
	Option "kmsdev" "/dev/dri/card0"
	Option "UseGammaLUT" "false"
#	Option "SWcursor" "true"
EndSection

Section "OutputClass"
	Identifier "es_drm_display"
	MatchDriver "es_drm"
#	Option	"PrimaryGPU"	"true"
EndSection
EOF

    cat << EOF > "$CHROOT_TARGET"/etc/powervr.ini
[supertuxkart]
DisableFBCDC=1
EOF

# for lightdm
    cp -vf addons/80-workaround-lightdm-X-on-drm-hotplug.rules "$CHROOT_TARGET"/etc/udev/rules.d/
    cp -vf addons/kill-lightdm-X "$CHROOT_TARGET"/usr/libexec/
    chroot $CHROOT_TARGET /bin/bash -c 'chmod a+x /usr/libexec/kill-lightdm-X'
    #mkdir -p "$CHROOT_TARGET"/etc/systemd/system/lightdm.service.d/
    #cp -vf addons/override.conf "$CHROOT_TARGET"/etc/systemd/system/lightdm.service.d/

    # for wifi
    chroot $CHROOT_TARGET /bin/bash << EOF
export DEBIAN_FRONTEND=noninteractive
apt install -y wpasupplicant
EOF
    cp -vf addons/10-wifi.conf "$CHROOT_TARGET"/etc/NetworkManager/conf.d/
    mkdir -p "$CHROOT_TARGET"/lib/firmware/
    cp -rf firmware/* "$CHROOT_TARGET"/lib/firmware/

    # for auto load module
    cat addons/modules.conf >> "$CHROOT_TARGET"/etc/modules-load.d/modules.conf
    cat "$CHROOT_TARGET"/etc/modules-load.d/modules.conf

    # add udevs rules
    cp -vf rules/* "$CHROOT_TARGET"/etc/udev/rules.d/
    sed -i '/SUBSYSTEMS=="platform", ENV{SOUND_FORM_FACTOR}="internal".*/d' "$CHROOT_TARGET"/usr/lib/udev/rules.d/78-sound-card.rules

    #bin
    if [ -d bin ];then
        cp -vf bin/* "$CHROOT_TARGET"/usr/bin/
    fi

    #lib
    if [ -d lib ];then
        cp -vf lib/* "$CHROOT_TARGET"/usr/lib/
    fi


    #P550 
    if [ "$BOARD" == "eic7700-hifive-premier-p550" ];then
        cp -vf bmc/es-bmcd "$CHROOT_TARGET"/usr/bin/
        cp -vf bmc/98-es-bmcd.preset "$CHROOT_TARGET"/usr/lib/systemd/system-preset/
        cp -vf bmc/es-bmcd.sh "$CHROOT_TARGET"/usr/bin/es-bmcd.sh
        cp -vf bmc/es-bmcd.service "$CHROOT_TARGET"/usr/lib/systemd/system
        chroot "$CHROOT_TARGET" sh -c "systemctl enable es-bmcd.service" 
    fi

    if [ "$BOARD" == "eic7700-ai-nas" ];then
        cp -vf addons/etc/systemd/logind.conf "$CHROOT_TARGET"/etc/systemd/
        chmod 0644 "$CHROOT_TARGET"/etc/systemd/logind.conf
    fi

    if [[ "$BOARD" =~ "eic7702" ]];then
        if [ -f "$CHROOT_TARGET"/usr/share/X11/xorg.conf.d/10-pvr.conf ];then
	sed -i '8i\EndSection' "$CHROOT_TARGET"/usr/share/X11/xorg.conf.d/10-pvr.conf
	#sed -i '8i\#	Option "SWcursor" "true"' "$CHROOT_TARGET"/usr/share/X11/xorg.conf.d/10-pvr.conf
	sed -i '8i\     Option "UseGammaLUT" "false"' "$CHROOT_TARGET"/usr/share/X11/xorg.conf.d/10-pvr.conf
	sed -i '8i\     Option "kmsdev" "/dev/dri/card1"' "$CHROOT_TARGET"/usr/share/X11/xorg.conf.d/10-pvr.conf
	sed -i '8i\	Driver "modesetting"' "$CHROOT_TARGET"/usr/share/X11/xorg.conf.d/10-pvr.conf
	sed -i '8i\	Identifier "Card2"' "$CHROOT_TARGET"/usr/share/X11/xorg.conf.d/10-pvr.conf
	sed -i '8i\Section "Device"' "$CHROOT_TARGET"/usr/share/X11/xorg.conf.d/10-pvr.conf
	fi
    fi

    #es thermal
    cp -vf es-thermald/es-thermald "$CHROOT_TARGET"/usr/bin/
    cp -vf es-thermald/es-thermald.sh "$CHROOT_TARGET"/usr/bin/
    cp -vf es-thermald/es-thermald.service "$CHROOT_TARGET"/usr/lib/systemd/system/
    cp -vf es-thermald/98-es-thermald.preset "$CHROOT_TARGET"/usr/lib/systemd/system-preset/
    for config_file in es-thermald/config/es-thermald*.conf; do
        if [ -f "${config_file}" ]; then
            cp -vf "${config_file}" "$CHROOT_TARGET"/etc/
        fi
    done
    chroot "$CHROOT_TARGET" sh -c "systemctl enable es-thermald.service"

    #es watchdogd
    cp -vf es-watchdogd/es-watchdogd "$CHROOT_TARGET"/usr/bin/
    cp -vf es-watchdogd/es-watchdogd.sh "$CHROOT_TARGET"/usr/bin/
    cp -vf es-watchdogd/es-watchdogd.service "$CHROOT_TARGET"/usr/lib/systemd/system/
    chroot "$CHROOT_TARGET" sh -c "systemctl enable es-watchdogd.service"

    #es vmcore uploader
    cp -vf es-vmcore-uploader/es-vmcore-uploader "$CHROOT_TARGET"/usr/bin/
    cp -vf es-vmcore-uploader/es-vmcore-uploader.sh "$CHROOT_TARGET"/usr/bin/
    cp -vf es-vmcore-uploader/es-vmcore-uploader.service "$CHROOT_TARGET"/usr/lib/systemd/system/
    cp -vf es-vmcore-uploader/vmcore_uploader.conf "$CHROOT_TARGET"/etc/
    chroot "$CHROOT_TARGET" sh -c "systemctl enable es-vmcore-uploader.service"

    #es kdump
    if [[ -n "${KDUMP}" && "${KDUMP}" == "kdump" ]]; then
        mkdir "$CHROOT_TARGET"/usr/bin/kdump
        cp -vf capture_kernel/kexec "$CHROOT_TARGET"/usr/bin/kdump

        case "$BOARD" in
            eic7700*)
                cp -vrf capture_kernel/eic7700/* "$CHROOT_TARGET"/usr/bin/kdump
                ;;
            eic7702*)
                cp -vrf capture_kernel/eic7702/* "$CHROOT_TARGET"/usr/bin/kdump
                ;;
            *)
                echo "error: Unsupported board types: $BOARD"
                exit 2
                ;;
        esac
    fi

    #es release
    chroot $CHROOT_TARGET /bin/bash << EOF
echo $BOARD:$RELEASE_TAG> /etc/es_release
apt install -y pulseaudio pulseaudio-module-bluetooth
apt purge -y libplymouth*
exit
EOF

    echo load-module module-bluetooth-policy       >>"$CHROOT_TARGET"/etc/pulse/default.pa
    echo load-module module-bluez5-device          >>"$CHROOT_TARGET"/etc/pulse/default.pa
    echo load-module module-bluez5-discover        >>"$CHROOT_TARGET"/etc/pulse/default.pa
}

make_imagefile
pre_mkrootfs
make_rootfs
make_bootable
after_mkrootfs
unmount_image
