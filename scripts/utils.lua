local utils = {}

utils.predifinedSideLengths = {100,170,140}
utils.predifinedAngle = {55,35, 90}
utils.masterPoint1 = Point.create(0, 0, 0)
utils.masterPoint2 = Point.create(0, 0, 0)
utils.masterPoint3 = Point.create(0, 0, 0)
utils.slavePoint1 = Point.create(0, 0, 0)
utils.slavePoint2 = Point.create(0, 0 , 0)
utils.slavePoint3 = Point.create(0, 0, 0)
utils.degreeSlaveMaster = 0
utils.triangleMaster = {0,0,0}
utils.triangleSlave = {0,0,0}
utils.degreeSlaveMaster = {0}
utils.originPoint = Point.create(0, 0, 0)
utils.showMaster = false
utils.cutOffDistance = 300
utils.slaveActive = false
utils.masterActive = false
utils.transformation = false
utils.blueShapeDecoration = View.ShapeDecoration.create()
utils.blueShapeDecoration:setLineColor(0, 0, 255)
utils.greenShapeDecoration = View.ShapeDecoration.create()
utils.greenShapeDecoration:setLineColor(0, 255, 0)
utils.redShapeDecoration = View.ShapeDecoration.create()
utils.redShapeDecoration:setLineColor(255, 0, 0)

return utils