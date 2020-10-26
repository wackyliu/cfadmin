local CRYPT = require "lcrypt"

local sys = require "sys"
local now = sys.now
local hostname = sys.hostname
local modf = math.modf

local uuid = CRYPT.uuid
local guid = CRYPT.guid

local md5 = CRYPT.md5
local hmac64 = CRYPT.hmac64
local hmac_md5 = CRYPT.hmac_md5
local hmac64_md5 = CRYPT.hmac64_md5

local sha1 = CRYPT.sha1
local sha224 = CRYPT.sha224
local sha256 = CRYPT.sha256
local sha384 = CRYPT.sha384
local sha512 = CRYPT.sha512

local hmac_sha1 = CRYPT.hmac_sha1
local hmac_sha256 = CRYPT.hmac_sha256
local hmac_sha512 = CRYPT.hmac_sha512

local crc32 = CRYPT.crc32
local crc64 = CRYPT.crc64

local xor_str = CRYPT.xor_str
local hashkey = CRYPT.hashkey
local randomkey = CRYPT.randomkey

local hmac_hash = CRYPT.hmac_hash

local base64encode = CRYPT.base64encode
local base64decode = CRYPT.base64decode

local hexencode = CRYPT.hexencode
local hexdecode = CRYPT.hexdecode

local desencode = CRYPT.desencode
local desdecode = CRYPT.desdecode

local dhsecret = CRYPT.dhsecret
local dhexchange = CRYPT.dhexchange

local urlencode = CRYPT.urlencode
local urldecode = CRYPT.urldecode

local aes_ecb_encrypt = CRYPT.aes_ecb_encrypt
local aes_ecb_decrypt = CRYPT.aes_ecb_decrypt

local aes_cbc_encrypt = CRYPT.aes_cbc_encrypt
local aes_cbc_decrypt = CRYPT.aes_cbc_decrypt

-- 填充方式
local RSA_NO_PADDING = CRYPT.RSA_NO_PADDING
local RSA_PKCS1_PADDING = CRYPT.RSA_PKCS1_PADDING
local RSA_PKCS1_OAEP_PADDING = CRYPT.RSA_PKCS1_OAEP_PADDING

local rsa_public_key_encode = CRYPT.rsa_public_key_encode
local rsa_private_key_decode = CRYPT.rsa_private_key_decode

local rsa_private_key_encode = CRYPT.rsa_private_key_encode
local rsa_public_key_decode = CRYPT.rsa_public_key_decode

-- 当前支持的签名与验签
local rsa_algorithms = {
  ["md5"]     =  CRYPT.nid_md5,
  ["sha1"]    =  CRYPT.nid_sha1,
  ["sha128"]  =  CRYPT.nid_sha1,
  ["sha256"]  =  CRYPT.nid_sha256,
  ["sha512"]  =  CRYPT.nid_sha512,
}

-- 当前支持的签名与验签方法
local rsa_sign = CRYPT.rsa_sign
local rsa_verify = CRYPT.rsa_verify

local crypt = {}

function crypt.uuid()
  return uuid()
end

