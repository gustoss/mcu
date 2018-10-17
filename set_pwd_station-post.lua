return function(req, res) 
      local pwd = get_body(req, 'pwd')
      if pwd == nil or string.len(pwd) == 0 then
        res:status(400)
        res:send('PASSWORD must be passed!')
        return
      end
      print(pwd)
      config.passwd = pwd
      configuration = dofile('configuration.lc')
      local suc = configuration.save_config(config)
      file.close('configuration.lc')
      if suc then
        res:send('PASSWORD OTP saved!')
      else
        res:status(500)
        res:send('PASSWORD OTP didn\'t save!')
      end
  end