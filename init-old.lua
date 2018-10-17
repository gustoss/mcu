
if config.ssid_station ~= nil and config.pwd_station ~= nil then
  print('STATION Mode...')
  local dis_wifi = 0
  access:connect_station(function()
    server = dofile('server.lc')(config, access:get_mac())
    totp = dofile('totp.lc')(config)
    local pins = {
      [config.rele1] = {
        pin = 5,
        status = gpio.HIGH
      },
      [config.rele2] = {
        pin = 6,
        status = gpio.HIGH
      },
      [config.rele3] = {
        pin = 7,
        status = gpio.HIGH
      },
      [config.rele4] = {
        pin = 1,
        status = gpio.HIGH
      }
    }

    for key, value in pairs(pins) do
      gpio.mode(pins[key].pin, gpio.OUTPUT)
      gpio.write(pins[key].pin, gpio.HIGH)
    end

    server:post('/rele', function(req, res)
      if valid_otp(req, res, config.passwd, totp:totp()) == false then
        return
      end
      local pin = get_body(req, 'name')
      print(pin)
      if pin == nil or string.len(pin) == 0 or pins[pin] == nil then
        res:status(400)
        res:send('Name must be passed!')
        return
      end
      local status = get_body(req, 'status')
      if status == nil or string.len(status) == 0 then
        res:status(400)
        res:send('Status must be passed!')
        return
      end
      status = status:lower()
      if status == 'on' then
        pins[pin].status = gpio.LOW
      elseif status == 'off' then
        pins[pin].status = gpio.HIGH
      else
        res:status(400)
        res:send('Status must be On or Off!')
        return
      end

      gpio.write(pins[pin].pin, pins[pin].status)
      res:send(pin..' '..status)
    end)

    server:get('/rele', function(req, res)
      local st = function (s)
        if s == gpio.HIGH then
          return 'Off'
        end
        return 'On'
      end
      
      local name = '['
        ..'{"name":"'..config.rele1..'","status":"'..st(pins[config.rele1].status)..'"},'
        ..'{"name":"'..config.rele2..'","status":"'..st(pins[config.rele2].status)..'"},'
        ..'{"name":"'..config.rele3..'","status":"'..st(pins[config.rele3].status)..'"},'
        ..'{"name":"'..config.rele4..'","status":"'..st(pins[config.rele4].status)..'"}]'
      res:type('application/json')
      res:send(name)
    end)

    server:put('/description', function(req, res)
      local desc = get_body(req, 'description')
      if desc == nil or string.len(desc) == 0 then
        res:status(400)
        res:send('Description must be passed!')
        return
      end
      config.description = desc
      configuration = dofile('configuration.lc')
      local suc = configuration.save_config(config)
      file.close('configuration.lc')
      if suc then
        res:send('Description saved!')
      else
        res:status(500)
        res:send('Description didn\'t save!')
      end
    end)

    server:get('/description', function(req, res)
      res:type('application/json')
      res:send('{"description":'..config.description..'}')
    end)

    server:put('/location', function(req, res)
      local loc = get_body(req, 'location')
      if loc == nil or string.len(loc) == 0 then
        res:status(400)
        res:send('Location must be passed!')
        return
      end
      config.location = loc
      configuration = dofile('configuration.lc')
      local suc = configuration.save_config(config)
      file.close('configuration.lc')
      if suc then
        res:send('Location saved!')
      else
        res:status(500)
        res:send('Location didn\'t save!')
      end
    end)

    server:get('/location', function(req, res)
      res:type('application/json')
      res:send('{"location":'..config.location..'}')
    end)

    server:put('/name_dns', function(req, res)
      local loc = get_body(req, 'name_dns')
      if loc == nil or string.len(loc) == 0 then
        res:status(400)
        res:send('Name DNS must be passed!')
        return
      end
      config.name_dns = loc
      configuration = dofile('configuration.lc')
      local suc = configuration.save_config(config)
      file.close('configuration.lc')
      if suc then
        res:send('Name DNS saved!')
      else
        res:status(500)
        res:send('Name DNS didn\'t save!')
      end
    end)

    server:get('/name_dns', function(req, res)
      res:type('application/json')
      res:send('{"name_dns":'..config.name_dns..'}')
    end)

    server:put('/rele/name', function(req, res)
      local rele = nil
      local name = get_body(req, 'old_name')
      if name ~= nil then
        if config.rele1 == name then rele = 'rele1'
        elseif config.rele2 == name then rele = 'rele2'
        elseif config.rele3 == name then rele = 'rele3'
        elseif config.rele4 == name then rele = 'rele4'
        end
        if rele == nil then
          res:status(400)
          res:send('Old name must be passed!')
          return
        end

        local new_name = get_body(req, 'new_name')
        if new_name == nil or string.len(new_name) == 0 then
          res:status(400)
          res:send('New name must be passed!')-- else
  print('AP Mode...')
  access:connect_ap(function()
    server = require("server")(config, access:get_mac())
    config_route(server)
  end)
end
          return
        end

        pins[new_name] = pins[name]
        pins[name] = nil
        config[rele] = new_name

        configuration = dofile('configuration.lc')
        local suc = configuration.save_config(config)
        file.close('configuration.lc')
        if suc then
          res:send('Name saved!')
        else
          res:status(500)
          res:send('Internal error!')
        end
        return
      end
      res:status(400)
      res:send('Old name must be passed!')
    end)

    server:get('/rele/name', function(req, res)
      local name = '{"names":['
        ..'"'..config.rele1..'",'
        ..'"'..config.rele2..'",'
        ..'"'..config.rele3..'",'
        ..'"'..config.rele4..'"]}'
      res:type('application/json')
      res:send(name)
    end)

    config_route(server)
  end, function()
    print(dis_wifi)
    dis_wifi = dis_wifi + 1
    if dis_wifi > 10 then
      config.ssid_station = nil
      pins[pin].config.pwd_station = nil
      configuration = dofile('configuration.lc')
      local suc = configuration.save_config(config)
      file.close('configuration.lc')
      if suc then
        node.restart()
      end
    end
  end)
