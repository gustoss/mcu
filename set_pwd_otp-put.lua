return function(req, res) 
  if valid_otp(req, res) == false then
      return
  end
  local pwd = req.body.pwd
  if valid_field_json(pwd) then
    res:status(400)
    res:send('PASSWORD must be passed!')
    return
  end
  config.passwd = pwd
  local suc = assert(loadfile('save_config.lua'))()
  if suc then
    res:send('PASSWORD OTP saved!')
  else
    res:status(500)
    res:send('PASSWORD OTP didn\'t save!')
  end
end