return function(req, res) 
    print('Restart!')
    res:send('Restart '..config.description..' in 3 seconds!')
    tmr.create():alarm(3000, tmr.ALARM_SINGLE, node.restart)
  end