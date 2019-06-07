include "configInstance"
include "vec2"
include "vec2util"
include "rays"
include "mcontroller"
include "activeItem"
include "transforms"
include "animations"
include "attachmentSystem"
include "aim"
include "magazine"

--this is the default system for any gun

--THING TODO:
--[[

- Firing implementation
- Ammo management
- Adaptable Animation
- Animation Manager
- Attachments System

]]

gun = {}

function gun:init()
	aim:init()
	animations:init()
	transforms:init()
end

function gun:update(dt, fireMode, shift, moves)
	aim:update(dt)
	animations:update(dt)
	transforms:apply(animations:transforms({"reload","cock","draw","shoot"}))
	transforms:update(dt)
	aim:at(activeItem.ownerAimPosition())
end

function gun:activate(fireMode, shift)
	if fireMode == "primary" then
		animations:play("shoot")
	elseif fireMode == "alt" then
		animations:play("reload")
	end
end

function gun:uninit()

	transforms:uninit()
end