itemInstance = {}
itemInstance.config = {}
itemInstance.parameters = {}
itemInstance.directory = "/"


function itemInstance:init()
	local itemConfig = root.itemConfig({name = item.name(), count = 1})
	self.config = itemConfig.config
	self.parameters = item.descriptor()
	self.directory = itemConfig.directory or "/"
end

function itemInstance:uninit()
	for i,v in pairs(self.parameters) do
		if type(v) ~= "function" and type(v) ~= "userdata" then
			activeItem.setInstanceValue(i,v)
		end
	end
end

function itemInstance:path(p)
	if p:sub(1,1) == "/" then return p end
	return self.directory..p
end

function itemInstance:getAnimation()
	
end

setmetatable(itemInstance,
	{
		__newindex = function(t, key, value)
			itemInstance.parameters[key] = value
			activeItem.setInstanceValue(key,value)
		end,
		__index = function(t, key)
			return itemInstance.parameters[key] or itemInstance.config[key]
		end
	}
)
