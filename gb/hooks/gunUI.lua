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
    x, e = pcall(oldUpdate, ...)
    if not x then
        sb.logError(e)
        oldUpdate = function() localAnimator.clearDrawables() end
    end

    local altHand = player.getProperty("GB_altHand", {})
    local primaryHand = player.getProperty("GB_primaryHand", {})

    for i,v in pairs(altHand) do
        if v.func and localAnimator[v.func] then
            localAnimator[v.func](table.unpack(v.args))
        end
    end

    for i,v in pairs(primaryHand) do
        if v.func and localAnimator[v.func] then
            localAnimator[v.func](table.unpack(v.args))
        end
    end

    player.setProperty("GB_altHand", {})
    player.setProperty("GB_primaryHand", {})
end