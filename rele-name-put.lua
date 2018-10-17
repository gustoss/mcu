return function(req, res) 
    local rele = nil
    local name = get_body(req, 'old_name')
    if name ~= nil then
      if config.rele1 == name then rele = 'rele1'
      elseif config.rele2 == name then rele = 'rele2'
      elseif config.rele3 == name then rele = 'rele3'
      elseif config.rele4 == name then rele = 'rele4'
      end
      if rele == nil then
        res:status(400)
        res:send('Old name must be passed!')
        return
      end

      local new_name = get_body(req, 'new_name')
      if new_name == nil or string.len(new_name) == 0 then
        res:status(400)
        res:send('New name must be passed!')
        return
      end

      pins[new_name] = pins[name]
      pins[name] = nil
      config[rele] = new_name

      local suc = assert(loadfile('save_config.lua'))()
      if suc then
        res:send('Name saved!')
      else
        res:status(500)
        res:send('Internal error!')
      end
      return
    end
    res:status(400)
    res:send('Old name must be passed!')
end