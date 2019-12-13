local ViewerModule = {}
-- luacheck: globals Viewer
Viewer = View.create("scanViewer")

function ViewerModule.PointCloudViewer(cloud)
  Viewer:view(cloud)
end

-- luacheck: globals numScans scans pointCloudDecoration transformer
numScans = 0
scans = {}
pointCloudDecoration = View.PointCloudDecoration.create()
View.PointCloudDecoration.setPointSize(pointCloudDecoration, 3)
transformer = Scan.Transform.create()
Viewer:setDefaultDecoration(pointCloudDecoration)

--@showScans(scan:Scan):function
function ViewerModule.showScans(scan)
  --draw scans
  local function drawScans()
    Viewer:clear()
    local clouds = {}
    clouds[0] = Scan.Transform.transformToPointCloud(transformer, scans[0])
    clouds[1] = Scan.Transform.transformToPointCloud(transformer, scans[1])
    clouds[2] = Scan.Transform.transformToPointCloud(transformer, scans[2])
    clouds[3] = Scan.Transform.transformToPointCloud(transformer, scans[3])
    View.addPointCloud(Viewer, clouds[0])
    View.addPointCloud(Viewer, clouds[1])
    View.addPointCloud(Viewer, clouds[2])
    View.addPointCloud(Viewer, clouds[3])
    
    Viewer:present()
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

