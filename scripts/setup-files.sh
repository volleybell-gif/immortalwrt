#!/bin/bash
# scripts/setup-files.sh

echo "设置默认配置文件..."

# 创建必要的目录
mkdir -p files/etc/uci-defaults
mkdir -p files/etc/hotplug.d/iface
mkdir -p files/etc/hotplug.d/net

# 创建默认网络配置脚本
cat > files/etc/uci-defaults/99-custom-network << 'EOF'
#!/bin/sh

# 设置LAN口IP为192.168.1.1
uci set network.lan.ipaddr='192.168.1.1'
uci commit network

# 启用无线
uci set wireless.radio0.disabled='0'
uci commit wireless

# 重启网络
/etc/init.d/network restart

exit 0
EOF

chmod +x files/etc/uci-defaults/99-custom-network

# 创建简单的SSH欢迎信息
cat > files/etc/banner << 'EOF'
  ___  _  _  ____  _  _  ___  _   _  ____ 
 / __)( \/ )(  _ \( \/ )/ __)( )_( )(_  _)
( (__  \  /  ) _ < \  /( (__  ) _ (   )(  
 \___) (__) (____/ (__) \___)(_) (_) (__) 
                                          
 ImmortalWrt for AR9331 (64MB/16MB)
 Built: $(date)
EOF

echo "文件设置完成！"
