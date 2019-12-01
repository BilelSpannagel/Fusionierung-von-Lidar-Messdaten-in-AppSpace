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
  local closestPoint, minDistance, firstPoint, lastPoint, firstEdgeLength
  local secondEdgeLength, closestPointIndex, leftClosestPoint, rightClosestPoint, _

  closestPoint, closestPointIndex, firstPoint, lastPoint = DataProcessing.getCorners(inputCloud)
  minDistance = Point.getDistance(closestPoint, Point.create(0, 0, 0))
  
  firstEdgeLength = Point.getDistance(firstPoint, closestPoint)
  secondEdgeLength = Point.getDistance(closestPoint, lastPoint)

  if ((closestPoint == firstPoint) or (closestPoint == lastPoint)) then
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

--@getCorners(inputCloud:PointCloud):Point, Integer, Point, Point
function DataProcessing.getCorners(inputCloud)
  local zeroPoint, closestPoint, secondPoint, thirdPoint, closestPointIndex, _
  zeroPoint = Point.create(0, 0, 0)
  closestPoint, closestPointIndex = inputCloud:findClosestPoint(zeroPoint)
  secondPoint, _ = inputCloud:getPoint3D(0)
  thirdPoint, _ = inputCloud:getPoint3D(inputCloud:getSize()-1)
  return closestPoint, closestPointIndex, secondPoint, thirdPoint
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