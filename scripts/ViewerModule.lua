local ViewerModule = {}
-- luacheck: globals Viewer

-- luacheck: globals numScans scans pointCloudDecoration ViewerModule.transformer ViewerModule.lastScan
numScans = 0
scans = {}

numClouds = 0
clouds = {}
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

--@showScans(scan:Scan):function
function ViewerModule.showScans(scan)
  --add scans to collection and redraw every 4th scan
  scans[numScans] = scan
  numScans = numScans+1
  if numScans % 4 == 0 then
    --Viewer:clear()
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

function ViewerModule.showMergedCloud(scan, slaveScans)
  --add scans to collection and redraw every 4th scan
  print("1", type(slaveScans))
  tempSlaveScan = slaveScans
  clouds[numClouds] = scan
  numClouds = numClouds + 1
  if numClouds % 4 == 0 then
    --Viewer:clear()
    --[[
    local cloud = Scan.Transform.transformToPointCloud(ViewerModule.transformer, clouds[0])
    local temp = Scan.Transform.transformToPointCloud(ViewerModule.transformer, clouds[1])
    cloud = cloud:merge(temp)

    local temp = Scan.Transform.transformToPointCloud(ViewerModule.transformer, clouds[2])
    cloud = cloud:merge(temp)
    
    local temp = Scan.Transform.transformToPointCloud(ViewerModule.transformer, clouds[3])
    cloud = cloud:merge(temp)
    cloud = cloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, utils.slaveScans:remove(1)))
    cloud = cloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, utils.slaveScans:remove(1)))
    cloud = cloud:merge(Scan.Transform.transformToPointCloud(ViewerModule.transformer, utils.slaveScans:remove(1)))
    --]]
    print("2", type(slaveScans))
    --[[
    local i, object = next(slaveScans, i)
    if not object == nil then
      cloud = Scan.Transform.transformToPointCloud(ViewerModule.transformer, slaveScans:remove(1))
      end
      ViewerModule.Viewer:addPointCloud(cloud)
    
    ViewerModule.Viewer:present()
    clouds = {}
    numClouds = 0
      --]]
  end
end

return ViewerModule

