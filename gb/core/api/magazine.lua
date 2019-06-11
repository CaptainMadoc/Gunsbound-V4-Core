include "config"
include "ammoGroup"
include "module"

magazine = {}
magazine.max = 30
magazine.storage = {}

function magazine:init()
	for i,v in ipairs(config.magazine or {}) do
		local newAmmo = module("modules/ammo.lua")
		newAmmo:load(v)
		self.storage[#self.storage + 1] = newAmmo
	end
end

function magazine:uninit()
	local saveMag = {}
	for i,v in pairs(self.storage) do
		local ammoItem = v:save()
		saveMag[#saveMag + 1] = ammoItem
	end
	config.magazine = saveMag
end

function magazine:reload(ammos)
	local getAmmo = ammos or ammoGroup:get(self.max - self:count())
	for i,v in ipairs(getAmmo) do 
		local newAmmo = module("modules/ammo.lua")
		newAmmo:load(v)
		self.storage[#self.storage + 1] = newAmmo
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