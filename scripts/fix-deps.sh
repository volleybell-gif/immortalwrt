#!/bin/bash
# 修复编译依赖问题

echo "修复编译依赖..."

cd immortalwrt

# 修复 default-settings 包
if [ -f "package/emortal/default-settings/Makefile" ]; then
    echo "修复 default-settings..."
    sed -i 's/DEPENDS:=/DEPENDS:=+libubox +libubus +libuci +luci-base/' package/emortal/default-settings/Makefile
fi

# 修复 e2fsprogs 包
if [ -f "package/utils/e2fsprogs/Makefile" ]; then
    echo "修复 e2fsprogs..."
    # 简化编译选项
    sed -i 's/--enable-elf-shlibs/--disable-elf-shlibs/' package/utils/e2fsprogs/Makefile
fi

# 更新 feeds 确保依赖正确
./scripts/feeds update -a
./scripts/feeds install -a

echo "依赖修复完成"