-- hash(主机名)-时间戳-微秒-(1~65535的随机数)
function crypt.guid(host)
  local hi, lo = modf(now())
  return guid(host or hostname(), hi, lo * 1e4 // 1)
end

function crypt.md5(str, hex)
  local hash = md5(str)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.hmac_md5 (key, text, hex)
  local hash = hmac_md5(key, text)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.sha1(str, hex)
  local hash = sha1(str)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

crypt.sha128 = crypt.sha1

function crypt.sha224 (str, hex)
  local hash = sha224(str)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.sha256 (str, hex)
  local hash = sha256(str)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.sha384 (str, hex)
  local hash = sha384(str)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.sha512 (str, hex)
  local hash = sha512(str)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end


function crypt.hmac_sha1 (key, text, hex)
  local hash = hmac_sha1(key, text)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

crypt.hmac_sha128 = crypt.hmac_sha1

function crypt.hmac_sha256 (key, text, hex)
  local hash = hmac_sha256(key, text)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.hmac_sha512 (key, text, hex)
  local hash = hmac_sha512(key, text)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.xor_str (text, key, hex)
  local hash = xor_str(text, key)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.randomkey(hex)
  local hash = randomkey(8)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.randomkey_ex(byte, hex)
  local hash = randomkey(byte)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.hashkey (key, hex)
  local hash = hashkey(key)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.hmac_hash (key, text, hex)
  local hash = hmac_hash(key, text)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.hmac64 (key, text, hex)
  local hash = hmac64(key, text)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.hmac64_md5 (key, text, hex)
  local hash = hmac64_md5(key, text)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.aes_128_cbc_encrypt(key, text, iv, hex)
  local hash = aes_cbc_encrypt(16, #key == 16 and key or nil, text, iv)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.aes_128_ecb_encrypt(key, text, iv, hex)
  local hash = aes_ecb_encrypt(16, #key == 16 and key or nil, text, iv)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.aes_192_cbc_encrypt(key, text, iv, hex)
  local hash = aes_cbc_encrypt(24, #key == 24 and key or nil, text, iv)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.aes_192_ecb_encrypt(key, text, iv, hex)
  local hash = aes_ecb_encrypt(24, #key == 24 and key or nil, text, iv)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.aes_256_cbc_encrypt(key, text, iv, hex)
  local hash = aes_cbc_encrypt(32, #key == 32 and key or nil, text, iv)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.aes_256_ecb_encrypt(key, text, iv, hex)
  local hash = aes_ecb_encrypt(32, #key == 32 and key or nil, text, iv)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.aes_128_cbc_decrypt(key, text, iv, hex)
  if hex then
    text = hexdecode(text)
  end
  return aes_cbc_decrypt(16, #key == 16 and key or nil, text, iv)
end

function crypt.aes_128_ecb_decrypt(key, text, iv, hex)
  if hex then
    text = hexdecode(text)
  end
  return aes_ecb_decrypt(16, #key == 16 and key or nil, text, iv)
end

function crypt.aes_192_cbc_decrypt(key, text, iv, hex)
  if hex then
    text = hexdecode(text)
  end
  return aes_cbc_decrypt(24, #key == 24 and key or nil, text, iv)
end

function crypt.aes_192_ecb_decrypt(key, text, iv, hex)
  if hex then
    text = hexdecode(text)
  end
  return aes_ecb_decrypt(24, #key == 24 and key or nil, text, iv)
end

function crypt.aes_256_cbc_decrypt(key, text, iv, hex)
  if hex then
    text = hexdecode(text)
  end
  return aes_cbc_decrypt(32, #key == 32 and key or nil, text, iv)
end

function crypt.aes_256_ecb_decrypt(key, text, iv, hex)
  if hex then
    text = hexdecode(text)
  end
  return aes_ecb_decrypt(32, #key == 32 and key or nil, text, iv)
end

function crypt.base64urlencode(data)
  return base64encode(data):gsub('+', '-'):gsub('/', '_')
end

function crypt.base64urldecode(data)
  return base64decode(data:gsub('-', '+'):gsub('_', '/'))
end

function crypt.base64encode (...)
  return base64encode(...)
end

function crypt.base64decode (...)
  return base64decode(...)
end

function crypt.hexencode (...)
  return hexencode(...)
end

function crypt.hexdecode (...)
  return hexdecode(...)
end

function crypt.desencode (key, text, hex)
  local hash = desencode(key, text)
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

function crypt.desdecode (key, text, hex)
  if hex then
    text = hexdecode(text)
  end
  return desdecode(key, text)
end

function crypt.dhsecret (...)
  return dhsecret(...)
end

function crypt.dhexchange (...)
  return dhexchange(...)
end

function crypt.crc32 (...)
  return crc32(...)
end

function crypt.crc64 (...)
  return crc64(...)
end

function crypt.urldecode (...)
  return urldecode(...)
end

function crypt.urlencode (...)
  return urlencode(...)
end

-- text 为原始文本内容, public_key_path 为公钥路径, b64 为是否为结果进行base64编码
function crypt.rsa_public_key_encode(text, public_key_path, b64)
  local hash = rsa_public_key_encode(text, public_key_path, RSA_PKCS1_PADDING)
  if hash and b64 then
    return base64encode(hash)
  end
  return hash
end

function crypt.rsa_public_key_oaep_padding_encode(text, public_key_path, b64)
  local hash = rsa_public_key_encode(text, public_key_path, RSA_PKCS1_OAEP_PADDING)
  if hash and b64 then
    return base64encode(hash)
  end
  return hash
end

-- text 为加密后的内容, private_key_path 为私钥路径, b64 为是否为text先进行base64解码
function crypt.rsa_private_key_decode(text, private_key_path, b64)
  return rsa_private_key_decode(b64 and base64decode(text) or text, private_key_path, RSA_PKCS1_PADDING)
end

function crypt.rsa_private_key_oaep_padding_decode(text, private_key_path, b64)
  return rsa_private_key_decode(b64 and base64decode(text) or text, private_key_path, RSA_PKCS1_OAEP_PADDING)
end


-- text 为原始文本内容, private_key_path 为公钥路径, b64 为是否为结果进行base64编码
function crypt.rsa_private_key_encode(text, private_key_path, b64)
  local hash = rsa_private_key_encode(text, private_key_path, RSA_PKCS1_PADDING)
  if hash and b64 then
    return base64encode(hash)
  end
  return hash
end

function crypt.rsa_private_key_oaep_padding_encode(text, private_key_path, b64)
  local hash = rsa_private_key_encode(text, private_key_path, RSA_PKCS1_OAEP_PADDING)
  if hash and b64 then
    return base64encode(hash)
  end
  return hash
end

-- text 为加密后的内容, public_key_path 为公钥路径, b64 为是否为text先进行base64解码
function crypt.rsa_public_key_decode(text, public_key_path, b64)
  return rsa_public_key_decode(b64 and base64decode(text) or text, public_key_path, RSA_PKCS1_PADDING)
end

function crypt.rsa_public_key_oaep_padding_decode(text, public_key_path, b64)
  return rsa_public_key_decode(b64 and base64decode(text) or text, public_key_path, RSA_PKCS1_OAEP_PADDING)
end

-- RSA签名函数: 第一个参数是等待签名的明文, 第二个参数是私钥所在路径, 第三个参数是算法名称, 第四个参数决定是否以hex输出
function crypt.rsa_sign(text, private_key_path, algorithm, hex)
  local hash = rsa_sign(text, private_key_path, rsa_algorithms[(algorithm or ""):lower()] or rsa_algorithms["md5"])
  if hash and hex then
    return hexencode(hash)
  end
  return hash
end

-- RSA验签函数: 第一个参数是等待签名的明文, 第二个参数是私钥所在路径, 第三个参数为签名sign密文, 第四个参数是算法名称, 第五个参数决定是否对sign进行unhex
function crypt.rsa_verify(text, public_key_path, sign, algorithm, hex)
  if hex then
    sign = hexdecode(sign)
  end
  return rsa_verify(text, public_key_path, sign, rsa_algorithms[(algorithm or ""):lower()] or rsa_algorithms["md5"])
end

return crypt