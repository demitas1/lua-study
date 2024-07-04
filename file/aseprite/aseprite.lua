local aseprite_header = require("aseprite/header")
local aseprite_frame_header = require("aseprite/frame_header")
local aseprite_chunk = require("aseprite/chunk")
local aseprite_layer_chunk = require("aseprite/layer_chunk")


-- Define the module table to export
local aseprite = {
    AsepriteHeader = aseprite_header.AsepriteHeader,
    FrameHeader = aseprite_frame_header.FrameHeader,
    Chunk = aseprite_chunk.Chunk,
    LayerChunk = aseprite_layer_chunk.LayerChunk,
}
return aseprite
