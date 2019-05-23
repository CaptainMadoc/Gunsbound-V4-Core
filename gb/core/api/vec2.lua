include "Class"

local v2 = {}
v2[1] = 0
v2[2] = 0

function v2:__index(a)
	if a == "x" then 
		return self[1]
	elseif a == "y" then 
		return self[2]
	end
end

function v2:__newindex(a, b)
	if a == 1 then 
		self[1] = b
	elseif a == 2 then 
		self[2] = b
	end
	return self
end

function v2:__call(x, y) -- constructor
	local cloned = Class:new(v2)

	if type(x) == "table" then
		if x[1] then
			cloned[1] = x[1]
			cloned[2] = x[2] or x[1]
		elseif #x >= 2 then
			cloned[1] = x[1]
			cloned[2] = x[2] or x[1]
		end
	elseif x and y then
		cloned = {x,y}
	end

	cloned[1] = cloned[1] or 0
	cloned[2] = cloned[2] or 0
	return cloned
end

--basic operators

function v2:__unm()
	return vec2(-self[1], -self[2])
end

function v2:__add(b)
	if type(b) == "number" then 
		return vec2(self[1] + b, self[2] + b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] + b[1], self[2] + b[2])
	end
end

function v2:__sub(b)
	if type(b) == "number" then 
		return vec2(self[1] - b, self[2] - b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] - b[1], self[2] - b[2])
	end
end

function v2:__mul(b)
	if type(b) == "number" then 
		return vec2(self[1] * b, self[2] * b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] * b[1], self[2] * b[2])
	end
end

function v2:__div(b)
	if type(b) == "number" then 
		return vec2(self[1] / b, self[2] / b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] / b[1], self[2] / b[2])
	end
end

function v2:__idiv(b)
	if type(b) == "number" then 
		return vec2(self[1] // b, self[2] // b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] // b[1], self[2] // b[2])
	end
end

function v2:__mod(b)
	if type(b) == "number" then 
		return vec2(self[1] % b, self[2] % b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] % b[1], self[2] % b[2])
	end
end

function v2:__pow(b)
	if type(b) == "number" then 
		return vec2(self[1] ^ b, self[2] ^ b)
	elseif type(b) == "table" and b[1] and b[2] then
		return vec2(self[1] ^ b[1], self[2] ^ b[2])
	end
end

function v2:__tostring(b)
	return "["..self[1]..","..self[2].."]"
end

function v2:__concat(b)
	return self:__tostring()..tostring(b)
end

--compare operator

function v2:__eq(b)
	if type(b) == "number" then 
		return self[1] == b and self[2] == b
	elseif type(b) == "table" and b[1] and b[2] then
		return self[1] == b[1] and self[2] == b[2]
	end
	return false
end

function v2:__lt(b)
	if type(b) == "number" then 
		return self[1] < b and self[2] < b
	elseif type(b) == "table" and b[1] and b[2] then
		return self[1] < b[1] and self[2] < b[2]
	end
	return false
end

function v2:__le(b)
	if type(b) == "number" then 
		return self[1] <= b and self[2] <= b
	elseif type(b) == "table" and b[1] and b[2] then
		return self[1] <= b[1] and self[2] <= b[2]
	end
	return false
end

function v2:__metatable(b)
	return nil
end

vec2 = Class:new(v2)