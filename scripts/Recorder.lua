
local dataSource = "local"       -- can be local or remote
local ipAddress = "192.168.1.10"  -- if remote

local path = "public/"            -- path to save the recorded data in
local gFilename = "Aufnahme01"      -- filenames used for recoded data
local filetype = "json"        -- msgpack or json

local gRecordingStopped = true --true while recording scans
local gPlaybackStopped = true
local gPlaybackPaused = false
local gEnableLoop = false

local gRecorder = Recording.Recorder.create()
local gPlayer = Recording.Player.create()
local gScanProvider




--Aufnahme

gRecorder:addFileTarget(path..gFilename..".sdr."..filetype,path..gFilename..".sdri."..filetype)

local function timerAblauf()


if dataSource == "remote" then
  gScanProvider:stop()
end
gRecorder:start()
print("Aufnahme gestartet")

end

local handle = Timer.create()
Timer.setExpirationTime(handle, 5000)
Timer.setPeriodic(handle, false)
Timer.register(handle, "OnExpired", timerAblauf)
handle:start()

local function main()

  


  local  crownName = ""
  if dataSource == "remote" then
    print("remote mode")
    gScanProvider = Scan.Provider.RemoteScanner.create()
    gScanProvider:setIPAddress(ipAddress)
    crownName = "Scan.Provider.RemoteScanner"
  elseif dataSource == "local" then
    print("local mode")
    gScanProvider = Scan.Provider.RemoteScanner.create()
    crownName = "Scan.Provider.Scanner"
  else
    print("Error: Unknown value for dataSource")
  end

  
  local Providers = {}
  local Provider = Recording.Provider.create()
  Provider:setAppName("ScanRecorder")
  Provider:setCrownName(crownName)
  Provider:setSelected(true)
  table.insert(Providers,Provider)
  
  gRecorder:setProviders(Providers)
  gRecorder:setDataFormat(string.upper(filetype))

end
Script.register("Engine.OnStarted", main)



