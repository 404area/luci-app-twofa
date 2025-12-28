module("luci.controller.admin.system.twofa", package.seeall)

function index()
    entry({"admin", "services", "twofa"}, cbi("admin_system/twofa"), _("2FA Settings"), 99)
    entry({"admin", "services", "twofa", "status"}, call("action_status")).leaf = true
    entry({"admin", "services", "twofa", "verify"}, call("action_verify")).leaf = true

    -- 注册一个全局钩子 (这需要修改 LuCI 核心或者利用某些主题的特性，但在标准插件中很难做到完全的后端拦截)
    -- 替代方案：利用 uci-access-acl (OpenWrt 19.07+)
    -- 但最通用的方法是覆盖 dispatcher，这太危险。
    -- 我们这里尝试一种折中方案：提供一个“强制验证网关”
end

function action_status()
    local auth = require "luci.twofa.auth"
    local sid = luci.http.getcookie("sysauth")
    luci.http.prepare_content("application/json")
    luci.http.write_json({enabled = auth.is_enabled(), verified = auth.is_verified(sid)})
end

function action_verify()
    local auth = require "luci.twofa.auth"
    local json = require "luci.jsonc"
    local val = json.parse(luci.http.read_content() or "{}")
    local sid = luci.http.getcookie("sysauth")
    luci.http.prepare_content("application/json")
    luci.http.write_json({success = auth.verify_token(sid, val.token)})
end
