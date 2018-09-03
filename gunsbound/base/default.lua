main = {
    fireQueued = 0,
    semifired = false
}

function main:init()

end

function main:fire()
    gun:fire()
end

function main:updateFire(firemode)
    if self.fireQueued > 0 and gun:ready() then
        local fireStatus = self:fire()
        if magazine:count() == 0 then
            self.fireQueued = 0
        else
            self.fireQueued = self.fireQueued - 1
        end
    end

    if firemode == "primary" and gun:ready() and not self.semifired then
        if data.fireTypes[gun.fireMode] == "semi" then
            self.fireQueued = data.gunStats.burst
        elseif data.fireTypes[gun.fireMode] == "semi" or data.fireTypes[gun.fireMode] == "semi" then
            self:fire()
            if data.fireTypes[gun.fireMode] == "semi" then
                self.semifired = true
            end
        end
    elseif firemode ~= "primary" and self.semifired then
        self.semifired = false
    end
end

function main:update()
   self:updateFire(updateInfo.firemode) 
end