return function(req, res) -- Restart the hardware
    print('Restart!')
    res:status(204)
    res:send()
    tmr.create():alarm(1000, tmr.ALARM_SINGLE, node.restart)
  end