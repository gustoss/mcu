return function(req, res) 
    res:type('application/json')
    res:send('{"description":'..config.description..'}')
  end