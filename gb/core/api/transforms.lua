include "vec2"

transforms = {}
transforms.current = {}
transforms.default = {}

function transforms:init()

end

function transforms:update(dt)

end

function transforms:uninit()

end

function transforms:blend(transform)
    for i,v in pairs(transform) do
        self.current[i] = v
    end
end

function transforms:apply(transform)
    for i,v in pairs(transform) do
        self.current[i] = v
    end
end

function transform:reset()
    for i,v in pairs(self.current) do
        
    end
end