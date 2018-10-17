return function(req, res) 
    res:type('application/json')
    res:send('{"name_dns":'..config.name_dns..'}')
end