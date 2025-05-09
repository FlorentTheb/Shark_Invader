--[[   -Hitbox- CHECKER
    check if a given point is in a given paralelogram
    The point passed as argument must have :
        x => x coordinate
        y => y coordinate
    
    The paralelogram passed as argument must have
        4 coordinates, and foreach they must have an x and y given coordinate
        example : paralelogram = { {x = ..., y = ...}, ...} so we can loop on the 4 corners
    The 4 corners are defined clockwise (example : top left -> top right -> bottom right -> bottom left)
]]
    
local hitboxChecker = {}

function hitboxChecker.isIn(point, paralelogram)
    if #paralelogram < 3 then
        return false
    end

    local refSign  -- sign of the side reference (the first one)

    for i = 1, #paralelogram do
        local a = paralelogram[i]
        local b = paralelogram[(i % 4) + 1]

        local AB = {
            -- Vector from a corner to the next one (clockwise)
            x = b.x - a.x,
            y = b.y - a.y
        }
        local APoint = {
            -- Vector from a corner to the point
            x = point.x - a.x,
            y = point.y - a.y
        }
        local prodVec = AB.x * APoint.y - AB.y * APoint.x

        if i == 1 then
            refSign = prodVec > 0 and 1 or -1
        else
            if (prodVec > 0 and refSign < 0) or (prodVec < 0 and refSign > 0) then
                return false -- One sign of a side is different from the reference (or : not all the sides have the same sign) => Point is not in hitbox
            end
        end
    end

    return true -- Same sign on all sides => Point is in hitbox
end

function hitboxChecker.getHitbox(center, angle, width, height)
    local hitbox = {
        {
            x = center.x - math.cos(angle) * (width + 2) + math.cos(angle - math.pi * .5) * height,
            y = center.y - math.sin(angle) * (width + 2) + math.sin(angle - math.pi * .5) * height
        },
        {
            x = center.x + math.cos(angle) * (width - 2) + math.cos(angle - math.pi * .5) * height,
            y = center.y + math.sin(angle) * (width - 2) + math.sin(angle - math.pi * .5) * height
        },
        {
            x = center.x + math.cos(angle) * (width - 2) + math.cos(angle + math.pi * .5) * height,
            y = center.y + math.sin(angle) * (width - 2) + math.sin(angle + math.pi * .5) * height
        },
        {
            x = center.x - math.cos(angle) * (width + 2) + math.cos(angle + math.pi * .5) * height,
            y = center.y - math.sin(angle) * (width + 2) + math.sin(angle + math.pi * .5) * height
        }
    }
    return hitbox
end

function hitboxChecker.drawHitbox(center, angle, width, height)
    local hitbox = hitboxChecker.getHitbox(center, angle, width, height)
    love.graphics.polygon("line", hitbox[1].x, hitbox[1].y, hitbox[2].x, hitbox[2].y, hitbox[3].x, hitbox[3].y, hitbox[4].x, hitbox[4].y)
end

return hitboxChecker
