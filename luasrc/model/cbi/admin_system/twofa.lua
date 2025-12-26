local m, s, o
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local translate = luci.i18n.translate

m = Map("twofa", translate("Two-Factor Authentication"))
m.on_after_save = function(self)
    -- 保存后重载 uhttpd 不必要，session 会自动生效
end

s = m:section(NamedSection, "global", "twofa")
s.addremove = false

o = s:option(Flag, "enabled", translate("Enable Two-Factor Authentication"))
o.default = "0"

-- 自动生成密钥（仅当为空时）
local secret = uci:get("twofa", "global", "secret") or ""
if secret == "" then
    secret = sys.exec("dd if=/dev/urandom bs=10 count=1 2>/dev/null | base32 | tr -d '=' | tr a-z A-Z")
    uci:set("twofa", "global", "secret", secret)
    uci:commit("twofa")
end

o = s:option(DummyValue, "_qr", translate("Scan this QR code with Google or Microsoft Authenticator"))
o.rawhtml = true
local issuer = uci:get("twofa", "global", "issuer") or "OpenWrt"
local otpauth = "otpauth://totp/%s:root?secret=%s&issuer=%s&algorithm=SHA1&digits=6&period=30"
otpauth = string.format(otpauth, issuer, secret, issuer)
o.value = string.format('<div style="text-align:center;margin:1em"><img src="https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl=%s" alt="QR Code"/></div>', luci.http.urlencode(otpauth))

o = s:option(Value, "secret", translate("Secret Key (Base32)"))
o.password = true
o.readonly = true
o.value = secret

return m
