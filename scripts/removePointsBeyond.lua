--@removePointsBeyond(inputCloud: PointCloud, maxDistance: double):PointCloud
local function removePointsBeyond(inputCloud, maxDistance)
  local resultCloud = PointCloud.create()
  local size, width, height = inputCloud:getSize()
  for i = 1, (size - 1) do
    local point, intensity = inputCloud:getPoint3D(i)
    local distance, totalDistance = Point.getDistance(point, Point.create(0, 0, 0))
    if ( distance < maxDistance) then
      resultCloud:appendPoint(point:getX(), point:getY(), point:getZ(), intensity)
    end
  end
  return resultCloud
end