
#!/bin/bash

# 添加自定义配置
cat >> .config <<EOF

# 配置硬件平台
CONFIG_TARGET_ar71xx=y
CONFIG_TARGET_ar71xx_generic=y
CONFIG_TARGET_ar71xx_generic_DEVICE_tl-wr841-v11=y

# 启用无线支持
CONFIG_PACKAGE_kmod-ath9k-htc=y
CONFIG_PACKAGE_kmod-rt2800-usb=y
CONFIG_PACKAGE_kmod-rtl8192cu=y
CONFIG_PACKAGE_hostapd-common=y
CONFIG_PACKAGE_wpad-basic=y

# 文件系统与存储
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_TARGET_SQUASHFS_BLOCK_SIZE=256
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-ntfs=y
CONFIG_PACKAGE_kmod-usb-storage=y

# 网络配置
CONFIG_PACKAGE_luci-proto-ipv6=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-app-firewall=y

# 性能优化
CONFIG_DEVEL=y
CONFIG_CCACHE=y

EOF

# 修改网络接口配置
cat > ./files/etc/config/network <<EOF
config interface 'loopback'
    option ifname 'lo'
    option proto 'static'
    option ipaddr '127.0.0.1'
    option netmask '255.0.0.0'

config globals 'globals'
    option ula_prefix 'fd35:433f:58a4::/48'

config interface 'lan'
    option type 'bridge'
    option ifname 'eth0'
    option proto 'static'
    option ipaddr '192.168.1.1'
    option netmask '255.255.255.0'
    option ip6assign '60'

EOF

# 修改无线配置
cat > ./files/etc/config/wireless <<EOF
config wifi-device 'radio0'
    option type 'mac80211'
    option channel '11'
    option hwmode '11g'
    option path 'platform/ar933x_wmac'
    option htmode 'HT20'
    option disabled '0'

config wifi-iface 'default_radio0'
    option device 'radio0'
    option network 'lan'
    option mode 'ap'
    option ssid 'ImmortalWrt'
    option encryption 'psk2'
    option key 'password'

EOF

# 修改防火墙配置
cat > ./files/etc/config/firewall <<EOF
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

EOF

echo "自定义配置完成"
