-- Configure of server and mDns
config = config or {}
local port = 80
local name_dns = 'darkdevicepointswitch'
if not valid_field_json(config.id) then
  name_dns = config.id
end
-- Control is object that will have all route to call function to route
control = {
  get = {},
  post = {},
  delete = {},
  patch = {},
  put = {}
}

mqttConnected = false
topics = {}
obj = {}

function obj:get(route, exc)
  control.get[route] = exc
end

function obj:post(route, exc)
  control.post[route] = exc
end

function obj:delete(route, exc)
  control.delete[route] = exc
end

function obj:patch(route, exc)
  control.patch[route] = exc
end

function obj:put(route, exc)
  control.put[route] = exc
end

function obj:subscribe(topic, exc, qos)
  if qos  == nil then qos = 0 end
  topics[topic] = exc
  if mqttConnected then
    broker:subscribe(topic, qos)
  end
end

function obj:publish(topic, message, qos)
  if qos  == nil then qos = 0 end
  if mqttConnected then
    broker:publish(topic, message, qos, 0, function(conn) print('Sent to '..topic) end)
  end
end

function obj:url()
  return 'http://'..name_dns..'.local:'..port
end

response = {
  _skt = nil,
  status = nil,
  type = nil
}

function response:new(skt)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self._skt = skt
  self._status = 200
  self._type = 'text/html; charset=utf-8'
  return o
end

function response:status(st)
  if st ~= nil then
    self._status = st
  end
end

function response:type(ty)
  if ty ~= nil then
    self._type = ty
  end
end

function response:send(body)
  if body == nil then body = '' end
  local r = 'HTTP/1.1 '..self._status..'\r\n'
          ..'Content-Type: '..self._type..'\r\n'
          ..'Content-Length: '..string.len(body)..'\r\n'
          ..'\r\n'..body
  self._skt:send(r)
end

function build_request(str)
  local req = {}
  req.method = str:match('^[a-zA-Z]+'):lower()
  req.path = str:match('/[a-zA-Z0-9_/]*')

  req.query = {}
  for key, value in str:gmatch('\\?([a-zA-Z0-9_]+)=([a-zA-Z0-9_\"]+)[&]*') do
      req.query[key] = value
  end
  
  req.header = {}
  for key, value in str:gmatch('([%w%-]+): ([%w%-%*/%.]+)') do
      req.header[key] = value
  end

  req.body = str:match('[%[%{].+[%]%}]$')
  return req
end

server = net.createServer(net.TCP)
server:listen(port, function(conn) 
  conn:on('receive', function(skt, payload) 
    local req = build_request(payload)
    local ok = false
    if req.body == nil then
      req.body = ''
      ok = true
    else
      ok, req.body = pcall(sjson.decode, req.body)
    end
    exc = control[req.method][req.path]
    local res = response:new(skt)
    if ok then
      if exc ~= nil and req.path ~= nil then
        assert(loadfile(exc..'.lua'))()(req, res)
      else
        res._status = 404
        res:send('Not Found')
      end
    else
      res._status = 400
      res:send()
    end
  end)
  conn:on("sent", function(skt, payload)
    skt:close()
  end)
end)

local mac = nil
if wifi.getmode() == wifi.STATION then
  mac = wifi.sta.getmac()
elseif wifi.getmode() == wifi.SOFTAP then
  mac = wifi.ap.getmac()
end

mdns.register(name_dns, {
  description='devicePointSwitch',
  service='http',
  port=port,
  id=config.id,
  platform='devicePointSwitch'
})

function conn() 
  if config.mqtt_server ~= nil then
    print('Connecting to MQTT ('..config.mqtt_server..')')
    local host = string.match(config.mqtt_server, '(.*):')
    local port = string.match(config.mqtt_server, ':(%d*)')
    broker:connect(host, port, 0, function(client) 
      print('Connected to MQTT ('..config.mqtt_server..')') 
      for key, value in pairs(topics) do
        broker:subscribe(key, 1)
      end
      mqttConnected = true

      if not valid_field_json(config.topic_i) then -- Only publish after to set topic in /mqtt rest
        server:publish(config.topic_i, 
                      '{"plataform":"devicesPointSwitch","hardware":"'..config.id..'","action":"mqtt","level":"info","message":"connected to MQTT"}', 0)
      end
    end, function(client, reason) print("Failed reason: "..reason) end)
  end
end

if not valid_field_json(config.user_mqtt) and valid_field_json(config.pwd_mqtt) then
  local id = config.id 
  if valid_field_json(id) then
    id = node.chipid()
  end
  broker = mqtt.Client(id, 240, config.user_mqtt, config.pwd_mqtt)
  broker:on('offline', function() tmr.create():alarm(60000, tmr.ALARM_SINGLE, conn) end)
  broker:on('message', function(conn, topic, data)
    exc = topics[topic]
    local ok = false 
    local body = ''
    ok, body = pcall(sjson.decode, data)
    if not ok then
      body = data
    end
    if exc ~= nil then
      assert(loadfile(exc..'.lua'))()(conn, data)
    end
  end)
  conn()
end

print('Server running, http://'..name_dns..'.local:'..port)
return obj