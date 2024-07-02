-- Require the struct library
local struct = require("struct")

-- Define the AsepriteHeader class
AsepriteHeader = {}
AsepriteHeader.__index = AsepriteHeader

-- Constructor for AsepriteHeader
function AsepriteHeader:new()
    local self = setmetatable({}, AsepriteHeader)
    self.file_size = 0
    self.magic_number = 0
    self.frames = 0
    self.width = 0
    self.height = 0
    self.color_depth = 0
    self.flags = 0
    self.speed = 0
    self.reserved1 = 0
    self.reserved2 = 0
    self.transparent_palette_entry = 0
    self.ignore_bytes = ""
    self.num_colors = 0
    self.pixel_width = 0
    self.pixel_height = 0
    self.grid_x = 0
    self.grid_y = 0
    self.grid_width = 0
    self.grid_height = 0
    self.future = ""
    return self
end

-- Method to read the header from a file
function AsepriteHeader:read(file)
    local header_format = "<I4I2I2I2I2I2I4I2I4I4I1c3I2I1I1i2i2I2I2c84"
    local data = file:read(128) -- Read 128 bytes for the header

    if not data or #data < 128 then
        error("Failed to read complete header: file might be incomplete or corrupt.")
    end

    local unpacked = {struct.unpack(header_format, data)}

    self.file_size = unpacked[1]
    self.magic_number = unpacked[2]
    self.frames = unpacked[3]
    self.width = unpacked[4]
    self.height = unpacked[5]
    self.color_depth = unpacked[6]
    self.flags = unpacked[7]
    self.speed = unpacked[8]
    self.reserved1 = unpacked[9]
    self.reserved2 = unpacked[10]
    self.transparent_palette_entry = unpacked[11]
    self.ignore_bytes = unpacked[12]
    self.num_colors = unpacked[13]
    self.pixel_width = unpacked[14]
    self.pixel_height = unpacked[15]
    self.grid_x = unpacked[16]
    self.grid_y = unpacked[17]
    self.grid_width = unpacked[18]
    self.grid_height = unpacked[19]
    self.future = unpacked[20]

    -- Check if magic number is correct
    if self.magic_number ~= 0xA5E0 then
        error(string.format("Invalid magic number: expected 0xA5E0, got 0x%04X", self.magic_number))
    end

    -- Check if reserved1 and reserved2 are zero
    if self.reserved1 ~= 0 or self.reserved2 ~= 0 then
        error("Invalid header: reserved1 and reserved2 must be zero.")
    end

    -- Check if future elements are all zero
    if self.future:match("[^%z]") then
        error("Invalid header: future elements must be all zero.")
    end
end

-- Main function to read the header of an Aseprite file
function read_aseprite_header(filename)
    local file = assert(io.open(filename, "rb"), "Failed to open file.")
    local header = AsepriteHeader:new()

    local status, err = pcall(function()
        header:read(file)
    end)

    file:close()

    if not status then
        error("Error reading Aseprite header: " .. err)
    end

    return header
end


-- Main program
local filename = arg[1]
if not filename then
    error("Usage: lua read_aseprite.lua <aseprite_file>")
end

local header = read_aseprite_header(filename)

print("File size:", header.file_size)
print("Magic number:", string.format("0x%04X", header.magic_number))
print("Frames:", header.frames)
print("Width:", header.width)
print("Height:", header.height)
print("Color depth:", header.color_depth)
print("Flags:", header.flags)
print("Speed:", header.speed)
print("Transparent palette entry:", header.transparent_palette_entry)
print("Number of colors:", header.num_colors)
print("Pixel width:", header.pixel_width)
print("Pixel height:", header.pixel_height)
print("Grid X:", header.grid_x)
print("Grid Y:", header.grid_y)
print("Grid width:", header.grid_width)
print("Grid height:", header.grid_height)

