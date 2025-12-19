#!/bin/bash
# 检查目标配置是否正确

echo "检查OpenWrt构建配置..."

if [ ! -f .config ]; then
  echo "错误：找不到.config文件"
  exit 1
fi

echo "=== 当前配置 ==="
echo "目标架构:"
grep "CONFIG_TARGET_" .config | head -20

echo ""
echo "包配置:"
grep "CONFIG_PACKAGE" .config | wc -l
echo "个包被选中"

echo ""
echo "目标目录结构:"
ls -la target/linux/ 2>/dev/null || echo "目标目录不存在"

echo ""
echo "检查ar71xx目录:"
if [ -d "target/linux/ar71xx" ]; then
  echo "ar71xx目录存在"
  ls -la target/linux/ar71xx/
else
  echo "警告：ar71xx目录不存在"
fi

echo ""
echo "检查内核配置:"
if [ -f "target/linux/ar71xx/tiny/config-4.14" ]; then
  echo "找到tiny内核配置"
else
  echo "警告：未找到tiny内核配置"
fi
