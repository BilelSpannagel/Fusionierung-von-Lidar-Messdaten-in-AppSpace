local function main()

  local PointCloudViewer = require("ViewerModule")
  local Triangle = require("Triangle")
  local cloud = PointCloud.create()
  cloud = Triangle.createTriangle()
  print(cloud)
  PointCloudViewer.PointCloudViewer(cloud)

end
Script.register("Engine.OnStarted", main)