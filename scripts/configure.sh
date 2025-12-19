#!/bin/bash

set -e

echo "开始配置AR9331编译..."

# 检查当前目录
if [ -f "feeds.conf.default" ]; then
    echo "当前在openwrt目录中"
    OPENWRT_DIR="."
elif [ -f "openwrt/feeds.conf.default" ]; then
    echo "当前在仓库根目录中，切换到openwrt目录"
    cd openwrt
    OPENWRT_DIR="."
else
    echo "错误：找不到openwrt目录"
    exit 1
fi

echo "更新feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 移除不需要的包，精简固件
echo "清理不需要的包..."
./scripts/feeds uninstall luci
./scripts/feeds uninstall luci-ssl
./scripts/feeds uninstall luci-app-firewall
./scripts/feeds uninstall luci-theme-bootstrap

# 安装必要的包
echo "安装必要的包..."
./scripts/feeds install -p packages kmod-ath9k
./scripts/feeds install -p packages wpad-openssl
./scripts/feeds install -p packages iptables
./scripts/feeds install -p packages dnsmasq
./scripts/feeds install -p packages firewall
./scripts/feeds install -p packages odhcpd-ipv6only
./scripts/feeds install -p packages odhcp6c

# 配置目标
cat > .config << 'EOF'
CONFIG_TARGET_ar71xx=y
CONFIG_TARGET_ar71xx_tiny=y
CONFIG_TARGET_ar71xx_tiny_DEVICE_generic=y
CONFIG_TARGET_ar71xx_tiny_DEVICE_generic_ar9331=y

# 架构配置
CONFIG_TARGET_SUBTARGET="tiny"
CONFIG_TARGET_BOARD="ar71xx"
CONFIG_TARGET_ARCH_PACKAGES="mips_24kc"

# 镜像配置
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_TARGET_IMAGES_GZIP=y
CONFIG_TARGET_ROOTFS_PARTSIZE=48

# 内核模块 - 必要
CONFIG_PACKAGE_kmod-ath9k=y
CONFIG_PACKAGE_kmod-ath9k-common=y
CONFIG_PACKAGE_kmod-ath=y
CONFIG_PACKAGE_kmod-gpio-button-hotplug=y
CONFIG_PACKAGE_kmod-leds-gpio=y
CONFIG_PACKAGE_kmod-ledtrig-default-on=y
CONFIG_PACKAGE_kmod-ledtrig-timer=y
CONFIG_PACKAGE_kmod-usb-core=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb-net=y
CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y
CONFIG_PACKAGE_kmod-nls-base=y

# 基础系统
CONFIG_PACKAGE_base-files=y
CONFIG_PACKAGE_block-mount=y
CONFIG_PACKAGE_busybox=y
CONFIG_PACKAGE_dropbear=y
CONFIG_PACKAGE_fstools=y
CONFIG_PACKAGE_fwtool=y
CONFIG_PACKAGE_jshn=y
CONFIG_PACKAGE_jsonfilter=y
CONFIG_PACKAGE_libc=y
CONFIG_PACKAGE_libgcc=y
CONFIG_PACKAGE_libustream-wolfssl=y
CONFIG_PACKAGE_logd=y
CONFIG_PACKAGE_mtd=y
CONFIG_PACKAGE_netifd=y
CONFIG_PACKAGE_opkg=y
CONFIG_PACKAGE_procd=y
CONFIG_PACKAGE_swconfig=y
CONFIG_PACKAGE_ubox=y
CONFIG_PACKAGE_ubus=y
CONFIG_PACKAGE_ubusd=y
CONFIG_PACKAGE_uci=y
CONFIG_PACKAGE_urandom-seed=y
CONFIG_PACKAGE_usign=y

# 网络配置
CONFIG_PACKAGE_dnsmasq=y
CONFIG_PACKAGE_firewall=y
CONFIG_PACKAGE_ip6tables=y
CONFIG_PACKAGE_iptables=y
CONFIG_PACKAGE_iptables-mod-conntrack-extra=y
CONFIG_PACKAGE_iptables-mod-ipopt=y
CONFIG_PACKAGE_kmod-ipt-offload=y
CONFIG_PACKAGE_odhcp6c=y
CONFIG_PACKAGE_odhcpd-ipv6only=y
CONFIG_PACKAGE_ppp=y
CONFIG_PACKAGE_ppp-mod-pppoe=y

# 无线配置
CONFIG_PACKAGE_wpad-openssl=y
CONFIG_PACKAGE_hostapd-common=y
CONFIG_PACKAGE_hostapd-utils=y

# 工具
CONFIG_PACKAGE_iperf3=y
CONFIG_PACKAGE_tcpdump=y
CONFIG_PACKAGE_vim=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_wget=y

# 文件系统
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-vfat=y
CONFIG_PACKAGE_kmod-nls-utf8=y

# 精简选项：移除不需要的
# CONFIG_PACKAGE_luci is not set
# CONFIG_PACKAGE_wpad-basic-wolfssl is not set
# CONFIG_PACKAGE_wayland-utils is not set
# CONFIG_PACKAGE_weston is not set

# 内核配置
CONFIG_KERNEL_BUILD_USER="AR9331-Custom"
CONFIG_KERNEL_BUILD_DOMAIN="github.com"
CONFIG_KERNEL_DEBUG_INFO=n
EOF

echo "配置完成！"
