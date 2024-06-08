--
-- main function
--
local makeAnime = function(args)
    -- Choose (or create) active sprite.
    local sprite = app.activeSprite
    if sprite == nil then
        sprite = Sprite(64, 64)
        app.activeSprite = sprite
    end

    -- TODO: Expand sprite 32px vertically, if no empty area
    --sprite:crop(0, 0, sprite.width, sprite.height + 32)

    -- Create new layer and new cel.
    local newLayer = sprite:newLayer()
    local cel = sprite:newCel(newLayer, 1)

    -- fill white bottom 32px area
    -- copy and paste 32x32 region to bottom left
    -- repeat 4 times with json setting

    -- Create brush.
    local brush = Brush {
        type = BrushType.CIRCLE,
        size = args.stroke 
    }

    -- Place pencil at point.
    app.useTool {
        tool = "pencil",
        color = args.clr,
        brush = brush,
        points = { Point(args.x, args.y) },
        cel = cel,
        layer = newLayer
    }

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
