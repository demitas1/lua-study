require "imlib2"

local function read_png(file_path)
    local img = imlib2.image.load(file_path)
    local width, height = img:get_width(), img:get_height()

    local pixels = {}
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local p = img:get_pixel(x, y)
            table.insert(pixels, { pixel = p })
        end
    end

    return pixels, width, height
end

local pixels, width, height = read_png("level1-working/tilemap-test1.png")

-- Use pixels as needed

local first_pixel = pixels[1].pixel
print("pixel:", first_pixel)
print("Content of the first pixel (RGBA):")
print("  R:", first_pixel.red)
print("  G:", first_pixel.green)
print("  B:", first_pixel.blue)
print("  A:", first_pixel.alpha)

-- Print width and height
print("Image width:", width)
print("Image height:", height)
