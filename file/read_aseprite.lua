package.path = './?.lua;' .. package.path

-- Require the struct library
local struct = require("struct")

local aseprite = require("aseprite/aseprite")


-- Function to read a chunk and handle LayerChunk specifically
function read_chunk(file)
    local chunk = aseprite.Chunk:new()
    chunk:read(file)
    if chunk.chunk_type == 0x2004 then
        local layer_chunk = aseprite.LayerChunk:new()
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
    local header = aseprite.AsepriteHeader:new()

    local status, err = pcall(function()
        header:read(file)

        header.all_frames = {}  -- TODO: better class to store frames
        for i = 1, header.frames do
            local frame = aseprite.FrameHeader:new()
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

-- TODO: return header and frames classes and print them
