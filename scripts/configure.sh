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

# 只安装必要的包，避免luci相关警告
echo "安装基础包..."
./scripts/feeds install -a -p packages

# 跳过luci相关的包
echo "跳过luci相关的包..."
for pkg in luci luci-ssl luci-theme-bootstrap luci-app-firewall; do
    ./scripts/feeds uninstall $pkg 2>/dev/null || true
done

# 配置目标 - 精简配置，只包含必要功能
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
CONFIG_TARGET_ROOTFS_PARTSIZE=48
CONFIG_TARGET_IMAGES_GZIP=y

# 内核配置
CONFIG_KERNEL_BUILD_USER="AR9331-Custom"
CONFIG_KERNEL_BUILD_DOMAIN="github.com"
CONFIG_KERNEL_DEBUG_INFO=n
CONFIG_KERNEL_DEBUG_KERNEL=n

# 精简内核模块
CONFIG_PACKAGE_kmod-ath9k=y
CONFIG_PACKAGE_kmod-ath9k-common=y
CONFIG_PACKAGE_kmod-ath=y
CONFIG_PACKAGE_kmod-gpio-button-hotplug=y
CONFIG_PACKAGE_kmod-leds-gpio=y
CONFIG_PACKAGE_kmod-nls-base=y

# 基础系统包
CONFIG_PACKAGE_base-files=y
CONFIG_PACKAGE_busybox=y
CONFIG_PACKAGE_dropbear=y
CONFIG_PACKAGE_fstools=y
CONFIG_PACKAGE_procd=y
CONFIG_PACKAGE_ubox=y
CONFIG_PACKAGE_ubus=y
CONFIG_PACKAGE_ubusd=y
CONFIG_PACKAGE_uci=y
CONFIG_PACKAGE_netifd=y

# 网络配置
CONFIG_PACKAGE_dnsmasq=y
CONFIG_PACKAGE_firewall=y
CONFIG_PACKAGE_iptables=y
CONFIG_PACKAGE_odhcp6c=y
CONFIG_PACKAGE_odhcpd-ipv6only=y

# 无线配置
CONFIG_PACKAGE_wpad-openssl=y
CONFIG_PACKAGE_hostapd-common=y

# 工具（可选）
CONFIG_PACKAGE_iperf3=y
CONFIG_PACKAGE_tcpdump=y
CONFIG_PACKAGE_vim=y

# 文件系统
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-vfat=y

# 禁用不需要的包
# CONFIG_PACKAGE_luci is not set
# CONFIG_PACKAGE_luci-ssl is not set
# CONFIG_PACKAGE_luci-theme-bootstrap is not set
# CONFIG_PACKAGE_luci-app-firewall is not set
# CONFIG_PACKAGE_wayland-utils is not set
# CONFIG_PACKAGE_weston is not set
# CONFIG_PACKAGE_wpad-basic-wolfssl is not set
EOF

echo "应用配置..."
make defconfig

# 生成diff配置便于调试
./scripts/diffconfig.sh > config.diff
echo "配置差异:"
cat config.diff

echo "配置完成！"
