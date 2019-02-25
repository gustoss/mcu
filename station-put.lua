-- Save all configuration required to make connection with WIFI

return function(req, res) 
  local save = false
  local ssid = req.body.ssid
  if not valid_field_json(ssid) then
    config.ssid_station = ssid
    save = true
  end

  local pwd = req.body.pwd
  if not valid_field_json(pwd) then
    config.pwd_station = pwd
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