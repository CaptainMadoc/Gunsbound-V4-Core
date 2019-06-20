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
include "magazine"
include "attachmentSystem"

--this is the default system for any gun

--THING TODO:
--[[

- Attachments System

]]

gun = {}

function gun:init()
	animations:init()
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

	aim:at(activeItem.ownerAimPosition())
end

function gun:activate(fireMode, shift)
	if fireMode == "primary" and magazine:count() > 0 then
		local ammo = magazine:use()
		muzzle:fire(ammo)
		animations:play("shoot")
	elseif fireMode == "alt" then
		magazine:reload()
		animations:play("reload")
	end
end

function gun:uninit()

	magazine:uninit()
	transforms:uninit()
end