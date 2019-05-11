include "itemInstance"
include "vec2"
include "vec2util"
include "rays"
include "mcontroller"
include "activeItem"
include "animations"
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

end

function gun:update(dt, fireMode, shift, moves)
    sb.setLogMap("gb", "%s", sb.printJson(mcontroller.position()), "green")
    sb.setLogMap("gbray", "%s", rays.collide(
        mcontroller.position(), 
        vec2util.angle(activeItem.ownerAimPosition() - mcontroller.position()),
        100
    ), "green")
    world.debugLine(
        mcontroller.position(), 
        rays.collide(
            mcontroller.position(), 
            vec2util.angle(activeItem.ownerAimPosition() - mcontroller.position()),
            100
        ),
        "green" 
    )
end

function gun:activate(fireMode, shift)

end

function gun:uninit()

end