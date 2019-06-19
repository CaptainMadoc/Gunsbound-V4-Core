muzzle = {}
muzzle._parts = {}

function muzzle:addPart(part, offset)
    self._parts[part] = offset
end

function muzzle:fire(ammo)
    for i,v in pairs(self._parts) do

    end
end