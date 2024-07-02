package.path = './?.lua;' .. package.path

local image_hasher = require("image_hasher")


--
-- main
--
local image_path_tilemap_png = "level1-working/Tilemap - Wall1.png"
local image_path_tileset_png = "level1-working/tilemap-test1-Sheet-wall.png"

-- hash 16x16 cells of tilemap png
local hash_tilemap_png = image_hasher.ImageHasher:new()
hash_tilemap_png:load_image(image_path_tilemap_png, 16, 16, 'sha1')

-- hash 16x16 cells of tileset png
local hash_tileset_png = image_hasher.ImageHasher:new()
hash_tileset_png:load_image(image_path_tileset_png, 16, 16, 'sha1')



-- Lookup hash for a specific cell_id
local cell_id = 0
local cell = hash_tilemap_png:lookup(cell_id)
if cell then
    print(string.format("Cell ID %d has hash %s", cell.cell_id, cell.cell_hash))
else
    print(string.format("Cell ID %d not found", cell_id))
end


-- Iterate over the whole hash
for cell in hash_tilemap_png:iter() do
    local hash = cell.cell_hash
    local c = hash_tileset_png:lookup_by_hash(cell.cell_hash)
    if c then
        print(string.format("%d: <-  %d: %s",
            cell.cell_id,
            c.cell_id,
            c.cell_hash))
    else
        -- TODO: エラー終了する
        print(string.format("%d: %s : not found",
            cell.cell_id,
            cell.cell_hash))
    end
end
