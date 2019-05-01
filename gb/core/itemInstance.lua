itemInstance = {}

function itemInstance:init()
	local itemConfig = root.itemConfig({name = item.name(), count = 1})
	local descriptors = item.descriptors()
	for i,v in pairs(sb.jsonMerge(itemConfig.config, descriptors)) do
		self[i] = v
	end
	self.directory = itemConfig.directory or "/"
end

function itemInstance:path(p)
	if p:sub(1,1) == "/" then return p end
	return self.directory..p
end

function itemInstance:getAnimation()
	
end

function itemInstance:uninit()
	for i,v in pairs(self) do
		if type(v) ~= "function" and type(v) ~= "userdata" then
			activeItem.setInstanceValue(i,v)
		end
	end
end