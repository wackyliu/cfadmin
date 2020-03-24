--[[
  微信支付SDK v0.1
  (Native)扫码支付
]]

local httpc = require "httpc"
local xml2lua = require "xml2lua"
local domains = require "cloud.wechat.domains"
local sign = require "cloud.wechat.sign"
local order = require "cloud.wechat.order"

local type = type
local next = next
local tonumber = tonumber

-- 验证域名是否规范
local function is_domain(URI)
  if not URI or URI == '' then
    return nil
  end
  return string.find(URI, "http[s]://[^/]+/.*")
end


local native = { __Version__ = 0.1, domains = domains }

-- 验证请求返回签名(请勿在外部调用)
native.sign_varify = sign.sign_varify

-- 出错信息格式化(请勿在外部调用)
native.error_format = sign.error_format

-- 查询订单
native.native_query = order.query

-- 关闭订单
native.native_close = order.close

--[[

1. NATIVE(扫码)支付下单

appid         --  公众号APPID,
apikey     --  API KEY,
mch_id        --  支付商户号,
amount        --  支付金额(分),
amount_type   -- 币种(默认CNY),
trade_no      --  支付订单号,
describe      --  商品描述,
opt.ip        --  指定客户端IP(当前版本可不指定)
sign_type     --  签名类型(MD5/HMAC-SHA256),
notify_url    --  交易成功的回调地址,
receipt       --  电子发票入口开放标识,
limit_pay     --  limit_pay == true 则不允许信用卡支付,

]]
function native.native_pay( opt )
  assert(type(opt) == 'table' and next(opt), "invalide parameters.")
  -- appid 必须是string类型并且不能为空
  assert(type(opt.appid) == 'string' and opt.appid ~= '', "invalide appid.")
  -- apikey 必须是string类型并且不能为空
  assert(type(opt.apikey) == 'string' and opt.apikey ~= '', "invalide apikey.")
  -- mch_id 必须是string类型并且不能为空
  assert(type(opt.mch_id) == 'string' and opt.mch_id ~= '', "invalide mch_id.")
  -- trade_no 必须是string类型并且不能为空
  assert(type(opt.trade_no) == 'string' and opt.trade_no ~= '', "invalide trade_no.")
  -- product_id 必须是string类型并且不能为空
  -- assert((type(opt.product_id) == 'string' or tonumber(opt.product_id)) and opt.product_id ~= '', "invalide product_id.")
  -- describe 必须是string类型并且不能为空
  assert(type(opt.describe) == 'string' and opt.describe ~= '', "invalide describe.")
  -- sign_type 必须是HMAC-SHA256或者MD5其中一个
  assert(opt.sign_type == 'HMAC-SHA256' or opt.sign_type == 'MD5', "invalide sign_type(need HMAC-SHA256 or MD5).")
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
    trade_type = "NATIVE",
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

  local code, response = httpc.raw { domain = native.domains[1] .. '/pay/unifiedorder', method = "POST", headers = {{ "Content-Type", "application/xml;"}}, body = xml2lua.toxml(req, "xml") }
  if code ~= 200 then
    if code == nil then
      code, response = httpc.raw { domain = native.domains[2] .. '/pay/unifiedorder', method = "POST", headers = {{ "Content-Type", "application/xml;"}}, body = xml2lua.toxml(req, "xml") }
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
    return nil, native.error_format(response)
  end

  -- 签名验证
  return native.sign_varify(opt, req, response)
end

--[[
  2. NATIVE回调通知内容验证
  response --  回调内容
  apikey -- API KEY
]]
native.native_notice_varify = sign.notice_varify

return native