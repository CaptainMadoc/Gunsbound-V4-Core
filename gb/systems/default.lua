include "itemInstance"
include "vec2"
include "vec2util"
include "rays"
include "mcontroller"
include "activeItem"
include "animations"
include "transforms"
include "attachmentSystem"
include "ammoManager"

--this is the default system for any gun
--note only use gun for the callbacks

--THING TODO:
--[[

- Firing implementation
- Ammo management
- Adaptable Animation
- Animation Manager
- Transforms manager
- Attachments System

]]

gun = {}

function gun:init()
    transforms:init()
end

function gun:update(dt, fireMode, shift, moves)
    transforms:update()
end

function gun:activate(fireMode, shift)

end

function gun:uninit()

    transforms:uninit()
end