
local json = require "json"
local httpc = require "httpc"
local sign = require "cloud.alipay.sign"
local domains = require "cloud.alipay.domains"

local type = type
local assert = assert
local tonumber = tonumber

local fmt = string.format

local wap = { __Version__ = 0.1, domains = domains }


function wap.pay( opt )
  assert(type(opt) == 'table', "invalide parameters.")
  -- 支付宝APPID
  assert(type(opt.appid) == 'string' and opt.appid ~= '' , "invalide appid.")
  -- 支付宝RSA2密钥路径
  assert(type(opt.key_path) == 'string' and opt.key_path ~= '' , "invalide key_path.")
  -- 支付宝订单号
  assert(type(opt.trade_no) == 'string' and opt.trade_no ~= '' , "invalide trade_no.")
  -- 支付宝的金额单位是(元)
  assert(tonumber(opt.amount) and tonumber(opt.amount) >= 0.01 , "invalide amount.")
  -- 支付宝的订单标题
  assert(type(opt.title) == 'string' and opt.title ~= '' , "invalide title.")
  -- 支付宝的订单描述
  -- assert(type(opt.describe) == 'string' and opt.describe ~= '' , "invalide describe.")

  -- local jsonify = fmt([[{"body":"%s","out_trade_no":"%s","product_code","FAST_INSTANT_TRADE_PAY","subject":"%s","total_amount":"%s"}]], opt.describe or "", opt.trade_no, opt.title, opt.amount)
  -- local sig = sign.rsa_sign(jsonify, opt.key_path)
  -- local req = {
  --   {"app_id", opt.appid},
  --   {"method", "alipay.trade.page.pay"},
  --   {"format", "JSON"},
  --   {"charset", "utf-8"},
  --   {"sign_type", "RSA2"},
  --   -- {"sign", sig},
  --   {"timestamp", os.date("%Y-%m-%d %H:%M:%S")},
  --   {"version",  "1.0"},
  --   {"biz_content", jsonify},
  -- }
  local req = {
    app_id = opt.appid,
    method = "alipay.trade.wap.pay",
    format = "JSON",
    charset = "utf-8",
    sign_type = "RSA2",
    -- {"sign", sig},
    timestamp = os.date("%Y-%m-%d %H:%M:%S"),
    version = "1.0",
    biz_content = json.encode {
      body = opt.describe,
      out_trade_no = opt.out_trade_no,
      subject = opt.title,
      product_code = "FAST_INSTANT_TRADE_PAY",
      total_amount = opt.amout,
    },
  }
  -- var_dump(req)
  -- print(jsonify)
  local sig, t = sign.rsa_sign(req, opt.key_path)
  -- print(sig)
  req.sign = sign
  -- print(json.encode (req))
  local code, response = httpc.json(wap.domains[1], nil, json.encode (req))
  -- local code, response = httpc.json(wap.domains[1], nil, table.concat(t, "&"))
  if code ~= 200 then
    return nil, response
  end
  local response_json = json.decode(response)
  if type(response_json) ~= 'table' then
    return nil, response
  end
  return response_json
end


return wap