Script.disableGarbageCollectionByEngine()
local Communication = {}

local socket = UDPSocket.create()

--@receiveScans(_scanner: Scann.Provider.Scanner, masterIP: String):void
function Communication.receiveScans(handleOnReceive)
  print("Waiting for new Scans to arrive.")
  UDPSocket.bind(socket, 2111)
  UDPSocket.register(socket, "OnReceive", "hndOnReceive")

  local scanViewer = View.create("scanViewer")

  
  scan = Object.deserialize(data, "MSGPACK")
  handleOnNewScan(scan)
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