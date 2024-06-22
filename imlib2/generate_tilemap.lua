local md5 = require("md5")
local sha1 = require("sha1")
local imlib2 = require("imlib2")


function calculate_hash(image_path, hash_algorithm, cell_size_h, cell_size_v)
    local hash_values = {}

    local image_map = imlib2.image.load(image_path)
    local width, height = image_map:get_width(), image_map:get_height()
    print(string.format("image_map size (%d, %d)", width, height))

    local n_cell_h = width / cell_size_h;
    local n_cell_v = height / cell_size_v;
    print(string.format(" cells (%d, %d)", n_cell_h, n_cell_v))
    print(string.format(" total cells = %d", n_cell_h * n_cell_v))

    for j = 0, n_cell_v - 1 do
        for i = 0, n_cell_h - 1 do
            local pixel_byte_array = get_cell_from_image(image_map, i, j, cell_size_h, cell_size_v)
            local cell_hash = byte_array_to_hash(pixel_byte_array, hash_algorithm)
            table.insert(
                hash_values,
                {
                    cell_id = (j * n_cell_h + i),
                    cell_hash = cell_hash,
                    x = i,
                    y = j,
                }
            )
        end
    end

    return hash_values
end


function get_cell_from_image(image_map, cell_x, cell_y, cell_size_h, cell_size_v)
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


function byte_array_to_hash(byte_array, hash_algorithm)
    if hash_algorithm == 'md5' then
        return md5.sumhexa(byte_array)
    elseif hash_algorithm == 'sha1' then
        return sha1.sha1(byte_array)
    end
end


-- main
--
local image_path_tilemap = "level1-working/Tilemap - Wall1.png"
local image_path_tileset = "level1-working/tilemap-test1-Sheet-wall.png"
local hash_algorithm = 'md5'  -- Change this to 'sha1' for SHA1 hash

local cell_hashes = calculate_hash(image_path_tilemap, hash_algorithm, 16, 16)
-- Print the hash values of each cell
for _, v in ipairs(cell_hashes) do
    print(string.format(
        " (%03d, %03d), %06d: %s",
        v.x, v.y, v.cell_id, v.cell_hash))
end

local cell_hashes = calculate_hash(image_path_tileset, hash_algorithm, 16, 16)
-- Print the hash values of each cell
for _, v in ipairs(cell_hashes) do
    print(string.format(
        " (%03d, %03d), %06d: %s",
        v.x, v.y, v.cell_id, v.cell_hash))
end
