include "itemConfig"
include "tableutil"

module = {}
module.itemName = ""
module.config = {}
module.parameters = {}
module.count = 0

function module:load(item) -- loads from a item
	local orignalItemConfig = itemConfig(item.name, {})
	self.itemName = item.name
	self.config = orignalItemConfig
	self.parameters = item.parameters or {}
	self.count = item.count
end

--test placeholder
function module:create(projectileName, projectileConfig)
	self.parameters.projectile = projectileName
	self.parameters.projectileConfig = projectileConfig
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
		position,
		0,
		direction,
		false,
		self.parameters.projectileConfig or self.config.projectileConfig
	}
end

function module:casing(position, direction)
	local projectileArgs = {
		self.parameters.casingProjectile or self.config.casingProjectile,
		position,
		0,
		direction,
		false,
		self.parameters.casingProjectileConfig or self.config.casingProjectileConfig
	}
	if self.count > 0 then
		projectileArgs[6] = projectileArgs[6] or {}
		projectileArgs[6].actionOnReap = projectileArgs[6].actionOnReap or jarray()
		local ammoitem = self:save()
		projectileArgs[6].actionOnReap[#projectileArgs[6].actionOnReap + 1] = {action = "item", name = ammoitem.name, count = ammoitem.count, parameters = ammoitem.parameters} 
	end
	return projectileArgs
end
