ssid = config.ssid_station
pwd = config.pwd_station

if ssid ~= nil and pwd ~= nil then
    time = time or 2
    time = time * 1000

    wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T) 
    print('Connection to AP('..T.SSID..') established!')
    print('Waiting for IP address...')
    end)
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T) 
    print('Wifi connection is ready! IP address is: '..T.IP)
    print('Startup will resume momentarily, you have '..time..' miliseconds to abort.')
    print('Waiting...') 
    if cbs_wifi_station ~= nil then
        tmr.create():alarm(time, tmr.ALARM_SINGLE, cbs_wifi_station)
    end
    end)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
    if cbe_wifi_station ~= nil then
        cbe_wifi_station(T)
    end
    end)

    print('Connecting to WiFi access point...')
    wifi.setmode(wifi.STATION)
    wifi.sta.config({ssid=ssid, pwd=pwd})
else
    print('There aren\'t SSID or/and PASSWORD!')
end