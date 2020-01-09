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

--@getTwoCornersAndEdgeLength(inputCloud:PointCloud):Point, Int, Point, Int, Float, Point, Int, Float
function DataProcessing.getTwoCornersAndEdgeLength(inputCloud)
  local closestPoint, firstPoint, lastPoint, pointCloudSize, closestPointIndex, distance, _
  local firstPointIndex, lastPointIndex

  closestPoint, closestPointIndex, _, _ = DataProcessing.getCorners(inputCloud)
  firstPoint, lastPoint, firstPointIndex, lastPointIndex = inputCloud:findMaxDistancePointPair()
  distance = Point.getDistance(firstPoint, lastPoint)
  pointCloudSize = inputCloud:getSize()

  if ((closestPointIndex == 0) or (closestPointIndex == pointCloudSize - 1)) then
    return firstPoint, firstPointIndex, lastPoint, lastPointIndex, distance
  else
    if (distance * 1.1 <
      (Point.getDistance(firstPoint, closestPoint) + Point.getDistance(lastPoint, closestPoint))) then
      return firstPoint, firstPointIndex, closestPoint, closestPointIndex, Point.getDistance(firstPoint, closestPoint),
      lastPoint, lastPointIndex, Point.getDistance(lastPoint, closestPoint)
    else
      return firstPoint, firstPointIndex, lastPoint, lastPointIndex, distance
    end
  end
end


--@round(num:number, numDecimalPlaces:number): number
local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
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


--rotateAroundPoint(originPoint:Point, pointRotate: Point, angle:number) : point
function DataProcessing.rotateAroundPoint(originPoint, pointRotate, angle)
  local anglerad = (3.141 / 180) * angle
  local shiftedPoint = Point.create(pointRotate:getX() - originPoint:getX(), pointRotate:getY() - originPoint:getY())
  local retPoint = Point.create(0,0)
  retPoint:setX(math.cos(anglerad) * shiftedPoint:getX() + (math.sin(anglerad) * shiftedPoint:getY()))
  retPoint:setY(math.sin(anglerad) * shiftedPoint:getX() + (math.cos(anglerad) * shiftedPoint:getY()))
  retPoint:setX(retPoint:getX() + originPoint:getX())
  retPoint:setY(retPoint:getY() + originPoint:getY())

  return retPoint
end

--@getDegree(point1:Point, point2:Point):number
function DataProcessing.getDegree(point1, point2)
  local lenghtp1 = math.sqrt(math.pow(point1:getX(), 2)+math.pow(point1:getY(), 2))
  local lenghtp2 = math.sqrt(math.pow(point2:getX(), 2)+math.pow(point2:getY(), 2))
  local nenner = lenghtp1 * lenghtp2

  local zaehler = (point1:getX()*point2:getX()) + (point1:getY()*point2:getY())

  local degree = math.deg(math.acos(zaehler/nenner))
  return degree
end


--@checkEdgeLength(p1:float):bool
function checkEdgeLength(length, index)
  local predifinedEdgeLength = utils.predifinedSideLengths[index]
  return predifinedEdgeLength * 0.90 < length and length < predifinedEdgeLength * 1.1
end


