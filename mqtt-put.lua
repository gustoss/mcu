-- Save all configuration required to make connection with mqtt server

return function(req, res) 
  local save = false
  local server = req.body.server
  if not valid_field_json(server) then
    config.mqtt_server = server
    save = true
  end

  local user = req.body.user
  if not valid_field_json(user) then
    config.user_mqtt = user
    save = true
  end

  local pwd = req.body.pwd
  if not valid_field_json(pwd) then
    config.pwd_mqtt = pwd
    save = true
  end

  local switch = req.body.switch
  if not valid_field_json(switch) then
    config.topic_s = switch
    save = true
  end

  local att = req.body.att
  if not valid_field_json(att) then
    config.topic_a = att
    save = true
  end

  if save then 
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