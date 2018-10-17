config = config or {}
time = time or 3
time = time * 1000
cfg = {
  ssid = config.ssid_ap or 'NodeMCU',
  pwd = config.pwd_ap or 'nodemcu',
  auth = wifi.OPEN,
  max = 1
}
wifi.setmode(wifi.SOFTAP)
wifi.ap.config(cfg)
if cbs_wifi_ap ~= nil then
  tmr.create():alarm(time, tmr.ALARM_SINGLE, cbs_wifi_ap)
end