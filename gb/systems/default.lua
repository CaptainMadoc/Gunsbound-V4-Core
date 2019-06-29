include "config"
include "updateable"

include "vec2"
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

include "localAnimator"

--this is the default system for any gun

--THING TODO:
--[[

- Attachments System
- ui system

]]

include "stats"

gun = {}
gun.cooldown = 0
gun.settings = {
	drySound = "dry",
	fireSound = "fire",

	fireTypes = {"auto", "burst", "semi"},

	showCasings = true,
	chamberEjection = true
}

function gun:init()
	gun.settings = config.settings or gun.settings
	gun.chamber = config.chamber
	if gun.chamber then
		local ammo = module("modules/ammo.lua")
		ammo:load(gun.chamber)
		gun.chamber = ammo
	end

	gun.dry = config.dry or true

	magazine.max = stats.maxMagazine or 30

	animations:init()
	self:setupEvents()
	transforms:init()
	aim:init()
end

function gun:update(dt, fireMode, shift, moves)
	aim:update(dt)
	animations:update(dt)

	if animations:isAnyPlaying() then
		transforms:apply(animations:transforms())
	end

	transforms:update(dt)

	if self.cooldown > 0 then
		self.cooldown = math.max(self.cooldown - dt,0)
	end

	aim:at(activeItem.ownerAimPosition())

	self:updateReload(dt, fireMode, shift, moves)

	if fireMode == "primary" then
		self:fire()
	end

	self:updateUI()
end

function gun:activate(fireMode, shift) end

function gun:uninit()
	config.chamber = self.chamber:save()
	config.dry = self.dry

	transforms:uninit()
	animations:uninit()
end

function gun:setupEvents()
	animations:addEvent("eject_chamber", function() gun:eject_chamber() end)
	animations:addEvent("load_ammo", function() gun:load_chamber(magazine:use()) end)
	animations:addEvent("reload_loop", function() self.reloadLoop = true end)
	animations:addEvent("reloadLoop", function() self.reloadLoop = true end)
	animations:addEvent("insert_mag", function() magazine:reload() end)
	animations:addEvent("insert_bullet", function() magazine:reload(1) end)
	animations:addEvent("remove_mag", function() magazine:unload() end)
end

-- gun ammo management
gun.chamber = false
gun.reloadLoop = false
gun.dry = false

function gun:eject_chamber()
	if self.chamber then
		casingEmitter:fire(self.chamber)
		self.chamber = false
	end
end

function gun:load_chamber(ammo)
	if self.chamber then
		self:eject_chamber()
	end
	self.chamber = ammo
	self.dry = false
end

function gun:updateReload(dt, fireMode, shift, moves)
	local animationPlaying = animations:isAnyPlaying()
	
	if not self.chamber and self.cooldown == 0 and not self.dry and self.settings.chamberEjection then
		self:load_chamber(magazine:use())
	elseif not self.chamber and not animationPlaying and magazine:count() > 0 then
		self:animatePrefix("cock")
	end

	if self.cooldown == 0 then
		if self.dry and magazine:count() == 0 and not animationPlaying and ammoGroup:available() then
			self:animatePrefix("reload")
		elseif moves.up and not animationPlaying then
			if shift then
				self:animatePrefix("reload")
			else
				self:animatePrefix("cock")
			end
		end
	end
end

--event
function gun:fire()
	if self.chamber and self.chamber.count > 0 and (not animations:isAnyPlaying() or animations:isPlaying("shoot")) and self.cooldown == 0 then
		local ammo = self.chamber:use()
		muzzle:fire(self.chamber)
		self.chamber:use()
		if self.chamber.count <= 0 and self.settings.chamberEjection then
			self:eject_chamber()
			if magazine:count() == 0 then
				self.dry = true
			end
		end
		
		self:animatePrefix("shoot")
		animator.playSound(gun.settings.fireSound)
		self.cooldown = 60 / stats:get("rpm")
	elseif not self.chamber and self.cooldown == 0 then
		animator.playSound(gun.settings.drySound)
		self.cooldown = 60 / stats:get("rpm")
	end
end

--play animation with dry prefix 
function gun:animatePrefix(animationName)
	local prefix = ""
	if self.dry then
		prefix = "_dry"
	end
	if animations:has(animationName..prefix) then
		animations:play(animationName..prefix)
	elseif animations:has(animationName) then
		animations:play(animationName)
	end
end

--gun ui
gun.uiPosition = vec2(0)
function gun:updateUI()
	local handPosition = activeItem.handPosition()
	self.uiPosition = self.uiPosition:lerp(activeItem.handPosition(), 0.125)
	--background
	localAnimator.addDrawable(
		{
			line = {handPosition, vec2(0,-5) + self.uiPosition},
			width = 0.5,
			color = {255,255,255,128},
			fullbright = true,
			position = {0,0}
		},
		"overlay"
	)
	--background ammo
	localAnimator.addDrawable(
		{
			line = {vec2(0,-5), vec2(10,-5)},
			width = 4,
			color = {0,0,0,128},
			fullbright = true,
			position = self.uiPosition
		},
		"overlay"
	)
	localAnimator.addDrawable(
		{
			line = {
				vec2(0.125,-5),
				vec2((0.125) + 10 * (magazine:count() / magazine.max),-5)
			},
			width = 2,
			color = {255,255,255,255},
			fullbright = true,
			position = self.uiPosition
		},
		"overlay"
	)
end