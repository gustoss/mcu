-- Save id to each port, to mqtt's control

return function(req, res) 
  if type(req.body) == 'table' then
    local toSave = {}
    local save = false
    for key, value in pairs(req.body) do
      local valid = key:match('^d0$') or key:match('^d1$') or key:match('^d2$') or key:match('^d3$')
      print(key..' - '..value)
      if valid_field_json(key) or not valid then
        res:status(400)
        res:type('application/json')
        res:send('{"message":"Invalid device\'s name passed!"}')
        return
      end
      toSave[key] = value
      save = true
    end
    if save then
      for key, value in pairs(toSave) do config[key] = value end
      local suc = assert(loadfile('save_config.lua'))()
      if suc then
        res:status(204)
        res:send()
      else
        res:status(500)
        res:type('application/json')
        res:send('{"message":"Error when saved the configuration!"}')

        if not valid_field_json(config.topic_i) then -- Only publish after to set topic in /mqtt rest
          server:publish(config.topic_i, 
                        '{"plataform":"devicesPointSwitch","hardware":"'..config.id..'","action":"server","level":"error","message":"Error when saved the configuration!"}', 1)
        end
      end
      return
    end
  end
  res:status(400)
  res:type('application/json')
  res:send('{"message":"Some data must be passed!"}')
end