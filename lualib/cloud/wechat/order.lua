--[[
  微信支付SDK v0.1
  (Native)扫码支付
]]

local httpc = require "httpc"
local xml2lua = require "xml2lua"
local sign = require "cloud.wechat.sign"
local domains = require "cloud.wechat.domains"

local type = type
local next = next
local assert = assert

-- 验证域名是否规范
local function is_domain(URI)
  if not URI or URI == '' then
    return nil
  end
  return string.find(URI, "http[s]://[^/]+/.*")
end


local order = { __Version__ = 0.1, domains = domains }

-- 验证请求返回签名(请勿在外部调用)
order.sign_varify = sign.sign_varify

-- 出错信息格式化(请勿在外部调用)
order.error_format = sign.error_format

--[[

1. 查询order订单

appid          --  微信支付分配的公众账号ID（企业号corpid即为此appId）
mch_id         --  微信支付分配的商户号
out_trade_no   --  商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*@ ，且在同一个商户号下唯一。 详见商户订单号
nonce_str      --  随机字符串，不长于32位。推荐随机数生成算法
sign           --  通过签名算法计算得出的签名值，详见签名生成算法
sign_type      --  HMAC-SHA256 签名类型，目前支持HMAC-SHA256和MD5，默认为MD5

]]
function order.query( opt )
  assert(type(opt) == 'table' and next(opt), "invalide parameters.")
  -- appid 必须是string类型并且不能为空
  assert(type(opt.appid) == 'string' and opt.appid ~= '', "invalide appid")
  -- apikey 必须是string类型并且不能为空
  assert(type(opt.apikey) == 'string' and opt.apikey ~= '', "invalide apikey")
  -- mch_id 必须是string类型并且不能为空
  assert(type(opt.mch_id) == 'string' and opt.mch_id ~= '', "invalide mch_id")
  -- trade_no 必须是string类型并且不能为空
  assert(type(opt.trade_no) == 'string' and opt.trade_no ~= '', "invalide trade_no")

  local req = {
    appid = opt.appid,
    mch_id = opt.mch_id,
    out_trade_no = opt.trade_no,
    nonce_str = sign.gen_nonce(),
  }

  -- 签名
  local sign_str = nil
  if opt.sign_type == 'MD5' then
    opt.sign_type = "MD5"
    req.sign_type = "MD5"
    req.sign = sign.md5(req, opt.apikey)
  else
    opt.sign_type = "HMAC-SHA256"
    req.sign_type = "HMAC-SHA256"
    req.sign = sign.hmac_sha256(req, opt.apikey)
  end

  local code, response = httpc.raw { domain = order.domains[1] .. '/pay/orderquery', method = "POST", headers = {{ "Content-Type", "application/xml;"}}, body = xml2lua.toxml(req, "xml") }
  if code ~= 200 then
    if code == nil then
      code, response = httpc.raw { domain = order.domains[2] .. '/pay/orderquery', method = "POST", headers = {{ "Content-Type", "application/xml;"}}, body = xml2lua.toxml(req, "xml") }
    end
    if code ~= 200 then
      return nil, response
    end
  end
  -- print(response)
  response = xml2lua.parser(response)
  if type(response) ~= 'table' then
    return nil, "invalide response"
  end
  -- var_dump(response)
  response = response['xml']
  if response['result_code'] ~= 'SUCCESS' then
    return nil, order.error_format(response)
  end

  -- 签名验证
  return order.sign_varify(opt, req, response, apikey)
end


--[[

2. 关闭order订单

appid          --  微信支付分配的公众账号ID（企业号corpid即为此appId）
mch_id         --  微信支付分配的商户号
out_trade_no   --  商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*@ ，且在同一个商户号下唯一。 详见商户订单号
nonce_str      --  随机字符串，不长于32位。推荐随机数生成算法
sign           --  通过签名算法计算得出的签名值，详见签名生成算法
sign_type      --  HMAC-SHA256 签名类型，目前支持HMAC-SHA256和MD5，默认为MD5

]]
function order.close( opt )
  assert(type(opt) == 'table' and next(opt), "invalide parameters.")
  -- appid 必须是string类型并且不能为空
  assert(type(opt.appid) == 'string' and opt.appid ~= '', "invalide appid")
  -- apikey 必须是string类型并且不能为空
  assert(type(opt.apikey) == 'string' and opt.apikey ~= '', "invalide apikey")
  -- mch_id 必须是string类型并且不能为空
  assert(type(opt.mch_id) == 'string' and opt.mch_id ~= '', "invalide mch_id")
  -- trade_no 必须是string类型并且不能为空
  assert(type(opt.trade_no) == 'string' and opt.trade_no ~= '', "invalide trade_no")

  local req = {
    appid = opt.appid,
    mch_id = opt.mch_id,
    nonce_str = sign.gen_nonce(),
    out_trade_no = opt.trade_no,
  }

  -- 签名
  local sign_str = nil
  if opt.sign_type == 'MD5' then
    opt.sign_type = "MD5"
    req.sign_type = "MD5"
    req.sign = sign.md5(req, opt.apikey)
  else
    opt.sign_type = "HMAC-SHA256"
    req.sign_type = "HMAC-SHA256"
    req.sign = sign.hmac_sha256(req, opt.apikey)
  end

  local code, response = httpc.raw { domain = order.domains[1] .. '/pay/closeorder', method = "POST", headers = {{ "Content-Type", "application/xml;"}}, body = xml2lua.toxml(req, "xml") }
  if code ~= 200 then
    if code == nil then
      code, response = httpc.raw { domain = order.domains[2] .. '/pay/closeorder', method = "POST", headers = {{ "Content-Type", "application/xml;"}}, body = xml2lua.toxml(req, "xml") }
    end
    if code ~= 200 then
      return nil, response
    end
  end
  -- print(response)
  response = xml2lua.parser(response)
  if type(response) ~= 'table' then
    return nil, "invalide response"
  end
  -- var_dump(response)
  response = response['xml']
  if response['result_code'] ~= 'SUCCESS' then
    return nil, order.error_format(response)
  end

  -- 签名验证
  return order.sign_varify(opt, req, response, apikey)
