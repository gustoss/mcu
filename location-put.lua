return function(req, res) 
  local loc = get_body(req, 'location')
  if loc == nil or string.len(loc) == 0 then
      res:status(400)
      res:send('Location must be passed!')
      return
  end
  config.location = loc
  local suc = assert(loadfile('save_config.lua'))()
  if suc then
      res:send('Location saved!')
  else
      res:status(500)
      res:send('Location didn\'t save!')
  end
end