-- Save ID for this device

return function(req, res) 
  local stat = req.body.stat
  if type(stat) ~= 'boolean' then
    res:status(400)
    res:type('application/json')
    res:send('{"message":"State must be passed like a boolean!"}"')
    return
  end

  local gpStat = gpio.HIGH
  if stat then
    gpStat = gpio.LOW
  end
  -- Put all port to SOME level
  for key, value in pairs(pins) do
    pins[key].stat = gpStat
    gpio.write(pins[key].pin, gpStat)
  end
  res:status(204)
  res:send()
end