config = assert(loadfile('load_config.lua'))()

function valid_field_json(field) -- Valid fields loaded from file's config
  if type(field) == 'string' then
    return field == nil or string.len(field) == 0
  end
  return true
end

function valid_otp(req, res) -- Valid OTP from all request, need be called, not when field have to be fill
  if not valid_field_json(config.passwd) then
    local otp = req.body.otp
    if valid_field_json(otp) then
      res:status(400)
      res:send('OTP must be passed!')
      return
    end
    return totp() == otp
  end
  return true
end

-- This way is to connect to WIFI and run all application
if not valid_field_json(config.ssid_station) and not valid_field_json(config.pwd_station) then
  print('STATION Mode...')
  assert(loadfile('totp.lua'))()
  local dis_wifi = 0
  function cbs_wifi_station() 
    -- Control status of all pins
    pins = {
      r0 = {
        pin = 5,
        status = gpio.HIGH
      },
      r1 = {
        pin = 6,
        status = gpio.HIGH
      },
      r2 = {
        pin = 7,
        status = gpio.HIGH
      },
      r3 = {
        pin = 1,
        status = gpio.HIGH
      }
    }

    -- Put all port to HIGH level to shutdown rele
    for key, value in pairs(pins) do
      gpio.mode(pins[key].pin, gpio.OUTPUT)
      gpio.write(pins[key].pin, gpio.HIGH)
    end

    server = assert(loadfile('server.lua'))()
    server:put('/rele', 'rele-put') -- Set status of ports, that is really important
    server:get('/rele', 'rele-get') -- Get status each port, that I need it for control of application
    server:put('/id', 'id-put') -- Set for ID for this hardware, it's necessary for control of application
    server:get('/id', 'id-get') -- Get ID for this hardware

    -- server:put('/description', 'description-put') -- Set (blabla) some description for it, 
    -- server:get('/description', 'description-get') -- Get some description, this appear when app looking for in network for mDns
    -- server:put('/location', 'location-put') -- Set the location where will put it, for the logic of app, need it, but I have to think
    -- server:get('/location', 'location-get') -- Get location where NodeMCU is, for the logic of app, need it, but I have to think
    -- server:put('/name_dns', 'name_dns-put') -- Change name of mDns, need reset, but I don't need with pi
    -- server:get('/name_dns', 'name_dns-get') -- Get name of mDns, don't need more with pi 
    -- server:put('/rele/name', 'rele-name-put') -- Change name of port, don't need more with pi
    -- server:get('/rele/name', 'rele-name-get') -- Get all names of port, don't need more with pi

    server:put('/set_pwd_otp', 'set_pwd_otp-put') -- Set password for OTP, for any request must be passed
    server:put('/set_ssid_station', 'set_ssid_station-put') -- Set SSID for connect to WIFI
    server:put('/set_pwd_station', 'set_pwd_station-put') -- Set PASSWORD for connect to WIFI
    server:post('/restart', 'restart-post') -- When change some things, the NodeMCU must to be restart and OTP must be passed
  end

  -- Reset SSID and PWD of WIFI em open AP to set both again, 
  function cbe_wifi_station()
    print(dis_wifi)
    dis_wifi = dis_wifi + 1
    if dis_wifi > 10 then
      config.ssid_station = nil
      local suc = assert(loadfile('save_config.lua'))()
      if suc then
        node.restart()
      end
    end
  end
  assert(loadfile('wifi_station.lua'))()
else -- Here only in fisrt run, to configure PWD and SSID of WIFI
  print('AP Mode...')
  function cbs_wifi_ap()
    server = assert(loadfile('server.lua'))()
    -- server:post('/set_pwd_otp', 'set_pwd_otp-post') -- Set only in Station, don't need here
    server:put('/set_ssid_station', 'set_ssid_station-put')
    server:put('/set_pwd_station', 'set_pwd_station-put')
    server:post('/restart', 'restart-post')
  end
  assert(loadfile('wifi_ap.lua'))()
end