local config = {}
if file.open('config', 'r+') then
    local str = ''
    local s = file.readline()
    while s ~= nil do
    str = str..s
    s = file.readline()
    end
    for key, value in string.gmatch(str, '%${([a-z0-9_]+)}=([a-zA-Z0-9_!@#%$%%&%*%(%)/%?;:><%.=%+%-%s|]*)\n') do
    if string.len(value) == 0 then 
        config[key] = nil 
    else
        config[key] = value
    end
    end
    file.close()
    return config
end
file.close()
return {}
