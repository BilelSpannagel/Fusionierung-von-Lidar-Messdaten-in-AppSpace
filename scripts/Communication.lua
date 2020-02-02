local Communication = {}

--luacheck: globals handle receiveHandle handleOnNewScan
Communication.socket = UDPSocket.create()
Communication.isMaster = false
Communication.masterIP = "192.168.1.10" --default IP
UDPSocket.bind(Communication.socket, 2111)

--@handle(data: String):void
function handle(data)
  local scan = Object.deserialize(data, "MSGPACK")
  receiveHandle(scan)
end
  
--@receiveScans(_handleOnReceive: Handle):void
function Communication.receiveScans(_handleOnReceive)
  receiveHandle = _handleOnReceive
  UDPSocket.register(Communication.socket, "OnReceive", "handle")
end

--@stopReceiving():void
function Communication.stopReceiving()
  Communication.socket:deregister("OnReceive", "handle")
end

--@sendScans(_scanner: Scann.Provider.Scanner, masterIP: String):void
function Communication.sendScans(_scanProvider)
  function handleOnNewScan(scan)
    local counter = Scan.getNumber(scan)
    print("Sending Scan: " .. counter)
    local scanObj = Object.serialize(scan, "MSGPACK")
    UDPSocket.transmit(Communication.socket, Communication.masterIP, 2111, scanObj)
  end
  print("start sending scan to Master with IP: ", Communication.masterIP)
  _scanProvider:register("OnNewScan", handleOnNewScan)
end

return Communication