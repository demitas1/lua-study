local md5 = require("md5")
local sha1 = require("sha1")
local imlib2 = require("imlib2")


-- Define the class
local ImageHasher = {}
ImageHasher.__index = ImageHasher


-- Constructor
function ImageHasher:new()
    local obj = setmetatable({}, self)
    obj.hash_table = {}
    return obj
end


-- Method to load png file from given path
function ImageHasher:load_image(image_path, cell_size_h, cell_size_v, hash_algorithm)
    local image = imlib2.image.load(image_path)
    local width, height = image:get_width(), image:get_height()
    local n_cell_h = width / cell_size_h;
    local n_cell_v = height / cell_size_v;

    for j = 0, n_cell_v - 1 do
        for i = 0, n_cell_h - 1 do
            local pixel_byte_array = self:_get_cell_from_image(image, i, j, cell_size_h, cell_size_v)
            local cell_hash = self:_byte_array_to_hash(pixel_byte_array, hash_algorithm)
            local cell_id = j * n_cell_h + i
            self:_insert_hash(cell_id, cell_hash)
        end
    end
end


-- Public method to look up hash_table by cell_id
function ImageHasher:lookup(cell_id)
    for _, entry in ipairs(self.hash_table) do
        if entry.cell_id == cell_id then
            return entry.cell_hash
        end
    end
    return nil
end


-- Private method to insert hash to hash_table
function ImageHasher:_insert_hash(cell_id, cell_hash)
    if cell_id == 0 then
        print(cell_id, cell_hash)
    end
    table.insert(self.hash_table, {cell_id = cell_id, cell_hash = cell_hash})
end


-- Private method to extract byte array from cell rectangle area of the image
function ImageHasher:_get_cell_from_image(image_map, cell_x, cell_y, cell_size_h, cell_size_v)
    local byte_array = ""
    for j = 0, cell_size_v - 1 do
        for i = 0, cell_size_h - 1 do
            local p = image_map:get_pixel(cell_x * cell_size_h + i, cell_y * cell_size_v + j)
            byte_array = byte_array .. string.char(p.red)
            byte_array = byte_array .. string.char(p.green)
            byte_array = byte_array .. string.char(p.blue)
            byte_array = byte_array .. string.char(p.alpha)
        end
    end
    return byte_array
end


-- Private method to generate hash
function ImageHasher:_byte_array_to_hash(byte_array, hash_algorithm)
    if hash_algorithm == 'md5' then
        return md5.sumhexa(byte_array)
    elseif hash_algorithm == 'sha1' then
        return sha1.sha1(byte_array)
    end
end


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
