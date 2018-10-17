return function(req, res) 
  if valid_otp(req, res) == false then
    return
  end
  local pin = get_body(req, 'name')
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
end