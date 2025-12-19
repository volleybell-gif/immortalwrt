#!/bin/bash

echo "应用AR9331设备树补丁..."

# 创建自定义设备树文件
cat > ar9331_myrouter.dts << 'EOF'
/dts-v1/;

#include "ar9331.dtsi"

/ {
	model = "My Custom AR9331 Router";
	compatible = "qca,ar9331";

	memory@0 {
		device_type = "memory";
		reg = <0x0 0x4000000>;  // 64MB
	};

	chosen {
		bootargs = "console=ttyATH0,115200";
	};

	aliases {
		serial0 = &uart;
		led-boot = &led_system;
		led-failsafe = &led_system;
		led-running = &led_system;
		led-upgrade = &led_system;
	};

	leds {
		compatible = "gpio-leds";

		led_system: system {
			label = "blue:system";
			gpios = <&gpio 0 GPIO_ACTIVE_LOW>;
			default-state = "on";
		};

		lan {
			label = "green:lan";
			gpios = <&gpio 13 GPIO_ACTIVE_LOW>;
		};

		wlan {
			label = "green:wlan";
			gpios = <&gpio 17 GPIO_ACTIVE_LOW>;
			linux,default-trigger = "phy0tpt";
		};
	};

	keys {
		compatible = "gpio-keys-polled";
		poll-interval = <100>;

		reset {
			label = "reset";
			linux,code = <KEY_RESTART>;
			gpios = <&gpio 12 GPIO_ACTIVE_LOW>;
			debounce-interval = <60>;
		};
	};

	gpio-export {
		compatible = "gpio-export";

		gpio_usb_power {
			gpio-export,name = "usb_power";
			gpio-export,output = <1>;
			gpios = <&gpio 8 GPIO_ACTIVE_HIGH>;
		};
	};
};

&spi {
	status = "okay";
	num-cs = <1>;

	flash@0 {
		compatible = "jedec,spi-nor";
		reg = <0>;
		spi-max-frequency = <25000000>;

		partitions {
			compatible = "fixed-partitions";
			#address-cells = <1>;
			#size-cells = <1>;

			partition@0 {
				label = "u-boot";
				reg = <0x0 0x20000>;
				read-only;
			};

			partition@20000 {
				label = "firmware";
				reg = <0x20000 0xfd0000>;
			};

			art: partition@ff0000 {
				label = "art";
				reg = <0xff0000 0x10000>;
				read-only;
			};
		};
	};
};

&eth0 {
	status = "okay";

	phy-handle = <&swphy>;
	phy-mode = "rgmii";

	fixed-link {
		speed = <1000>;
		full-duplex;
	};
};

&eth1 {
	status = "okay";
	phy-handle = <&phy0>;
};

&mdio0 {
	swphy: ethernet-switch@0 {
		compatible = "qca,ar9330-switch";
		reg = <0>;
	};
};

&wmac {
	status = "okay";
	qca,no-eeprom;
};

&uart {
	status = "okay";
};
EOF

echo "设备树补丁应用完成！"
