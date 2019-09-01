include "config"
include "attachment"
include "localAnimator"

attachmentSystem = {}
attachmentSystem.currentSpecial = false
attachmentSystem.list = {}
attachmentSystem.specials = {}

--[[
"attachments" : {
	"attachname" : <attachment>
}
]]


function attachmentSystem:init()
	if config.giveback then
		for i,v in pairs(config.giveback) do
			player.giveItem(v)
		end
		config.giveback = {}
	end

	for attachname,aconfig in pairs(config.attachments) do
		self.list[attachname] = attachment:new(attachname, aconfig)
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

function attachmentSystem:save()
	local conf = {}
	for i,v in pairs(self.list) do
		if v.save then
			conf[i] = self.list[i]:save()
		end
	end
	config.attachments = conf
end

function attachmentSystem:uninit()
	for i,v in pairs(self.list) do
		if v.uninit then
			self.list[i]:uninit()
		end
	end
	self:save()
end

-- for systems Scripts
function attachmentSystem:addSpecial(name, callbackFunction)
	self.specials[#self.specials + 1] = {name = name, func = callbackFunction}

	if not self.currentSpecial then
		self.currentSpecial = 1
	end
end

function attachmentSystem:activate()
	if self.currentSpecial and self.specials[self.currentSpecial] and self.specials[self.currentSpecial].func then
		self.specials[self.currentSpecial].func()
	end
end

function attachmentSystem:switch()
	if self.currentSpecial then
		self.currentSpecial = self.currentSpecial + 1

		if self.currentSpecial > #self.specials then
			self.currentSpecial = 1
		end
	end
end
