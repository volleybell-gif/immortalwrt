#!/bin/bash

echo "开始配置AR9331编译环境..."

cd openwrt

# 设置目标
cat > .config << EOF
CONFIG_TARGET_ath79=y
CONFIG_TARGET_ath79_generic=y
CONFIG_TARGET_MULTI_PROFILE=y
CONFIG_TARGET_PER_DEVICE_ROOTFS=y
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_TARGET_ROOTFS_PARTSIZE=48
EOF

# 基础包
cat >> .config << EOF
CONFIG_PACKAGE_kmod-ath9k=y
CONFIG_PACKAGE_kmod-gpio-button-hotplug=y
CONFIG_PACKAGE_kmod-leds-gpio=y
CONFIG_PACKAGE_kmod-ledtrig-default-on=y
CONFIG_PACKAGE_kmod-ledtrig-netdev=y
CONFIG_PACKAGE_kmod-ledtrig-timer=y
CONFIG_PACKAGE_kmod-usb-core=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_ath9k-htc-firmware=y
EOF

# 网络配置
cat >> .config << EOF
CONFIG_PACKAGE_dnsmasq=y
CONFIG_PACKAGE_firewall=y
CONFIG_PACKAGE_iptables=y
CONFIG_PACKAGE_iptables-mod-conntrack-extra=y
CONFIG_PACKAGE_iptables-mod-ipopt=y
CONFIG_PACKAGE_iw=y
CONFIG_PACKAGE_iwinfo=y
CONFIG_PACKAGE_wpad-basic-wolfssl=y
CONFIG_PACKAGE_hostapd-common=y
CONFIG_PACKAGE_odhcpd=y
CONFIG_PACKAGE_odhcpd-ipv6only=y
CONFIG_PACKAGE_odhcp6c=y
EOF

# 系统工具
cat >> .config << EOF
CONFIG_PACKAGE_busybox=y
CONFIG_BUSYBOX_CUSTOM=y
CONFIG_BUSYBOX_CONFIG_FEATURE_EDITING=y
CONFIG_BUSYBOX_CONFIG_FEATURE_EDITING_HISTORY=64
CONFIG_BUSYBOX_CONFIG_HUSH=y
CONFIG_PACKAGE_dropbear=y
CONFIG_PACKAGE_opkg=y
CONFIG_PACKAGE_uci=y
CONFIG_PACKAGE_ubus=y
CONFIG_PACKAGE_ubusd=y
CONFIG_PACKAGE_libubus=y
CONFIG_PACKAGE_libblobmsg-json=y
CONFIG_PACKAGE_libjson-c=y
CONFIG_PACKAGE_libuci=y
CONFIG_PACKAGE_libuclient=y
CONFIG_PACKAGE_libnl-tiny=y
CONFIG_PACKAGE_libpthread=y
EOF

echo "配置完成！"
