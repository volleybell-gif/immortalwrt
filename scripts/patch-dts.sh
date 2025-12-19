#!/bin/bash

set -e

echo "开始应用AR9331自定义设备树补丁..."

# 改变到openwrt目录
cd openwrt

# 找到目标DTS文件
TARGET_DTS="target/linux/ar71xx/dts/ar9331.dtsi"
CUSTOM_DTS="../config/dts-overlay/ar9331-custom.dts"

if [ ! -f "$TARGET_DTS" ]; then
    echo "错误：找不到目标DTS文件: $TARGET_DTS"
    exit 1
fi

if [ ! -f "$CUSTOM_DTS" ]; then
    echo "警告：找不到自定义DTS文件，跳过设备树补丁"
    exit 0
fi

echo "备份原始DTS文件..."
cp "$TARGET_DTS" "${TARGET_DTS}.backup"

echo "合并自定义DTS..."
# 使用更可靠的方法合并
{
    # 读取原始文件，直到最后一个闭合括号前
    head -n $(($(wc -l < "$TARGET_DTS") - 1)) "$TARGET_DTS"
    echo ""
    echo "/* 自定义设备树配置 - AR9331 */"
    cat "$CUSTOM_DTS"
    echo "};"
} > "${TARGET_DTS}.new"

mv "${TARGET_DTS}.new" "$TARGET_DTS"

echo "设备树补丁应用完成！验证文件..."
# 验证DTS文件格式
if grep -q "compatible.*ar9331" "$TARGET_DTS"; then
    echo "DTS文件验证通过"
else
    echo "警告：DTS文件可能格式不正确"
fi
