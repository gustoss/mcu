-- Catch message from mqtt and switch the device 

return function(conn, data) 
  if type(data) == 'table' then
    local id = data.id
    local stat = data.user
    if not valid_field_json(id) and not valid_field_json(stat) and type(stat) == 'boolean' then
      local key = nil
      if config.d0 == id then key = 'd0'
      elseif config.d1 == id then key = 'd1'
      elseif config.d2 == id then key = 'd2'
      elseif config.d3 == id then key = 'd3'
      if key ~= nil then
        local gpStat = gpio.HIGH
        if stat then gpStat = gpio.LOW end
        local oldStat = false
        if pins[key].stat == gpio.LOW then oldStat = true end

        pins[key].stat = gpStat
        gpio.write(pins[key].pin, gpio.HIGH)

        if valid_field_json(data.plataform) then data.plataform = '-' end
        if not valid_field_json(config.topic_a) then -- Only publish after to set topic in /mqtt rest
          server:publish(config.topic_a, 
                        '{"id":"'..id..'","stat":'..stat..',"plataform":"'..data.plataform..'","hardware":"'..config.id..'","action":"switch"}', 1)
        end
      end
    end
  end
end