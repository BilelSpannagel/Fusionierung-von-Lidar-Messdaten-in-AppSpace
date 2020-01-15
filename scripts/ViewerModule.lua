local ViewerModule = {}
-- luacheck: globals Viewer

-- luacheck: globals numScans scans pointCloudDecoration ViewerModule.transformer ViewerModule.lastScan numClouds clouds slaveScans
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

