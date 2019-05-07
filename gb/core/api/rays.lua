include "vec2"
include "vec2util"

rays = {}

function rays.collide(from, angle, range) --bigger range can mean big lag
    return world.lineCollision( from, from + vec2util.rotate(vec2(1 * range,0), angle) ) 
        or from + vec2util.rotate(vec2(1 * range,0), 0)
end