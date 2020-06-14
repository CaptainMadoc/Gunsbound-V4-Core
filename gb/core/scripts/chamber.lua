include "casingEmitter"

chamber = {}
chamber.list = {}
chamber.storage = {}

function chamber:init()
	local muzzleConfig = config.muzzle or {}
    local chamberConfig = config.chamber or {}
    
	for i,v in ipairs(muzzleConfig) do
        chamber.list[i] = v
        if chamberConfig[i] then
            self.storage[i] = ammo:new(chamberConfig[i])
        else
            self.storage[i] = false
        end
    end
    
end

function chamber:uninit()
    local json = {}
    for i, ammo in ipairs(chamber.list) do
        if self.storage[i] then
            json[i] = self.storage[i]:save()
        else
            json[i] = false
        end
    end
    config.chamber = json
end

function chamber:load(ammo)
    for i,v in ipairs(self.list) do
        if not self.storage[i] then
            self.storage[i] = ammo
            return true
        end
    end
    return false
end

function chamber:fillFromMagazine(magazine)
    for i,v in ipairs(self.list) do
        if not self.storage[i] then
            self.storage[i] = magazine:use()
        end
    end
end

function chamber:useat(at, callback)
	if self.storage[at] and self.storage[at].count > 0 then
		callback(at, self.storage[at])
	end
end

function chamber:use(callback)
    for i,v in ipairs(self.list) do
        self:useat(i, callback)
    end
end

function chamber:loads()
    local count = 0
    for i,v in ipairs(self.list) do
        if self.storage[i] then
            count = count + 1
        end
    end
    return count
end

function chamber:ready()
    local count = 0
    for i,v in ipairs(self.list) do
        if self.storage[i] and self.storage[i].count > 0 then
            count = count + 1
        end
    end
    return count
end

function chamber:eject(at)
	if self.storage[at] then
		casingEmitter:fire(self.storage[at])
		self.storage[at] = false
	end
end

function chamber:ejectAll()
    for i,v in ipairs(self.list) do
        self:eject(i)
    end
end

updateable:add("chamber")