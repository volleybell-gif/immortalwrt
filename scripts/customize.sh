#!/bin/bash

echo "开始执行自定义配置脚本"

cd openwrt

# 设置目标系统
cat > .config << 'EOF'
CONFIG_TARGET_ath79=y
CONFIG_TARGET_ath79_generic=y
EOF

# 选择具体的设备（这里以 TP-Link TL-MR3420 v2 为例，同样使用 AR9331）
echo "CONFIG_TARGET_ath79_generic_DEVICE_tplink_tl-mr3420-v2=y" >> .config

# 设置 Flash 大小为 16MB
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=16" >> .config

# 启用 squashfs 文件系统
echo "CONFIG_TARGET_ROOTFS_SQUASHFS=y" >> .config

# 启用 ccache 加速编译
echo "CONFIG_CCACHE=y" >> .config

# 设置并行编译线程数
CPU_CORES=$(nproc)
echo "设置并行编译线程数: $CPU_CORES"
echo "CONFIG_CCACHE=y" >> .config

# 设置编译日志
echo "CONFIG_BUILD_LOG=y" >> .config

# 选择必要的软件包
echo "CONFIG_PACKAGE_kmod-ath9k=y" >> .config
echo "CONFIG_PACKAGE_wpad-basic-wolfssl=y" >> .config
echo "CONFIG_PACKAGE_dnsmasq=y" >> .config
echo "CONFIG_PACKAGE_firewall=y" >> .config

echo "自定义配置脚本执行完成"
