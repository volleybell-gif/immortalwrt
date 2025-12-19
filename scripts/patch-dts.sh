#!/bin/bash

set -e

echo "开始应用AR9331自定义设备树补丁..."

# 检查当前目录
if [ -d "target/linux/ar71xx/dts" ]; then
    # 已经在openwrt目录中
    OPENWRT_DIR="."
elif [ -d "openwrt/target/linux/ar71xx/dts" ]; then
    # 在仓库根目录中
    OPENWRT_DIR="openwrt"
else
    echo "错误：找不到openwrt目录结构"
    echo "当前目录: $(pwd)"
    ls -la
    exit 1
fi

echo "OpenWrt目录: $OPENWRT_DIR"

# 设置路径
TARGET_DTS="$OPENWRT_DIR/target/linux/ar71xx/dts/ar9331.dtsi"
CUSTOM_DTS="$OPENWRT_DIR/../config/dts-overlay/ar9331-custom.dts"

if [ ! -f "$TARGET_DTS" ]; then
    echo "错误：找不到目标DTS文件: $TARGET_DTS"
    echo "搜索目录: $(dirname "$TARGET_DTS")"
    find "$OPENWRT_DIR" -name "*.dtsi" | head -10
    exit 1
fi

if [ ! -f "$CUSTOM_DTS" ]; then
    echo "警告：找不到自定义DTS文件: $CUSTOM_DTS"
    echo "使用默认设备树配置..."
    exit 0
fi

echo "目标DTS: $TARGET_DTS"
echo "自定义DTS: $CUSTOM_DTS"

# 备份原始文件
cp "$TARGET_DTS" "${TARGET_DTS}.backup"

echo "合并自定义DTS配置..."
# 更安全的合并方法
{
    # 读取原始文件直到最后一个闭合括号前
    head -n $(($(wc -l < "$TARGET_DTS") - 1)) "$TARGET_DTS"
    echo ""
    echo "/* 自定义AR9331设备树配置 */"
    echo "/* 适用于64MB DDR2, 16MB SPI Flash */"
    echo ""
    cat "$CUSTOM_DTS"
    echo "};"
} > "${TARGET_DTS}.new"

# 检查新文件是否有效
if [ -s "${TARGET_DTS}.new" ]; then
    mv "${TARGET_DTS}.new" "$TARGET_DTS"
    echo "设备树补丁应用成功！"
    echo "新文件大小: $(wc -l < "$TARGET_DTS") 行"
else
    echo "错误：生成的DTS文件为空"
    exit 1
fi
