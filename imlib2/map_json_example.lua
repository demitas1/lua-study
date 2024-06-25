package.path = './?.lua;' .. package.path

local cjson = require("cjson")        -- assume cjson is installed.
require("map_json")     -- map_json.lua in the current directory.


-- Function to read JSON data from a file
local function readJsonFile(filePath)
    local file = io.open(filePath, "r")
    if not file then
        error("Could not open file: " .. filePath)
    end
    local content = file:read("*a")
    file:close()
    return cjson.decode(content)
end

-- File path to the JSON data
local filePath = "level1-working/map1.json"

-- Read JSON data from file
local mapDataTable = readJsonFile(filePath)

-- Create MapData instance
local mapData = MapData:new()
mapData:readfrom(mapDataTable)

-- Print map information
mapData:printInfo()


local mapData = MapData:new()
local tileset = Tileset:new()
local tile1 = Tile:new(100)
tileset:addTile(tile1)
mapData:addTileset(tileset)

-- Print map information
mapData:printInfo()
