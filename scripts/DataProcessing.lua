local DataProcessing = {}
local utils = require("utils")

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

--@getTwoCornersAndEdgeLength(inputCloud:PointCloud):Point, Point, Float
function DataProcessing.getTwoCornersAndEdgeLength(inputCloud)
  local closestPoint, firstPoint, lastPoint, firstEdgeLength, pointCloudSize
  local secondEdgeLength, closestPointIndex, leftClosestPoint, rightClosestPoint, _

  closestPoint, closestPointIndex, firstPoint, lastPoint = DataProcessing.getCorners(inputCloud)
  firstEdgeLength = Point.getDistance(firstPoint, closestPoint)
  secondEdgeLength = Point.getDistance(closestPoint, lastPoint)
  pointCloudSize = inputCloud:getSize()

  if ((closestPointIndex == 0) or (closestPointIndex == pointCloudSize - 1)) then
    return firstPoint, lastPoint, Point.getDistance(firstPoint, lastPoint)
  else
    leftClosestPoint, _ = inputCloud:getPoint3D(closestPointIndex - 1)
    rightClosestPoint, _ = inputCloud:getPoint3D(closestPointIndex + 1)

    if (Point.getDistance(leftClosestPoint, rightClosestPoint) * 1.05 >
      (Point.getDistance(leftClosestPoint, closestPoint) + Point.getDistance(closestPoint, rightClosestPoint))) then
      return firstPoint, lastPoint, (firstEdgeLength + secondEdgeLength)
    else
      return firstPoint, closestPoint, firstEdgeLength
    end
  end
end

--@getCorners(inputCloud:PointCloud):Point, Integer, Point, Point
function DataProcessing.getCorners(inputCloud)
  local closestPoint, secondPoint, thirdPoint, closestPointIndex, _
  closestPoint, closestPointIndex = inputCloud:findClosestPoint(utils.originPoint)
  secondPoint, _ = inputCloud:getPoint3D(0)
  thirdPoint, _ = inputCloud:getPoint3D(inputCloud:getSize()-1)
  return closestPoint, closestPointIndex, secondPoint, thirdPoint
end
--@isSideLengthInPredinedSideLengths(input: number):boolean
local function isSideLengthInPredinedSideLengths(input)
  for _, length in ipairs(utils.predifinedSideLengths) do
    if input == length then
       return true
    end
  end
  return false
end

--getThirdCorner(firstPoint:Point, secondPoint: Point, edgeLength:number)
function DataProcessing.getThirdCorner(firstPoint, secondPoint, edgeLength)
  local alpha, A, G, x, y, transform
  if isSideLengthInPredinedSideLengths(edgeLength) then
    A = math.abs(firstPoint:getX() - secondPoint:getX())
    G = math.abs(firstPoint:getY() - secondPoint:getY())
    alpha = math.atan(A/G)
    
    if edgeLength == utils.predifinedSideLengths[1] then
      transform = Transform.createTranslation2D(0, 15)
    elseif edgeLength == utils.predifinedSideLengths[2] then
      transform = Transform.createTranslation2D(-15, 10)
    elseif edgeLength == utils.predifinedSideLengths[3] then
      transform = Transform.createTranslation2D(xTrans, yTrans)
    end
    return firstPoint:add(Point.create(x, y))
  else
    return error("Error: wrong side length")
  end
end

--@round(num:number, numDecimalPlaces:number): number
local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


--@fusePointClouds(firstCloud:PointCloud, secondCloud:PointCloud): pointCloud
function DataProcessing.fusePointClouds(firstCloud, secondCloud)
  local _, firstEdgeLength, secondEdgeLength, firstCorner, secondCorner, thirdCorner, fourthCorner, combinedEdgeLength
  local resultCloud
  local compareCorner = {}
  firstCorner, secondCorner, firstEdgeLength = DataProcessing.getTwoCornersAndEdgeLength(firstCloud)
  thirdCorner, fourthCorner , secondEdgeLength = DataProcessing.getTwoCornersAndEdgeLength(secondCloud)
  firstEdgeLength = round(firstEdgeLength, -1)
  secondEdgeLength = round(secondEdgeLength, -1)
  combinedEdgeLength = firstEdgeLength + secondEdgeLength
  if firstEdgeLength == secondEdgeLength then
    local lengthIsLogic = false
    for length in utils.predifinedSideLengths do
      if firstEdgeLength == length then
        lengthIsLogic = true
      end
    end
    if lengthIsLogic == true then
      compareCorner[0] = firstCorner
      compareCorner[1] = thirdCorner
    else
      return error("Error: wrong side length")
    end
  else
    if isSideLengthInPredinedSideLengths(firstEdgeLength) and isSideLengthInPredinedSideLengths(secondEdgeLength) then

    else
      return error("Error: wrong side length")
    end
  end
  return resultCloud
end


return DataProcessing