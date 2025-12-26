local m, s, o
local twofa_auth = require "luci.twofa.auth"
local http = require "luci.http"
local translate = luci.i18n.translate

m = SimpleForm("twofa_verify", translate("Two-Factor Authentication"))
m.reset = false
m.submit = translate("Verify")

o = m:field(Value, "token", translate("Enter 6-digit code from your authenticator app"))
o.datatype = "and(uinteger,minlength(6),maxlength(6))"
o.placeholder = "123456"

function m.on_submit(map, ...)
    local token = o:formvalue()
    if twofa_auth.verify_token(token) then
        http.session.data.twofa_verified = true
        http.redirect(luci.dispatcher.build_url("admin"))
        return false
    else
        m.message = "<font color='red'>" .. translate("Invalid code. Please try again.") .. "</font>"
        return false
    end
end

return m
