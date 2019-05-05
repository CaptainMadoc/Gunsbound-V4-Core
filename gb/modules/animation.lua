include("vec2")

module = {}
module.key = 1
module.keyTime = 0
module.keyTimeTarget = 0
module.playing = false
module.keyFrames = {}
module.defaultTransforms = {}

--initial animation: keyFrames, Whole transforms of your item
function module:load(keyFrames, defaultTransforms)
    self.keyFrames = keyFrames
    self.defaultTransforms = defaultTransforms
end

--internal use
function module:_reachkey(key)
    for i,v in pairs(key.playSounds or {}) do
        if type(v) == "string" and type(i) == "number" then
            if animator.hasSound(v) then
                animator.playSound(v)
            end
        end
    end
    for i,v in pairs(key.animationState or {}) do
        if type(v) == "string" and type(i) == "string" then
            animator.setAnimationState(i,v)
        end
    end
    for i,v in pairs(key.burstParticle or {}) do
        if type(v) == "string" and type(i) == "number" then
            animator.burstParticleEmitter(v)
        end
    end
    for i,v in pairs(key.lights or {}) do
        if type(v) == "bool" and type(i) == "string" then
            animator.setLightActive(i,v)
        end
    end
    for i,v in ipairs(key.fireEvents or {}) do
        self:fireEvent(v)
    end
end

--update animation time
function module:update(dt)
    if self.playing then
        if self.keyTime < self.keyTimeTarget then
            self.keyTime = math.min(self.keyTime + dt, self.keyTimeTarget)
        end
        if self.keyTime == self.keyTimeTarget then
            if self.keyFrames[self.key + 1] then
                self.keyTime = 0
                self:_reachkey(self.keyFrames[self.key])
                self.key = self.key + 1
                self.keyTimeTarget = self.keyFrames[self.key].wait
            else
                self.playing = false
            end
        end
    end

end

--play animation from start
function module:play()
    if #self.keyFrames == 0 then return end
    self.playing = true
    self.key = 1
    self.keyTime = 0
    self.keyTimeTarget = self.keyFrames[math.min(2, #self.keyFrames)].wait
    self:_reachkey(self.keyFrames[self.key])
end

-- to do
function module:inProgress()
    return self.key ~= 1
end

--pause animation
function module:pause()
    self.playing = false
end

--stop animation completely
function module:stop()
    self:pause()
    self.keyTime = 0
    self.key = 1
end

--full transfroms keys (fill the gaps in the key tranforms)
function module:ftk(key)
    local fkey = {}
    for i,transform in pairs(self.defaultTransforms) do
        fkey[i] = {}
        for i2, property in pairs(transform) do
            fkey[i][i2] = key.transforms[i][i2] or property
        end
    end
    return fkey
end

--key to key interpolation
function module:ktk(from, to, ratio)
    local from = self:ftk(from)
    local to = self:ftk(to)
    local current = {}
    for i,transform in pairs(self.defaultTransforms) do
        local timeRatio = ratio ^ (to[i].curve or 1)
        current[i] = {}
        for i2, property in pairs(transform) do
            if i == "time" or i == "curve" then
                --o
            elseif type(property) == "table" and #property == 2 then
                current[i][i2] = {}
                current[i][i2][1] = from[i][i2][1] + ((to[i][i2][1] - from[i][i2][1]) * timeRatio)
                current[i][i2][2] = from[i][i2][2] + ((to[i][i2][2] - from[i][i2][2]) * timeRatio)
            elseif type(property) == "number" then
                current[i][i2] = from[i][i2] + ((to[i][i2] - from[i][i2]) * timeRatio)
            end
        end
    end
    return current
end

--current animation transforms interpolations
function module:transforms()
    if self.key == #self.keyFrames then
        return self:ftk(self.keyFrames[#self.keyFrames])
    end
    return self:ktk(self.keyFrames[self.key], self.keyFrames[self.key+1], self.keyTime/self.keyTimeTarget)
end

module._events = {}

--add event for "fireEvents" : []
function module:addEvent(name, func)
    module._events[name] = func
end

function module:fireEvent(name)
    if type(module._events[name]) == "function" then
        module._events[name]()
    end
end