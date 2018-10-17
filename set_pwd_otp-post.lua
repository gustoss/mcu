return function(req, res) 
    if valid_otp(req, res) == false then
        return
      end
      local pwd = get_body(req, 'pwd')
      if pwd == nil or string.len(pwd) == 0 then
        res:status(400)
        res:send('PASSWORD must be passed!')
        return
      end
      config.passwd = pwd
      print(config.passwd)
      local suc = assert(loadfile('save_config.lua'))()
      print('Save')
      if suc then
        res:send('PASSWORD OTP saved!')
      else
        res:status(500)
        res:send('PASSWORD OTP didn\'t save!')
      end
  end