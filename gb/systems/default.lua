include "config"
include "updateable"

include "vec2"
include "rays"

include "mcontroller"
include "activeItem"

include "transforms"
include "animations"
include "crosshair"


include "aim"

include "chamber"
include "muzzle"
include "casingEmitter"

include "ammo"
include "magazine"
include "ammoGroup"

include "attachmentSystem"

include "localAnimator"
include "camera"

--this is the default system for any gun

--THING TODO:
--[[

- Attachments System

]]

include "stats"
include "settings"

gun = {}
gun.ready = false

--callbacks

function gun:init()

	if type(config.dry) == "boolean" then
		self.dry = config.dry
	else
		self.dry = true
	end
	self._firemode = config.fireMode or 1

	magazine.max = stats:get("maxMagazine")
	aim.recoilRecovery = stats:get("recoilRecovery")
	
	if config.FlexArm then
		include "arms"
	else
		include "altarms"
		altarms:init()
	end

	self:setupEvents()
	animations:init()
	transforms:init()
	aim:init()
	attachmentSystem:init()

	local confanimation = config:getAnimation()
    transforms:addCustom(
        "armRotation", 
            (confanimation.transformationGroups.armRotation or {rotation = 0}).transform or {rotation = 0}, 
        function(tr)
	        aim.offset = tr.rotation or 0
        end
	)

	self:animate("draw")
end

function gun:setupEvents()
	animations:addEvent("eject_chamber", function() self:eject_chambers() end)
	animations:addEvent("load_ammo", function() self:load_chambers() end)
	animations:addEvent("reload_loop", function() self.reloadLoop = true end)
	animations:addEvent("reloadLoop", function() self.reloadLoop = true end)
	animations:addEvent("insert_mag", function() magazine:reload() end)
	animations:addEvent("insert_bullet", function() magazine:reload(ammoGroup:get(1)) end)
	animations:addEvent("remove_mag", function() magazine:unload() end)
end

function gun:update(dt, firemode, shift, moves)
	if not self.ready and not animations:isAnyPlaying() then
		self.ready = true
	end

	animations:update(dt)
	if animations:isAnyPlaying() and not transforms.overriden then
		transforms:apply(animations:transforms())
	end
	transforms:update(dt)

	aim:at(activeItem.ownerAimPosition())
	aim:update(dt)
	camera.target = ((activeItem.ownerAimPosition() - mcontroller.position()) * vec2(stats:get("aimLookRatio") / 2)) + vec2(0, aim:getRecoil() * 0.125)

	attachmentSystem:update(dt)
	self:updateControls(dt, firemode, shift, moves)
	self:updateAccuracy(dt)
	self:updateReload(dt)
	self:updateFire(dt)
	self:updateTimers(dt)

	if not config.FlexArm then
		altarms.frontTarget = activeItem.handPosition(animator.transformPoint({0,0},"R_handPoint"))
		altarms.backTarget = activeItem.handPosition(animator.transformPoint({0,0},"L_handPoint"))
		world.debugPoint(activeItem.handPosition(animator.transformPoint({0,0},"R_handPoint")) + mcontroller.position(),"green")
		world.debugPoint(activeItem.handPosition(animator.transformPoint({0,0},"L_handPoint")) + mcontroller.position(),"green")
		altarms:update(dt, fireMode, shift, moves)
	end
end

function gun:activate(firemode, shift)
	
end

function gun:uninit()
	config.dry = self.dry
	config.fireMode = self._firemode

	attachmentSystem:uninit()
	transforms:uninit()
	animations:uninit()
end

function gun:updateTimers(dt)
	if self.cooldown == 0 and self.shouldLoad then
		self:load_chambers()
		self.shouldLoad = false
	end
	if self.cooldown > 0 then
		self.cooldown = math.max(self.cooldown - dt,0)
	elseif self.burstcooldown > 0 then
		self.burstcooldown = math.max(self.burstcooldown - dt,0)
	end
end

