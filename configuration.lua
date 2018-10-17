local funcs = {}

function funcs.load_config()
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
end

function funcs.save_config(config)
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
end

return funcs