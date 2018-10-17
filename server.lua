-- Configuração do serviço e DNS
config = config or {}
local port = 80
local name_dns = config.name_dns or 'darknodemcu'
control = {
  get = {},
  post = {},
  delete = {},
  patch = {},
  put = {}
}

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

function obj:url()
  return 'http://'..name_dns..'.local:'..port
end

response = {
  _skt = nil,
  status = nil,
  type = nil
}

function response:new (skt)
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
  local r = 'HTTP/1.1 '..self._status..'\r\n'
          ..'Content-Type: '..self._type..'\r\n'
          ..'Content-Length: '..string.len(body)..'\r\n'
          ..'\r\n'..body
  self._skt:send(r)
end

function build_request(str)
  local req = {}
  req.method = string.match(str, '^[a-zA-Z]+'):lower()
  req.path = string.match(str, '/[a-zA-Z0-9_/]*')

  req.query = {}
  for key, value in string.gmatch(str, '\\?([a-zA-Z0-9_]+)=([a-zA-Z0-9_\"]+)[&]*') do
      req.query[key] = value
  end
  
  req.header = {}
  for key, value in string.gmatch(str, '[%r%n]*([a-zA-Z0-9%-]+): ([a-zA-Z0-9%./%*,(%s);]+)') do
      req.header[key] = value
  end

  req.body = string.match(str, '{[a-zA-Z0-9_\'":%[%]{}%-,%s%(%)%+@!#%$&%*%%;%?%.><|/\\]+}$')
  return req
end

server = net.createServer(net.TCP)
server:listen(port, function(conn) 
  conn:on('receive', function(skt, payload) 
    local req = build_request(payload)
    if req.body == nil then
      req.body = ''
    end
    exc = control[req.method][req.path]
    local res = response:new(skt)
    if exc ~= nil and req.path ~= nil then
      assert(loadfile(exc..'.lua'))()(req, res)
    else
      res._status = 404
      res:send(req.path..' Not Found')
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
  description=config.description or 'NodeMCU',
  service='http',
  port=80,
  location=config.location or 'Room',
  mac=mac or ':'
})
print('Server running, http://'..name_dns..'.local:'..port)
return obj