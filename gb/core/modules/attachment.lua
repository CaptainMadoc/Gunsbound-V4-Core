include "itemConfig"

module = {}
module.item = nil
module.part = nil

function module:load(config)
	self.item = itemConfig(config.item)
	self.part = config.part
end

function module:update()
	
end