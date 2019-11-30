local GetMinDistanceAndEdgeLengths = {}

--@getMinDistanceAndEdgeLengths(inputCloud:PointCloud):Float, Float, Float
function GetMinDistanceAndEdgeLengths.getMinDistanceAndEdgeLengths(inputCloud)
  local zeroPoint, closestPoint, minDistance, pointCloudSize, firstPoint, lastPoint, firstEdgeLength, secondEdgeLength,_
  zeroPoint = Point.create(0, 0, 0)
  closestPoint, _ = inputCloud:findClosestPoint(zeroPoint)
  minDistance = Point.getDistance(closestPoint, zeroPoint)

  pointCloudSize, _ = inputCloud:getSize()
  firstPoint, _ = inputCloud:getPoint3D(0)
  lastPoint, _ = inputCloud:getPoint3D(pointCloudSize - 1)

  firstEdgeLength = Point.getDistance(firstPoint, closestPoint)
  secondEdgeLength = Point.getDistance(closestPoint, lastPoint)
  return minDistance, firstEdgeLength , secondEdgeLength
end

return GetMinDistanceAndEdgeLengths