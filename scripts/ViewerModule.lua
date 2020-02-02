local ViewerModule = {}
--luacheck: globals Viewer slaveScans first3dTransform second3dTransform third3dTransform nullpt masterScans
--luacheck: globals scanCounter scans pointCloudDecoration ViewerModule.transformer ViewerModule.lastScan mergedCloud

local utils = require("utils")
local DataProcessing = require("DataProcessing")

scanCounter = 0
scans = {}
masterScans = {}
slaveScans = {}

pointCloudDecoration = View.PointCloudDecoration.create()
pointCloudDecoration:setPointSize(3)
pointCloudDecoration:setXColormap(0)
ViewerModule.transformer = Scan.Transform.create()
ViewerModule.Viewer = View.create("scanViewer")
ViewerModule.Viewer:setDefaultDecoration(pointCloudDecoration)

--@showScans(scan: Scan):void
function ViewerModule.showScans(scan)
  --add scans to collection and redraw every 4th scan
  scans[scanCounter] = scan
  scanCounter = scanCounter + 1
  if scanCounter % 4 == 0 then
    local cloud = Scan.Transform.transformToPointCloud(ViewerModule.transformer, scans[0])
    for _, eachScan in ipairs(scans) do
      if Scan.getPointPhi(eachScan, 0) == 0 then
        ViewerModule.lastScan = eachScan
      end
    end
    cloud = cloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, scans[1]))
    cloud = cloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, scans[2]))
    cloud = cloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, scans[3]))
    ViewerModule.Viewer:addPointCloud(cloud)
        
    ViewerModule.Viewer:present()
    scans = {}
    scanCounter = 0
  end
end

--@showMergedCloud(scan: Scan): void
function ViewerModule.showMergedCloud(scan)
  table.insert(masterScans, scan)

  if #masterScans == 4 then
    --Combine the last four scans of the master as one PointCloud
    local combinedMasterCloud = Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(masterScans, 1))
    combinedMasterCloud = PointCloud.merge(combinedMasterCloud, Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(masterScans, 1)))
    combinedMasterCloud = PointCloud.merge(combinedMasterCloud, Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(masterScans, 1)))
    combinedMasterCloud = PointCloud.merge(combinedMasterCloud, Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(masterScans, 1)))
    if (#slaveScans >= 4) then
      --Combine the last four scans of the slave as one PointCloud
      local combinedSlaveCloud = Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(slaveScans, 1))
      combinedSlaveCloud = combinedSlaveCloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(slaveScans, 1)))
      combinedSlaveCloud = combinedSlaveCloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(slaveScans, 1)))
      combinedSlaveCloud = combinedSlaveCloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(slaveScans, 1)))
      --Transform combinedSlaveCloud
      if utils.transformation == false then
        utils.transformation = true
        local angle = DataProcessing.computeAngle(utils.masterPoint1, utils.slavePoint1, utils.masterPoint2, utils.slavePoint2)
        print("Winkel der Sensoren zueinander", angle,"°")
        local firstMatrix, secondMatrix, thirdMatrix = DataProcessing.getMatrix(utils.masterPoint1, utils.slavePoint1, angle)
        first3dTransform = Transform.to3D(Transform.createFromMatrix2D(firstMatrix, "RIGID"))
        second3dTransform = Transform.to3D(Transform.createFromMatrix2D(secondMatrix, "RIGID"))
        third3dTransform = Transform.to3D(Transform.createFromMatrix2D(thirdMatrix, "RIGID"))
        nullpt = Matrix.create(3, 1)
        Matrix.setAll(nullpt, 0)
        Matrix.setValue(nullpt, 2, 0, 1)
        nullpt = Matrix.multiply(firstMatrix, nullpt)
        nullpt = Matrix.multiply(secondMatrix, nullpt)
        nullpt = Matrix.multiply(thirdMatrix, nullpt)
        local printnullpt = Point.create(nullpt:getValue(0, 0), nullpt:getValue(1,0))
        print("Distanz zwischen den beiden Sensoren", printnullpt:getDistance(Point.create(0, 0)) / 10, "cm")
      end

      ViewerModule.Viewer:addShape(Shape.createCircle(Point.create(nullpt:getValue(0, 0), nullpt:getValue(1, 0)), 65), utils.greenShapeDecoration, "slaveLidarShape")
      PointCloud.transformInplace(combinedSlaveCloud, first3dTransform)
      PointCloud.transformInplace(combinedSlaveCloud, second3dTransform)
      PointCloud.transformInplace(combinedSlaveCloud, third3dTransform)
      mergedCloud = combinedMasterCloud:merge(combinedSlaveCloud)
    end
    ViewerModule.Viewer:addPointCloud(mergedCloud)
    ViewerModule.Viewer:present()
  else if #masterScans > 4 then
     print("SOMETHING IS HORRIBLY WRONG. Number of Scans: ", #masterScans)
     end
  end
end

--@addSlaveScan(slaveScan: Scan):void
function ViewerModule.addSlaveScan(slaveScan)
  table.insert(slaveScans, slaveScan)
end

return ViewerModule