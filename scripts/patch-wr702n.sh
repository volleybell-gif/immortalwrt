
#!/bin/bash
# TL-WR702N v1 16MB Flash Patch Script

# Apply 16MB flash modifications to device definition
sed -i 's/tplink_led_read/tplink_wr702n_v1_led_read/g' target/linux/ar71xx/files/arch/mips/ath79/mach-tl-wr702n.c
sed -i 's/tplink_led_write/tplink_wr702n_v1_led_write/g' target/linux/ar71xx/files/arch/mips/ath79/mach-tl-wr702n.c

# Update partition table for 16MB flash
sed -i '/PARTNAMES :=/c\PARTNAMES := firmware@160k|kernel@4m|rootfs@12160k' target/linux/ar71xx/image/legacy.mk

# Modify flash partition sizes
sed -i '/KERNEL_SIZE :=/c\KERNEL_SIZE := 4096k' target/linux/ar71xx/image/legacy.mk
sed -i '/ROOTFS_SIZE :=/c\ROOTFS_SIZE := 12160k' target/linux/ar71xx/image/legacy.mk

# Update device profile with 16MB flash information
echo "define Device/tplink_tl-wr702n-v1" >> target/linux/ar71xx/image/legacy.mk
echo "  DEVICE_VENDOR := TP-Link" >> target/linux/ar71xx/image/legacy.mk
echo "  DEVICE_MODEL := TL-WR702N" >> target/linux/ar71xx/image/legacy.mk
echo "  DEVICE_VARIANT := v1 16MB" >> target/linux/ar71xx/image/legacy.mk
echo "  DEVICE_PACKAGES := kmod-usb-core kmod-usb2" >> target/linux/ar71xx/image/legacy.mk
echo "  BOARD_NAME := TL-WR702N-v1" >> target/linux/ar71xx/image/legacy.mk
echo "  IMAGE_SIZE := 16064k" >> target/linux/ar71xx/image/legacy.mk
echo "  SUPPORTED_DEVICES += tl-wr702n-v1" >> target/linux/ar71xx/image/legacy.mk
echo "endef" >> target/linux/ar71xx/image/legacy.mk
echo "\$(eval \$(call Device,tplink_tl-wr702n-v1))" >> target/linux/ar71xx/image/legacy.mk
