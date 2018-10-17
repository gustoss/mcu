return function(req, res) 
    local loc = get_body(req, 'name_dns')
    if loc == nil or string.len(loc) == 0 then
      res:status(400)
      res:send('Name DNS must be passed!')
      return
    end
    config.name_dns = loc
    local suc = assert(loadfile('save_config.lua'))()
    if suc then
      res:send('Name DNS saved!')
    else
      res:status(500)
      res:send('Name DNS didn\'t save!')
    end
end