--[[
  微信支付SDK v0.1
  提交(付款码)支付
]]

local httpc = require "httpc"
local xml2lua = require "xml2lua"
local domains = require "cloud.wechat.domains"
local sign = require "cloud.wechat.sign"
local order = require "cloud.wechat.order"

local type = type
local next = next
local tostring = tostring
local tonumber = tonumber

-- 验证域名是否规范
local function is_domain(URI)
  if not URI or URI == '' then
    return nil
  end
  return string.find(URI, "http[s]://[^/]+/.*")
end



local micro = { __Version__ = 0.1, domains = domains }

-- 验证请求返回签名(请勿在外部调用)
micro.sign_varify = sign.sign_varify

-- 出错信息格式化(请勿在外部调用)
micro.error_format = sign.error_format

-- 查询订单
micro.micro_query = order.query

-- 关闭订单
micro.micro_close = order.close

--[[

  1. 付款码下单

]]
function micro.micro_pay( opt )
  assert(type(opt) == 'table' and next(opt), "invalide parameters.")
  -- appid 必须是string类型并且不能为空
  assert(type(opt.appid) == 'string' and opt.appid ~= '', "invalide appid.")
  -- apikey 必须是string类型并且不能为空
  assert(type(opt.apikey) == 'string' and opt.apikey ~= '', "invalide apikey.")
  -- mch_id 必须是string类型并且不能为空
  assert(type(opt.mch_id) == 'string' and opt.mch_id ~= '', "invalide mch_id.")
  -- trade_no 必须是string类型并且不能为空
  assert(type(opt.trade_no) == 'string' and opt.trade_no ~= '', "invalide trade_no.")
  -- describe 必须是string类型并且不能为空
  assert(type(opt.describe) == 'string' and opt.describe ~= '', "invalide describe.")
  -- sign_type 必须是HMAC-SHA256或者MD5其中一个
  assert(opt.sign_type == 'HMAC-SHA256' or opt.sign_type == 'MD5', "invalide sign_type(need HMAC-SHA256 or MD5).")
  -- auth_code 必须是string类型并且不能为空
  assert(type(opt.auth_code) == 'string' and opt.auth_code ~= '', "invalide auth_code.")
  -- openid 必须是string类型并且不能为空
  assert(type(opt.openid) == 'string' and opt.openid ~= '', "invalide openid.")
  -- notify_url 必须是一个可以正确回应的微信支付后回调的url
  assert(type(opt.notify_url) == 'string' and is_domain(opt.notify_url), "invalide notify_url.")
  -- amount 必须是是整数类型
  assert(math.tointeger(opt.amount), "invalide amoun.")

  -- 初始化参数
  local req = {
    appid = opt.appid,
    mch_id = opt.mch_id,
    total_fee = opt.amount,
    product_id = opt.product_id,
    fee_type = opt.amount_type or "CNY",
    nonce_str = sign.gen_nonce(),
    auth_code = opt.auth_code,
    openid = opt.openid,
    out_trade_no = opt.trade_no,
    body = opt.describe,
    receipt = opt.receipt and "Y" or nil,
    notify_url = opt.notify_url,
    limit_pay = opt.limit_pay and "no_credit" or nil,
    spbill_create_ip = opt.ip,
    attach = opt.customize,
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

  local code, response = httpc.raw { domain = micro.domains[1] .. '/pay/micropay', method = "POST", headers = {{ "Content-Type", "application/xml;"}}, body = xml2lua.toxml(req, "xml") }
  if code ~= 200 then
    if code == nil then
      code, response = httpc.raw { domain = micro.domains[2] .. '/pay/micropay', method = "POST", headers = {{ "Content-Type", "application/xml;"}}, body = xml2lua.toxml(req, "xml") }
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
    return nil, micro.error_format(response)
  end

  -- 签名验证
  return micro.sign_varify(opt, req, response)
end

return micro