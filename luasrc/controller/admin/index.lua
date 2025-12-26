module("luci.controller.admin.index", package.seeall)

local twofa_auth = require "luci.twofa.auth"

function index()
    -- 注册 2FA 验证页
    entry({"admin", "twofa_verify"}, form("admin_system/twofa_verify"), nil, 1)

    -- 覆盖默认 /admin 行为
    entry({"admin"}, call("admin_index"), _("Administration"), 0)
end

function admin_index()
    -- 插入 2FA 检查
    twofa_auth.enforce_twofa_on_admin()

    -- 跳转到默认首页
    luci.http.redirect(luci.dispatcher.build_url("admin", "status", "overview"))
end
