print"start Script"

--luacheck: globals Viewer Communication provider DataProcessing utils removeScansAndShapes showOwnScans showSlaveScans 
--luacheck: globals calibrate setCutOffDistance showMergedScans
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
  
  cloud:setIntensity({firstPointIndex, secondPointIndex, thirdPointIndex}, 0.3)
  
  if thirdPoint == nil then
    thirdPoint = DataProcessing.getThirdCorner(firstPoint, secondPoint)
  end

  local d1 = Point.create(firstPoint:getX(),firstPoint:getY(),76.0)
  local d2 = Point.create(secondPoint:getX(),secondPoint:getY(),76.0)
  local d3 = Point.create(thirdPoint:getX(),thirdPoint:getY(),76.0)
  local d4 = Point.create(firstPoint:getX(),firstPoint:getY(),0.0)
  local d5 = Point.create(secondPoint:getX(),secondPoint:getY(),0.0)
  local d6 = Point.create(thirdPoint:getX(),thirdPoint:getY(),0.0)
  local pp = {d1,d2,d3,d1,d4,d5,d6,d4,d5,d2,d3,d6}
  local line3d = Shape3D.createPolyline(pp)
  Viewer.Viewer:addShape(line3d, nil, "foundTriangle")

  local thirdX, thirdY = thirdPoint:getXY()
  --Save to global

  if DataProcessing.checkEdgeLength(distance,1) then
    utils.masterPoint1 = firstPoint
    utils.masterPoint2 = secondPoint
    utils.masterPoint3 = thirdPoint
  elseif DataProcessing.checkEdgeLength(distance,2) then
    utils.masterPoint2 = firstPoint
    utils.masterPoint3 = secondPoint
    utils.masterPoint1 = thirdPoint
  elseif DataProcessing.checkEdgeLength(distance,3) then
    utils.masterPoint3 = firstPoint
    utils.masterPoint1 = secondPoint
    utils.masterPoint2 = thirdPoint
  end
  
  print(
    "FirstPoint            X:", firstX, "Y:", firstY,
    "\nSecondPoint           X:", secondX, "Y:", secondY,
    "\nCalculated ThirdPoint X:", thirdX, "Y:", thirdY,
    "\nEdge Lengths:", distance, secondDistance)
  
  cloud:setIntensity({firstPointIndex, secondPointIndex, thirdPointIndex}, 0.3)
  Viewer.PointCloudViewer(cloud)
end

--@showMergedScans(): void
function showMergedScans()
  print("show merged scans called")
  removeScansAndShapes()
  Communication.receiveScans()
  
end

--@setCutOffDistance(distance: int):void
function setCutOffDistance(distance)
  utils.cutOffDistance = distance * 10
  Viewer.Viewer:remove("cutOffDistanceShape")
  Viewer.Viewer:addShape(Shape.createCircle(Point.create(0,0), utils.cutOffDistance), nil, "cutOffDistanceShape")
  Viewer.Viewer:present()
end


local function main()
  Script.serveFunction("LIDAR_AppSpace.showSlaveScans", "showSlaveScans")
  Script.serveFunction("LIDAR_AppSpace.showOwnScans", "showOwnScans")
  Script.serveFunction("LIDAR_AppSpace.calibrate", "calibrate")
  Script.serveFunction("LIDAR_AppSpace.setCutOffDistance", "setCutOffDistance", "int")
  Script.serveFunction("LIDAR_AppSpace.showMergedScans", "showMergedScans")
  setCutOffDistance(utils.cutOffDistance)
end
Script.register("Engine.OnStarted", main)