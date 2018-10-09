magazine = {
	type = "rotating",
	storage = {
	},
	selected = 1
}

		--CallBacks

function magazine:init()
	self.storage = config.getParameter("magazine", jarray())
	self.selected = config.getParameter("selected", 1)
end

function magazine:lateinit()
	animation:addEvent("insert_mag", function() magazine:insert() end)
	animation:addEvent("insert_bullet", function() magazine:insert(1) end)
	animation:addEvent("remove_mag", function() magazine:remove() end)
	animation:addEvent("rotate_mag", function() magazine:rotate() end)
	animation:addEvent("resetSelect_mag", function() magazine.selected = 1 magazine:saveData() end)
	self:verify()
end

function magazine:update(dt)
	activeItem.setScriptedAnimationParameter("magazine", self.storage)
	activeItem.setScriptedAnimationParameter("magazineType", self.type)
	activeItem.setScriptedAnimationParameter("selected", self.selected)
	activeItem.setScriptedAnimationParameter("maxMagazine", data.gunStats.maxMagazine or 30)
end

function magazine:uninit()
	self:saveData()
end


		--API

function magazine:processCompatible(a)
	if type(a) == "string" then
		return root.assetJson(a)
	end
	return a
end

function magazine:saveData()
	activeItem.setInstanceValue("magazine", self.storage)
	activeItem.setInstanceValue("selected", self.selected)
	activeItem.setInstanceValue("gunLoad", data.gunLoad)
end

function magazine:insert(co)
	local compat = config.getParameter("compatibleAmmo", jarray())
	if type(compat) == "string" then
		compat = processDirectory(compat)
	end
	if not co then
		co = data.gunStats.maxMagazine - #self.storage
	end
	for i,v in pairs(self:processCompatible(compat)) do
		if co > 0 then
			if player.hasItem({name = v, count = 1}) then
				local con = player.consumeItem({name = v, count = co}, true)
				
				for i = 1,con.count do
					table.insert(self.storage, {name = v, count = 1, parameters = con.parameters or {}})
					co = co - 1
				end
			end
		end
	end
	
	if self.storage[self.selected] then
		data.gunLoad = self.storage[self.selected]
		self.storage[self.selected] = nil
	end
	
	magazine:saveData()
end

function magazine:rotate()
	if data.gunLoad then
		self.storage[self.selected] = data.gunLoad
		data.gunLoad = nil
	end
	self.selected = self.selected + 1
	if self.selected > data.gunStats.maxMagazine then
		self.selected = 1
	end
	if self.storage[self.selected] then
		data.gunLoad = self.storage[self.selected]
		self.storage[self.selected] = nil
	end
	magazine:saveData()
end

function magazine:playerHasAmmo()
	local compat = config.getParameter("compatibleAmmo", jarray())
	if type(compat) == "string" then
		compat = processDirectory(compat)
	end
	for i,v in pairs(self:processCompatible(compat)) do
		if player.hasItem({name = v, count = 1}) then
			return true
		end
	end
	return false
end

function magazine:remove()
	local togive = jarray()
	
	if data.gunLoad then
		self.storage[self.selected] = data.gunLoad
		data.gunLoad = nil
	end
	
	for i,v in pairs(self.storage) do
		if v.parameters and v.parameters.fired then
			if v.parameters.casingProjectile then
				world.spawnProjectile(
					v.parameters.casingProjectile, 
					gun:casingPosition(), 
					activeItem.ownerEntityId(), 
					vec2.rotate({0,1}, math.rad(math.random(90) - 45)), 
					false,
					v.parameters.casingProjectileConfig or {}
				)
			end
		else
			if #togive == 0 then
				table.insert(togive,v)
			else
				local matched = false
				for i2,v2 in pairs(togive) do
					if sb.printJson(v.parameters) == sb.printJson(v2.parameters) and v.name == v2.name then
						matched = true
						togive[i2].count = togive[i2].count + v.count
					end
				end
				if not matched then
					table.insert(togive, v)
				end
			end
		end
	end
	for i,v in pairs(togive) do
		player.giveItem(v)
	end
	self.storage = jarray();
	magazine:saveData()
end


function magazine:verify()
	for i,v in pairs(self.storage) do
		if i > data.gunStats.maxMagazine then
			self.storage[i] = nil
		end
	end
end

function magazine:take()
	if #self.storage > 0 then
		local ammoPull = self.storage[#self.storage]
		table.remove(self.storage,#self.storage)
		activeItem.setInstanceValue("magazine", self.storage)
		return ammoPull
	end
	return nil
end

function magazine:count()
	local c = 0
	for i,v in pairs(self.storage) do
		if not v.parameters or (v.parameters and not v.parameters.fired) then
			c = c + v.count
		end
	end
	return c
end

function magazine:rawcount()
	local c = 0
	for i,v in pairs(self.storage) do
		c = c + v.count
	end
	return c
end


addClass("magazine")