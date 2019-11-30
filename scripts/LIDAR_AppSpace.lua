local function main()

  local PointCloudViewer = require("ViewerModule")
  local Triangle = require("Triangle")
  local RemovePointsBeyond = require("RemovePointsBeyond")
  local GetMinDistanceAndEdgeLengths = require("GetMinDistanceAndEdgeLengths")
  local cloud = Triangle.createTriangle()
  local changedCloud = RemovePointsBeyond.removePointsBeyond(cloud, 750)
  print(GetMinDistanceAndEdgeLengths.getMinDistanceAndEdgeLengths(changedCloud))
  PointCloudViewer.PointCloudViewer(changedCloud)

end
Script.register("Engine.OnStarted", main)