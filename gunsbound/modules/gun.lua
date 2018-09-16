gun = {
    fireModeInt = 1,
	recoil = 0,
	cooldown = 0,
	aimPos = nil,
	features = {
		recoilRecovery = true,
		cameraAim = true,
		aim = true --disable this if you want to override things
	},
	camera = {0,0}
}

		--CALLBACKS

function gun:init()
    datamanager:load("gunLoad", true)
    datamanager:load("gunScript", false, "/gunsbound/base/default.lua")
	datamanager:load("gunStats", false, 
		{
			damageMultiplier = 2,
			maxMagazine = 30,
			aimLookRatio = 0.125,
			burst = 3,
			recoil = 4,
			recoilRecovery = 2,
			movingInaccuracy = 5,
			standingInaccuracy = 1,
			crouchInaccuracyMultiplier = 0.25,
			muzzleFlash = 1,
			rpm = 600
		}
	)
    datamanager:load("fireTypes", false, {"auto"})
    datamanager:load("casingFX", false, true)
    datamanager:load("bypassShellEject", false, false)
    datamanager:load("muzzlePosition", false, {part = "gun", tag = "muzzle_begin", tag_end = "muzzle_end"})
    datamanager:load("casing", false, {part = "gun", tag  = "casing_pos"})
    datamanager:load("gunAnimations")
    datamanager:load("compatibleAmmo")

	message.setHandler("isLocal", function(_, loc) return loc end )
	activeItem.setScriptedAnimationParameter("entityID", activeItem.ownerEntityId())
	activeItem.setCursor("/gunsbound/crosshair/crosshair2.cursor")
    self.fireSounds = config.getParameter("fireSounds",jarray())
	for i,v in pairs(self.fireSounds) do
		self.fireSounds[i] = processDirectory(v)
    end
	animator.setSoundPool("fireSounds", self.fireSounds)
	animation:addEvent("eject_chamber", function() self:eject_chamber() end)
	animation:addEvent("load_ammo", function() self:load_chamber() end)
	animation:addEvent("reload_loop", function() self.reloadLoop = true end)
	animation:addEvent("reloadLoop", function() self.reloadLoop = true end)

	require(processDirectory(data.gunScript))
end

function gun:lateinit(...)
	if main and main.init then
		main:init(...)
	end
end

function gun:uninit(...)
	if main and main.uninit then
		main:uninit(...)
	end
	datamanager:save("gunLoad")
end

function gun:activate(...)
	if main and main.activate then
		main:activate(...)
	end
end

function gun:update(dt, fireMode, shiftHeld, moves)

	--camerasystem
	if self.features.cameraAim then
		local distance = world.distance(activeItem.ownerAimPosition(), mcontroller.position())
		camera.target = vec2.add({distance[1] * util.clamp(data.gunStats.aimLookRatio, 0, 0.5),distance[2] * util.clamp(data.gunStats.aimLookRatio, 0, 0.5)}, self.camera)
		camera.smooth = 8
		self.camera = {lerp(self.camera[1],0,data.gunStats.recoilRecovery),lerp(self.camera[2],0,data.gunStats.recoilRecovery)}
	end
	
	if self.features.recoilRecovery then
	self.recoil = lerp(self.recoil, 0, data.gunStats.recoilRecovery)	
	end

	if self.features.aim then
		local angle, dir = activeItem.aimAngleAndDirection(0, vec2.add(self.aimPos or activeItem.ownerAimPosition(), vec2.div(mcontroller.velocity(), 28)))
		aim.target = math.deg(angle) + self.recoil
		aim.direction = dir
	end

	if self.hasToLoad and gun:ready() then
		self.hasToLoad = false
		self:load_chamber()
		self.cooldown = 0.016
    end

	if main and main.update then
		main:update(dt, fireMode, shiftHeld, moves)
	end

	self.cooldown = math.max(self.cooldown - updateInfo.dt, 0)
	
end

		--API--

--Use for calculation RPM to shots timer
function gun:rpm()
    return math.max((60/(data.gunStats.rpm or 666)) - 0.016, 0.016)
end

--i think its for the angle RNG -/+
function gun:inaccuracy()
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = data.gunStats.crouchInaccuracyMultiplier
	end
	local velocity = whichhigh(math.abs(mcontroller.xVelocity()), math.abs(mcontroller.yVelocity() + 1.28))
	local percent = math.min(velocity / 14, 1)
	return lerpr(data.gunStats.standingInaccuracy, data.gunStats.movingInaccuracy, percent) * crouchMult
end

--RNG
function gun:calculateInAccuracy(pos)
	local angle = (math.random(0,2000) - 1000) / 1000
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = data.gunStats.crouchInaccuracyMultiplier
	end
	if not pos then
		return math.rad((angle * self:inaccuracy()))
	end
	return vec2.rotate(pos, math.rad((angle * self:inaccuracy())))
