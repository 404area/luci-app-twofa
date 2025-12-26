include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-twofa
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_MAINTAINER:=Your Name <you@example.com>

# 下面这行定义了该包在菜单中的位置和名称
LUCI_TITLE:=LuCI Support for Two-Factor Authentication (TOTP)
LUCI_DEPENDS:=+luci-base +libnixio +libuci +rpcd +qrencode +luci-lib-jsonc
LUCI_PKGARCH:=all

# 这一行必须在 LUCI_TITLE 等变量定义之后，且在 LuciBuildPackage 调用之前
include $(TOPDIR)/feeds/luci/luci.mk

# 关键：必须传入 $(PKG_NAME) 参数
$(eval $(call LuciBuildPackage,$(PKG_NAME)))
