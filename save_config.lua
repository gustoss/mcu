if config ~= nil and file.open('config', 'r+') then
    local src = ''
    local s = file.readline()
    while s ~= nil do
      src = src..s
      s = file.readline()
    end
    file.close()
    if file.open('config', 'w+') then
        for key, value in string.gmatch(src, '%${([a-z0-9_]+)}=([a-zA-Z0-9_!@#%$%%&%*%(%)/%?;:><%.=%+%-%s|]*)\n') do
            local dst = '${'..key..'}='
            if config[key] ~= nil then
                dst = dst..config[key]
            end
            file.writeline(dst)
        end
        file.close()
        return true
    end
end
file.close()
return false