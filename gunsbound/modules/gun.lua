--another prototype for gun design
gun = {
    firemode = 1

}
function gun:lerp(value, to, speed) return value + ((to - value ) / speed )  end
function gun:lerpr(value, to, ratio) return value + ((to - value ) * ratio ) end


function gun:init()
	message.setHandler("isLocal", function(_, loc) return loc end )
	activeItem.setScriptedAnimationParameter("entityID", activeItem.ownerEntityId())
	activeItem.setCursor("/gunsbound/crosshair/crosshair2.cursor")
    datamanager:load("load", true)
    datamanager:load("gunStats")
    datamanager:load("fireTypes")
    datamanager:load("casingFX")
    datamanager:load("bypassShellEject")
    datamanager:load("muzzlePosition")
    datamanager:load("casing")
    datamanager:load("gunAnimations")
    datamanager:load("compatibleAmmo")

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

function gun:rpm(rpm)
    return 60/rpm
end

function gun:inaccuracy()
	local crouchMult = 1
	if mcontroller.crouching() then
		crouchMult = data.stats.crouchInaccuracyMultiplier
	end
	local velocity = whichhigh(math.abs(mcontroller.xVelocity()), math.abs(mcontroller.yVelocity() + 1.28))
	local percent = math.min(velocity / 14, 1)
	return self:lerpr(data.stats.standingInaccuracy, data.stats.movingInaccuracy, percent) * crouchMult
end

function gun:rel()

end

function gun:fire() end

function gun:eject_chamber() end

function gun:reload_chamber() end

function gun:dry() end

function gun:addRecoil(custom) end

function gun:switchFireModes(custom) end

function gun:ready() end


addClass("gun", 1)