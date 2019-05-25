include "transforms"
include "itemInstance"
include "module"

animations = {}
animations.list = {}

function animations:init()
    self.defaultTransforms = transforms:getDefaultTransforms()
    for i,v in pairs(itemInstance.animations) do
        self:add(i,v)
    end
end

function animations:update(dt)
    for i,v in pairs(self.list) do
        self.list[i]:update(dt)
    end
end

function animations:uninit()

end

function animations:add(name, keyFrames)
    if type(keyFrames) == "string" then
        keyFrames = root.assetJson(itemInstance:path(keyFrames))
    end
    if not keyFrames then return end
    self.list[name] = module("/gb/modules/animation.lua"):load(keyFrames, self.defaultTransforms)
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

function animations:addEvent(name, func)
    for i,v in pairs(self.list) do --probably gonna get reworked
        self.list[i]:addEvent(name, func)
    end
end