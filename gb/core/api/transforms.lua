include "vec2"
include "animator"
include "config"

local function lerp(f,t,r)
	return f + (t - f) * r
end

transforms = {}
transforms.current = {}
transforms.override = {}
transforms.default = nil

function transforms:init()
	self:load()
	message.setHandler("getTransforms", function(_, loc, ...) if loc then return self.default end end)
	message.setHandler("setTransforms", function(_, loc, transforms) if loc then self.override = table.vmerge(transforms or {}, {}) end end)
	self:update(1/60)
end

function transforms:update(dt)
	for name,def in pairs(self.default) do
		local current = self.override[name] or self.current[name] or {}
		local cal = {
			scale			= vec2(current.scale or def.scale or 1),
			scalePoint		= vec2(current.scalePoint or def.scalePoint or 0),
			position		= vec2(current.position or def.position or 0) * vec2(current.scale or def.scale or 1),
			rotation		= current.rotation or def.rotation or 0,
			rotationPoint	= lerp(
				vec2(current.scalePoint or def.scalePoint or 0), 
				vec2(current.rotationPoint or def.rotationPoint or 0), 
				vec2(current.scale or def.scale or 1)
			)
		}
		animator.resetTransformationGroup(name) 
		animator.scaleTransformationGroup(name, cal.scale, cal.scalePoint)
		animator.rotateTransformationGroup(name, math.rad(cal.rotation), cal.rotationPoint)
		animator.translateTransformationGroup(name, cal.position)
	end
	self.override = {}
end

function transforms:uninit()

end

-- apply over the current
function transforms:blend(transforms)
	for name,t in pairs(transforms) do
		self.current[name] = {}
		for name2, property in pairs(t) do
			if type(self.current[name][name2]) == "table" then
				self.current[name][name2] = vec2(property)
			else
				self.current[name][name2] = property
			end
		end
	end
end

-- reset and apply
function transforms:apply(transforms)
	self:reset()
	self:blend(transforms)
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
	local animation = config:getAnimation()
	for i,v in pairs(animation.transformationGroups or {}) do
		if not v.ignore then -- check if we can use it
			self:add(i, v.transform or {})
		end
	end
end

function transforms:getDefaultTransforms()
	if not self.default then
		self:load()
	end
	return self.default
end

