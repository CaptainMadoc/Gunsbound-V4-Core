include "vec2"
include "activeItem"

aim = {}
aim.target = nil
aim.recoil = 0

function aim:init()

end

function aim:update(dt)
	if self.target then
		local armAngle, direction = activeItem.aimAngleAndDirection(0, self.target)
		activeItem.setFacingDirection(direction)
		activeItem.setArmAngle(armAngle + math.rad(self.recoil))
	end
end

function aim:uninit()

end

function aim:at(pos)
	self.target = pos
end