function gun:updateControls(dt, firemode, shift, moves)
	if firemode == "primary" and self.cooldown == 0 and self.queueFire == 0 then
		local firemode = self:firemode() or "nil"
		if firemode == "semi" and update_lastInfo[2] ~= firemode then
			self.queueFire = 1
		elseif firemode == "auto" then
			self.queueFire = 1
		elseif firemode == "burst" and self.burstcooldown == 0 then
			local burst = stats:get("burst")
			self.queueFire = burst
			self.burstcooldown = stats:get("burstCooldown")
		end
	end

	if moves.up and not animations:isAnyPlaying() and self.cooldown <= 0 then
		if shift then
			self:animate("reload")
		else
			self:animate("cock")
		end
	end

	if moves.down then
		if shift and not update_lastInfo[3] then
			self:switchFiremode()
		end
	end

	if firemode == "alt" then
		if shift then
			attachmentSystem:switch()
		else
			attachmentSystem:activate()
		end
	end
end

function gun:updateAccuracy(dt)
	muzzle.inaccuracy = self:getInaccuracy()
end


function gun:getInaccuracy()
	local vel = math.max(math.abs(mcontroller.xVelocity()), math.abs(mcontroller.yVelocity() + 1.27))
	local movingRatio = math.min(vel / 14, 1)

	local acc = (stats:get("movingInaccuracy") * movingRatio) + (stats:get("standingInaccuracy") * (1 - movingRatio))

	if mcontroller.crouching() then
		return acc * stats:get("crouchInaccuracyMultiplier")
	else
		return acc
	end
end


-- firemode functions

gun._firemode = 1
function gun:firemode()
	return settings:get("fireTypes")[self._firemode]
end

function gun:switchFiremode()
	if #settings:get("fireTypes") <= self._firemode then
		self._firemode = 1
	else
		self._firemode = self._firemode + 1
	end
end

-- gun ammo management

gun.chamber = nil
gun.reloadLoop = false
gun.dry = false

function gun:updateReload(dt)
	if self.ready then
		if self.reloadLoop then
			if not animations:isAnyPlaying() then
				if magazine:count() == stats:get("maxMagazine") or not ammoGroup:available() then
					self.reloadLoop = false
					self:animate("reloadEnd")
				else
					self:animate("reloadLoop")
				end
			end
		else
			local chamberEjection = settings:get("chamberEjection")

			if (chamber:loads() == 0 or chamber:ready() == 0) and magazine:count() > 0 and self.cooldown == 0 then
				if not animations:isAnyPlaying() then
					self:animate("cock")
				end
			end

			if magazine:count() == 0 and (chamber:ready() == 0) and ammoGroup:available() and not animations:isAnyPlaying() then
				self:animate("reload")
			end
		end
	end
end

function gun:eject_chambers()
	chamber:ejectAll()
	if magazine:count() == 0 then
		self.dry = true
	end
end

function gun:load_chambers()
	if chamber:loads() > 0 then
		chamber:ejectAll()
	end

	self.dry = false
	chamber:fillFromMagazine(magazine)
end

--firing functions
gun.queueFire = 0
function gun:updateFire(dt)
	if self.queueFire > 0 and chamber:ready() > 0 and self.cooldown == 0 and (not animations:isAnyPlaying() or animations:isPlaying("shoot")) then
		self.queueFire = math.max(self.queueFire - 1, 0)
		self:fire()
	elseif magazine:count() == 0 and chamber:ready() == 0 then
		self.queueFire = 0
	end
end

gun.cooldown = 0
gun.burstcooldown = 0
function gun:addCooldown()
	self.cooldown = 60 / stats:get("rpm")
end

local function firecallback(at, ammo)
	muzzle:fireFromMuzzle(at, ammo)
	ammo:use()
end

function gun:fire()
	if chamber:ready() > 0 then
		muzzle.damageMultplier = stats:get("damageMultiplier")

		if stats:get("muzzleFlash") > 0 then
			muzzle:flash()
		end

		chamber:use(firecallback)

		if settings:get("chamberEjection") then
			self:eject_chambers()
		end
		if magazine:count() > 0 and settings:get("chamberAutoLoad") then
			self.shouldLoad = true
		end
		
		aim:recoil(stats:get("recoil"))
		self:animate("shoot")
		
		animator.playSound(settings:get("fireSound"))

		self:addCooldown()
	else
		animator.playSound(settings:get("drySound"))
		self:addCooldown()
		self.queueFire = 0
	end
end

--play animation with dry prefix 
function gun:animate(animationName)
	if self.dry and animations:has(animationName.."_dry") then
		animations:play(animationName.."_dry")
	elseif animations:has(animationName) then
		animations:play(animationName)
	end
end

