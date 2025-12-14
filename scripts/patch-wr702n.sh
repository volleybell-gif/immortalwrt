#!/bin/bash
# TL-WR702N v1 16MB Flash Patch Script

echo "开始应用16MB闪存补丁..."

# 修改设备分区大小
if [ -f "target/linux/ar71xx/image/legacy.mk" ]; then
    echo "修改分区大小..."
    # 备份原文件
    cp target/linux/ar71xx/image/legacy.mk target/linux/ar71xx/image/legacy.mk.bak
    
    # 修改TL-WR702N v1的配置
    sed -i '/define Device\/tplink_tl-wr702n-v1/,/endef/ {
        /IMAGE_SIZE/ s/:=.*/:= 16064k/
        /DEVICE_VARIANT/ s/:=.*/:= v1 16MB/
    }' target/linux/ar71xx/image/legacy.mk
    
    echo "分区大小已更新为16MB"
else
    echo "警告：未找到legacy.mk文件"
fi

# 确保使用正确的无线驱动
if [ -f "target/linux/ar71xx/image/legacy.mk" ]; then
    echo "确保使用正确的设备配置..."
    # 添加16MB闪存支持
    echo "" >> target/linux/ar71xx/image/legacy.mk
    echo "# 16MB flash support for TL-WR702N v1" >> target/linux/ar71xx/image/legacy.mk
    echo "define Device/tplink_16mb_tl-wr702n-v1" >> target/linux/ar71xx/image/legacy.mk
    echo "  \$(Device/tplink_tl-wr702n-v1)" >> target/linux/ar71xx/image/legacy.mk
    echo "  DEVICE_VARIANT := v1 16MB" >> target/linux/ar71xx/image/legacy.mk
    echo "  IMAGE_SIZE := 16064k" >> target/linux/ar71xx/image/legacy.mk
    echo "endef" >> target/linux/ar71xx/image/legacy.mk
    echo "TARGET_DEVICES += tplink_16mb_tl-wr702n-v1" >> target/linux/ar71xx/image/legacy.mk
fi

echo "补丁应用完成！"
