config = assert(loadfile('load_config.lua'))()

function get_body(req, field)
  print(req)
  print(field)
  print(string.gmatch(req.body, '"'..field..'":"([a-zA-Z0-9_!@#%$%%&%*%(%)%[%]{}\\/%?;:><%.=%+%-]+)"[,]*')(0))
  return string.gmatch(req.body, '"'..field..'":"([a-zA-Z0-9_!@#%$%%&%*%(%)%[%]{}\\/%?;:><%.=%+%-]+)"[,]*')(0)
end

function valid_otp(req, res)
  if config.passwd ~= nil then
    local otp = get_body(req, 'otp')
    if otp == nil or string.len(otp) == 0 then
      res:status(400)
      res:send('OTP must be passed!')
      return
    end
    return totp() == otp
  end
  return true
end

if config.ssid_station ~= nil and config.pwd_station ~= nil then
  print('STATION Mode...')
  assert(loadfile('totp.lua'))()
  local dis_wifi = 0
  function cbs_wifi_station() 
    pins = {
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

    server = assert(loadfile('server.lua'))()
    server:post('/rele', 'rele-post')
    server:get('/rele', 'rele-get')
    server:put('/description', 'description-put')
    server:get('/description', 'description-get')
    server:put('/location', 'location-put')
    server:get('/location', 'location-get')
    server:put('/name_dns', 'name_dns-put')
    server:get('/name_dns', 'name_dns-get')
    server:put('/rele/name', 'rele-name-put')
    server:get('/rele/name', 'rele-name-get')

    server:post('/set_pwd_otp', 'set_pwd_otp-post')
    server:post('/set_ssid_station', 'set_ssid_station-post')
    server:post('/set_pwd_station', 'set_pwd_station-post')
    server:post('/restart', 'restart-post')
  end

  function cbe_wifi_station()
    print(dis_wifi)
    dis_wifi = dis_wifi + 1
    if dis_wifi > 10 then
      config.ssid_station = nil
      pins[pin].config.pwd_station = nil
      local suc = assert(loadfile('save_config.lua'))()
      if suc then
        node.restart()
      end
    end
  end
  assert(loadfile('wifi_station.lua'))()
else
  print('AP Mode...')
  function cbs_wifi_ap()
    server = assert(loadfile('server.lua'))()
    server:post('/set_pwd_otp', 'set_pwd_otp-post')
    server:post('/set_ssid_station', 'set_ssid_station-post')
    server:post('/set_pwd_station', 'set_pwd_station-post')
    server:post('/restart', 'restart-post')
  end
  assert(loadfile('wifi_ap.lua'))()
end