--gun ui
gunUI = {}
gunUI.offset = vec2(0)
gunUI.lerpMag = 0
gunUI.lerpBurstMode = 0
gunUI.lerpAutoMode = 0

function gunUI:update(dt)
	local handPosition = activeItem.handPosition()
	local hand = activeItem.hand()
	local direction = (hand == "alt" and 1) or (hand == "primary" and -1)
	self.offset = self.offset:lerp(activeItem.handPosition() + vec2(2 * direction,0), 0.125)
	local currentMag = (magazine:count() / magazine.max)
	self.lerpMag = self.lerpMag + (currentMag - self.lerpMag) * 0.125

	--connecting line
	--localAnimator.addDrawable(
	--	{
	--		line = {handPosition, vec2(0,-5) + self.offset},
	--		width = 0.5,
	--		color = {255,255,255,32},
	--		fullbright = true,
	--		position = {0,0}
	--	},
	--	"overlay"
	--)
	--background ammo
	localAnimator.addDrawable(
		{
			line = {vec2(0 * direction,-5), vec2(10 * direction,-5)},
			width = 4,
			color = {0,0,0,128},
			fullbright = true,
			position = self.offset
		},
		"overlay"
	)

	--chamber status
	if chamber:loads() > 0 then
		local color = {255,255,255}
		if chamber:ready() == 0 then
			color = {255,0,0}
		end
		localAnimator.addDrawable(
			{
				line = {vec2(0.125 * direction,-5), vec2(1.125 * direction,-5)},
				width = 2,
				color = color,
				fullbright = true,
				position = self.offset
			},
			"overlay"
		)
	end

	--magazine status
	localAnimator.addDrawable(
		{
			line = {
				vec2(1.25 * direction,-5),
				vec2((1.25 + (10 - 1.375) * self.lerpMag) * direction,-5)
			},
			width = 2,
			color = {255,255,255},
			fullbright = true,
			position = self.offset
		},
		"overlay"
	)

	--firemode status
	local currentFireMode = gun:firemode()
	if currentFireMode == "burst" or currentFireMode == "auto" then
		self.lerpBurstMode = self.lerpBurstMode + (1 - self.lerpBurstMode) * 0.125
	else
		self.lerpBurstMode = self.lerpBurstMode + (0 - self.lerpBurstMode) * 0.125
	end
	if currentFireMode == "auto" then
		self.lerpAutoMode = self.lerpAutoMode + (1 - self.lerpAutoMode) * 0.125
	else
		self.lerpAutoMode = self.lerpAutoMode + (0 - self.lerpAutoMode) * 0.125
	end
	--semi
	localAnimator.addDrawable(
		{
			line = {
				vec2(0.125 * direction,-5.5),
				vec2(1.125 * direction,-5.5)
			},
			width = 1,
			color = {255,255,255},
			fullbright = true,
			position = self.offset
		},
		"overlay"
	)
	--burst
	localAnimator.addDrawable(
		{
			line = {
				vec2(0.125 * direction,-5.5 - (0.25 * self.lerpBurstMode)),
				vec2(1.125 * direction,-5.5 - (0.25 * self.lerpBurstMode))
			},
			width = 1,
			color = {255,255,255},
			fullbright = true,
			position = self.offset
		},
		"overlay"
	)
	localAnimator.addDrawable(
		{
			line = {
				vec2(0.125 * direction,-5.5 - (0.5 * self.lerpBurstMode)),
				vec2(1.125 * direction,-5.5 - (0.5 * self.lerpBurstMode))
			},
			width = 1,
			color = {255,255,255},
			fullbright = true,
			position = self.offset
		},
		"overlay"
	)
	--auto
	localAnimator.addDrawable(
		{
			line = {
				vec2(0.125 * direction,-5.5 - (0.75 * self.lerpAutoMode)),
				vec2(1.125 * direction,-5.5 - (0.75 * self.lerpAutoMode))
			},
			width = 1,
			color = {255,255,255},
			fullbright = true,
			position = self.offset
		},
		"overlay"
	)
	localAnimator.addDrawable(
		{
			line = {
				vec2(0.125 * direction,-5.5 - (1 * self.lerpAutoMode)),
				vec2(1.125 * direction,-5.5 - (1 * self.lerpAutoMode))
			},
			width = 1,
			color = {255,255,255},
			fullbright = true,
			position = self.offset
		},
		"overlay"
	)

end

updateable:add("gunUI")