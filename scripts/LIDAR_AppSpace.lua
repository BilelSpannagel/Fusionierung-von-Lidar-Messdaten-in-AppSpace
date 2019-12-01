local function main()

  local PointCloudViewer = require("ViewerModule")
  local Triangle = require("Triangle")
  local DataProcessing = require("DataProcessing")
  local cloud = Triangle.createTriangle()
  local changedCloud = DataProcessing.removePointsBeyond(cloud, 750)
  print(DataProcessing.getMinDistanceAndEdgeLengths(changedCloud))
  PointCloudViewer.PointCloudViewer(changedCloud)

end
Script.register("Engine.OnStarted", main)