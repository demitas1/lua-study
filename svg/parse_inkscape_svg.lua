local function parseSVG(svgContent)
    local groups = {}
    local currentGroup = nil
    local inGroupTag = false
    local inPathTag = false
    local inSodiPodiTag = false
    local pathAttributes = {}
    local sodipodiAttributes = {}

    for line in svgContent:gmatch("[^\r\n]+") do
        -- Check for sodipodi
        if line:match("<sodipodi:namedview%s*$") or inSodiPodiTag then
            inSodiPodiTag = true
            for attr, value in line:gmatch('([%w:-]+)="([^"]*)"') do
                sodipodiAttributes[attr] = value
            end
        end

        -- Check for group start
        if line:match("<g%s*$") or inGroupTag then
            inGroupTag = true
            local groupLabel = line:match('inkscape:label="([^"]*)"')
            if groupLabel then
                currentGroup = {label = groupLabel, paths = {}}
                table.insert(groups, currentGroup)
                inGroupTag = false
            end
        end

        -- Check for path start within a group
        if currentGroup and (line:match("<path%s*") or inPathTag) then
            inPathTag = true
            for attr, value in line:gmatch('([%w:]+)="([^"]*)"') do
                pathAttributes[attr] = value
            end
            
            -- Check if we have all required attributes
            if pathAttributes.id and pathAttributes["inkscape:label"] and pathAttributes.d then
                table.insert(currentGroup.paths, {
                    id = pathAttributes.id,
                    label = pathAttributes["inkscape:label"],
                    d = pathAttributes.d
                })
                inPathTag = false
                pathAttributes = {}
            end
        end

        -- Check for sodipodi end
        if line:match("</sodipodi:namedview>") then
            inSodiPodiTag = false
        end

        -- Check for group end
        if line:match("</g>") then
            currentGroup = nil
        end

        -- Check for path end
        if line:match("/>") then
            inPathTag = false
            pathAttributes = {}
        end
    end

    return sodipodiAttributes, groups
end

-- Get the filename from command-line argument
local filename = arg[1]

if not filename then
    print("Usage: lua script.lua <svg_filename>")
    os.exit(1)
end

-- Read the SVG file
local file, err = io.open(filename, "r")
if not file then
    print("Error opening file: " .. err)
    os.exit(1)
end

local svgContent = file:read("*all")
file:close()

local sodipodi, groups = parseSVG(svgContent)

-- Print the extracted information
for k, v in pairs(sodipodi) do
    print(string.format("sodipodi: %s : %s", k, v))
end

for _, group in ipairs(groups) do
    print("Group Label:", group.label)
    for _, path in ipairs(group.paths) do
        print("  Path ID:", path.id)
        print("  Path Label:", path.label)
        print("  Path d:", path.d)
        print()
    end
end
