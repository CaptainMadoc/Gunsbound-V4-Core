main = {
    fireQueued = 0,
    semifired = false
}

function main:animate(type)
	if magazine:count() == 0 and gun:chamberDry() then
		animation:play(data.gunAnimations[type.."_dry"] or data.gunAnimations[type]  or type.."_dry")
	else
		animation:play(data.gunAnimations[type] or type)
    end
end

function main:init()
    self:animate("draw")
end

function main:activate(fireMode, shiftHeld)
    if fireMode == "alt" and not shiftHeld then
        attachment:triggerSpecial()
    elseif updateInfo.fireMode == "alt" and shiftHeld then
        gun:switchFireModes()
    end
end

function main:fire()
    local status = gun:fire()
    if status then
        self:animate("shoot")
    end
    return status
end

function main:updateSpecial(shift, up)
    if shift and up and not animation:isAnyPlaying() then
        self:animate("reload")
    end
    if not shift and up and not animation:isAnyPlaying() then
        self:animate("cock")
    end
end

function main:updateFire(firemode)
    if firemode == "primary" and gun:ready() and data.gunLoad and not self.semifired then
        local gunFireMode = gun:fireMode()

        if gunFireMode == "burst" and self.fireQueued == 0 then
            self.fireQueued = data.gunStats.burst
        elseif gunFireMode == "semi" then
            self:fire()
            self.semifired = true
        elseif gunFireMode == "auto" then
            self:fire()
        end

    elseif firemode ~= "primary" and self.semifired then
        self.semifired = false
    end

    
    if self.fireQueued > 0 and gun:ready() and not gun:chamberDry() then
        local fireStatus = self:fire()
        if magazine:count() == 0 then
            self.fireQueued = 0
        else
            self.fireQueued = self.fireQueued - 1
        end
        if self.fireQueued == 0 then
            gun.cooldown = gun:rpm() * 4
        end
    end
end

function main:update()
   self:updateFire(updateInfo.fireMode) 
   self:updateSpecial(updateInfo.shiftHeld, updateInfo.moves.up)
end