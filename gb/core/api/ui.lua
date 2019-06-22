include "activeItem"

ui = {}

setmetatable(ui, 
    {
        __index = function(key)
            return function(...)
                local hand = activeItem.hand()
                local primaryHand = player.getProperty("GB_"..hand.."Hand", {})
                table.insert(primaryHand, {key, ...})
                player.setProperty("GB_"..hand.."Hand", primaryHand)
            end
        end
    }
)