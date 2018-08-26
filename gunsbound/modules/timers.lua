timers = {
    list = {

    }
}

function timers:check(name, def) --def for timer loop time
    if not self.list[name] and def then
        self.list[name] = def
        return false
    end
    if self.list[name] == 0 then
        if def then 
            self.list[name] = def
        end
        return true
    end
    return false
end

function timers:set(name, time)
    self.list[name] = time
end

function timers:init()

end

function timers:update(dt)
    for i,v in pairs(self.list) do
        self.list[i] = math.min(v - dt, 0)
    end
end

function timers:uninit()

end


addClass("timers", 632)