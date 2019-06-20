include "vec2"
include "class"

local activeItemWrapped = activeItem
local _activeItem = {}

function  _activeItem.ownerAimPosition()
	return vec2(activeItemWrapped.ownerAimPosition())
end

function  _activeItem.handPosition(a)
	return vec2(activeItemWrapped.handPosition(a))
end

function _activeItem:__index(key)
	return _activeItem[key] or activeItemWrapped[key]
end

activeItem = class:new(_activeItem)