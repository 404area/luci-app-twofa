include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-twofa
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Your Name <you@example.com>

LUCI_TITLE:=LuCI Support for Two-Factor Authentication (TOTP)
LUCI_DESCRIPTION:=Enable TOTP-based 2FA for LuCI login (Google/Microsoft Authenticator compatible)
LUCI_DEPENDS:=+libubox +libuci +rpcd +luci-base

define Package/$(PKG_NAME)/conffiles
/etc/config/twofa
endef

include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call LuciBuildPackage))
