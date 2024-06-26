

local Layer = {}
Layer.__index = Layer

function Layer:new()
    local instance = setmetatable({}, Layer)
    instance.compression = ""
    instance.data = ""
    instance.encoding = ""
    instance.height = 0
    instance.id = 0
    instance.name = ""
    instance.opacity = 1
    instance._type = ""
    instance.visible = true
    instance.width = 0
    instance.x = 0
    instance.y = 0
    return instance
end

function Layer:readfrom(layerData)
    self.compression = layerData.compression
    self.data = layerData.data
    self.encoding = layerData.encoding
    self.height = layerData.height
    self.id = layerData.id
    self.name = layerData.name
    self.opacity = layerData.opacity
    self._type = layerData.type
    self.visible = layerData.visible
    self.width = layerData.width
    self.x = layerData.x
    self.y = layerData.y
end

function Layer:printInfo()
    print("Layer ID: " .. self.id)
    print("Name: " .. self.name)
    print("Type: " .. self._type)
    print("Width: " .. self.width)
    print("Height: " .. self.height)
end

function Layer:toDict()
    local data = {
        compression = self.compression,
        data = self.data,
        encoding = self.encoding,
        height = self.height,
        id = self.id,
        name = self.name,
        opacity = self.opacity,
        type = self._type,
        visible = self.visible,
        width = self.width,
        x = self.x,
        y = self.y,
    }
    return data
end


local Tile = {}
Tile.__index = Tile

function Tile:new(id)
    local instance = setmetatable({}, Tile)
    instance.id = id
    return instance
end

function Tile:printInfo()
    print("Tile ID: " .. self.id)
end

function Tile:toDict()
    local data = {
        id = self.id
    }
    return data
end


local Tileset = {}
Tileset.__index = Tileset

function Tileset:new()
    local instance = setmetatable({}, Tileset)
    instance.columns = 0
    instance.firstgid = 0
    instance.image = ""
    instance.imageheight = 0
    instance.imagewidth = 0
    instance.margin = 0
    instance.name = ""
    instance.spacing = 0
    instance.tilecount = 0
    instance.tileheight = 0
    instance.tiles = {}
    instance.tilewidth = 0
    return instance
end

function Tileset:readfrom(tilesetData)
    self.columns = tilesetData.columns
    self.firstgid = tilesetData.firstgid
    self.image = tilesetData.image
    self.imageheight = tilesetData.imageheight
    self.imagewidth = tilesetData.imagewidth
    self.margin = tilesetData.margin
    self.name = tilesetData.name
    self.spacing = tilesetData.spacing
    self.tilecount = tilesetData.tilecount
    self.tileheight = tilesetData.tileheight
    self.tilewidth = tilesetData.tilewidth

    for _, tileData in ipairs(tilesetData.tiles) do
        self:addTile(Tile:new(tileData.id))
    end
end

function Tileset:addTile(tile)
    table.insert(self.tiles, tile)
end

function Tileset:printInfo()
    print("Tileset Name: " .. self.name)
    print("Image: " .. self.image)

    print("Tile Count: " .. self.tilecount)
    for _, tile in ipairs(self.tiles) do
        tile:printInfo()
    end
end


-- Method to return the JSON representation of a Tileset instance
function Tileset:toDict()
    local tilesData = {}
    for _, tile in ipairs(self.tiles) do
        table.insert(tilesData, tile:toDict())
    end

    local data = {
        columns = self.columns,
        firstgid = self.firstgid,
        image = self.image,
        imageheight = self.imageheight,
        imagewidth = self.imagewidth,
        margin = self.margin,
        name = self.name,
        spacing = self.spacing,
        tilecount = self.tilecount,
        tileheight = self.tileheight,
        tiles = tilesData,
        tilewidth = self.tilewidth
    }

    return data
end


local MapData = {}
MapData.__index = MapData

function MapData:new()
    local instance = setmetatable({}, MapData)
    instance.compressionlevel = -1
    instance.height = 0
    instance.infinite = false
    instance.layers = {}
    instance.nextlayerid = 0
    instance.nextobjectid = 0
    instance.orientation = ""
    instance.renderorder = ""
    instance.tiledversion = ""
    instance.tileheight = 0
    instance.tilesets = {}
    instance.tilewidth = 0
    instance._type = ""
    instance.version = ""
    instance.width = 0
    return instance
end

function MapData:readfrom(mapData)
    self.compressionlevel = mapData.compressionlevel
    self.height = mapData.height
    self.infinite = mapData.infinite
    self.layers = {}
    for _, layerData in ipairs(mapData.layers) do
        local layer = Layer:new()
        layer:readfrom(layerData)
        self:addLayer(layer)
    end

    self.nextlayerid = mapData.nextlayerid
    self.nextobjectid = mapData.nextobjectid
    self.orientation = mapData.orientation
    self.renderorder = mapData.renderorder
    self.tiledversion = mapData.tiledversion
    self.tileheight = mapData.tileheight

    self.tilesets = {}
    for _, tilesetData in ipairs(mapData.tilesets) do
        local tileset = Tileset:new()
        tileset:readfrom(tilesetData)
        self:addTileset(tileset)
    end
    self.tilewidth = mapData.tilewidth
    self._type = mapData.type
    self.version = mapData.version
    self.width = mapData.width
end

function MapData:addLayer(layer)
    table.insert(self.layers, layer)
end

function MapData:addTileset(tileset)
    table.insert(self.tilesets, tileset)
end

function MapData:printInfo()
    print("Map Type: " .. self._type)
    print("Version: " .. self.version)
    print("Width: " .. self.width)
    print("Height: " .. self.height)
    for _, layer in ipairs(self.layers) do
        layer:printInfo()
    end
    for _, tileset in ipairs(self.tilesets) do
        tileset:printInfo()
    end
end

function MapData:toDict()
    local layerData = {}
    for _, layer in ipairs(self.layers) do
        table.insert(layerData, layer:toDict())
    end

    local tilesetData = {}
    for _, tileset in ipairs(self.tilesets) do
        table.insert(tilesetData, tileset:toDict())
    end

    local data = {
        compressionlevel = self.compressionlevel,
        height = self.height,
        infinite = self.infinite,
        layers = layerData,
        nextlayerid = self.nextlayerid,
        nextobjectid = self.nextobjectid,
        orientation = self.orientation,
        renderorder = self.renderorder,
        tiledversion = self.tiledversion,
        tileheight = self.tileheight,
        tilesets = tilesetData,
        tilewidth = self.tilewidth,
        type = self._type,
        version = self.version,
        width = self.width,
    }
    return data
end


-- Define the module table to export
local mapJson = {
    Layer = Layer,
    Tile = Tile,
    Tileset = Tileset,
    MapData = MapData,
}
return mapJson
