-- Require the struct library
local struct = require("struct")

local aseprite_chunk = require("aseprite/chunk")


-- Define the LayerChunk class
local LayerChunk = setmetatable({}, Chunk)
LayerChunk.__index = LayerChunk

-- Constructor for LayerChunk
function LayerChunk:new()
    local self = aseprite_chunk.Chunk:new()
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
    local name_length = #self.chunk_data - name_start + 1
    if self.layer_type == 2 then
        name_length = name_length - 4
    end

    print(string.format("  header size: %d", struct.size(layer_header_format)))
    print(string.format("  name_start: %d", name_start))
    print(string.format("  layer_type: %d", self.layer_type))
    print(string.format("  chunk_size: %d", self.chunk_size))
    print(string.format("  (#chunk_data): %d", #self.chunk_data))
    print(string.format("  name_length: %d", name_length))

    -- TODO: make this separate function
    -- extract layer_name: "<I2cn" WORD: length, BYTE[n]: utf8 bytes
    local layer_string = {struct.unpack("<I2c" .. (name_length - 2), self.chunk_data, name_start)}
    self.layer_name = layer_string[2]
    print(string.format("  layer_name: %s", self.layer_name))

    if self.layer_type == 2 then
        self.tileset_index = struct.unpack("<I4", self.chunk_data, name_start + name_length)
    end
end




local aseprite_layer_chunk = {
    LayerChunk = LayerChunk,
}
return aseprite_layer_chunk
