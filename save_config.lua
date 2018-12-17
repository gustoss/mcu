-- Save configuration to file, everything in CONFIG object will be save to file
if config ~= nil then
  if file.open('config.json', 'w+') then
    ok, json = pcall(sjson.encode, config)
    if ok then
      file.write(json)
    end
    file.close()
    return ok
  end
end
return false