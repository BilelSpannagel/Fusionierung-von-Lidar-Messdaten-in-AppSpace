
local path = "public/"            -- path to save the recorded data in
local gFilename = "Recording"      -- filenames used for recoded data
local filetype = "json"        -- msgpack or json

local gRecordingStopped = true --true while recording scans
local gPlaybackStopped = true
local gPlaybackPaused = false
local gEnableLoop = false