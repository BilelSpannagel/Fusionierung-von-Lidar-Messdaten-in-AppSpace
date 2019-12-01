local DataProcessing = {}

--@removePointsBeyond(inputCloud: PointCloud, maxDistance: double):PointCloud
function DataProcessing.removePointsBeyond(inputCloud, maxDistance)
  local resultCloud = PointCloud.create()
  local size, _, _ = inputCloud:getSize()
  for i = 1, (size - 1) do
    local point, intensity = inputCloud:getPoint3D(i)
    local distance, _ = Point.getDistance(point, Point.create(0, 0, 0))
    if ( distance < maxDistance) then
      resultCloud:appendPoint(point:getX(), point:getY(), point:getZ(), intensity)
    end
  end
  return resultCloud
end

--@getMinDistanceAndEdgeLengths(inputCloud:PointCloud):Float, Float, Float
function DataProcessing.getMinDistanceAndEdgeLengths(inputCloud)
  local zeroPoint, closestPoint, minDistance, pointCloudSize, firstPoint, lastPoint, firstEdgeLength
  local  secondEdgeLength, closestPointIndex, leftClosestPoint, rightClosestPoint, _
  zeroPoint = Point.create(0, 0, 0)
  closestPoint, closestPointIndex = inputCloud:findClosestPoint(zeroPoint)
  minDistance = Point.getDistance(closestPoint, zeroPoint)
  
  pointCloudSize, _ = inputCloud:getSize()
  firstPoint, _ = inputCloud:getPoint3D(0)
  lastPoint, _ = inputCloud:getPoint3D(pointCloudSize - 1)
  
  firstEdgeLength = Point.getDistance(firstPoint, closestPoint)
  secondEdgeLength = Point.getDistance(closestPoint, lastPoint)

  if ((closestPointIndex == 0) or (closestPointIndex == pointCloudSize -1)) then
    return minDistance, Point.getDistance(firstPoint, lastPoint)
  else
   leftClosestPoint, _ = inputCloud:getPoint3D(closestPointIndex - 1)
   rightClosestPoint, _ = inputCloud:getPoint3D(closestPointIndex + 1)

   if (Point.getDistance(leftClosestPoint, rightClosestPoint) * 1.1 >
     (Point.getDistance(leftClosestPoint, closestPoint) + Point.getDistance(closestPoint, rightClosestPoint))) then
      return minDistance, (firstEdgeLength + secondEdgeLength)
    else
     return minDistance, firstEdgeLength , secondEdgeLength
    end
  end
end

return DataProcessing