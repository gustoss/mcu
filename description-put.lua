return function(req, res) 
  local desc = get_body(req, 'description')
  if desc == nil or string.len(desc) == 0 then
    res:status(400)
    res:send('Description must be passed!')
    return
  end
  config.description = desc
  local suc = assert(loadfile('save_config.lua'))()
  if suc then
    res:send('Description saved!')
  else
    res:status(500)
    res:send('Description didn\'t save!')
  end
end