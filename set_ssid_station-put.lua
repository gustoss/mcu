return function(req, res) 
  if valid_otp(req, res) == false then
    return
  end
  local ssid = req.body.ssid
  if valid_field_json(ssid) then
    res:status(400)
    res:send('SSID must be passed!')
    return
  end
  config.ssid_station = ssid
  local suc = assert(loadfile('save_config.lua'))()
  if suc then
    res:send('SSID Station saved!')
  else
    res:status(500)
    res:send('SSID Station didn\'t save!')
  end
end