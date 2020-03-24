local type = type
local assert = assert
local io_open = io.open
local find = string.find
local concat = table.concat
local insert = table.insert

--[[
RSA读取格式为: 
----- BEGIN -----
...base64内容...
----- END -----

支付宝生成的数据去掉了头尾, 所以我们必须用下面的代码将其转换为正常的内容.
]]

local PUBLIC_HEADER = "-----BEGIN PUBLIC KEY-----"
local PUBLIC_END = "-----END PUBLIC KEY-----"

local PRIVATE_HEADER = "-----BEGIN RSA PRIVATE KEY-----"
local PRIVATE_END = "-----END RSA PRIVATE KEY-----"

local function tanslate_set_rsa( t, typ )
  assert(typ == 'pub' or typ == 'pri', "invalide type.")
  if typ == 'pub' then
    insert(t, 1, PUBLIC_HEADER)
    insert(t, PUBLIC_END)
    -- insert(t, "")
    return concat(t, "\n")
  end
  if typ == 'pri' then
    insert(t, 1, PRIVATE_HEADER)
    insert(t, PRIVATE_END)
    -- insert(t, "")
    return concat(t, "\n")
  end
  return nil  
end

-- 转换成rsa文件读取格式
local function translate_splite( str )
  local t = {}
  local s = 1
  local len = 64
  while 1 do
    local splite = str:sub(s, s + len)
    if #splite < len then
      t[#t+1] = splite
      break
    end
    t[#t+1] = splite
    s = s + len + 1
  end
  return t
end

local function translate_rsa_from_file(public_key_path, private_key_path)
  assert(type(public_key_path) == 'string' or public_key_path ~= '', "invalide public_key_path")
  assert(type(private_key_path) == 'string' or private_key_path ~= '', "invalide private_key_path")
  local pub_f, err = io_open(public_key_path)
  local pri_f, err = io_open(private_key_path)
  if not pub_f or not pri_f then
    if pub_f then
      pub_f:close()
    end
    if pri_f then
      pri_f:close()
    end
    return pub_f, pri_f
  end
  local public_key = pub_f:read "*a"
  local private_key = pri_f:read "*a"
  pub_f:close()
  pri_f:close()
  if not find(public_key, "[%-]+") then
    public_key = tanslate_set_rsa(translate_splite(public_key), "pub")
  end
  if not find(private_key, "[%-]+") then
    private_key = tanslate_set_rsa(translate_splite(private_key), "pri")
  end
  return public_key, private_key
end

local function translate_rsa_from_string(public_key, private_key)
  assert(type(public_key) == 'string' and public_key ~= '', "invalide public_key")
  assert(type(private_key) == 'string' and private_key ~= '', "invalide private_key")
  return tanslate_set_rsa(translate_splite(public_key), "pub"), tanslate_set_rsa(translate_splite(private_key), "pri")
end

return { 
  __Version__ = 0.1,
  -- 从文件中将内容读取出来转换为标准格式字符串.
  translate_rsa_from_file = translate_rsa_from_file,
  -- 从字符串中将内容转换为标准格式字符串.
  translate_rsa_from_string = translate_rsa_from_string,
}