end

--Quick relativepos from hand + pos
function gun:rel(pos)	
	return vec2.add(mcontroller.position(), activeItem.handPosition(pos))
end

--vec2 angle from muzzlePosition
function gun:angle()
	return vec2.sub(self:rel(animator.partPoint(data.muzzlePosition.part, data.muzzlePosition.tag_end)),self:rel(animator.partPoint(data.muzzlePosition.part, data.muzzlePosition.tag)))
end

--vec2 angle from casing
function gun:casingPosition()
	local offset = {0,0}
	if data.casing then
		offset = animator.partPoint(data.casing.part, data.casing.tag)
	end
	return vec2.add(mcontroller.position(), activeItem.handPosition(offset))
end

--overrides from cursor aim if you want to make aimbot attachments
function gun:aimAt(pos)
	if not pos then self.aimPos = nil return end self.aimPos = pos
end

--You know
function gun:fire()
	if data.gunLoad and not data.gunLoad.parameters.fired then -- data.gunLoad must be a valid bullet without a parameter fired as true
		
		local newConfig = root.itemConfig({name = data.gunLoad.name, count = 1, parameters = data.gunLoad.parameters})		
		if not newConfig then self:eject_chamber() return end

		data.gunLoad.parameters = sb.jsonMerge(newConfig.config, newConfig.parameters)

		local finalProjectileConfig = data.gunLoad.parameters.projectileConfig or {}
		if not finalProjectileConfig.power then
			finalProjectileConfig.power = (root.projectileConfig(data.gunLoad.parameters.projectile or "bullet-4").power or 5.0) * (data.gunStats.damageMultiplier or 1.0)
		end

		for i=1,data.gunLoad.parameters.projectileCount or 1 do
			world.spawnProjectile(
				data.gunLoad.parameters.projectile or "bullet-4", 
				self:rel(animator.partPoint(data.muzzlePosition.part, data.muzzlePosition.tag)), 
				activeItem.ownerEntityId(), 
				self:calculateInAccuracy(self:angle()), 
				false,
				finalProjectileConfig
			)
		end

		--marks ammo as a fired bullet
		data.gunLoad.parameters.fired = true
		
		--used by action lever style
		if not data.bypassShellEject then
			self:eject_chamber()
			self.hasToLoad = true
		end
		
		--
		
		--emits FX muzzle flash sometimes changed by a silencer/flash hider
		if data.gunStats.muzzleFlash == 1 then
			animator.setAnimationState("firing", "on")
		end

		animator.playSound("fireSounds")
		self.cooldown = self:rpm()
		self:addRecoil()
		self.recoilCamera = {math.sin(math.rad(self.recoil * 80)) * ((self.recoil / 8) ^ 1.25), self.recoil / 8}

		datamanager:save("gunLoad")

		return true
	else --else plays a dry sound
		animator.playSound("dry")
		self.cooldown = self:rpm()
		return false
	end
end

--Gets bullet out from the internal gun
function gun:eject_chamber()
	if data.gunLoad then
		if data.gunLoad.parameters and data.gunLoad.parameters.fired and data.gunLoad.parameters.casingProjectile and data.casingFX then
			world.spawnProjectile(
				data.gunLoad.parameters.casingProjectile, 
				self:casingPosition(), 
				activeItem.ownerEntityId(), 
				vec2.rotate({0,1}, math.rad(math.random(90) - 45)), 
				false,
				data.gunLoad.parameters.casingProjectileConfig or {speed = 10, timeToLive = 1}
			)
		elseif not data.gunLoad.parameters or not data.gunLoad.parameters.fired then
			player.giveItem(data.gunLoad)
		end
		data.gunLoad = nil
		datamanager:save("gunLoad")
	end
end

--Gets bullet in from the internal gun; can be manual loaded with 'bullet'
function gun:load_chamber(bullet)
	if data.gunLoad then 
		self:eject_chamber()
	end
	data.gunLoad = bullet or magazine:take()
	datamanager:save("gunLoad")
end

--See if nothing is loaded
function gun:chamberDry()
	return type(data.gunLoad) ~= "table"
end

--Adding armOffsets
function gun:addRecoil(custom)
	local a = custom
	if not custom then
		a = data.gunStats.recoil
	end
	self.recoil = self.recoil + a * 2
end

--Gets Current Firemode
function gun:fireMode()
	return data.fireTypes[self.fireModeInt]
end

--todo
function gun:switchFireModes(custom)
	if not data.fireTypes then data.fireTypes = {"semi"} end
	if self.fireModeInt > #data.fireTypes then
		self.fireModeInt = 1
	else
		self.fireModeInt = self.fireModeInt + 1
	end
end

--Gun full ready
function gun:ready()
	if self.cooldown == 0 then
		return true
	end
	return false
end


addClass("gun", 1)