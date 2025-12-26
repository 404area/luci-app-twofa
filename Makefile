include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-twofa
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT

LUCI_TITLE:=LuCI Support for Two-Factor Authentication (TOTP)
LUCI_DEPENDS:=+luci-base +libnixio +libuci +rpcd +qrencode +luci-lib-jsonc
LUCI_PKGARCH:=all

# 使用这种写法，SDK 会自动在已安装的 feeds 中寻找 luci.mk
include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call LuciBuildPackage,$(PKG_NAME)))
