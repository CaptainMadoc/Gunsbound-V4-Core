include "configInstance"
include "attachment"

attachmentSystem = {}
attachmentSystem.currentSpecial = false
attachmentSystem.list = {}
attachmentSystem.specials = {}


function attachmentSystem:init()
	for attachname,property in pairs(configInstance:getParameterWithConfig("attachments")) do
		self.list[attachname] = attachment:new(property)
	end
	for i,v in pairs(self.list) do
		if self.list[i].init then
			self.list[i]:init()
		end
	end
end

function attachmentSystem:update(dt)
	for i,v in pairs(self.list) do
		if v.update then
			self.list[i]:update(dt)
		end
	end
end

function attachmentSystem:uninit()
	for i,v in pairs(self.list) do
		if v.uninit then
			self.list[i]:uninit()
		end
	end
end

-- for systems Scripts
function attachmentSystem:addSpecial(callbackFunction)
	
end

function attachmentSystem:activate()
	if self.currentSpecial then

	end
end

function attachmentSystem:switch()
	if not self.currentSpecial then
		
	end
end
