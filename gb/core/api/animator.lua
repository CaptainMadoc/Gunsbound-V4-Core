include "vec2"
include "Class"

local animatorWrapped = animator
local _animator = {}

function _animator.partPoint(...)
    return vec2(animatorWrapped.partPoint(...))
end

function _animator:__index(key)
    return _animator[key] or animatorWrapped[key]
end

animator = Class:new(_animator)