#!/bin/bash

echo "========================================"
echo "Starting custom configuration..."
echo "========================================"

# Change to ImmortalWrt directory
cd immortalwrt || {
    echo "Error: Cannot enter immortalwrt directory"
    exit 1
}

echo "Current directory: $(pwd)"

# Create necessary directories
mkdir -p files/etc/config
mkdir -p files/etc/uci-defaults
mkdir -p files/usr/lib/lua/luci/controller
mkdir -p files/usr/lib/lua/luci/model/cbi

echo "Directories created successfully"

# Create network configuration
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
    option multicast_querier '0'
    option igmp_snooping '0'
EOF

echo "Network configuration created"

# Create wireless configuration
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
    option legacy_rates '1'

config wifi-iface 'default_radio0'
    option device 'radio0'
    option network 'lan'
    option mode 'ap'
    option ssid 'AR9331-WiFi'
    option encryption 'psk2'
    option key 'OpenWrt123'
    option wpa_group_rekey '86400'
    option wpa_pair_rekey '86400'
    option wpa_master_rekey '86400'
    option isolate '0'
    option wmm '1'
EOF

echo "Wireless configuration created"

# Create firewall configuration
echo "Creating firewall configuration..."
cat > files/etc/config/firewall << 'EOF'
config defaults
    option syn_flood '1'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'REJECT'
    option disable_ipv6 '0'

config zone
    option name 'lan'
    list network 'lan'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'ACCEPT'
    option masq '0'
    option mtu_fix '0'

config zone
    option name 'wan'
    list network 'wan'
    list network 'wan6'
    option input 'REJECT'
    option output 'ACCEPT'
    option forward 'REJECT'
    option masq '1'
    option mtu_fix '1'

config forwarding
    option src 'lan'
    option dest 'wan'

config rule
    option name 'Allow-DHCP-Renew'
    option src 'wan'
    option proto 'udp'
    option dest_port '68'
    option target 'ACCEPT'
    option family 'ipv4'

config rule
    option name 'Allow-Ping'
    option src 'wan'
    option proto 'icmp'
    option icmp_type 'echo-request'
    option family 'ipv4'
    option target 'ACCEPT'

config rule
    option name 'Allow-IGMP'
    option src 'wan'
    option proto 'igmp'
    option family 'ipv4'
    option target 'ACCEPT'

config rule
    option name 'Allow-DHCPv6'
    option src 'wan'
    option proto 'udp'
    option src_ip 'fe80::/10'
    option src_port '547'
    option dest_ip 'fe80::/10'
    option dest_port '546'
    option family 'ipv6'
    option target 'ACCEPT'

config rule
    option name 'Allow-MLD'
    option src 'wan'
    option proto 'icmp'
    option src_ip 'fe80::/10'
    list icmp_type '130/0'
    list icmp_type '131/0'
    list icmp_type '132/0'
    list icmp_type '143/0'
    option family 'ipv6'
    option target 'ACCEPT'

config rule
    option name 'Allow-ICMPv6-Input'
    option src 'wan'
    option proto 'icmp'
    list icmp_type 'echo-request'
    list icmp_type 'echo-reply'
    list icmp_type 'destination-unreachable'
    list icmp_type 'packet-too-big'
    list icmp_type 'time-exceeded'
    list icmp_type 'bad-header'
    list icmp_type 'unknown-header-type'
    list icmp_type 'router-solicitation'
    list icmp_type 'neighbour-solicitation'
    list icmp_type 'router-advertisement'
    list icmp_type 'neighbour-advertisement'
    option limit '1000/sec'
    option family 'ipv6'
    option target 'ACCEPT'

config rule
    option name 'Allow-ICMPv6-Forward'
    option src 'wan'
    option dest '*'
    option proto 'icmp'
    list icmp_type 'echo-request'
    list icmp_type 'echo-reply'
    list icmp_type 'destination-unreachable'
    list icmp_type 'packet-too-big'
    list icmp_type 'time-exceeded'
    list icmp_type 'bad-header'
    list icmp_type 'unknown-header-type'
    option limit '1000/sec'
    option family 'ipv6'
    option target 'ACCEPT'

config include
    option path '/etc/firewall.user'
EOF

echo "Firewall configuration created"

# Create DHCP configuration
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
    option nonwildcard '1'
    option localservice '1'

