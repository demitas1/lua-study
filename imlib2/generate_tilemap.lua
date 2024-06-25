package.path = './?.lua;' .. package.path

require("image_hasher")


--
-- main
--
local image_path_tilemap = "level1-working/Tilemap - Wall1.png"
local image_path_tileset = "level1-working/tilemap-test1-Sheet-wall.png"

local hasher = ImageHasher:new()
local image_path = image_path_tilemap
hasher:load_image(image_path, 16, 16, 'sha1')


-- Lookup hash for a specific cell_id
local cell_id = 0
local hash = hasher:lookup(cell_id)
if hash then
    print(string.format("Cell ID %d has hash %s", cell_id, hash))
else
    print(string.format("Cell ID %d not found", cell_id))
end


-- Iterate over the whole hash
for entry in hasher:iter() do
    print(entry.cell_id, entry.cell_hash)
end
