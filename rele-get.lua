return function(req, res) 
    local st = function (s)
        if s == gpio.HIGH then
            return 'Off'
        end
        return 'On'
    end
    
    local name = '['
    ..'{"name":"'..config.rele1..'","status":"'..st(pins[config.rele1].status)..'"},'
    ..'{"name":"'..config.rele2..'","status":"'..st(pins[config.rele2].status)..'"},'
    ..'{"name":"'..config.rele3..'","status":"'..st(pins[config.rele3].status)..'"},'
    ..'{"name":"'..config.rele4..'","status":"'..st(pins[config.rele4].status)..'"}]'
    res:type('application/json')
    res:send(name)
  end