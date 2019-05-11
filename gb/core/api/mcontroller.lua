include "vec2"
include "Class"

local mcontrollerWrapped = mcontroller
local _mcontroller = {}

function _mcontroller.position()
    return vec2(mcontrollerWrapped.position())
end

function _mcontroller.__index(key)
    return _mcontroller[key] or mcontrollerWrapped[key]
end

mcontroller = Class:new(_mcontroller)