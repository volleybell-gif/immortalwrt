#!/bin/bash

# 进入源码目录
cd immortalwrt-source

# 清理旧配置（可选）
# make clean

echo "开始配置编译选项..."

# 生成默认配置，并指定目标设备[citation:1][citation:10]
cat > .config <<EOF
CONFIG_TARGET_ath79=y
CONFIG_TARGET_ath79_tiny=y
CONFIG_TARGET_ath79_tiny_DEVICE_tplink_tl-wr703n-v1=y
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_wpad-basic-wolfssl=y
EOF

# 使用多线程进行配置展开
make defconfig -j$(nproc)

echo "基础配置完成。"
