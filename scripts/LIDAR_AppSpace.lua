print"start Script"

--luacheck: globals Viewer Communication provider DataProcessing utils removeScansAndShapes showOwnScans showSlaveScans
--luacheck: globals calibrate setCutOffDistance
DataProcessing = require("DataProcessing")
Viewer = require("ViewerModule")
Communication = require("Communication")
provider = Scan.Provider.Scanner.create()
utils = require("utils")

-- @removeScansAndShapes():void
function removeScansAndShapes()
  provider:deregister("OnNewScan", Viewer.showScans)
  Communication.stopReceiving()
  Viewer.Viewer:remove("foundTriangle")
end

--@showMasterScans():void
function showOwnScans()
  removeScansAndShapes()
  print("show own scans called")
  provider:register("OnNewScan", Viewer.showScans)
end

--@showSlaveScans():void
function showSlaveScans()
  removeScansAndShapes()
  print"show slave scans called"
    Communication.receiveScans(Viewer.showScans)
end

--@calibrate():void
function calibrate()
  Communication.stopReceiving()
  provider:deregister("OnNewScan", Viewer.showScans)

  local edgeHitFilter = Scan.EchoFilter.create()
  edgeHitFilter:setType("Last")

  local scan = edgeHitFilter:filter(Viewer.lastScan:clone())
  local cloud = Viewer.transformer:transformToPointCloud(scan)
  
  cloud = DataProcessing.removePointsBeyond(cloud, utils.cutOffDistance)
  local firstPoint, firstPointIndex, secondPoint, secondPointIndex, distance, thirdPoint, thirdPointIndex, secondDistance
  = DataProcessing.getTwoCornersAndEdgeLength(cloud)
  
  local firstX, firstY = firstPoint:getXY()
  local secondX, secondY = secondPoint:getXY()
  if thirdPoint == nil then
    thirdPoint = DataProcessing.getThirdCorner(firstPoint, secondPoint)
  end
  local thirdX, thirdY = thirdPoint:getXY()
  
  print(
    "FirstPoint            X:", firstX, "Y:", firstY,
    "\nSecondPoint           X:", secondX, "Y:", secondY,
    "\nCalculated ThirdPoint X:", thirdX, "Y:", thirdY,
    "\nEdge Lengths:", distance, secondDistance)
  
  cloud:setIntensity({firstPointIndex, secondPointIndex, thirdPointIndex}, 0.3)
  local points = {Point.create(firstPoint:getXY()), Point.create(secondPoint:getXY()), Point.create(thirdPoint:getXY())}
  local triangle = Shape.createPolyline(points, true)
  Viewer.Viewer:addShape(triangle, nil, "foundTriangle")
  Viewer.PointCloudViewer(cloud)
end

--@setCutOffDistance(distance: int):nil
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
  setCutOffDistance(utils.cutOffDistance)
end
Script.register("Engine.OnStarted", main)