-- Require the struct library
local struct = require("struct")


-- Define the FrameHeader class
local FrameHeader = {}
FrameHeader.__index = FrameHeader

-- Constructor for FrameHeader
function FrameHeader:new()
    local self = setmetatable({}, FrameHeader)
    self.bytes_in_frame = 0
    self.magic_number = 0
    self.old_chunks = 0
    self.duration = 0
    self.future = ""
    self.new_chunks = 0
    self.chunks = {}
    return self
end

-- Method to read the frame header from a file
function FrameHeader:read(file)
    local frame_header_format = "<I4I2I2I2c2I4"
    local data = file:read(16) -- Read 16 bytes for the frame header

    if not data or #data < 16 then
        error("Failed to read complete frame header: file might be incomplete or corrupt.")
    end

    local unpacked = {struct.unpack(frame_header_format, data)}

    self.bytes_in_frame = unpacked[1]
    self.magic_number = unpacked[2]
    self.old_chunks = unpacked[3]
    self.duration = unpacked[4]
    self.future = unpacked[5]
    self.new_chunks = unpacked[6]

    -- Check if magic number is correct
    if self.magic_number ~= 0xF1FA then
        error(string.format("Invalid magic number in frame header: expected 0xF1FA, got 0x%04X", self.magic_number))
    end

    -- Check if future elements are all zero
    if self.future:match("[^%z]") then
        error("Invalid frame header: future elements must be all zero.")
    end
end



local aseprite_frame_header = {
    FrameHeader = FrameHeader,
}
return aseprite_frame_header
