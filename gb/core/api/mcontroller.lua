include "vec2"

local mcontrollerWrapped = mcontroller
mcontroller = {}

function mcontroller.position()
    return vec2(mcontrollerWrapped.position())
end