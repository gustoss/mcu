local timeSync = false
sntp.sync('time.google.com', 
function(sec, usec, server, info)
    if config.passwd ~= nil then
        timeSync = true
    end
end, 
function()
    print('Failed att time!')
end , 1)

function dec2hex(a)
    local s = ''
    for c in string.gmatch(a, '%w') do
        s = s..string.format('%02X' ,string.byte(c))
    end
    return s:lower()
end

function totp()
    if timeSync == false then return -1 end
    passwd = dec2hex(config.passwd)
    local time, _, _ = rtctime.get()
    time = math.floor(time / 30)
    time = dec2hex(time)
    local hmac = crypto.toHex(crypto.hmac('sha1', time, passwd))
    local offset = tonumber('0x0'..hmac:match('%w$')) * 2
    local otp = tonumber('0x'..hmac:sub((offset + 1), (offset + 8)))
    otp = (otp..''):sub(-6)
    return otp
end