else
  print('AP Mode...')
  access:connect_ap(function()
    server = require("server")(config, access:get_mac())
    config_route(server)
  end)
end

function config_route(server)
  server:post('/set_ssid_station', function(req, res)
    local ssid = get_body(req, 'ssid')
    if ssid == nil or string.len(ssid) == 0 then
      res:status(400)
      res:send('SSID must be passed!')
      return
    end
    config.ssid_station = ssid
    configuration = dofile('configuration.lc')
    local suc = configuration.save_config(config)
    file.close('configuration.lc')
    if suc then
      res:send('SSID Station saved!')
    else
      res:status(500)
      res:send('SSID Station didn\'t save!')
    end
  end)

  server:post('/set_pwd_station', function(req, res)
    locfig.passwd, totp:totp()) == false then
      return
    end
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
  end)

  server:post('/restart', function(req, res)
    print('Restart!')
    res:send('Restart '..config.description..' in 5 seconds!')
    tmr.create():alarm(5000, tmr.ALARM_SINGLE, node.restart)
  end)

  file.close('wifi_access.lc')
  access = nil  
  file.close('server.lc')
  server = nil
  collectgarbage()
  file.close('init.lua')
endpwd = get_body(req, 'pwd')
    if fig.passwd, totp:totp()) == false then
      return
    end
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
  end)

  server:post('/restart', function(req, res)
    print('Restart!')
    res:send('Restart '..config.description..' in 5 seconds!')
    tmr.create():alarm(5000, tmr.ALARM_SINGLE, node.restart)
  end)

  file.close('wifi_access.lc')
  access = nil  
  file.close('server.lc')
  server = nil
  collectgarbage()
  file.close('init.lua')
end == nil or string.len(pwd) == 0 then
      rfig.passwd, totp:totp()) == false then
      return
    end
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
  end)

  server:post('/restart', function(req, res)
    print('Restart!')
    res:send('Restart '..config.description..' in 5 seconds!')
    tmr.create():alarm(5000, tmr.ALARM_SINGLE, node.restart)
  end)

  file.close('wifi_access.lc')
  access = nil  
  file.close('server.lc')
  server = nil
  collectgarbage()
  file.close('init.lua')
endstatus(400)
      rfig.passwd, totp:totp()) == false then
      return
    end
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
  end)

  server:post('/restart', function(req, res)
    print('Restart!')
    res:send('Restart '..config.description..' in 5 seconds!')
    tmr.create():alarm(5000, tmr.ALARM_SINGLE, node.restart)
  end)

  file.close('wifi_access.lc')
  access = nil  
  file.close('server.lc')
  server = nil
  collectgarbage()
  file.close('init.lua')
endsend('PASSWORD must be passed!')
      rfig.passwd, totp:totp()) == false then
      return
    end
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
  end)

  server:post('/restart', function(req, res)
    print('Restart!')
    res:send('Restart '..config.description..' in 5 seconds!')
    tmr.create():alarm(5000, tmr.ALARM_SINGLE, node.restart)
  end)

  file.close('wifi_access.lc')
  access = nil  
  file.close('server.lc')
  server = nil
  collectgarbage()
  file.close('init.lua')
endrn
    endfig.passwd, totp:totp()) == false then
      return
    end
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
  end)

  file.close('wifi_access.lc')
  access = nil  
  file.close('server.lc')
  server = nil
  collectgarbage()
  file.close('init.lua')
end
    config.pwd_station = pwd
    configuration = dofile('configuration.lc')
    local suc = configuration.save_config(config)
    file.close('configuration.lc')
    if suc then
      res:send('PASSWORD Station saved!')
    else
      res:status(500)
      res:send('PASSWORD Station didn\'t save!')
    end
  end)

  server:post('/set_pwd_otp', function(req, res)
    if valid_otp(req, res, config.passwd, totp:totp()) == false then
      return
    end
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
  end)

  server:post('/restart', function(req, res)
    print('Restart!')
    res:send('Restart '..config.description..' in 5 seconds!')
    tmr.create():alarm(5000, tmr.ALARM_SINGLE, node.restart)
  end)

  file.close('wifi_access.lc')
  access = nil  
  file.close('server.lc')
  server = nil
  collectgarbage()
  file.close('init.lua')
end
      