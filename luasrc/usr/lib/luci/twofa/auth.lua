local uci = require "luci.model.uci".cursor()
local totp = require "luci.twofa.totp"
local http = require "luci.http"

function is_twofa_enabled()
    return uci:get("twofa", "global", "enabled") == "1"
end

function is_twofa_verified()
    return http.session and http.session.data and http.session.data.twofa_verified == true
end

function verify_token(token)
    local secret = uci:get("twofa", "global", "secret")
    return secret and totp.verify(secret, token)
end

-- 在访问 /admin 时调用此函数进行拦截
function enforce_twofa_on_admin()
    if not is_twofa_enabled() then
        return true
    end

    -- 检查是否已登录（sysauth cookie 存在）
    local sess = http.getcookie("sysauth")
    if not sess or sess == "" then
        return true  -- 未登录，由 LuCI 处理跳转到登录页
    end

    -- 已登录但未完成 2FA？
    if not is_twofa_verified() then
        local path = luci.dispatcher.context.path
        -- 避免在验证页自身循环重定向
        if #path >= 2 and path[2] ~= "twofa_verify" then
            http.redirect(luci.dispatcher.build_url("admin", "twofa_verify"))
            return false
        end
    end
    return true
end
