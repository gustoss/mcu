return function(req, res) 
    lres:type('application/json')
    res:send('{"location":'..config.location..'}')
end