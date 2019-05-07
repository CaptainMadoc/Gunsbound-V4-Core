include("vec2")

local activeItemWrapper = activeItem
activeItem = {}

function  activeItem.ownerAimPosition()
    return vec2(activeItemWrapper.ownerAimPosition())
end