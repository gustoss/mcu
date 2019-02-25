-- Set ID for this device in config file

return function(req, res) 
  local id = req.body.id
  if not valid_field_json(id) then
    config.id = id
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
  else
    res:status(400)
    res:type('application/json')
    res:send('{"message":"Some data must be passed!"}')
  end
end