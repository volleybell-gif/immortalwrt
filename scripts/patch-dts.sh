#!/bin/bash

set -e

echo "开始应用AR9331自定义设备树补丁..."

# 检查当前目录
CURRENT_DIR=$(pwd)
echo "当前目录: $CURRENT_DIR"

# 尝试找到目标DTS文件
if [ -f "target/linux/ar71xx/dts/ar9331.dtsi" ]; then
    echo "在当前目录找到目标DTS文件"
    TARGET_DTS="target/linux/ar71xx/dts/ar9331.dtsi"
elif [ -f "../target/linux/ar71xx/dts/ar9331.dtsi" ]; then
    echo "在父目录找到目标DTS文件"
    TARGET_DTS="../target/linux/ar71xx/dts/ar9331.dtsi"
else
    echo "错误：找不到目标DTS文件"
    echo "搜索DTS文件..."
    find . -name "ar9331.dtsi" 2>/dev/null | head -10
    echo "尝试寻找ar71xx目录..."
    find . -type d -name "ar71xx" 2>/dev/null | head -10
    exit 1
fi

# 查找自定义DTS文件
if [ -f "custom-dts/ar9331-custom.dts" ]; then
    CUSTOM_DTS="custom-dts/ar9331-custom.dts"
elif [ -f "../config/dts-overlay/ar9331-custom.dts" ]; then
    CUSTOM_DTS="../config/dts-overlay/ar9331-custom.dts"
elif [ -f "ar9331-custom.dts" ]; then
    CUSTOM_DTS="ar9331-custom.dts"
else
    echo "警告：找不到自定义DTS文件"
    echo "使用默认设备树配置..."
    exit 0
fi

echo "目标DTS: $TARGET_DTS"
echo "自定义DTS: $CUSTOM_DTS"

# 备份原始文件
cp "$TARGET_DTS" "${TARGET_DTS}.backup"
echo "已备份原始文件到: ${TARGET_DTS}.backup"

# 创建合并后的DTS文件
echo "合并自定义DTS配置..."

# 方法1：使用sed插入内容（更可靠）
{
    # 读取原始文件直到最后一个闭合括号前
    head -n $(($(wc -l < "$TARGET_DTS") - 1)) "$TARGET_DTS"
    echo ""
    echo "/* 自定义AR9331设备树配置 */"
    echo "/* 适用于64MB DDR2, 16MB SPI Flash */"
    echo "/* 单网口配置为LAN口 */"
    echo ""
    cat "$CUSTOM_DTS"
    echo "};"
} > "${TARGET_DTS}.tmp"

# 检查新文件是否有效
if [ -s "${TARGET_DTS}.tmp" ]; then
    mv "${TARGET_DTS}.tmp" "$TARGET_DTS"
    echo "设备树补丁应用成功！"
    
    # 验证文件
    echo "验证文件格式..."
    LINES=$(wc -l < "$TARGET_DTS")
    echo "新文件大小: $LINES 行"
    
    # 检查关键内容
    if grep -q "compatible.*ar9331" "$TARGET_DTS"; then
        echo "✓ 找到兼容性声明"
    fi
    if grep -q "64MB" "$TARGET_DTS"; then
        echo "✓ 找到内存配置"
    fi
else
    echo "错误：生成的DTS文件为空"
    exit 1
fi

echo "设备树补丁应用完成！"
