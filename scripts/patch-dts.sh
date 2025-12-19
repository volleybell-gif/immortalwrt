#!/bin/bash

set -e

echo "开始应用AR9331自定义设备树补丁..."

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

# 备份原始文件
cp "$TARGET_DTS" "${TARGET_DTS}.backup"

# 创建临时合并文件
TEMP_FILE="/tmp/ar9331-merged.dts"

# 提取原始DTS的主体部分（去除最后的闭合括号）
grep -v '^};$' "$TARGET_DTS" > "$TEMP_FILE"

# 追加自定义内容
cat "$CUSTOM_DTS" >> "$TEMP_FILE"

# 添加闭合括号
echo "};" >> "$TEMP_FILE"

# 替换原始文件
mv "$TEMP_FILE" "$TARGET_DTS"

echo "设备树补丁应用完成！"
