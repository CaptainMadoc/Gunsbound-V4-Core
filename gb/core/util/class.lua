local function cc(t)
	local cloned = {}
	for i,v in pairs(t) do
		if type(v) == "table" then
			cloned[i] = cc(v)
		else
			cloned[i] = v
		end
	end
	setmetatable(cloned, getmetatable(self))
	return cloned
end

local ClassMetatable = {}

function ClassMetatable:__add(...)
	if not self.__add then return end
	return self:__add(...)
end
function ClassMetatable:__sub(...)
	if not self.__sub then return end
	return self:__sub(...)
end
function ClassMetatable:__mul(...)
	if not self.__mul then return end
	return self:__mul(...)
end
function ClassMetatable:__div(...)
	if not self.__div then return end
	return self:__div(...)
end
function ClassMetatable:__mod(...)
	if not self.__mod then return end
	return self:__mod(...)
end
function ClassMetatable:__unm(...)
	if not self.__unm then return end
	return self:__unm(...)
end
function ClassMetatable:__concat(...)
	if not self.__concat then return end
	return self:__concat(...)
end
function ClassMetatable:__eq(...)
	if not self.__eq then return end
	return self:__eq(...) 
end
function ClassMetatable:__lt(...)
	if not self.__lt then return end
	return self:__lt(...)
end
function ClassMetatable:__le(...)
	if not self.__le then return end
	return self:__le(...)
end
function ClassMetatable:__tostring(...)
	if not self.__tostring then return end
	return self:__tostring(...)
end
function ClassMetatable:__call(...)
	if not self.__call then return end
	return self:__call(...)
end
function ClassMetatable:__index(...)
	if not self.__index then return end
	return self:__index(...)
end
function ClassMetatable:__newindex(...)
	if not self.__newindex then return end
	return self:__newindex(...)
end

Class = {}

function Class:new(tab)
	local newClass = cc(self)
	local inheritClass = cc(tab)
	for i,v in pairs(inheritClass) do
		newClass[i] = v
	end
	setmetatable(newClass, ClassMetatable)
	return newClass
end

function Class:clone()
	return cc(self)
end