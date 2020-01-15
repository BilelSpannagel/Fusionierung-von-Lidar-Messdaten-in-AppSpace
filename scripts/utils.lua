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
utils.triangleMaster = {0,0,0}
utils.triangleSlave = {0,0,0}
utils.degreeSlaveMaster = {0}
utils.originPoint = Point.create(0, 0, 0)
utils.showMaster = false
utils.cutOffDistance = 30
utils.slaveActive = false
utils.masterActive = false
utils.slaveScans = {}

return utils