include "directory"

configInstance = {}
configInstance.config = {}
configInstance.parameters = {}
configInstance.directory = "/"


function configInstance:init()
	local itemConfig = root.itemConfig({name = item.name(), count = 1})
	self.config = itemConfig.config
	self.parameters = item.descriptor()
	self.directory = itemConfig.directory or "/"
end

function configInstance:uninit()
	for i,v in pairs(self.parameters) do
		if type(v) ~= "function" and type(v) ~= "userdata" then
			--saving here
		end
	end
end

function configInstance:path(p)
	if p:sub(1,1) == "/" then return p end
	return self.directory..p
end

function configInstance:getAnimation()
	local animationDirectory = self:getParameterWithConfig("animation")
	local animations = {}
	if configanimation then
		animations = root.assetJson(itemDirectory(animationDirectory), {})
	end
	local animationCustom = self:getParameterWithConfig("animationCustom")
    return sb.jsonMerge(animations, animationCustom)
end

function configInstance:getParameterWithConfig(name)
	if type(self.config[name]) == "table" and type(self.parameters[name]) == "table" then
		return sb.jsonMerge(self.config[name], self.parameters[name])
	end
	return self.parameters[name] or self.config[name]
end

setmetatable(configInstance,
	{
		__newindex = function(t, key, value)
			configInstance.parameters[key] = value
			--saving here
		end,
		__index = function(t, key)
			return configInstance.parameters[key] or configInstance.config[key]
		end
	}
)
