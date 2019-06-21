include "config"
include "vec2"
include "vec2tableparser"

stats = {}
stats._values = {}
stats.inited = false

function stats:init()
    self:reset()
    self.inited = true
end

function stats:reset()
    self._values = vec2tableparser(config.stats) or {}
end

function stats:add(a)
    if not self.inited then self:init() end
    for i,v in pairs(a) do
        if self._values[i] and type(self._values[i]) == type(v) then
            self._values[i] = self._values[i] + v
        end
    end
end

function stats:get(i)
    if not self.inited then self:init() end
    return self._values[i]
end