include "config"
include "vec2"
include "animator"
include "world"
include "mcontroller"
include "activeItem"
include "updateable"

muzzle = {}
muzzle._parts = {}

function muzzle:init()
    local muzzleConfig = config.muzzle or {}
    for i,v in pairs(muzzleConfig) do
        self:addPart(v.part, v.offset)
    end
end

function muzzle:addPart(part, offset)
    self._parts[part] = vec2(offset or {0,0})
end

function muzzle:fire(ammo)
    for i,v in pairs(self._parts) do
        local position = activeItem.handPosition(animator.transformPoint(v,i))
        local end_position = activeItem.handPosition(animator.transformPoint(v + vec2(1,0), i))
        local projectileArgs = ammo:projectileArgs(position + mcontroller.position() , end_position - position)
        projectileArgs[3] = activeItem.ownerEntityId()
        world.spawnProjectile(table.unpack(projectileArgs))
    end
end

updateable:add("muzzle")