customSounds = {
    soundInt = 1,
    noWarn = false
}

--[[
    var = {
        sound = "path",
        volume = 1,
        pitch = 1,
        position = {0,0}
    }
]]

function customSounds:play(var)
    local varType = type(var)
    if varType == "table" then
        if not animator.hasSound("customSound_"..self.soundInt) then
            if self.soundInt == 1 and not self.noWarn then
                sb.logWarn("self.soundInt = 1 -- this means customSound_1 is not set properly")
                self.noWarn = true
            end
            self.soundInt = 1
        end

        local soundTarget = "customSound_"..self.soundInt
        
        local ft = type(var.sound)
        if ft == "table" then
            animator.setSoundPool(soundTarget, var.sound)
        else
            animator.setSoundPool(soundTarget, {var.sound or "/assetmissing.ogg"})
        end

        animator.setSoundVolume(soundTarget, var.volume or 1)
        animator.setSoundPitch(soundTarget, var.pitch or 1)
        animator.setSoundPosition(soundTarget, var.position or {0,0})

        self.soundInt = self.soundInt + 1
        return soundTarget
    elseif varType == "string" then
        self:play({file = var})
    end
end