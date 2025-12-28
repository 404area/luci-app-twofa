local uci = require "luci.model.uci".cursor()
local fs  = require "nixio.fs"
local json = require "luci.jsonc"
local totp = require "luci.twofa.totp"

local M = {}
local SESSION_FILE = "/var/run/luci-twofa-sessions.json"

local function get_data()
    return json.parse(fs.readfile(SESSION_FILE) or "{}") or {}
end

function M.is_enabled() return uci:get("twofa", "global", "enabled") == "1" end

function M.is_verified(sid)
    if not M.is_enabled() then return true end
    return sid and get_data()[sid] == true
end

function M.verify_token(sid, token)
    local secret = uci:get("twofa", "global", "secret")
    if secret and totp.verify(secret, token) then
        local d = get_data()
        d[sid] = true
        fs.writefile(SESSION_FILE, json.stringify(d))
        return true
    end
    return false
end

-- 新增：后端拦截检查器
-- 可以在其他 Controller 中调用此函数来强制检查
function M.check_access(dsp)
    local sid = dsp.context.authsession
    if M.is_enabled() and not M.is_verified(sid) then
        luci.http.status(403, "Forbidden")
        luci.http.write("Access Denied: Two-Factor Authentication Required")
        luci.http.close()
        return false
    end
    return true
end

return M
