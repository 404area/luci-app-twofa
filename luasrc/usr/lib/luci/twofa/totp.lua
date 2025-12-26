local os = require "os"
local math = require "math"
local string = require "string"
local table = require "table"
local nixio = require "nixio"
local bit = nixio.bit or require "bit"

local M = {}

local function hex2bin(hex)
    return (hex:gsub("..", function(cc) return string.char(tonumber(cc, 16)) end))
end

local function pack_int64(num)
    local t = {}
    for i = 1, 8 do
        table.insert(t, 1, string.char(bit.band(num, 0xFF)))
        num = math.floor(num / 256)
    end
    return table.concat(t)
end

local function base32_decode(s)
    s = s:upper():gsub("[^A-Z2-7]", "")
    local map = {
        A=0, B=1, C=2, D=3, E=4, F=5, G=6, H=7, I=8, J=9,
        K=10, L=11, M=12, N=13, O=14, P=15, Q=16, R=17, S=18, T=19,
        U=20, V=21, W=22, X=23, Y=24, Z=25, ["2"]=26, ["3"]=27,
        ["4"]=28, ["5"]=29, ["6"]=30, ["7"]=31
    }
    local buffer, bits_left, result = 0, 0, {}
    for i = 1, #s do
        buffer = bit.bor(bit.lshift(buffer, 5), map[s:sub(i,i)])
        bits_left = bits_left + 5
        if bits_left >= 8 then
            bits_left = bits_left - 8
            table.insert(result, string.char(bit.band(bit.rshift(buffer, bits_left), 0xFF)))
        end
    end
    return table.concat(result)
end

function M.verify(secret, token)
    if not secret or not token or #token ~= 6 then return false end
    local key = base32_decode(secret)
    local function gen(offset)
        local cp = pack_int64(math.floor(os.time() / 30) + offset)
        local hash = hex2bin(nixio.crypto.hmac("sha1", key, cp))
        local off = bit.band(string.byte(hash, -1), 0x0F)
        local bin = bit.band(string.byte(hash, off+1)*16777216 + string.byte(hash, off+2)*65536 + string.byte(hash, off+3)*256 + string.byte(hash, off+4), 0x7FFFFFFF)
        return string.format("%06d", bin % 1000000)
    end
    return token == gen(0) or token == gen(-1)
end

return M
