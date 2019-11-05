
local type = type
local string = string
local match = string.match

local time = os.time

local date = {}

--[[
支持三种格式转换:
  1. %Y/%m/%d %H:%M:%S
  2. %Y-%m-%d %H:%M:%S
  3. %Y:%m:%d %H:%M:%S
]]
function date.basic_to_unixstamp(datetime)
  if type(datetime) ~= 'string' then
    return
  end
  local year, month, day, hour, min, sec = match(datetime, "([%d]+)[:/-]([%d]+)[:/-]([%d]+) ([%d]+)[:/-]([%d]+)[:/-]([%d]+)")
  if not year or not month or not day or not hour or not min or not sec then
    return
  end
  return time { year = year, month = month, day = day, hour = hour, min = min, sec = sec}
end

function date.normal_to_unixstamp(datetime)
  if type(datetime) ~= 'string' then
    return
  end
end

-- GMT to unix stamp
function date.gmt_to_unixstamp(datetime)
  if type(datetime) ~= 'string' then
    return
  end
end

return date