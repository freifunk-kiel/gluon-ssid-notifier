include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-ssid-notifier
PKG_VERSION:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-ssid-notifier
  SECTION:=gluon
  CATEGORY:=Gluon
  TITLE:=Adds an extra SSID to notify if a node is offline
  DEPENDS:=+gluon-core +micrond
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

