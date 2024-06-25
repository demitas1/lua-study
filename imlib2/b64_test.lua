package.path = './?.lua;' .. package.path

local socket = require("socket")
local mime = require("mime")

local base64 = require("base64")


-- Function to encode data in Base64
local function base64_encode(data)
    return (mime.b64(data))
end

-- Function to decode Base64 data
local function base64_decode(data)
    return (mime.unb64(data))
end

-- Test the functions
local test_data = "Hello, World!"
local encoded_data = base64_encode(test_data)
local decoded_data = base64_decode(encoded_data)

print("Original Data: " .. test_data)
print("Encoded Data: " .. encoded_data)
print("Decoded Data: " .. decoded_data)

-- Test base64.lua
local enc_data = base64.enc(test_data)
local dec_data = base64.dec(enc_data)

print("Original Data: " .. test_data)
print("Encoded Data: " .. enc_data)
print("Decoded Data: " .. dec_data)
