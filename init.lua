config = assert(loadfile('load_config.lua'))()

function valid_field_json(field) -- Valid fields loaded from file's config
  if type(field) == 'string' then
    return field == nil or string.len(field) == 0
  end
  return true
end

-- This way is to connect to WIFI and run all application
if not valid_field_json(config.ssid_station) and not valid_field_json(config.pwd_station) then
  print('STATION Mode...')
  -- assert(loadfile('totp.lua'))()
  local dis_wifi = 0
  -- Successful connection with WIFI Station
  function cbs_wifi_station() 
    -- Control state of all pins
    pins = {
      d0 = {
        pin = 5,
        stat = gpio.HIGH
      },
      d1 = {
        pin = 6,
        stat = gpio.HIGH
      },
      d2 = {
        pin = 7,
        stat = gpio.HIGH
      },
      d3 = {
        pin = 1,
        stat = gpio.HIGH
      }
    }

    -- Put all port to HIGH level to shutdown rele
    for key, value in pairs(pins) do
      gpio.mode(pins[key].pin, gpio.OUTPUT)
      gpio.write(pins[key].pin, gpio.HIGH)
    end

    server = assert(loadfile('server.lua'))()
    server:put('/id', 'id-put') -- Set for ID for this hardware, it's necessary for control of application
    server:get('/id', 'id-get') -- Get ID for this hardware
    server:put('/id/device', 'device-put') -- Set id for each port or device
    server:put('/all', 'all-put') -- Some command to all ports ***** Doing this

    server:put('/mqtt', 'mqtt-put') -- Set IP, User, Password and Topic for connect to MQTT
    server:put('/station', 'station-put') -- Set SSID and Password for connect to WIFI
    server:post('/restart', 'restart-post') -- When change configuration's things, the NodeMCU must to be restart
    
    if not valid_field_json(config.topic_s) then -- Only subscribe after to set topic in /mqtt rest
      server:subscribe(config.topic_s, 'switch-topic')
    end
  end

  -- Reset SSID and PWD of WIFI em open AP to set both again
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
    server:put('/station', 'station-put') -- Set SSID and Password for connect to WIFI
    server:post('/restart', 'restart-post') -- When change configuration's things, the NodeMCU must to be restart
  end
  assert(loadfile('wifi_ap.lua'))()
end