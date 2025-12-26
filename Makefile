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
  TITLE:=Two-factor authentication for LuCI
  DEPENDS:=+qrencode +nixio
  PKGARCH:=all
end Package

define Build/Compile
endef

define Package/luci-app-twofa/install
	# 创建系统目录
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/admin/system
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/admin_system
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/twofa
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/www/luci-static/resources

	# 安装 Lua 文件
	$(CP) ./luasrc/controller/admin/system/*.lua $(1)/usr/lib/lua/luci/controller/admin/system/
	$(CP) ./luasrc/model/cbi/admin_system/*.lua $(1)/usr/lib/lua/luci/model/cbi/admin_system/
	$(CP) ./luasrc/usr/lib/luci/twofa/*.lua $(1)/usr/lib/lua/luci/twofa/

	# 安装配置文件和菜单 JSON
	$(CP) ./root/usr/share/luci/menu.d/*.json $(1)/usr/share/luci/menu.d/
	$(CP) ./root/usr/share/rpcd/acl.d/*.json $(1)/usr/share/rpcd/acl.d/
	$(CP) ./root/etc/config/twofa $(1)/etc/config/

	# 安装静态 JS 文件 (Hook 调用的文件)
	$(CP) ./htdocs/luci-static/resources/*.js $(1)/www/luci-static/resources/
endef

# 【关键步骤】安装后脚本：自动触发菜单刷新
define Package/luci-app-twofa/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
	/etc/init.d/rpcd restart
fi
exit 0
endef

$(eval $(call BuildPackage,luci-app-twofa))
