local function main()

  local PointCloudViewer = require("ViewerModule")
  local Triangle = require("Triangle")
  local DataProcessing = require("DataProcessing")
  --local cloud = Triangle.createTwoLines()
  local cloud = Triangle.createOneLineWithFirstPointAsClosestPoint()
  local changedCloud = DataProcessing.removePointsBeyond(cloud, 1000)
  print(DataProcessing.getMinDistanceAndEdgeLengths(changedCloud))
  PointCloudViewer.PointCloudViewer(changedCloud)

end
Script.register("Engine.OnStarted", main)