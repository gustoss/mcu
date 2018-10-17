return function(req, res) 
  local ssid = get_body(req, 'ssid')
  print(ssid)
  if ssid == nil or string.len(ssid) == 0 then
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