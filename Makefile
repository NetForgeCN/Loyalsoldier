#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=v2ray-geodata
PKG_VERSION:=$(shell date "+%Y.%m.%d")
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=sbwml <admin@cooluc.com>

include $(INCLUDE_DIR)/package.mk

define Package/v2ray-geodata/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  URL:=https://www.v2fly.org
  PKGARCH:=all
endef

define Package/v2ray-geoip
  $(call Package/v2ray-geodata/default)
  TITLE:=GeoIP List for V2Ray
  LICENSE:=CC-BY-SA-4.0
endef

define Package/v2ray-geosite
  $(call Package/v2ray-geodata/default)
  TITLE:=Geosite List for V2Ray
  LICENSE:=GPL-3.0
endef

GEOIP_URL:=https://github.com/NetForgeCN/v2ray-rules-dat/releases/latest/download/geoip.dat
GEOSITE_URL:=https://github.com/NetForgeCN/v2ray-rules-dat/releases/latest/download/geosite.dat


# 下载/校验逻辑已抽到 fetch-geodata.sh：Build/Compile 里的内联 shell 在
# OpenWrt package.mk 的 $(call) 二次展开下会把 $$1 / $$url 吃掉首字符，
# 导致 curl 拿到裸串并按 http 处理（--proto '=https' 直接拒绝）。
# Build/Prepare 负责把脚本送进 PKG_BUILD_DIR，Compile 只传 URL 并调用。
define Build/Prepare
	$(INSTALL_DIR) $(PKG_BUILD_DIR)
	$(CP) ./fetch-geodata.sh $(PKG_BUILD_DIR)/fetch-geodata.sh
endef

define Build/Compile
	cd "$(PKG_BUILD_DIR)"; \
		GEOIP_URL="$(GEOIP_URL)" GEOSITE_URL="$(GEOSITE_URL)" \
		bash ./fetch-geodata.sh
endef

define Package/v2ray-geoip/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/geoip.dat $(1)/usr/share/v2ray/geoip.dat
endef

define Package/v2ray-geosite/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/geosite.dat $(1)/usr/share/v2ray/geosite.dat
endef

$(eval $(call BuildPackage,v2ray-geoip))
$(eval $(call BuildPackage,v2ray-geosite))
