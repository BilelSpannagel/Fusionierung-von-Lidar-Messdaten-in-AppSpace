local function main()
  local PointCloudViewer = require("ViewerModule")
  local Triangle = require("Triangle")
  local DataProcessing = require("DataProcessing")
  local Communication = require("Communication")
  local cloud = Triangle.createTwoLines()
  --local cloud = Triangle.createOneLine()
  --local cloud = Triangle.createOneLineWithFirstPointAsClosestPoint()
  local changedCloud = DataProcessing.removePointsBeyond(cloud, 1000)
  print(DataProcessing.getMinDistanceAndEdgeLengths(changedCloud))
  PointCloudViewer.PointCloudViewer(changedCloud)

  scanProvider = Scan.Provider.Scanner.create()
  Communication.sendScans(scanProvider, "192.168.1.20")

end
Script.register("Engine.OnStarted", main)