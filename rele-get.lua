return function(req, res) -- Get STATUS of all pin
  local st = function (s)
    if s == gpio.HIGH then
      return 'false'
    end
    return 'true'
  end
  
  local name = '['
  ..'{"name":"r1","status":'..st(pins.r0.status)..'},'
  ..'{"name":"r2","status":'..st(pins.r1.status)..'},'
  ..'{"name":"r3","status":'..st(pins.r2.status)..'},'
  ..'{"name":"r4","status":'..st(pins.r3.status)..'}]'
  res:type('application/json')
  res:send(name)
end