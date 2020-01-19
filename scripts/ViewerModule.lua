local ViewerModule = {}
-- luacheck: globals Viewer

-- luacheck: globals numScans scans pointCloudDecoration ViewerModule.transformer ViewerModule.lastScan numClouds clouds slaveScans

utils = require("utils")
DataProcessing = require("DataProcessing")


numScans = 0
scans = {}

numClouds = 0
clouds = {}

slaveScans = {}

pointCloudDecoration = View.PointCloudDecoration.create()
pointCloudDecoration:setPointSize(3)
pointCloudDecoration:setXColormap(0)
ViewerModule.transformer = Scan.Transform.create()
ViewerModule.Viewer = View.create("scanViewer")
ViewerModule.Viewer:setDefaultDecoration(pointCloudDecoration)
ViewerModule.Viewer:addShape(Shape.createLineSegment(Point.create(0,0), Point.create(-8190, 5740)))
ViewerModule.Viewer:addShape(Shape.createLineSegment(Point.create(0,0), Point.create(-8190, -5740)))
ViewerModule.Viewer:addShape(Shape.createCircle(Point.create(0,0), 65), nil, "LidarShape")

function ViewerModule.PointCloudViewer(cloud)
  ViewerModule.Viewer:addPointCloud(cloud)
  ViewerModule.Viewer:present()
end

--@showScans(scan:Scan):void
function ViewerModule.showScans(scan)
  --add scans to collection and redraw every 4th scan
  scans[numScans] = scan
  numScans = numScans+1
  if numScans % 4 == 0 then
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
    numScans = 0
  end
end
--luacheck: globals clouds numClouds
function ViewerModule.showMergedCloud(scan)
   --add scans to collection and redraw every 4th scan
  table.insert(clouds, scan)

  if #clouds == 4 then
    local mergedCloud = Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(clouds, 1))
    mergedCloud = PointCloud.merge(mergedCloud, Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(clouds, 1)))
    mergedCloud = PointCloud.merge(mergedCloud, Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(clouds, 1)))
    mergedCloud = PointCloud.merge(mergedCloud, Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(clouds, 1)))
    if (#slaveScans >= 4) then
      local combinedSlaveCloud
      combinedSlaveCloud = Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(slaveScans, 1))
      combinedSlaveCloud =  combinedSlaveCloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(slaveScans, 1)))
      combinedSlaveCloud =  combinedSlaveCloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(slaveScans, 1)))
      combinedSlaveCloud =  combinedSlaveCloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, table.remove(slaveScans, 1)))
      --Transform combinedSlaveCloud
      if utils.transformation == false then
      utils.transformation = true
      local a
      a = DataProcessing.computeAngle(utils.masterPoint1, utils.slavePoint1, utils.masterPoint2, utils.slavePoint2)
      print(a)
      local matr = DataProcessing.computeMatrix(utils.masterPoint1,utils.slavePoint1,a)
      local transform = Transform.createFromMatrix2D(matr, "RIGID")
      transform3d = Transform.to3D(transform)
      local nullpt = Matrix.create(3, 1)
      Matrix.setAll(nullpt, 0)
      Matrix.setValue(nullpt, 2, 0, 1)
      nullpt = Matrix.multiply(matr, nullpt)
      Viewer.Viewer:addShape(Shape.createCircle(Point.create(nullpt:getValue(0, 0),nullpt:getValue(1, 0)), 65), nil, "slaveLidarShape")
      end
      PointCloud.transformInplace(combinedSlaveCloud, transform3d)
      mergedCloud = mergedCloud:merge(combinedSlaveCloud)
      --print(#slaveScans)
    end
    --print(#clouds)
    Viewer.Viewer:addPointCloud(mergedCloud)
    Viewer.Viewer:present()
  else if #clouds > 4 then
     print("SOMETHING IS HORRIBLY WRONG. Cloud Size: ", #clouds)
     end
  end
end

--@addSlaveScan(scan:slaveScan):void
function ViewerModule.addSlaveScan(slaveScan)
    --rename this
  table.insert(slaveScans, slaveScan)
end



return ViewerModule

