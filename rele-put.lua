return function(req, res) -- Controler STATUS of an pin to turn 'on' or 'off', send in status 'true' or 'false'
  if valid_otp(req, res) == false then
    return
  end
  local pin = req.body.name
  if valid_field_json(pin) or pins[pin] == nil then
    res:status(400)
    res:send('Name must be passed!')
    return
  end
  local status = req.body.status
  if type(status) ~= 'boolean' then
    res:status(400)
    res:send('Status must be passed like a boolean!')
    return
  end
  if status then
    pins[pin].status = gpio.LOW
  else
    pins[pin].status = gpio.HIGH
  end

  gpio.write(pins[pin].pin, pins[pin].status)
  res:send(pin..' is '..(status and 'on' or 'off'))
end