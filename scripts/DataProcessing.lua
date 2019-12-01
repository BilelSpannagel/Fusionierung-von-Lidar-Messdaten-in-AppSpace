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

--@getCorners(inputCloud:PointCloud):Point, Point, Point
function DataProcessing.getCorners(inputCloud)
  local zeroPoint, closestPoint, secondPoint, thirdPoint, _
  zeroPoint = Point.create(0, 0, 0)
  closestPoint, _ = inputCloud:findClosestPoint(zeroPoint)
  secondPoint, _ = inputCloud:getPoint3D(0)
  thirdPoint, _ = inputCloud:getPoint3D(inputCloud:getSize()-1)
  return closestPoint, secondPoint, thirdPoint
end

--@getSensorPoisition(firstPoint:Point, secondPoint:Point, thirdPoint:Point):Point, Point, Point
function DataProcessing.getVectors(firstPoint, secondPoint, thirdPoint)
  local zeroPoint, zfVector, zsVector, ztVector
  zeroPoint = Point.create(0, 0, 0)
  zfVector = Point.create(firstPoint.getX()-zeroPoint.getX(),firstPoint.getY()-zeroPoint.getY()
  ,firstPoint.getZ()-zeroPoint.getZ())
  zsVector = Point.create(secondPoint.getX()-zeroPoint.getX(),secondPoint.getY()-zeroPoint.getY()
  ,secondPoint.getZ()-zeroPoint.getZ())
  ztVector = Point.create(thirdPoint.getX()-zeroPoint.getX(),thirdPoint.getY()-zeroPoint.getY()
  ,thirdPoint.getZ()-zeroPoint.getZ())
  return zfVector, zsVector, ztVector
end

return DataProcessing