include "config"
include "updateable"

include "vec2"
include "vec2util"
include "rays"

include "mcontroller"
include "activeItem"

include "transforms"
include "animations"

include "arms"
include "aim"
include "muzzle"
include "casingEmitter"
include "magazine"
include "ammoGroup"
include "attachmentSystem"

--this is the default system for any gun

--THING TODO:
--[[

- Attachments System
- ui system

]]

include "stats"

gun = {}
gun.cooldown = 0
gun.chamber = false
gun.reloadLoop = false
gun.settings = {
	drySound = "dry",
	fireSound = "fire",

	fireTypes = {"auto", "burst", "semi"},

	showCasings = true,
	chamberEjection = true
}

function gun:init()
	gun.settings = config.settings or gun.settings
	gun.chamber = config.chamber or false

	animations:init()
	animations:addEvent("eject_chamber", function() gun:eject_chamber() end)
    animations:addEvent("load_ammo", function() gun:load_chamber(magazine:use()) end)
	animations:addEvent("reload_loop", function() self.reloadLoop = true end)
	animations:addEvent("reloadLoop", function() self.reloadLoop = true end)
	animations:addEvent("insert_mag", function() magazine:reload() end)
	animations:addEvent("insert_bullet", function() magazine:reload(1) end)
	animations:addEvent("remove_mag", function() magazine:unload() end)

	transforms:init()
	magazine:init()
	aim:init()
	arms:init()
end

function gun:update(dt, fireMode, shift, moves)
	aim:update(dt)
	arms:update(dt)

	animations:update(dt)
	transforms:apply(animations:transforms({"reload","cock","draw","shoot"}))
	transforms:update(dt)

	if self.cooldown > 0 then
		self.cooldown = math.max(self.cooldown - dt,0)
	end

	aim:at(activeItem.ownerAimPosition())
	self:autoReload()


	if fireMode == "primary" then
		self:fire()
	end

end

function gun:eject_chamber()
	if self.chamber then
		if self.chamber.count <= 0 then
			casingEmitter:fire(self.chamber)
		else
			local saved = self.chamber:save()
			player.giveItem(saved)
		end
		self.chamber = false
	end
end

function gun:load_chamber(ammo)
	self.chamber = ammo
end

function gun:autoReload()
	if self.chamber and self.chamber.count <= 0 and self.settings.chamberEjection then
		self:eject_chamber()
	elseif not self.chamber and self.cooldown == 0 then
		self:load_chamber(magazine:use())
	end

	if self.cooldown == 0 then
		if magazine:count() == 0 and not animations:isAnyPlaying() and self.cooldown == 0 and ammoGroup:available() then
			animations:play("reload")
		end
	end
end

function gun:fire()
	if self.chamber and self.chamber.count > 0 and (not animations:isAnyPlaying() or animations:isPlaying("shoot")) and self.cooldown == 0 then
		local ammo = self.chamber:use()
		muzzle:fire(self.chamber)
		animations:play("shoot")
		animator.playSound(gun.settings.fireSound)
		self.chamber:use()
		self.cooldown = 60 / stats:get("rpm")
	elseif not self.chamber and self.cooldown == 0 then
		animator.playSound(gun.settings.drySound)
		self.cooldown = 60 / stats:get("rpm")
	end
end

function gun:activate(fireMode, shift)
end

function gun:uninit()
	config.load = gun.load
	magazine:uninit()
	transforms:uninit()
end