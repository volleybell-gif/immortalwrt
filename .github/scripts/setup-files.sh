#!/bin/bash
echo "设置自定义配置文件..."

# 创建网络配置文件
mkdir -p openwrt/files/etc/config
cat > openwrt/files/etc/config/network << 'EOF'
config interface 'loopback'
    option ifname 'lo'
    option proto 'static'
    option ipaddr '127.0.0.1'
    option netmask '255.0.0.0'

config interface 'lan'
    option ifname 'eth0'
    option proto 'static'
    option ipaddr '192.168.1.1'
    option netmask '255.255.255.0'
    option ip6assign '60'

config interface 'wan'
    option ifname 'eth0.2'
    option proto 'dhcp'
    option delegate '0'
EOF

# 创建无线配置文件
cat > openwrt/files/etc/config/wireless << 'EOF'
config wifi-device 'radio0'
    option type 'mac80211'
    option path 'platform/ahb/18100000.wmac'
    option channel '11'
    option htmode 'HT20'
    option disabled '0'
    option hwmode '11g'
    option country 'US'
    option txpower '20'

config wifi-iface 'default_radio0'
    option device 'radio0'
    option network 'lan'
    option mode 'ap'
    option ssid 'ImmortalWrt-AR9331'
    option encryption 'psk2'
    option key '12345678'
EOF

# 创建 DHCP 配置文件
cat > openwrt/files/etc/config/dhcp << 'EOF'
config dnsmasq
    option domainneeded '1'
    option boguspriv '1'
    option localise_queries '1'
    option rebind_protection '1'
    option local '/lan/'
    option domain 'lan'
    option expandhosts '1'
    option authoritative '1'
    option readethers '1'
    option leasefile '/tmp/dhcp.leases'

config dhcp 'lan'
    option interface 'lan'
    option start '100'
    option limit '150'
    option leasetime '12h'
    option dhcpv4 'server'
    option ra 'server'
EOF

# 创建防火墙配置
cat > openwrt/files/etc/config/firewall << 'EOF'
config defaults
    option syn_flood '1'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'REJECT'

config zone
    option name 'lan'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'ACCEPT'
    option network 'lan'

config zone
    option name 'wan'
    option input 'REJECT'
    option output 'ACCEPT'
    option forward 'REJECT'
    option masq '1'
    option mtu_fix '1'
    option network 'wan'

config forwarding
    option src 'lan'
    option dest 'wan'
EOF

echo "自定义配置文件创建完成"
