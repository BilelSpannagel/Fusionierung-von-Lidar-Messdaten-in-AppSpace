print"start Script"

--luacheck: globals ViewerModule Communication provider DataProcessing utils removeScansAndShapes showOwnScans
--luacheck: globals calibrate setCutOffDistance showMergedScans addShapes tempMasterIP tempIsMaster setTempIsMaster
--luacheck: globals setTempMasterIP setSettings showSlaveScans

DataProcessing = require("DataProcessing")
ViewerModule = require("ViewerModule")
Communication = require("Communication")
provider = Scan.Provider.Scanner.create()
utils = require("utils")

--Used to temporarily save the Settings set in the Page.
--These values are transfered to the Communications script on Save click
tempMasterIP = Communication.masterIp
tempIsMaster = Communication.isMaster

-- @removeScansAndShapes():void
function removeScansAndShapes()
  provider:deregister("OnNewScan", ViewerModule.showScans)
  provider:deregister("OnNewScan", ViewerModule.showMergedCloud)
  Communication.stopReceiving()
  ViewerModule.Viewer:remove("foundTriangleShape")
  ViewerModule.Viewer:remove("slaveLidarShape")
end

--@addShapes():void
function addShapes()
  ViewerModule.Viewer:addShape(Shape.createCircle(Point.create(0,0), 65), utils.blueShapeDecoration, "LidarShape")
  ViewerModule.Viewer:addShape(Shape.createLineSegment(Point.create(0,0), Point.create(-8190, 5740)), utils.blueShapeDecoration, "FirstBlindShape")
  ViewerModule.Viewer:addShape(Shape.createLineSegment(Point.create(0,0), Point.create(-8190, -5740)), utils.blueShapeDecoration, "SecondBlindShape")
  ViewerModule.Viewer:addShape(Shape.createCircle(Point.create(0,0), utils.cutOffDistance), utils.redShapeDecoration, "cutOffDistanceShape")
end

--@showMasterScans():void
function showOwnScans()
  addShapes()
  utils.slaveActive = false
  utils.masterActive = true
  removeScansAndShapes()
  print("show own scans called")
  provider:register("OnNewScan", ViewerModule.showScans)
end

--@showSlaveScans():void
function showSlaveScans()
  addShapes()
  utils.slaveActive = true
  utils.masterActive = false
  removeScansAndShapes()
  print"show slave scans called"
  Communication.receiveScans(ViewerModule.showScans)
end

--@showMergedScans(): void
function showMergedScans()
  print("show merged scans called")
  removeScansAndShapes()
  Communication.receiveScans(ViewerModule.addSlaveScan)
  provider:register("OnNewScan", ViewerModule.showMergedCloud)
  ViewerModule.Viewer:remove("FirstBlindShape")
  ViewerModule.Viewer:remove("SecondBlindShape")
  ViewerModule.Viewer:remove("cutOffDistanceShape")
end

--@setCutOffDistance(distance: int):void
function setCutOffDistance(distance)
  utils.cutOffDistance = distance * 10
  ViewerModule.Viewer:remove("cutOffDistanceShape")
  ViewerModule.Viewer:addShape(Shape.createCircle(Point.create(0,0), utils.cutOffDistance), utils.redShapeDecoration, "cutOffDistanceShape")
  ViewerModule.Viewer:present()
end

--@calibrate():void
function calibrate()
  Communication.stopReceiving()
  provider:deregister("OnNewScan", ViewerModule.showScans)
  
  local edgeHitFilter = Scan.EchoFilter.create()
  edgeHitFilter:setType("Last")
  local scan = edgeHitFilter:filter(ViewerModule.lastScan:clone())
  utils.transformation = false
  local cloud, points = DataProcessing.calculateCalibration(ViewerModule.transformer:transformToPointCloud(scan))
  ViewerModule.Viewer:addPointCloud(cloud)
  ViewerModule.Viewer:addShape(Shape3D.createPolyline(points), nil, "foundTriangleShape")
  ViewerModule.Viewer:present()
end

--@setTempIsMaster(isMaster: boolean): void
function setTempIsMaster(isMaster)
  tempIsMaster = isMaster
end

--@setTempMasterIP(masterIP: string): void
function setTempMasterIP(masterIP)
  tempMasterIP = masterIP
end

--@setSettings(isMaster: boolean, masterIP: string): void
function setSettings()
  if tempIsMaster then
    Communication.isMaster = true
    showSlaveScans()
  else
    Communication.isMaster = false
    Communication.masterIP = tempMasterIP
    Communication.sendScans(provider)
  end
end

local function main()
  Script.serveFunction("LIDAR_AppSpace.showSlaveScans", "showSlaveScans")
  Script.serveFunction("LIDAR_AppSpace.showOwnScans", "showOwnScans")
  Script.serveFunction("LIDAR_AppSpace.calibrate", "calibrate")
  Script.serveFunction("LIDAR_AppSpace.setCutOffDistance", "setCutOffDistance", "int")
  Script.serveFunction("LIDAR_AppSpace.showMergedScans", "showMergedScans")
  Script.serveFunction("LIDAR_AppSpace.setTempIsMaster", "setTempIsMaster", "isMaster")
  Script.serveFunction("LIDAR_AppSpace.setTempMasterIP", "setTempMasterIP", "masterIP")
  Script.serveFunction("LIDAR_AppSpace.setSettings", "setSettings")
end
Script.register("Engine.OnStarted", main)