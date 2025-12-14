#!/bin/bash
# TL-WR702N v1 16MB闪存配置脚本

# 设置编译目标
TARGET="ar71xx/generic"
DEVICE="tplink_tl-wr702n-v1"

# 修改设备定义以支持16MB闪存
if [ -f "target/linux/ar71xx/image/legacy.mk" ]; then
    sed -i 's/IMAGE_SIZE := .*/IMAGE_SIZE := 16064k/' target/linux/ar71xx/image/legacy.mk
fi

# 配置基础软件包
echo "CONFIG_PACKAGE_luci=y" >> .config
echo "CONFIG_PACKAGE_luci-theme-bootstrap=y" >> .config
echo "CONFIG_PACKAGE_dnsmasq=y" >> .config
echo "CONFIG_PACKAGE_firewall=y" >> .config

# 16MB专用优化（禁用非必要功能）
echo "CONFIG_PACKAGE_luci-app-ddns=n" >> .config
echo "CONFIG_PACKAGE_luci-app-upnp=n" >> .config

# 启用必要驱动
echo "CONFIG_PACKAGE_kmod-ath9k=y" >> .config
echo "CONFIG_ATH_USER_REGD=y" >> .config

echo "TL-WR702N v1 16MB配置完成！"
