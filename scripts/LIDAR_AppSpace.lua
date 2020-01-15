print"start Script"

--luacheck: globals Viewer Communication provider DataProcessing utils removeScansAndShapes showOwnScans showSlaveScans 
--luacheck: globals slaveScans calibrate setCutOffDistance showMergedScans
DataProcessing = require("DataProcessing")
Viewer = require("ViewerModule")
Communication = require("Communication")
provider = Scan.Provider.Scanner.create()
utils = require("utils")
slaveScans = {}

-- @removeScansAndShapes():void
function removeScansAndShapes()
  provider:deregister("OnNewScan", Viewer.showScans)
  Communication.stopReceiving()
  Viewer.Viewer:remove("foundTriangleShape")
end

--@showMasterScans():void
function showOwnScans()
  utils.slaveActive = false
  utils.masterActive = true
  removeScansAndShapes()
  print("show own scans called")
  provider:register("OnNewScan", Viewer.showScans)
end

--@showSlaveScans():void
function showSlaveScans()
  utils.slaveActive = true
  utils.masterActive = false
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
  = DataProcessing.getCornersAndEdgeLengths(cloud)
  
  cloud:setIntensity({firstPointIndex, secondPointIndex, thirdPointIndex}, 0.3)
  
  if thirdPoint == nil then
    thirdPoint = DataProcessing.getThirdCorner(firstPoint, secondPoint)
  end
  
  local firstX, firstY = firstPoint:getXY()
  local secondX, secondY = secondPoint:getXY()
  local thirdX, thirdY = thirdPoint:getXY()

  local d1 = Point.create(firstX, firstY, 76)
  local d2 = Point.create(secondX, secondY, 76)
  local d3 = Point.create(thirdX, thirdY, 76)
  local d4 = Point.create(firstX,firstY, 0)
  local d5 = Point.create(secondX, secondY, 0)
  local d6 = Point.create(thirdX, thirdY, 0)
  local pp = {d1,d2,d3,d1,d4,d5,d6,d4,d5,d2,d3,d6}
  local line3d = Shape3D.createPolyline(pp)
  Viewer.Viewer:addShape(line3d, nil, "foundTriangleShape")

  --Save to global

  if (utils.masterActive == true and utils.slaveActive == false) then
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
  end

  if (utils.masterActive == false and utils.slaveActive == true) then
    if DataProcessing.checkEdgeLength(distance,1) then
      utils.slavePoint1 = firstPoint
      utils.slavePoint2 = secondPoint
      utils.slavePoint3 = thirdPoint
    elseif DataProcessing.checkEdgeLength(distance,2) then
      utils.slavePoint2 = firstPoint
      utils.slavePoint3 = secondPoint
      utils.slavePoint1 = thirdPoint
    elseif DataProcessing.checkEdgeLength(distance,3) then
      utils.slavePoint3 = firstPoint
      utils.slavePoint1 = secondPoint
      utils.slavePoint2 = thirdPoint
    end
  end
  
  print(
    "FirstPoint            X:", firstX, "Y:", firstY,
    "\nSecondPoint           X:", secondX, "Y:", secondY,
    "\nCalculated ThirdPoint X:", thirdX, "Y:", thirdY,
    "\nEdge Lengths:", distance, secondDistance)
  
  cloud:setIntensity({firstPointIndex, secondPointIndex, thirdPointIndex}, 0.3)
  Viewer.PointCloudViewer(cloud)
end

--@mergeAndShowScans(masterData: Scan): void
function mergeAndShowScans(masterScan)
  --rename this
  Viewer:showMergedCloud(masterScan, slaveScans)
end

--@showMergedScans(): void
function showMergedScans()
  print("show merged scans called")
  removeScansAndShapes()
  Communication.receiveScans(addSlaveScan)
  provider:register("OnNewScan", mergeAndShowScans)
end

--@setCutOffDistance(distance: int):void
function setCutOffDistance(distance)
  utils.cutOffDistance = distance * 10
  Viewer.Viewer:remove("cutOffDistanceShape")
  Viewer.Viewer:addShape(Shape.createCircle(Point.create(0,0), utils.cutOffDistance), nil, "cutOffDistanceShape")
  Viewer.Viewer:present()
end

--@addSlaveScan(scan:slaveScan):void
function addSlaveScan(slaveScan)
    --rename this
  table.insert(slaveScans, slaveScan)
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