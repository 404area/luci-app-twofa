include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-twofa
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_MAINTAINER:=YourName

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-twofa
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI Support for Two-Factor Authentication (TOTP)
  DEPENDS:=+luci-base +libnixio +libuci +rpcd +qrencode +luci-lib-jsonc
  PKGARCH:=all
endef

define Build/Compile
endef

define Package/luci-app-twofa/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/admin/system
	$(INSTALL_DATA) ./luasrc/controller/admin/system/twofa.lua $(1)/usr/lib/lua/luci/controller/admin/system/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/admin_system
	$(INSTALL_DATA) ./luasrc/model/cbi/admin_system/twofa.lua $(1)/usr/lib/lua/luci/model/cbi/admin_system/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/twofa
	$(INSTALL_DATA) ./luasrc/usr/lib/luci/twofa/*.lua $(1)/usr/lib/lua/luci/twofa/

	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./root/usr/share/luci/menu.d/*.json $(1)/usr/share/luci/menu.d/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/twofa $(1)/etc/config/

	$(INSTALL_DIR) $(1)/www/luci-static/resources
	$(INSTALL_DATA) ./htdocs/luci-static/resources/*.js $(1)/www/luci-static/resources/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(foreach po,$(wildcard ./po/zh_Hans/*.po), \
		po2lmo $(po) $(1)/usr/lib/lua/luci/i18n/twofa.zh-cn.lmo; \
	)
endef

$(eval $(call BuildPackage,luci-app-twofa))
