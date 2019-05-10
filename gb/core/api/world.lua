include "vec2"
include "Class"

local worldWrapped = world
local _world = {}

function _world.__index(key)
    return _world[key] or worldWrapped[key]
end

world = Class(_world)