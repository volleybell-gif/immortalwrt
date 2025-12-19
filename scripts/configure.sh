#!/bin/bash

echo "开始强制清理并重新配置..."

cd openwrt

# 完全清理
make clean
rm -rf tmp/
rm -rf staging_dir/target-*/
rm -rf build_dir/target-*/
rm -f .config .config.old feeds.conf feeds.conf.bak

# 创建全新的最小配置
cat > .config << 'EOF'
# Target
CONFIG_TARGET_ath79=y
CONFIG_TARGET_ath79_generic=y
CONFIG_TARGET_ATH79_SINGLE_IMAGE=y

# Filesystem
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_TARGET_ROOTFS_PARTSIZE=48

# Kernel modules
CONFIG_PACKAGE_kmod-ath9k=y
CONFIG_PACKAGE_kmod-ath9k-common=y
CONFIG_PACKAGE_kmod-usb-core=y
CONFIG_PACKAGE_kmod-usb2=y

# Network
CONFIG_PACKAGE_dnsmasq=y
CONFIG_PACKAGE_firewall=y
CONFIG_PACKAGE_odhcpd=y

# Wireless
CONFIG_PACKAGE_wpad-basic-wolfssl=y
CONFIG_PACKAGE_iw=y

# System
CONFIG_PACKAGE_uci=y
CONFIG_PACKAGE_ubus=y
CONFIG_PACKAGE_dropbear=y
CONFIG_PACKAGE_opkg=y

# Optimizations
CONFIG_SMALL_FLASH=y
EOF

# 显式禁用冲突包
echo "# Explicitly disable conflicting packages" >> .config
echo "# CONFIG_PACKAGE_dnsmasq-full is not set" >> .config
echo "# CONFIG_PACKAGE_odhcpd-ipv6only is not set" >> .config
echo "# CONFIG_PACKAGE_luci is not set" >> .config
echo "# CONFIG_PACKAGE_uhttpd is not set" >> .config
echo "# CONFIG_PACKAGE_ip6tables is not set" >> .config

# 显示配置摘要
echo "=== 配置摘要 ==="
echo "dnsmasq配置:"
grep -i dnsmasq .config || echo "未找到dnsmasq配置"
echo ""
echo "odhcpd配置:"
grep -i odhcpd .config || echo "未找到odhcpd配置"

echo "配置完成！"