end

--[[

  3. 退款订单(暂不支持)

  appid          --  微信支付分配的公众账号ID（企业号corpid即为此appId）
  mch_id         --  微信支付分配的商户号
  out_trade_no   --  商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*@ ，且在同一个商户号下唯一。 详见商户订单号
  nonce_str      --  随机字符串，不长于32位。推荐随机数生成算法
  sign           --  通过签名算法计算得出的签名值，详见签名生成算法
  sign_type      --  HMAC-SHA256 签名类型，目前支持HMAC-SHA256和MD5，默认为MD5

]]
function order.refund( opt )
  return nil, "暂不支持在线退款接口"
end

--[[

  4. 退款查询

  appid          --  微信支付分配的公众账号ID（企业号corpid即为此appId）
  mch_id         --  微信支付分配的商户号
  out_trade_no   --  商户系统内部订单号，要求32个字符内，只能是数字、大小写字母_-|*@ ，且在同一个商户号下唯一。 详见商户订单号
  nonce_str      --  随机字符串，不长于32位。推荐随机数生成算法
  sign           --  通过签名算法计算得出的签名值，详见签名生成算法
  sign_type      --  HMAC-SHA256 签名类型，目前支持HMAC-SHA256和MD5(默认为MD5)

]]
function order.refund_query( opt )
  assert(type(opt) == 'table' and next(opt), "invalide parameters.")
  -- appid 必须是string类型并且不能为空
  assert(type(opt.appid) == 'string' and opt.appid ~= '', "invalide appid")
  -- apikey 必须是string类型并且不能为空
  assert(type(opt.apikey) == 'string' and opt.apikey ~= '', "invalide apikey")
  -- mch_id 必须是string类型并且不能为空
  assert(type(opt.mch_id) == 'string' and opt.mch_id ~= '', "invalide mch_id")

  local req = {
    appid = opt.appid,
    mch_id = opt.mch_id,
    nonce_str = sign.gen_nonce(),
    transaction_id = opt.transaction_id,
    out_refund_no = opt.refund_no,
    out_refund_id = opt.refund_id,
    out_trade_no = opt.trade_no,
    offset = math.tointeger(opt.offset) and opt.offset or nil,
  }

  -- 签名
  local sign_str = nil
  if opt.sign_type == 'MD5' then
    opt.sign_type = "MD5"
    req.sign_type = "MD5"
    req.sign = sign.md5(req, opt.apikey)
  else
    opt.sign_type = "HMAC-SHA256"
    req.sign_type = "HMAC-SHA256"
    req.sign = sign.hmac_sha256(req, opt.apikey)
  end

  local code, response = httpc.raw { domain = order.domains[1] .. '/pay/refundquery', method = "POST", headers = {{ "Content-Type", "application/xml;"}}, body = xml2lua.toxml(req, "xml") }
  if code ~= 200 then
    if code == nil then
      code, response = httpc.raw { domain = order.domains[2] .. '/pay/refundquery', method = "POST", headers = {{ "Content-Type", "application/xml;"}}, body = xml2lua.toxml(req, "xml") }
    end
    if code ~= 200 then
      return nil, response
    end
  end
  -- print(response)
  response = xml2lua.parser(response)
  if type(response) ~= 'table' then
    return nil, "invalide response"
  end
  -- var_dump(response)
  response = response['xml']
  if response['result_code'] ~= 'SUCCESS' then
    return nil, order.error_format(response)
  end

  -- 签名验证
  return order.sign_varify(opt, req, response, apikey)
end

return order