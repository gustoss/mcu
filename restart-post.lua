return function(req, res) -- Restart the hardware
    print('Restart!')
    res:send('Restart in 3 seconds!')
    tmr.create():alarm(3000, tmr.ALARM_SINGLE, node.restart)
  end