include "vec2"
include "Class"

local activeItemWrapped = activeItem
_activeItem = {}

function  _activeItem.ownerAimPosition()
    return vec2(activeItemWrapped.ownerAimPosition())
end

function _activeItem.__index(key)
    return _activeItem[key] or activeItemWrapped[key]
end

activeItem = Class:new(_activeItem)