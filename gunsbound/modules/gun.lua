--another prototype for gun design
gun = {
    fireMode = 1,
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
function gun:lerp(value, to, speed) return value + ((to - value ) / speed )  end
function gun:lerpr(value, to, ratio) return value + ((to - value ) * ratio ) end

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
    datamanager:load("fireTypes")
    datamanager:load("casingFX")
    datamanager:load("bypassShellEject")
    datamanager:load("muzzlePosition")
    datamanager:load("casing")
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
	animation:addEvent("eject_ammo", function() self:eject_ammo() end)
	animation:addEvent("load_ammo", function() self:load_ammo() end)
	animation:addEvent("reload_loop", function() self.reloadLoop = true end)
	animation:addEvent("reloadLoop", function() self.reloadLoop = true end)
end

function gun:lateinit()
	if main and main.init then
		main:init()
	end
end

function gun:uninit()
	if main and main.uninit then
		main:uninit(...)
	end
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
		self.camera = {self:lerp(self.camera[1],0,data.gunStats.recoilRecovery),self:lerp(self.camera[2],0,data.gunStats.recoilRecovery)}
	end
	
	if self.features.recoilRecovery then
	self.recoil = self:lerp(self.recoil, 0, data.gunStats.recoilRecovery)	
	end

	if self.features.aim then
		local angle, dir = activeItem.aimAngleAndDirection(0, vec2.add(self.aimPos or activeItem.ownerAimPosition(), vec2.div(mcontroller.velocity(), 28)))
		aim.target = math.deg(angle) + self.recoil
		aim.direction = dir
	end

	
	self.cooldown = math.max(self.cooldown - updateInfo.dt, 0)
	if self.cooldown == 0 and self:dry() then
		self:load_chamber()
	end
	
	if main and main.update then
		main:update(dt, fireMode, shiftHeld, moves)
	end

end

function gun:rpm(rpm)
    return 60/rpm
end

function gun:inaccuracy()
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = data.gunStats.crouchInaccuracyMultiplier
	end
	local velocity = whichhigh(math.abs(mcontroller.xVelocity()), math.abs(mcontroller.yVelocity() + 1.28))
	local percent = math.min(velocity / 14, 1)
	return self:lerpr(data.gunStats.standingInaccuracy, data.gunStats.movingInaccuracy, percent) * crouchMult
end

function gun:rel()	
	return vec2.add(mcontroller.position(), activeItem.handPosition(pos))
end

function gun:fire(force)
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
				self:rel(animator.partPoint(self.muzzlePosition.part, self.muzzlePosition.tag)), 
				activeItem.ownerEntityId(), 
				self:calculateInAccuracy(self:angle()), 
				false,
				finalProjectileConfig
			)
		end

		--marks ammo as a fired bullet
		data.gunLoad.parameters.fired = true
		
		--used by action lever style
		if not self.bypassShellEject then
			self:eject_ammo()
			self.hasToLoad = true
		end
		
		--
		if magazine:count() == 0 then
			animation:play(self.animations["shoot_dry"] or self.animations.shoot)
		else
			animation:play(self.animations.shoot)
		end
		
		--emits FX muzzle flash sometimes changed by a silencer/flash hider
		if data.gunStats.muzzleFlash == 1 then
			animator.setAnimationState("firing", "on")
		end

		animator.playSound("fireSounds")
		self.cooldown = self:calculateRPM(data.gunStats.rpm or 600)
		self.recoil = self.recoil + data.gunStats.recoil
		self.recoilCamera = {math.sin(math.rad(self.recoil * 80)) * ((self.recoil / 8) ^ 1.25), self.recoil / 8}

		activeItem.setInstanceValue("gunLoad", data.gunLoad)
	else --else plays a dry sound
		animator.playSound("dry")
		self.cooldown = self:calculateRPM(data.gunStats.rpm or 600)
	end
end

function gun:aimAt(pos)
	if not pos then self.aimPos = nil return end self.aimPos = pos
end

function gun:eject_chamber()
	if data.gunLoad then
		if not data.load.parameters.fired then
			player.giveItem(data.load)
		elseif data.gunLoad.parameters.casingProjectile and data.casingFX then
			world.spawnProjectile(
				data.gunLoad.parameters.casingProjectile, 
				data:casingPosition(), 
				activeItem.ownerEntityId(), 
				vec2.rotate({0,1}, math.rad(math.random(90) - 45)), 
				false,
				data.gunLoad.parameters.casingProjectileConfig or {speed = 10, timeToLive = 1}
			)
		end
		data.gunLoad = nil
		activeItem.setInstanceValue("gunLoad", data.gunLoad)
	end
end

function gun:load_chamber()
	if data.gunLoad then 
		self:eject_chamber()
	end
	data.gunLoad = magazine:take()
end

function gun:dry()
	return type(data.gunLoad) == "table"
end

function gun:addRecoil(custom)
	local a = custom
	if not custom then
		a = data.gunStats.recoil
	end
	self.recoil = self.recoil + a
end

function gun:switchFireModes(custom)
	if not data.fireTypes then data.fireTypes = {"semi"} end
	if self.fireMode > #data.fireTypes then
		self.fireMode = 1
	else
		self.fireMode = self.fireMode + 1
	end
end

function gun:ready()
	if self.cooldown == 0 and not animation:isAnyPlaying() then
		return true
	end
	return false
end


addClass("gun", 1)