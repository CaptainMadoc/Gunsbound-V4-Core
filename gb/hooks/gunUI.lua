local oldInit = init or function () end
local oldUpdate = update or function() localAnimator.clearDrawables() end

function init()

    x, e = pcall(oldInit)
    if not x then
        sb.logError(e)
        oldInit = function() end
    end
end

function update(...)
    local altHand = player.getProperty("GB_altHand", {})
    local primaryHand = player.getProperty("GB_primaryHand", {})

    for i,v in pairs(altHand) do
        if v[1] and type(v[1]) == "string" and localAnimator[v[1]] then
            local funcname = v[1]
            table.remove(v, 1)
            localAnimator[funcname](table.unpack(v))
        end
    end

    for i,v in pairs(primaryHand) do
        if v[1] and type(v[1]) == "string" and localAnimator[v[1]] then
            local funcname = v[1]
            table.remove(v, 1)
            localAnimator[funcname](table.unpack(v))
        end
    end

    player.setProperty("GB_altHand", {})
    player.setProperty("GB_primaryHand", {})



    x, e = pcall(oldUpdate, ...)
    if not x then
        sb.logError(e)
        oldUpdate = function() localAnimator.clearDrawables() end
    end
end