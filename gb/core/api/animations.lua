include "transforms"
include "itemInstance"
include "module"
include "tableutil"

animations = {}
animations.list = {}

function animations:init()
	message.setHandler("isAnyPlaying", function(_, loc, ...) if loc then return self:isAnyPlaying() end end)
    message.setHandler("play", function(_, loc, keyFrames) if loc then self:playOverride(keyFrames) end end)
    
    for i,v in pairs(itemInstance.animations) do
        self:add(i,v)
    end
end

function animations:update(dt)
    if self.override then 
        if self.override.playing then
            self.override:update(dt)
        else
            self.override = nil
        end
    end

    for i,v in pairs(self.list) do
        self.list[i]:update(dt)
        sb.setLogMap("1 - "..i, sb.printJson(v.playing))
        if v.temporary and not v.playing then
            self.list[i] = nil
        end
    end
end

function animations:uninit()

end

function animations:add(name, keyFrames)
    if type(keyFrames) == "string" then keyFrames = root.assetJson(itemInstance:path(keyFrames)) end
    if not keyFrames then return end
    self.list[name] = module("/gb/modules/animation.lua")
    self.list[name]:load(keyFrames)
end

function animations:playOverride(keyFrames)
    if type(keyFrames) == "string" then keyFrames = root.assetJson(itemInstance:path(keyFrames)) end
    if not keyFrames then return end
    self.override = module("/gb/modules/animation.lua")
    self.override:load(keyFrames)
    self.override:play()
end

function animations:isAnyPlaying()
    if self.override and self.override.playing then return true end

    for i,animation in pairs(self.list) do
        if animation.playing then
            return true
        end
    end
    return false
end

function animations:play(name)
    if self.list[name] then
        self.list[name]:play()
        return true
    end
end

function animations:stop(name)
    if self.list[name] then
        self.list[name]:stop()
    end
end

function animations:pause(name)
    if self.list[name] then
        self.list[name]:pause()
    end
end

function animations:transforms(animationOrder)
    local transforms = {}
    if self.override then
        return self.override:transforms()
    end
    for _,name in pairs(animationOrder) do
        if self.list[name] and self.list[name].playing then
            transforms = table.vmerge(transforms, self.list[name]:transforms())
        end
    end
    return transforms
end

function animations:addEvent(name, func)
    for i,v in pairs(self.list) do --probably gonna get reworked
        self.list[i]:addEvent(name, func)
    end
end