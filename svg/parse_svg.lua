function parsePath(input)
    local out = {};

    for instr, vals in input:gmatch("([a-df-zA-DF-Z])([^a-df-zA-DF-Z]*)") do
        local line = { instr };
        --for v in vals:gmatch("([+-]?[%deE.]+)") do
        for v in vals:gmatch("([^%a%d%.eE-]+)") do
            line[#line+1] = v;
        end
        out[#out+1] = line;
    end
    return out;
end

-- Test output
local input = 'M20-30L20,20,20X40,40-40H1,2E1.7 1.8e22,3,12.8z'
input = "M 880,560 C 920,480 1120,240 1120,240"
input = "m 143.93333,1065.1834 h -4.23334 l 10e-6,-40.2167 h 4.23333 z" -- TODO: fix for this
input = 'M20-30L20,20,20X40,40-40H1,2E1.7 1.8e22,3,12.8z'
input = 'M20-30L20,20,20X40,40-40H1,2E1.7 1.8e22,1.8e-22,3,12.8z' -- TODO: fix 1.8e-22

local r = parsePath(input)
for i=1, #r do
    print("{ "..table.concat(r[i], ", ").." }")
end
