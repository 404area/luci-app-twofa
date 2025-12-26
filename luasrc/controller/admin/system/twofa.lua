module("luci.controller.admin.system.twofa", package.seeall)

function index()
    entry({"admin", "system", "twofa"}, cbi("admin_system/twofa"), _("Two-Factor Authentication"), 90)
end
