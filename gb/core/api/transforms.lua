include "vec2"
include "itemInstance"

local function lerp(f,t,r)
    return f + (t - f) * r
end

transforms = {}
transforms.current = {}
transforms.default = {}

function transforms:init()
    self:load()
    self:update(1/60)
end

function transforms:update(dt)
    for name,def in pairs(self.default) do
        local current = self.current[name] or {}
        local cal = {
            scale           = current.scale or def.scale or vec2(1,1),
            scalePoint      = current.scalePoint or def.scalePoint or vec2(0,0),
            position        = (current.position or def.position or vec2(0,0)) * (current.scale or def.scale or vec2(1,1)),
            rotation        = current.rotation or def.rotation or 0,
            rotationPoint   = lerp(
                                current.scalePoint or def.scalePoint or vec2(0,0), 
                                current.rotationPoint or def.rotationPoint or vec2(0,0), 
                                current.scale or def.scale or vec2(1,1)
                            )
        }
        animator.resetTransformationGroup(name) 
        animator.scaleTransformationGroup(name, cal.scale, cal.scalePoint)
        animator.rotateTransformationGroup(name, math.rad(cal.rotation), cal.rotationPoint)
        animator.translateTransformationGroup(name, cal.position)
        sb.setLogMap("1 - "..name, sb.printJson(cal))
    end
end

function transforms:uninit()

end

-- apply over the current
function transforms:blend(transforms)
    for name,t in pairs(transforms) do
        self.current[name] = {}
        for name2, property in pairs(t) do
            self.current[name][name2] = property
        end
    end
end

-- reset and apply
function transforms:apply(transforms)
    self:reset()
    for i,v in pairs(transforms) do
        self.current[i] = v
    end
end

function transforms:reset()
    self.current = {}
end

function transforms:add(name, def)
    local newtrans = {position = vec2(0,0), scale = vec2(1,1), scalePoint = vec2(0,0), rotation = 0, rotationPoint = vec2(0,0)}
    if def then
        newtrans = sb.jsonMerge(newtrans, def)
    end
    for i2,v2 in pairs(newtrans) do
        if type(v2) == "table" and #v2 == 2 then
            newtrans[i2] = vec2(v2)
        end
    end
    self.default[name] = newtrans
end

function transforms:load()
    self:reset()
    self.default = {}
    local animations = itemInstance:getAnimation()
    for i,v in pairs(animations.transformationGroups) do
        if not v.ignore then -- check if we can use it
            self:add(i, v.transform or {})
        end
    end
end

