local utils = {}

utils.predifinedSideLengths = {100,170,140}
utils.predifinedAngle = {55,35, 90}
utils.masterPoint1 = Point.create(0, 0)
utils.masterPoint2 = Point.create(0, 0)
utils.masterPoint3 = Point.create(0, 0)
utils.slavePoint1 = Point.create(0, 0)
utils.slavePoint2 = Point.create(0, 0)
utils.slavePoint3 = Point.create(0, 0)
utils.degreeSlaveMaster = 0
--utils.predifinedAngle = {56.31,33.69, 90}
utils.originPoint = Point.create(0, 0, 0)
utils.showMaster = false
utils.cutOffDistance = 300



return utils