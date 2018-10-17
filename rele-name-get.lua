return function(req, res) 
    local name = '{"names":['
    ..'"'..config.rele1..'",'
    ..'"'..config.rele2..'",'
    ..'"'..config.rele3..'",'
    ..'"'..config.rele4..'"]}'
  res:type('application/json')
  res:send(name)
  end