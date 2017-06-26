include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ssid-notifier
PKG_VERSION:=0.1
PKG_RELEASE:=$(GLUON_BRANCH)

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-ssid-notifier
	SECTION:=gluon
	CATEGORY:=Gluon
	TITLE:=Adds an extra Offline-SSID to notify if a node is offline
	DEPENDS:=+gluon-core +micrond
endef
			
define Package/gluon-ssid-notifier/description
	Script to add an extra Offline-SSID when there is no sufficient connection quality to 
	the selected gateway. This SSID is generated from the nodes hostname with the first 
	and last part of the nodename to allow observers to recognise which node is down
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-ssid-notifier/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,gluon-ssid-notifier))
