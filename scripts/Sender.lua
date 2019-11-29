local senderModule = {]}

Script.disableGarbageCollectionByEngine()

function senderModule.Sender()
  -- luacheck: globals handleOnNewScan
  function handleOnNewScan(scan)
    counter = Scan.getNumber(scan)
    print("Sending Scan: " .. counter)
    scanObj = Object.serialize(scan, "MSGPACK")
    UDPSocket.transmit(socket, "192.168.1.10", 2111, scanObj)
  end

  -- write app code in local scope, using API
  socket = UDPSocket.create()
  scanProvider = Scan.Provider.Scanner.create()
  Scan.Provider.Scanner.register(scanProvider, "OnNewScan", handleOnNewScan)
  scanProvider:start()
  
  
end
Script.register("Engine.OnStarted", main)
-- serve API in global scope
