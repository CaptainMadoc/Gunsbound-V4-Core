include "itemConfig"
include "vec2"
include "vec2util"
include "tableutil"

module = {}
module.itemName = ""
module.config = {}
module.parameters = {}
module.count = 0

function module:load(item) -- loads from a item
	local orignalItemConfig = itemConfig(item.name)
	self.itemName = item.name
	self.config = orignalItemConfig.parameters
	self.parameters = item.parameters or {}
	self.count = item.count
end


function module:save() -- returns a item
	return {
		name = self.itemName,
		count = self.count,
		parameters = self.parameters
	}
end

function module:use()
	if self.count > 0 then
		self.count = self.count - 1
		local copy = table.copy(self)
		copy.count = 1
		return copy
	end
	return false
end

function module:projectileArgs(position, direction)
	return {
		self.parameters.projectile or self.config.projectile,
		nil, -- will be overriden
		0,
		vec2util.angle(direction),
		false,
		self.parameters.projectileConfig or self.config.projectileConfig
	}
end
