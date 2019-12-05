local recorderModule = {}

local dataSource = "local"       -- can be local or remote
local ipAddress = "192.168.1.10"  -- if remote

local path = "public/"            -- path to save the recorded data in
local gFilename = "Aufnahme02"      -- filenames used for recoded data
local filetype = "json"        -- msgpack or json

local gRecordingStopped = true --true while recording scans
local gPlaybackStopped = true
local gPlaybackPaused = false
local gEnableLoop = false

local gRecorder = Recording.Recorder.create()
local gPlayer = Recording.Player.create()
local gScanProvider




local function aufnahmeStarten()
  print("Aufnahme wird eingerichtet")
  if dataSource == "remote" then
    gScanProvider:stop()
  end
  gRecorder:addFileTarget(path..gFilename..".sdr."..filetype,path..gFilename..".sdri."..filetype)
  gRecorder:start()
  print("Aufnahme gestartet")
end
Script.serveFunction("Recorder.aufnahmeStarten", aufnahmeStarten())

local function abspielen()
  gPlayer:setFileSource(path..gFilename..".sdr."..filetype,path..gFilename..".sdri"..filetype)
  if gRecordingStopped then
    if gPlaybackPaused then
      gPlayer:pause()
    else
      gPlayer:start()
    end
    gPlaybackStopped = false
    gPlaybackPaused = false
    print("playback started")
  end
end
Script.serveFunction("Recorder.play",abspielen)

local function aufnahmeStoppen()
    gRecorder:removeAllTargets()
    gRecorder:stop()
    if dataSource == "remote" then
      gScanProvider:stop()
    end
    gRecordingStopped = true
    gPlayer:stop()
    gPlaybackStopped = true
    print("all stopped")
end
Script.serveFunction("ScanRecorder.stop",stop)

local function timerAblauf()
  print("Timerfunktion")
  while(1) do
  end
--  Aufnahme()
end


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

  local handle = Timer.create()
  Timer.setExpirationTime(handle, 10)
  Timer.setPeriodic(handle, true)
  Timer.start(handle)
  Timer.register(handle, "OnExpired", timerAblauf)
  print("Timer gestartet")


  aufnahmeStarten()
  Script.sleep(5000)
  aufnahmeStoppen()
  print("main ende erreicht")

end
Script.register("Engine.OnStarted", main)

return recorderModule
