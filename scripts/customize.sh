#!/bin/bash

echo "========================================"
echo "Starting custom configuration..."
echo "========================================"

# 确保我们在正确的目录
echo "Current directory: $(pwd)"

# 创建必要的目录
mkdir -p files/etc/config
mkdir -p files/etc/uci-defaults

echo "Creating network configuration..."
cat > files/etc/config/network << 'EOF'
config interface 'loopback'
    option ifname 'lo'
    option proto 'static'
    option ipaddr '127.0.0.1'
    option netmask '255.0.0.0'

config globals 'globals'
    option ula_prefix 'fdfd:35a9:7970::/48'

config interface 'lan'
    option type 'bridge'
    option ifname 'eth0'
    option proto 'static'
    option ipaddr '192.168.1.1'
    option netmask '255.255.255.0'
    option ip6assign '60'
    option force_link '1'
EOF

echo "Creating wireless configuration..."
cat > files/etc/config/wireless << 'EOF'
config wifi-device 'radio0'
    option type 'mac80211'
    option channel '6'
    option hwmode '11ng'
    option path 'platform/ar933x_wmac'
    option htmode 'HT20'
    option disabled '0'
    option country 'CN'
    option txpower '20'

config wifi-iface 'default_radio0'
    option device 'radio0'
    option network 'lan'
    option mode 'ap'
    option ssid 'AR9331-ImmortalWrt'
    option encryption 'psk2'
    option key '12345678'
    option wmm '1'
EOF

echo "Creating firewall configuration..."
cat > files/etc/config/firewall << 'EOF'
config defaults
    option syn_flood '1'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'REJECT'

config zone
    option name 'lan'
    list network 'lan'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'ACCEPT'

config zone
    option name 'wan'
    list network 'wan'
    list network 'wan6'
    option input 'REJECT'
    option output 'ACCEPT'
    option forward 'REJECT'
    option masq '1'

config forwarding
    option src 'lan'
    option dest 'wan'

config rule
    option name 'Allow-Ping'
    option src 'wan'
    option proto 'icmp'
    option icmp_type 'echo-request'
    option family 'ipv4'
    option target 'ACCEPT'
EOF

echo "Creating system configuration..."
cat > files/etc/config/system << 'EOF'
config system
    option hostname 'AR9331-ImmortalWrt'
    option timezone 'CST-8'
    option ttylogin '0'
    option log_size '64'
    option urandom_seed '0'
    option zonename 'Asia/Shanghai'

config timeserver 'ntp'
    option enabled '1'
    option enable_server '0'
    list server 'time1.cloud.tencent.com'
    list server 'time2.cloud.tencent.com'
    list server 'time3.cloud.tencent.com'
EOF

echo "Creating DHCP configuration..."
cat > files/etc/config/dhcp << 'EOF'
config dnsmasq
    option domainneeded '1'
    option boguspriv '1'
    option filterwin2k '0'
    option localise_queries '1'
    option rebind_protection '1'
    option rebind_localhost '1'
    option local '/lan/'
    option domain 'lan'
    option expandhosts '1'
    option nonegcache '0'
    option authoritative '1'
    option readethers '1'
    option leasefile '/tmp/dhcp.leases'
    option resolvfile '/tmp/resolv.conf.auto'

config dhcp 'lan'
    option interface 'lan'
    option start '100'
    option limit '150'
    option leasetime '12h'
    option dhcpv6 'server'
    option ra 'server'
EOF

echo "========================================"
echo "Custom configuration completed!"
echo "========================================"
echo "Summary:"
echo "- Target: AR9331 (16MB Flash, 64MB RAM)"
echo "- LAN IP: 192.168.1.1"
echo "- WiFi SSID: AR9331-ImmortalWrt"
echo "- WiFi Password: 12345678"
echo "- Firmware type: squashfs-sysupgrade"
echo "========================================"
