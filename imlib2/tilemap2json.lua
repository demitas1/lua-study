package.path = './?.lua;' .. package.path

local cjson = require("cjson")        -- assume cjson is installed.
local mapJson = require("map_json")     -- map_json.lua in the current directory.


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
local mapData = mapJson.MapData:new()
mapData:readfrom(mapDataTable)

-- Print map information
mapData:printInfo()


local mapData = mapJson.MapData:new()
local tileset = mapJson.Tileset:new()
local tile1 = mapJson.Tile:new(100)
tileset:addTile(tile1)
mapData:addTileset(tileset)

-- Print map information
mapData:printInfo()

local data = {
    name = "John Doe",
    age = 30,
    hobbies = { "reading", "swimming", "coding" }
}

-- Encode Lua table to JSON string
local json_data = cjson.encode(mapData:toDict())

-- Write JSON string to file
local file = io.open("output.json", "w")
if file then
    file:write(json_data)
    file:close()
    print("Data successfully written to output.json")
else
    print("Failed to open file for writing")
end
