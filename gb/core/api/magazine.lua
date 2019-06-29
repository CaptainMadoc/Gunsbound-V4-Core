include "config"
include "ammoGroup"
include "module"
include "updateable"
include "animator"

magazine = {}
magazine.max = 30
magazine.storage = {}

function magazine:init()
	self.storage = jarray()
	for i,v in ipairs(config.magazineStorage or {}) do
		local newAmmo = module("modules/ammo.lua")
		newAmmo:load(v)
		self.storage[#self.storage + 1] = newAmmo
	end
	animator.setPartTag(config.magazine.part, config.magazine.tag or "partImage", config.magazine.image or "/assetmissing.png")
end

function magazine:uninit()
	local saveMag = jarray()
	for i,v in ipairs(self.storage) do
		local ammoItem = v:save()
		sb.logInfo(sb.printJson(ammoItem))
		saveMag[#saveMag + 1] = ammoItem
	end
	config.magazineStorage = saveMag
end

function magazine:reload(ammos)
	local getAmmo = ammos or ammoGroup:get(self.max - self:count())
	for i,v in ipairs(getAmmo) do 
		local newAmmo = module("modules/ammo.lua")
		newAmmo:load(v)
		self.storage[#self.storage + 1] = newAmmo
	end
end

function magazine:unload()
	for i,v in ipairs(self.storage) do 
		local item = self.storage[#self.storage]:save()
		player.giveItem(item)
		self.storage[#self.storage] = nil
	end
end

function magazine:count()
	local counts = 0
	for i,v in ipairs(self.storage) do
		counts = counts + v.count
	end
	return counts
end

--returns a ammo module type
function magazine:use()
	if #self.storage > 0 then
		local ammo = self.storage[#self.storage]:use()

		if self.storage[#self.storage].count <= 0 then --remove if empty
			self.storage[#self.storage] = nil
		end

		return ammo
	end
end

function magazine:hide()
	animator.setPartTag(config.magazine.part, config.magazine.tag or "partImage", "/assetmissing.png")	
end

function magazine:show()
	animator.setPartTag(config.magazine.part, config.magazine.tag or "partImage", config.magazine.image or "/assetmissing.png")
end

updateable:add("magazine")