--@getThirdCorner(p1:Point, p2: Point): point
function DataProcessing.getThirdCorner(p1, p2)
  -- Get Left Point
  local firstPoint = p2
  local secondPoint = p1
  if (p1:getY() > p2:getY()) then
    firstPoint = p1
    secondPoint = p2
  end
  
  local A = secondPoint:getX() - (firstPoint:getX())
  local G = secondPoint:getY() - (firstPoint:getY())
  print(A,G)
  local alpha
  if (G ~= 0) then
    alpha = math.deg(math.atan(G/A))
    
  else
    alpha = 0
  end

  if(alpha > 0) then
      alpha = -90 -(90-alpha)
  end
  
  local edgeLength = math.sqrt(math.pow(A, 2)+math.pow(G, 2))

  if checkEdgeLength(edgeLength, 1) then
    local deg = (alpha+utils.predifinedAngle[1])
    local retPoint = Point.create(firstPoint:getX()+ utils.predifinedSideLengths[2], firstPoint:getY())
    retPoint = DataProcessing.rotateAroundPoint(firstPoint, retPoint, deg)
    print(alpha,utils.predifinedAngle[1],deg)
    return retPoint
  elseif checkEdgeLength(edgeLength, 2) then
    local deg = (alpha+utils.predifinedAngle[2])
    local retPoint = Point.create(firstPoint:getX()+utils.predifinedSideLengths[3], firstPoint:getY())
    retPoint = DataProcessing.rotateAroundPoint(firstPoint, retPoint, deg)
    print(alpha,utils.predifinedAngle[2],deg)
    return retPoint
  elseif checkEdgeLength(edgeLength, 3) then
    local deg = (alpha+utils.predifinedAngle[3])
    local retPoint = Point.create(firstPoint:getX()+ utils.predifinedSideLengths[1], firstPoint:getY())
    retPoint = DataProcessing.rotateAroundPoint(firstPoint, retPoint, deg)
    print(alpha,utils.predifinedAngle[3],deg)
    return retPoint
  else
    print("Falsche Kantenlänge")
    return nil
  end
end



--translatePositivePoint(originPoint:Point,vec:Point) : Point
function DataProcessing.translatePositivePoint(originpoint,vec)
  originpoint = Point.add(originpoint, vec)
  return originpoint
end

--translateNegativePoint(originPoint:Point,vec:Point) : Point
function DataProcessing.translateNegativePoint(originpoint,vec)
  Point.setXY(vec, Point.getX(vec) * (-1), Point.getY(vec) * (-1) )
  originpoint = Point.add(originpoint, vec)
  return originpoint
end

--computeAngle(p1Scan1:Point, p1Scan2:Point, p2Scan1:Point, p2Scan2:Point) : number
function DataProcessing.computeAngle(p1Scan1, p1Scan2, p2Scan1, p2Scan2)
  local zero = Point.create(0, 0)
  p2Scan1 = DataProcessing.translateNegativePoint(p2Scan1, p1Scan1)
  p2Scan2 = DataProcessing.translateNegativePoint(p2Scan2, p1Scan2)
  local denominator = Point.getDistance(p2Scan1, zero)*Point.getDistance(p2Scan2, zero)
  local angle = math.deg(math.acos(((p2Scan1:getX()*p2Scan2:getX())+(p2Scan1:getY()*p2Scan2:getY())) / denominator))
  return angle
end

--@computeMatrix(p1Scan1:Point, p2Scan1:Point, angle:number):Matrix
function DataProcessing.computeMatrix(p1Scan1, p1Scan2, angle)
  local m1 = Matrix.create(3, 3)
  m1:setAll(0)
  m1:setValue(1, 1, 1)
  m1:setValue(2, 2, 1)
  m1:setValue(3, 3, 1)
  m1:setValue(1, 3, Point.getX(p1Scan1))
  m1:setValue(2, 3, Point.getY(p1Scan1))

  local m2 = Matrix.create(3, 3)
  m2:setAll(0)
  m2:setValue(1, 1, 1)
  m2:setValue(2, 2, 1)
  m2:setValue(3, 3, 1)
  m2:setValue(1, 3, -Point.getX(p1Scan2))
  m2:setValue(2, 3, -Point.getY(p1Scan2))

  local m3 = Matrix.create(3, 3)
  m3:setAll(0)
  m3:setValue(1, 1, math.cos(angle))
  m3:setValue(1, 2, -math.sin(angle))
  m3:setValue(2, 1, math.sin(angle))
  m3:setValue(2, 2, math.cos(angle))
  m3:setValue(3, 3, 1)

  local m4 = Matrix.multiply(m1, m3)
  local m5 = Matrix.multiply(m4, m2)

  return m5
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