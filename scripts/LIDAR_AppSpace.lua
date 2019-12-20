print"start Script"

-- luacheck: globals Viewer Communication provider DataProcessing utils
DataProcessing = require("DataProcessing")
Viewer = require("ViewerModule")
Communication = require("Communication")
provider = Scan.Provider.Scanner.create()
utils = require("utils")

--@showMasterScans():void
function showOwnScans()
  provider:deregister("OnNewScan", Viewer.showScans)
  Communication.stopReceiving()
  print("show own scans called")
  provider:register("OnNewScan", Viewer.showScans)
end

--@showSlaveScans():void
function showSlaveScans()
  provider:deregister("OnNewScan", Viewer.showScans)
  Communication.stopReceiving()
  print"show slave scans called"
    Communication.receiveScans(Viewer.showScans)
end

--@calibrate():void
function calibrate()
  Communication.stopReceiving()
  provider:deregister("OnNewScan", Viewer.showScans)
  ---[[
  local medianFilter = Scan.MedianFilter.create()
  medianFilter:setType("2d")
  --]]
  edgeHitFilter = Scan.EchoFilter.create()
  edgeHitFilter:setType("Last")

  --local scan = edgeHitFilter:filter(Viewer.lastScan:clone())
  --local scan = Viewer.lastScan
  --local  scan = medianFilter:filter()
  local scan = edgeHitFilter:filter(Viewer.lastScan:clone())
  local cloud = Viewer.transformer:transformToPointCloud(scan)
  
  cloud = DataProcessing.removePointsBeyond(cloud, utils.cutOffDistance)
  local firstPoint, firstPointIndex, secondPoint, secondPointIndex, distance, thirdPoint, thirdPointIndex, secondDistance
  = DataProcessing.getTwoCornersAndEdgeLength(cloud)
  
  local firstX, firstY = firstPoint:getXY()
  local secondX, secondY = secondPoint:getXY()
  
  cloud:setIntensity({firstPointIndex, secondPointIndex, thirdPointIndex}, 0.3)
  
  print(distance)
  print("FirstPoint X:", firstX, "Y:", firstY,"SecondPoint X:", secondX, "Y:", secondY, "Edge Lengths:", distance, secondDistance)
  Viewer.PointCloudViewer(cloud)
  
  if thirdPoint == nil then
    thirdPoint = DataProcessing.getThirdCorner(firstPoint, secondPoint)
  end
  local thirdX, thirdY = thirdPoint:getXY()
  print("Calculated ThirdPoint X:", thirdX, "Y:" , thirdY)
end

function setCutOffDistance(distance)
    local _
    utils.cutOffDistance = distance * 10
  Viewer.Viewer:remove("cutOffDistanceShape")
  Viewer.Viewer:addShape(Shape.createCircle(Point.create(0,0), utils.cutOffDistance), _, "cutOffDistanceShape")
  Viewer.Viewer:present()
end


local function main()
  Script.serveFunction("LIDAR_AppSpace.showSlaveScans", "showSlaveScans")
  Script.serveFunction("LIDAR_AppSpace.showOwnScans", "showOwnScans")
  Script.serveFunction("LIDAR_AppSpace.calibrate", "calibrate")
  Script.serveFunction("LIDAR_AppSpace.setCutOffDistance", "setCutOffDistance", "int")
  --[[
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
  --]]
  --scanProvider = Scan.Provider.Scanner.create()
  --Communication.sendScans(scanProvider, "192.168.1.20") --Set the right IP!

  --Communication.receiveScans(Viewer.showScans)
  --showOwnScans()
end
Script.register("Engine.OnStarted", main)