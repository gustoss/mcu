return function(req, res) -- Set ID for this in config file
  if valid_otp(req, res) == false then
    return
  end
  local id = req.body.id
  if valid_field_json(id) then
    res:status(400)
    res:send('ID must be passed!')
    return
  end
  config.id = id
  local suc = assert(loadfile('save_config.lua'))()
  if suc then
    res:send('ID saved!')
  else
    res:status(500)
    res:send('ID didn\'t save!')
  end
end