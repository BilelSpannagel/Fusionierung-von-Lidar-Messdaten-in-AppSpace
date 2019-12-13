local Communication = {}

socket = UDPSocket.create()

--@receiveScans(_scanner: Scann.Provider.Scanner, masterIP: String):void
function Communication.receiveScans(_handleOnReceive)
  -- luacheck: globals receiveHandle
  receiveHandle = _handleOnReceive
  --@hndOnReceive(data, ipaddess, port): void
  function hndOnReceive(data,ipaddress,port)
    local scan = Object.deserialize(data, "MSGPACK")
    receiveHandle(scan)
  end

  UDPSocket.bind(socket, 2111)
  UDPSocket.register(socket, "OnReceive", "hndOnReceive")
end

--@sendScans(_scanner: Scann.Provider.Scanner, masterIP: String):void
function Communication.sendScans(_scanProvider, _masterIP)
  function handleOnNewScan(scan)
    local counter = Scan.getNumber(scan)
    print("Sending Scan: " .. counter)
    local scanObj = Object.serialize(scan, "MSGPACK")
    UDPSocket.transmit(socket, _masterIP, 2111, scanObj)
  end
  -- "192.168.1.10"

  _scanProvider:register("OnNewScan", handleOnNewScan)
  --_scanProvider:start()
  print "Scanner started"
end

return Communication