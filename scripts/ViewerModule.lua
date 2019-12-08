local ViewerModule = {}
-- luacheck: globals Viewer
Viewer = View.create()

function ViewerModule.PointCloudViewer(cloud)
  Viewer:view(cloud)
end

--@functionname(p1:type):returnType
function ViewerModule.showScans()
  local scanViewer = View.create("scanViewer")
  
  local scanViewDecorations = {}
  scanViewDecorations["0"] = View.ScanDecoration.create()
  scanViewDecorations["1"] = View.ScanDecoration.create()
  scanViewDecorations["-1"] = View.ScanDecoration.create()
  scanViewDecorations["-2"] = View.ScanDecoration.create()
  --View.PointCloudDecoration.setColor(scanViewDecorations["0"], 255, 0, 0)     --red
  View.ScanDecoration.setColor(scanViewDecorations["1"], 0, 255, 0)     --green
  View.ScanDecoration.setColor(scanViewDecorations["-1"], 0, 0, 255)    --blue
  View.ScanDecoration.setColor(scanViewDecorations["-2"], 255, 165, 0)  --orange
  View.ScanDecoration.setPointSize(scanViewDecorations["0"] , 3)
  View.ScanDecoration.setPointSize(scanViewDecorations["1"], 3)
  View.ScanDecoration.setPointSize(scanViewDecorations["-1"], 3)
  View.ScanDecoration.setPointSize(scanViewDecorations["-2"], 3)
  local numScans = 0
  local scans = {}
  local transformer = Scan.Transform.create()
  
  --draw scans
  function drawScans()
    scanViewer:clear()
    local cloudDeco = View.PointCloudDecoration.create()
    cloudDeco:setIntensityColormap(1)
    cloudDeco:setIntensityRange(0,1)
    --
    scanViewer:addScan(scans[0], scanViewDecorations["0"])
    ---
    scanViewer:present()
  end  


--@handleOnReceive(data:binary,ipaddress:string,port:int)
  function hndOnReceive(data,ipaddress,port)
  ---[[
    --count scan, print missing scans for the last 100 scans.
    local cnt = Scan.getNumber(scan)
    if cnt % 100 == 0 then
      if numScans ~= 100 then
        print("Missing Scans = " .. numScans)
      end
      print("Scan: " .. cnt)
      numScans = 0
    end
    --add scans to collection and redraw every 4th scan
    scans[numScans] = scan
    numScans = numScans + 1
    
    if numScans % 4 == 0 then
      numScans = 0
      drawScans();
      scans = {}
    end
    --]]
    end

end


return ViewerModule

