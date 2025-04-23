local hitbox = {}

--[[   HITBOX Checker
    check if a given point is in a given paralelogram
    The point passed as argument must have :
        x => x coordinate
        y => y coordinate
    
    The paralelogram passed as argument must have
        4 coordinates, and foreach they must have a x and y like the point
        example : paralelogram = { {x = ..., y = ...}, ...} so we can loop on the 4 corners
    The 4 corners are defined clockwise (example : top left -> top right -> bottom right -> bottom left)
]]
function hitbox.isIn(point, paralelogram)
    if #paralelogram < 3 then
        return false
    end

    local refSign  -- sign of the side reference (the first one)

    for i = 1, #paralelogram do
        local a = paralelogram[i]
        local b = paralelogram[(i % 4) + 1]

        local AB = {
            -- Vector of a side
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
                return false -- Dès que l'on a un des produits vectoriels différents d'un autre, on sait que l'on sera en dehors de la hitbox
            end
        end
    end

    return true -- Tous les produits vectoriels ont le même signe : on est à l'intérieur du rectangle
end

return hitbox
