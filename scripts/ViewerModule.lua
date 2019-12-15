local ViewerModule = {}
-- luacheck: globals Viewer

-- luacheck: globals numScans scans pointCloudDecoration transformer ViewerModule.lastScan
ViewerModule.lastScan = 0
numScans = 0
scans = {}
pointCloudDecoration = View.PointCloudDecoration.create()
pointCloudDecoration:setPointSize(3)
pointCloudDecoration:setXColormap(0)
transformer = Scan.Transform.create()
ViewerModule.Viewer = View.create("scanViewer")
ViewerModule.Viewer:setDefaultDecoration(pointCloudDecoration)


function ViewerModule.PointCloudViewer(cloud)
ViewerModule.Viewer:addPointCloud(cloud)
ViewerModule.Viewer:present()
end

--@showScans(scan:Scan):function
function ViewerModule.showScans(scan)
  --draw scans
  function drawScans()
    --Viewer:clear()

    local cloud = Scan.Transform.transformToPointCloud(transformer, scans[0])
    if Scan.getPointPhi(scans[0], 0) == 0 then
      --print "set first scan"
      ViewerModule.lastScan = transformer:transformToPointCloud(scans[0])
    elseif Scan.getPointPhi(scans[1], 0) == 0 then
      --print "set second scan"
      ViewerModule.lastScan = transformer:transformToPointCloud(scans[1])
    elseif Scan.getPointPhi(scans[2], 0) == 0 then
      --print "set third scan"
      ViewerModule.lastScan = transformer:transformToPointCloud(scans[2])
    elseif Scan.getPointPhi(scans[3], 0) == 0 then
      --print "set fourth scan"
      ViewerModule.lastScan = transformer:transformToPointCloud(scans[3])
    end
    
    cloud = cloud:merge(Scan.Transform.transformToPointCloud(transformer, scans[1]))
    cloud = cloud:merge(Scan.Transform.transformToPointCloud(transformer, scans[2]))
    cloud = cloud:merge(Scan.Transform.transformToPointCloud(transformer, scans[3]))
    
    ViewerModule.Viewer:addPointCloud(cloud)
        
    ViewerModule.Viewer:present()
    scans = {}
    numScans = 0
  end
  --add scans to collection and redraw every 4th scan
  scans[numScans] = scan
  numScans = numScans+1
  if numScans % 4 == 0 then
    drawScans();
  end
end

return ViewerModule

