print"start Script"

-- luacheck: globals Viewer Communication provider DataProcessing
DataProcessing = require("DataProcessing")
Viewer = require("ViewerModule")
Communication = require("Communication")
provider = Scan.Provider.Scanner.create()

--@showMasterScans():void
function showOwnScans()
  Communication.stopReceiving()
  print("show own scans called")
  provider:register("OnNewScan", Viewer.showScans)
end

--@showSlaveScans():void
function showSlaveScans()
  provider:deregister("OnNewScan", Viewer.showScans)
  print"show slave scans called"
    Communication.receiveScans(Viewer.showScans)
end

--@calibrate():void
function calibrate()
  Communication.stopReceiving()
  provider:deregister("OnNewScan", Viewer.showScans)
  local cloud = Viewer.lastScan:clone()
  cloud = DataProcessing.removePointsBeyond(cloud, 500)
  Viewer.PointCloudViewer(cloud)
end

local function main()
  Script.serveFunction("LIDAR_AppSpace.showSlaveScans", "showSlaveScans")
  Script.serveFunction("LIDAR_AppSpace.showOwnScans", "showOwnScans")
  Script.serveFunction("LIDAR_AppSpace.calibrate", "calibrate")

  local Triangle = require("Triangle")
  local cloud = Triangle.createTwoLines()
  --local cloud = Triangle.createOneLine()
  --local cloud = Triangle.createOneLineWithFirstPointAsClosestPoint()
  local changedCloud = DataProcessing.removePointsBeyond(cloud, 1000)
  print(DataProcessing.getTwoCornersAndEdgeLength(changedCloud))
  Viewer.PointCloudViewer(changedCloud)
 
  local firstPoint, secondPoint, distance = DataProcessing.getTwoCornersAndEdgeLength(changedCloud)
  local firstX, firstY = firstPoint:getXY()
  local secondX, secondY = secondPoint:getXY()
  print(firstX, firstY, secondX, secondY, distance)
  local thirdPoint = DataProcessing.getThirdCorner(Point.create(0,0),Point.create(150, 0), 150)
  local thirdX, thirdY = thirdPoint:getXY()
  print("Dritter Punkt: ", thirdX, thirdY)
  Viewer.PointCloudViewer(changedCloud)

  --scanProvider = Scan.Provider.Scanner.create()
  --Communication.sendScans(scanProvider, "192.168.1.20") --Set the right IP!

  --Communication.receiveScans(Viewer.showScans)
  --showOwnScans()
end
Script.register("Engine.OnStarted", main)