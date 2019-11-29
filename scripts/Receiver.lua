local receiverModule = {}

Script.disableGarbageCollectionByEngine()

scanViewer = View.create("scanViewer")

local scanViewDecorations = {}

scanViewDecorations["0"] = View.ScanDecoration.create()
scanViewDecorations["1"] = View.ScanDecoration.create()
scanViewDecorations["-1"] = View.ScanDecoration.create()
scanViewDecorations["-2"] = View.ScanDecoration.create()

View.ScanDecoration.setColor(scanViewDecorations["0"], 255, 0, 0)     --red
View.ScanDecoration.setColor(scanViewDecorations["1"], 0, 255, 0)     --green
View.ScanDecoration.setColor(scanViewDecorations["-1"], 0, 0, 255)    --blue
View.ScanDecoration.setColor(scanViewDecorations["-2"], 255, 165, 0)  --orange

View.ScanDecoration.setPointSize(scanViewDecorations["0"], 3)
View.ScanDecoration.setPointSize(scanViewDecorations["1"], 3)
View.ScanDecoration.setPointSize(scanViewDecorations["-1"], 3)
View.ScanDecoration.setPointSize(scanViewDecorations["-2"], 3)



local numScans = 0
local scans = {}

--@(p1:type):returnType
local function drawScans()
  scanViewer:clear()
  local cloudDeco = View.PointCloudDecoration.create()
  cloudDeco:setIntensityColormap(1)
  cloudDeco:setIntensityRange(0,1)
  
  View.addScan(scanViewer, scans[0], scanViewDecorations["0"])
  View.addScan(scanViewer, scans[1], scanViewDecorations["1"])
  View.addScan(scanViewer, scans[2], scanViewDecorations["-1"])
  View.addScan(scanViewer, scans[3], scanViewDecorations["-2"])
  

  --scanViewer:addScan(scans[0], scanViewDecorations[string.format("%.0f", currentLayer)], "scan_".. currentLayer)
  --[[
  scanViewer:addPointCloud(scans[1], cloudDeco)
  scanViewer:addPointCloud(scans[2], cloudDeco)
  scanViewer:addPointCloud(scans[3], cloudDeco)
  pdeco = View.PointCloudDecoration.create()
  pdeco:setIntensityColormap(1)
  pdeco:setIntensityRange(0,65536)
  pdeco:setPointSize(5)
  --]]
  
  scanViewer:present()
end


function receiverModule.Receiver()

  
  socket = UDPSocket.create()
  UDPSocket.bind(socket, 2111)
  UDPSocket.register(socket, "OnReceive", "handleOnReceive")
  
  --@handleOnReceive(data:binary,ipaddress:string,port:int)
  function handleOnReceive(data,ipaddress,port)
    --DESERIALIZE;TRANSFORM; ADD
    local transformer = Scan.Transform.create()
    scan = Object.deserialize(data, "MSGPACK")

     local cnt = Scan.getNumber(scan)
    if cnt % 100 == 0 then
      if numScans ~= 100 then
        print("Missing Scans = " .. numScans)
      end
      print("Scan: " .. cnt)
      numScans = 0
    end
    --scans[numScans]  = transformer:transformToPointCloud(scan)
    scans[numScans] = scan
    numScans = numScans + 1
    --Update the View every 4 scans and reset
    
    
    if numScans % 4 == 0 then
      numScans = 0
      drawScans();
      scans = {}
    end
  end


end
Script.register("Engine.OnStarted", main)
-- serve API in global scope