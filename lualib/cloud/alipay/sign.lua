
local crypt = require "crypt"
local urlencode = crypt.urlencode
local base64encode = crypt.base64encode
local base64urlencode = crypt.base64urlencode
local sha256_with_rsa_sign = crypt.sha256_with_rsa_sign
local sha256_with_rsa_verify = crypt.sha256_with_rsa_verify

local io_open = io.open
local fmt = string.format
local concat = table.concat
local table_sort = table.sort

local sign = { __Version__ = 0.1 }


-- 进行key排序
local function key_sort(opt)
  local keys = {}
  for key, value in pairs(opt) do
    if key ~= '' and value ~= '' and key ~= 'sign' then
      keys[#keys+1] = key
    end
  end
  table_sort(keys)
  return keys
end

-- 进行key连接
local function key_concat(keys, opt)
  local parameters = {}
  for _, k in ipairs(keys) do
    -- parameters[#parameters+1] = fmt("%s=%s", k, urlencode(opt[k]))
    parameters[#parameters+1] = fmt("%s=%s", k, opt[k])
  end
  return parameters
end


-- 用于签名
function sign.rsa_sign(opt, key_path)
  local keys = key_sort(opt)
  local t = key_concat(keys, opt)
  local f, err = io_open(key_path, 'r+')
  if not f then
    return nil, err
  end
  f:close()
  local sig = sha256_with_rsa_sign(concat(t, "&"), key_path)
  if not sig then
    return
  end
  return base64encode(sig), t
  -- return base64urlencode(sig)
end


-- 用于验签
function sign.rsa_verify(text, key_path, sig)
  -- body
end

return sign