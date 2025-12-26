local math = require "math"
local string = require "string"
local os = require "os"
local nixio = require "nixio"

local function base32_decode(s)
    s = s:upper():gsub("[^A-Z2-7]", "")
    if s == "" then return "" end

    local b32chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    local dict = {}
    for i = 1, #b32chars do
        dict[b32chars:sub(i,i)] = i - 1
    end

    local bits = ""
    for i = 1, #s do
        local c = s:sub(i,i)
        if dict[c] then
            bits = bits .. string.format("%05d", dict[c])
        end
    end

    local bytes = {}
    for i = 1, #bits - 7, 8 do
        table.insert(bytes, tonumber(bits:sub(i, i+7), 2))
    end
    return string.char(unpack(bytes))
end

local function generate_totp(secret, time_step)
    time_step = time_step or 30
    local counter = math.floor(os.time() / time_step)
    local counter_bytes = string.pack(">Q", counter)
    local key = base32_decode(secret)
    if #key == 0 then return nil end
    local hash = nixio.hmac("sha1", key, counter_bytes)

    local offset = string.byte(hash, -1) % 16
    local truncated = string.unpack(">I4", hash:sub(offset + 1, offset + 4))
    truncated = bit32.band(truncated, 0x7fffffff)
    return string.format("%06d", truncated % 1000000)
end

return {
    verify = function(secret, token)
        if not secret or not token or #token ~= 6 or not token:match("^[0-9]+$") then
            return false
        end
        local t1 = generate_totp(secret)
        local t2 = generate_totp(secret, 60)  -- 容忍前一个窗口
        return (token == t1) or (token == t2)
    end
}
