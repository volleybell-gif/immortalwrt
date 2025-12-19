#!/bin/bash

echo "=== AR9331 配置脚本 ==="
cd openwrt

# 设置目标平台
echo "CONFIG_TARGET_ath79=y" > .config
echo "CONFIG_TARGET_ath79_generic=y" >> .config
echo "CONFIG_TARGET_ath79_generic_DEVICE_tplink_tl-mr3420-v2=y" >> .config

# 设置 flash 大小
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=16" >> .config
echo "CONFIG_TARGET_ROOTFS_SQUASHFS=y" >> .config

# 启用编译加速
echo "CONFIG_CCACHE=y" >> .config
echo "CONFIG_BUILD_LOG=y" >> .config

echo "配置完成"
