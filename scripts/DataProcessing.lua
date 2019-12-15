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

--getThirdCorner(firstPoint:Point, secondPoint: Point) : point
function DataProcessing.getThirdCorner(firstPoint, secondPoint)

  local A = math.abs(firstPoint:getX() - secondPoint:getX())
  local G = math.abs(firstPoint:getY() - secondPoint:getY())
  local alpha = math.atan(A/G)
  local edgeLength = math.sqrt(math.pow(A, 2)+math.pow(G, 2))
    
  if edgeLength == utils.predifinedSideLengths[1] then
    local retPoint = Point.create(A, G + utils.predifinedSideLengths[2])
    DataProcessing:rotateAroundPoint(firstPoint, retPoint, alpha+utils.predifinedAngle[2])
    return retPoint
  elseif edgeLength == utils.predifinedSideLengths[2] then
    local retPoint = Point.create(A, G + utils.predifinedSideLengths[3])
    DataProcessing:rotateAroundPoint(firstPoint, retPoint, alpha+utils.predifinedAngle[3])
    return retPoint
  elseif edgeLength == utils.predifinedSideLengths[3] then
    local retPoint = Point.create(A, G + utils.predifinedSideLengths[1])
    DataProcessing:rotateAroundPoint(firstPoint, retPoint, alpha+utils.predifinedAngle[1])
    return retPoint
  else
    print("Falsche Kantenlänge")
    return nil
  end
end

--rotateAroundPoint(originPoint:Point, pointToRotate: Point, angle:number) : point
function DataProcessing.rotateAroundPoint(originPoint, pointToRotate, angle)
  local retPoint = Point.create(pointToRotate:getX() - originPoint:getX(), pointToRotate:getY() - originPoint:getY())
  retPoint:setX(math.cos(angle) * retPoint:getX() + (-math.sin(angle) * retPoint:getY()))
  retPoint:setY(math.sin(angle) * retPoint:getX() + (math.cos(angle) * retPoint:getY()))
  retPoint:setX(retPoint:getX() + originPoint:getX())
  retPoint:setY(retPoint:getY() + originPoint:getY())

  return retPoint
end


--translatePoint(originPoint:Point,vec:Point) : Point
function DataProcessing.translatePoint(originpoint,vec)
  originpoint = Point.add(originpoint, vec)
  return originpoint
end

--computeAngle(p1Scan1:Point, p2Scan1:Point, p2Scan2:Point) : number
function DataProcessing.computeAngle(p1Scan1, p2Scan1, p2Scan2)
--Mach ich bald fertig
  math.acos()
  local angle = 0
  return angle
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