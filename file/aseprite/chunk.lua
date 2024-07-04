-- Require the struct library
local struct = require("struct")


-- Define the Chunk class
local Chunk = {}
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


local aseprite_chunk = {
    Chunk = Chunk,
}
return aseprite_chunk
