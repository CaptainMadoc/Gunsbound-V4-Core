include "itemConfig"
include "tableutil"
include "attachmentSystem"

attachment = {}
attachment.item = nil
attachment.itemDirectory = nil
attachment.part = nil
attachment.config = {}
attachment.parameters = {}

function attachment:new(config)
	local n = table.copy(self)
	n.item = itemConfig(config.item.name)
	n.itemDirectory = itemDirectory(config.item)
	n.config = item.attachment or {}
	n.storage = n.config.storage or {}
	n.part = config.part
end

function attachment:init()

end

function attachment:update()
	
end   