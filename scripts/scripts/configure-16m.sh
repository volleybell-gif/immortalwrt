#!/bin/bash
# TL-WR902AC v1 16MB配置脚本

# 修改设备定义以支持16MB闪存
sed -i 's/IMAGE_SIZE := .*/IMAGE_SIZE := 16064k/' target/linux/ath79/image/tiny-tp-link.mk

# 调整内核分区表
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=256" >> .config
echo "CONFIG_TARGET_KERNEL_PARTSIZE=16" >> .config

# 启用必要驱动
echo "CONFIG_PACKAGE_kmod-usb-core=y" >> .config
echo "CONFIG_PACKAGE_kmod-usb2=y" >> .config
