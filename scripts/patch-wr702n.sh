#!/bin/bash
# TL-WR702N v1 16MB Flash Patch Script (简化版)

echo "开始应用TL-WR702N v1 (16MB)补丁..."

cd immortalwrt

# 更新并安装所有feeds
echo "更新feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 创建一个简单的补丁来修改分区大小
echo "修改分区大小配置..."

# 修改设备定义文件
if [ -f "target/linux/ar71xx/image/legacy.mk" ]; then
    echo "备份原始文件..."
    cp target/linux/ar71xx/image/legacy.mk target/linux/ar71xx/image/legacy.mk.bak
    
    echo "修改分区大小..."
    # 查找TL-WR702N v1的定义并修改IMAGE_SIZE
    sed -i '/define Device\/tplink_tl-wr702n-v1/,/endef/ {
        /IMAGE_SIZE/ s/:=.*/:= 16064k/
        /DEVICE_VARIANT/ s/:=.*/:= v1 16MB/
    }' target/linux/ar71xx/image/legacy.mk
    
    echo "分区大小已修改为16MB"
else
    echo "警告：legacy.mk文件不存在，跳过分区修改"
fi

# 修改内核分区大小
if [ -f "target/linux/ar71xx/generic/target.mk" ]; then
    echo "调整内核分区大小..."
    sed -i 's/KERNEL_SIZE := 4m/KERNEL_SIZE := 4096k/' target/linux/ar71xx/generic/target.mk
fi

echo "补丁应用完成！"