config dhcp 'lan'
    option interface 'lan'
    option start '100'
    option limit '150'
    option leasetime '12h'
    option dhcpv6 'server'
    option ra 'server'
    option ra_management '1'

config dhcp 'wan'
    option interface 'wan'
    option ignore '1'

config odhcpd 'odhcpd'
    option maindhcp '0'
    option leasefile '/tmp/hosts/odhcpd'
    option leasetrigger '/usr/sbin/odhcpd-update'
    option loglevel '4'
EOF

echo "DHCP configuration created"

# Create system configuration
echo "Creating system configuration..."
cat > files/etc/config/system << 'EOF'
config system
    option hostname 'AR9331-ImmortalWrt'
    option timezone 'CST-8'
    option ttylogin '0'
    option log_size '64'
    option urandom_seed '0'
    option zonename 'Asia/Shanghai'
    option log_proto 'udp'
    option conloglevel '8'
    option cronloglevel '8'

config timeserver 'ntp'
    option enabled '1'
    option enable_server '0'
    list server 'time1.cloud.tencent.com'
    list server 'time2.cloud.tencent.com'
    list server 'time3.cloud.tencent.com'
    list server 'ntp.aliyun.com'
EOF

echo "System configuration created"

# Create Luci configuration (optional)
echo "Creating Luci configuration..."
cat > files/etc/config/luci << 'EOF'
config core 'main'
    option resourcebase '/luci-static/resources'
    option mediaurlbase '/luci-static/bootstrap'

config internal 'themes'
    option Bootstrap '/luci-static/bootstrap'

config internal 'auth'
    option force_ssl '0'

config internal 'sauth'
    option sessionpath '/tmp/luci-sessions'
    option maxstay '3600'
EOF

echo "Luci configuration created"

# Create UCI defaults script
echo "Creating UCI defaults script..."
cat > files/etc/uci-defaults/99-custom-config << 'EOF'
#!/bin/sh

# Set hostname
uci set system.@system[0].hostname='AR9331-ImmortalWrt'

# Set timezone
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'

# Configure LAN interface
uci set network.lan.ifname='eth0'
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.1.1'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.ip6assign='60'

# Disable WAN interface (only one Ethernet port)
uci delete network.wan 2>/dev/null || true
uci delete network.wan6 2>/dev/null || true

# Configure wireless
if [ -n "$(uci get wireless.radio0 2>/dev/null)" ]; then
    uci set wireless.radio0.channel='6'
    uci set wireless.radio0.country='CN'
    uci set wireless.radio0.txpower='20'
    uci set wireless.radio0.disabled='0'
    
    uci set wireless.@wifi-iface[0].ssid='AR9331-WiFi'
    uci set wireless.@wifi-iface[0].encryption='psk2'
    uci set wireless.@wifi-iface[0].key='OpenWrt123'
fi

# Commit changes
uci commit network
uci commit wireless
uci commit system
uci commit firewall

# Remove this script after execution
rm -f /etc/uci-defaults/99-custom-config

exit 0
EOF

chmod +x files/etc/uci-defaults/99-custom-config

echo "UCI defaults script created and made executable"

# Create a simple banner
echo "Creating banner..."
cat > files/etc/banner << 'EOF
  ___   _   _   _   ___ _  _   _   ___ ___ 
 | _ \ /_\ | \| | |_ _| \| | /_\ | _ \_ _|
 |   // _ \| .` |  | || .` |/ _ \|   /| | 
 |_|_/_/ \_\_|\_| |___|_|\_/_/ \_\_|_\___|
                                           
 ImmortalWrt 21.02 for AR9331
 Build: $(date +%Y%m%d)
 Memory: 64MB DDR2
 Flash: 16MB SPI
 LAN IP: 192.168.1.1
 WiFi: AR9331-WiFi (OpenWrt123)
EOF

echo "========================================"
echo "Custom configuration completed!"
echo "========================================"
echo "Summary:"
echo "- Target: AR9331 (16MB Flash, 64MB RAM)"
echo "- LAN IP: 192.168.1.1"
echo "- WiFi SSID: AR9331-WiFi"
echo "- WiFi Password: OpenWrt123"
echo "- Firmware: squashfs-sysupgrade"
echo "========================================"
