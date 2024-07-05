function round(num)
    return math.floor(num + 0.5)
end

function parsePath(input)
    local out = {}
    local roundCommands = {M=true, L=true, H=true, V=true, m=true, l=true, h=true, v=true}
    local x, y = 0, 0
    local startX, startY = 0, 0

    for instr, vals in input:gmatch("([a-df-zA-DF-Z])([^a-df-zA-DF-Z]*)") do
        local line = { instr }
        local numbers = {}
        for v in vals:gmatch("([+-]?%d*%.?%d+[eE]?[+-]?%d*)") do
            local num = tonumber(v)
            if num and roundCommands[instr] then
                num = round(num)
            end
            table.insert(numbers, num)
        end

        if instr == "M" or instr == "m" then
            if instr == "M" then
                x, y = numbers[1], numbers[2]
            else
                x, y = x + numbers[1], y + numbers[2]
            end
            startX, startY = x, y
        elseif instr == "L" or instr == "l" then
            if instr == "L" then
                x, y = numbers[1], numbers[2]
            else
                x, y = x + numbers[1], y + numbers[2]
            end
        elseif instr == "H" or instr == "h" then
            if instr == "H" then
                x = numbers[1]
            else
                x = x + numbers[1]
            end
        elseif instr == "V" or instr == "v" then
            if instr == "V" then
                y = numbers[1]
            else
                y = y + numbers[1]
            end
        elseif instr == "Z" or instr == "z" then
            x, y = startX, startY
        end

        line[#line+1] = string.format("(%.2f, %.2f)", x, y)
        out[#out+1] = line
    end
    return out
end

-- Test output
local input = "m 143.93333,1065.1834 h -4.23334 l 10e-6,-40.2167 h 4.23333 z"
local r = parsePath(input)
for i=1, #r do
    print("{ "..table.concat(r[i], ", ").." }")
end
