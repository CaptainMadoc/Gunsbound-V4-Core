include "itemInstance"
include "itemConfig"

attachmentSystem = {}
attachmentSystem.currentSpecial = false
attachmentSystem.list = {}
attachmentSystem.specials = {}


function attachmentSystem:init()
    for name,property in pairs(itemInstance:getParameterWithConfig("attachments")) do
        local item = itemConfig(property.item)
        
    end
end

function attachmentSystem:update(dt)

end

function attachmentSystem:uninit()

end

-- for systems Scripts
function attachmentSystem:activate()
    if self.currentSpecial then

    end
end

function attachmentSystem:switch()
    
end