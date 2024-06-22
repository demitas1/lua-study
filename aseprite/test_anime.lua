--
-- read-only table for constant definitions
--
function readonlytable(table)
    return setmetatable({},
        {
            __index = table,
            __newindex = function(table, key, value)
                error("Attempt to modify read-only table")
            end,
            __metatable = false,
        });
end

-- Color constants
constColor = readonlytable {
    WHITE = Color {r=255, g=255, b=255, a=255},
    BLACK = Color {r=0, g=0, b=0, a=0},
    otherstuff = {}  -- custom stuff
}


-- debug utility
function debug_print(...)
    print(string.format(...))
end

--
-- main function
--
local makeAnime = function(args)
    -- Choose (or create) active sprite.
    local sprite = app.sprite
    if sprite == nil then
        return

    local spec = sprite.spec

    -- TODO: Expand sprite 32px vertically, if no empty area
    --sprite:crop(0, 0, sprite.width, sprite.height + 32)

    -- print information
    -- frames
    for i, frame in ipairs(sprite.frames) do
        local d = math.floor(frame.duration * 1000)
        debug_print("Frame %d: %0.0f mS", frame.frameNumber, d)
    end

    -- layer
    for i, layer in ipairs(sprite.layers) do
        debug_print("Layer %d: %s", i, layer.name)
    end

    -- cels
    for i, cel in ipairs(sprite.cels) do
        debug_print("Cel " .. i)
    end

    -- find cel and get cel image
    local layer1
    local cel1

    for i, layer in ipairs(sprite.layers) do
        if layer.name == "1" then
            layer1 = layer
            break
        end
    end

    if layer1 == nil then
        return
    end

    debug_print("found layer1")
    cel1 = layer1:cel(1)
    if cel1 == nil then
        return
    end
    debug_print("found layer1:cel1")

    local bbx0, bbx1
    bbx1 = cel1.bounds
    --print(string.format("bbx1: %d, %d - %d, %d", bbx1.x, bbx1.y, bbx1.width, bbx1.height))
    debug_print("bbx1: %d, %d - %d, %d", bbx1.x, bbx1.y, bbx1.width, bbx1.height)

    -- img0 = empty image with full sprite size, new result cel image
    local img0 = Image(spec)
    bbx0 = img0.bounds
    debug_print("bbx0: %d, %d - %d, %d", bbx0.x, bbx0.y, bbx0.width, bbx0.height)

    -- img1 = cel image to copy from
    local img1 = cel1.image
    debug_print("image: %d, %d", img1.width, img1.height)

    -- copy img1 to img0 (opacity=255, blend_mode = NORMAL)
    img0:drawImage(img1, Point(bbx1.x, bbx1.y), 255, BlendMode.NORMAL)

    -- copy 32x32 region from img0
    local img2 = Image(img0, Rectangle(0, 0, 32, 32))

    -- paste 32x32 to img0
    img0:drawImage(img2, Point(32, 160), 255, BlendMode.NORMAL)

    -- test: draw pixel
    img0:drawPixel(0, 0, constColor.WHITE)

    -- draw img0 back to cel1
    cel1.image = img0
    cel1.position = Point(bbx0.x, bbx0.y)

    -- check result cel image bounds
    local bbx = cel1.bounds
    debug_print("cel1 bbx: %d, %d - %d, %d", bbx.x, bbx.y, bbx.width, bbx.height)

    -- Create new layer and new cel.
    --local newLayer = sprite:newLayer()
    --local cel = sprite:newCel(newLayer, 1)

    -- fill white bottom 32px area
    -- copy and paste 32x32 region to bottom left
    -- repeat 4 times with json setting

    app.refresh()
end

--
-- Script main dialog
--
local dlg = Dialog { title = "Make Anime Test" }

dlg:number {
    id = "x",
    label = "X: ",
    text = string.format("%.1f", 32),
    decimals = 5
}

dlg:number {
    id = "y",
    label = "Y: ",
    text = string.format("%.1f", 32),
    decimals = 5
}

dlg:slider {
    id = "stroke",
    label = "Stroke: ",
    min = 1,
    max = 64,
    value = 24
}

dlg:color {
    id = "clr",
    label = "Color: ",
    color = Color(0xffff7f00)
}

dlg:button{
    id = "ok",
    text = "OK",
    focus = true,
    onclick = function()
        makeAnime(dlg.data)
    end
}

dlg:button {
    id = "cancel",
    text = "CANCEL",
    onclick = function()
        dlg:close()
    end
}

dlg:show { wait = false }
