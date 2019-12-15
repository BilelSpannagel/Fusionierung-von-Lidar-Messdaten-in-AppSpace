local Communication = {}

socket = UDPSocket.create()
UDPSocket.bind(socket, 2111)

--@receiveScans(_handleOnReceive: Handle):void

function handle(data,ipaddress,port)
  local scan = Object.deserialize(data, "MSGPACK")
  receiveHandle(scan)
end

function Communication.receiveScans(_handleOnReceive)
  -- luacheck: globals receiveHandle
  
  receiveHandle = _handleOnReceive
  --@hndOnReceive(data, ipaddess, port): void
  UDPSocket.register(socket, "OnReceive", "handle")
  print "Socket bound"
end

--@functionname(p1:type):returnType
function Communication.stopReceiving()
  socket:deregister("OnReceive", "handle")
end


--@sendScans(_scanner: Scann.Provider.Scanner, masterIP: String):void
function Communication.sendScans(_scanProvider, _masterIP)
  function handleOnNewScan(scan)
    local counter = Scan.getNumber(scan)
    print("Sending Scan: " .. counter)
    local scanObj = Object.serialize(scan, "MSGPACK")
    UDPSocket.transmit(socket, _masterIP, 2111, scanObj)
  end
  _scanProvider:register("OnNewScan", handleOnNewScan)
  --_scanProvider:start()
end

return Communication