local Triangle = {}

function Triangle.createTriangle()
--  local a = Point.create(500,500,0)
--  local b = Point.create(600,600,0)
--  local c = Point.create(600,500,0)

  local triangleCloud = PointCloud.create()
  for i = 500, 600 do
--    triangleCloud:appendPoint(i,i,0,1)
    triangleCloud:appendPoint(i,500,0,1)
    triangleCloud:appendPoint(500,i,0,1)
  end
  for i = 0,100 do
    triangleCloud:appendPoint(500+i,600-i,0,1)
  end
  return triangleCloud
end

return Triangle