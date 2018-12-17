local config = {}
if file.open('config.json', 'r+') then
  local str = ''
  local s = file.readline()
  while s ~= nil do
    str = str..s
    s = file.readline()
  end
  file.close()
  return sjson.decode(str)
end
file.close()
return {}
