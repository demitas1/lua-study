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

-- Define the FrameHeader class
FrameHeader = {}
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

-- Define the Chunk class
Chunk = {}
Chunk.__index = Chunk

-- Constructor for Chunk
function Chunk:new()
    local self = setmetatable({}, Chunk)
    self.chunk_size = 0
    self.chunk_type = 0
    self.chunk_data = ""
    return self
end

-- Method to read the chunk from a file
function Chunk:read(file)
    local chunk_header_format = "<I4I2"
    local header_data = file:read(6) -- Read 6 bytes for the chunk header

    if not header_data or #header_data < 6 then
        error("Failed to read complete chunk header: file might be incomplete or corrupt.")
    end

    local unpacked_header = {struct.unpack(chunk_header_format, header_data)}

    self.chunk_size = unpacked_header[1]
    self.chunk_type = unpacked_header[2]

    local data_size = self.chunk_size - 6
    if data_size > 0 then
        self.chunk_data = file:read(data_size)
    else
        self.chunk_data = ""
    end

    if not self.chunk_data or #self.chunk_data < data_size then
        error("Failed to read complete chunk data: file might be incomplete or corrupt.")
    end
end

-- Define the LayerChunk class
LayerChunk = setmetatable({}, Chunk)
LayerChunk.__index = LayerChunk

-- Constructor for LayerChunk
function LayerChunk:new()
    local self = Chunk:new()
    setmetatable(self, LayerChunk)
    self.flags = 0
    self.layer_type = 0
    self.layer_child_level = 0
    self.default_layer_width = 0
    self.default_layer_height = 0
    self.blend_mode = 0
    self.opacity = 0
    self.future = ""
    self.layer_name = ""
    self.tileset_index = nil
    return self
end

function LayerChunk:parse()
    -- Debug: Dump chunk_data
    print("LayerChunk data dump:")
    for i = 1, #self.chunk_data do
        io.write(string.format("%02X ", self.chunk_data:byte(i)))
    end
    print("\n")

    local layer_header_format = "<I2I2I2I2I2I2I1c3"
    local unpacked_data = {struct.unpack(layer_header_format, self.chunk_data)}

    self.flags = unpacked_data[1]
    self.layer_type = unpacked_data[2]
    self.layer_child_level = unpacked_data[3]
    self.default_width = unpacked_data[4]
    self.default_height = unpacked_data[5]
    self.blend_mode = unpacked_data[6]
    self.opacity = unpacked_data[7]
    -- Ignore the next 3 bytes for future use

    local name_start = struct.size(layer_header_format) + 1
    local name_length = #self.chunk_data - name_start
    if self.layer_type == 2 then
        name_length = name_length - 4
    end

    print(string.format("  header size: %d", struct.size(layer_header_format)))
    print(string.format("  name_start: %d", name_start))
    print(string.format("  layer_type: %d", self.layer_type))
    print(string.format("  chunk_size: %d", self.chunk_size))
    print(string.format("  (#chunk_data): %d", #self.chunk_data))
    print(string.format("  name_length: %d", name_length))

    self.layer_name = struct.unpack("c" .. name_length, self.chunk_data, name_start)

    if self.layer_type == 2 then
        self.tileset_index = struct.unpack("<I4", self.chunk_data, name_start + name_length)
    end
end


-- Function to read a chunk and handle LayerChunk specifically
function read_chunk(file)
    local chunk = Chunk:new()
    chunk:read(file)
    if chunk.chunk_type == 0x2004 then
        local layer_chunk = LayerChunk:new()
        layer_chunk.chunk_size = chunk.chunk_size
        layer_chunk.chunk_type = chunk.chunk_type
        layer_chunk.chunk_data = chunk.chunk_data
        layer_chunk:parse()
        return layer_chunk
    else
        return chunk
    end
end

-- Main function to read the header and frames of an Aseprite file
function read_aseprite_file(filename)
    local file = assert(io.open(filename, "rb"), "Failed to open file.")
    local header = AsepriteHeader:new()

    local status, err = pcall(function()
        header:read(file)

        header.all_frames = {}  -- TODO: better class to store frames
        for i = 1, header.frames do
            local frame = FrameHeader:new()
            frame:read(file)

            local chunk_count = frame.new_chunks > 0 and frame.new_chunks or frame.old_chunks
            for j = 1, chunk_count do
                local chunk = read_chunk(file)
                table.insert(frame.chunks, chunk)
                print(string.format("  Chunk: type 0x%04x", chunk.chunk_type))
            end
            table.insert(header.all_frames, frame)
        end
    end)

    file:close()

    if not status then
        error("Error reading Aseprite file: " .. err)
    end

    return header
end

-- Main program
local filename = arg[1]
if not filename then
    error("Usage: lua read_aseprite.lua <aseprite_file>")
end

local header = read_aseprite_file(filename)
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

