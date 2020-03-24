local crypt = require "crypt"
local uuid = crypt.uuid
local md5 = crypt.md5
local hmac_sha256 = crypt.hmac_sha256

local type = type
local pairs = pairs
local ipairs = ipairs
local fmt = string.format
local table_sort = table.sort
local table_concat = table.concat

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
local function key_concat(keys, opt, apikey)
  local parameters = {}
  for _, k in ipairs(keys) do
    parameters[#parameters+1] = fmt("%s=%s", k, opt[k])
  end
  parameters[#parameters+1] = "key=" .. apikey
  return parameters
end

-- 微信支付的HMAC_SHA256签名方法
local function hmac_sha256_sign(opt, apikey)
  -- 1. 首先对所有参数进行排序
  local keys = key_sort(opt)
  -- 2. 对排序后的字段进行拼接
  local parameters = key_concat(keys, opt, apikey)
  -- 3. 使用hmac_sha256对参数结果与apikey进行签名, 最后将签名的结果大写化
  return hmac_sha256(apikey, table_concat(parameters, "&"), true):upper()
end

-- 微信支付的MD5签名方法
local function hmac_md5_sign(opt, apikey)
  -- 1. 首先对所有参数进行排序
  local keys = key_sort(opt)
  -- 2. 对排序后的字段进行拼接
  local parameters = key_concat(keys, opt, apikey)
  -- 3. 使用md5对参数结果进行签名, 最后将签名的结果大写化.
  return md5(table_concat(parameters, "&"), true):upper()
end

-- 回调签名验证
local function notice_varify(response, apikey)
  if type(response) ~= 'table' or type(apikey) ~= 'string' then
    return nil, "invalide response or apikey"
  end
  if response["xml"] then
    response = response["xml"]
  end
  local sign_str = response.sign
  response.sign = nil
  if response.sign_type == 'MD5' and sign_str ~= hmac_md5_sign(response, apikey) then
    return nil, "notice: MD5签名验证失败"
  elseif response.sign_type == 'HMAC-SHA256' and sign_str ~= hmac_sha256_sign(response, apikey) then
    return nil, "notice: HMAC-SHA256签名验证失败"
  elseif not response.sign_type and sign_str ~= hmac_md5_sign(response, apikey) then
    return nil, "notice: (None)MD5签名验证失败"
  end
  response.sign = sign_str
  return true
end

-- 回应验证签名
local function sign_varify(opt, request, response)
  local sign_str = response.sign
  response.sign = nil
  if request.sign_type == 'MD5' and sign_str ~= hmac_md5_sign(response, opt.apikey) then
    return nil, "Sign : MD5签名验证失败"
  elseif request.sign_type == 'HMAC-SHA256' and sign_str ~= hmac_sha256_sign(response, opt.apikey) then
    return nil, "Sign: HMAC-SHA256签名验证失败"
  end
  response.sign = sign_str
  return response
end

-- 出错信息格式化
local function error_format(response)
  return fmt('["%s", "%s", "%s", "%s"]', 
      response['return_code'] or "unknown",
      response['return_msg'] or "unknown",
      response['err_code'] or "unknown",
      response['err_code_des'] or "unknown"
    )
end

-- 生成Nonce_str
local function gen_nonce()
  return md5(uuid(), true)
end

return {
  gen_nonce = gen_nonce,
  sign_varify = sign_varify,
  notice_varify = notice_varify,
  error_format = error_format,
  md5 = hmac_md5_sign,
  hmac_sha256 = hmac_sha256_sign,
}