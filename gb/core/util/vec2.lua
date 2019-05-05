local v2 = {}
v2.x = 0
v2.y = 0

function v2:__index(a)
	if a == 1 then 
		return self.x
	elseif a == 2 then 
		return self.y
	end
end

function v2:__newindex(a, b)
	if a == 1 then 
		self.x = b
	elseif a == 2 then 
		self.y = b
	end
	return self
end

function v2:__call(x, y) -- constructor
	local cloned = self:clone()

	if type(x) == "table" then
		if x.x then
			x = x.x
			y = x.y or x.x
		elseif #x > 2 then
			x = x[1]
			y = x[2] or x[1]
		end
	end

	cloned.x = x or 0
	cloned.y = y or 0

	setmetatable(cloned, getmetatable(self))
	return cloned
end

--basic operators

function v2:__unm()
	self.x = -self.x
	self.y = -self.y
	return self
end

function v2:__add(b)
	if type(b) == "number" then 
		self.x = self.x + b 
		self.y = self.y + b
	elseif type(b) == "table" and b.x and b.y then
		self.x = self.x + b.x
		self.y = self.y + b.y
	end
	return self
end

function v2:__sub(b)
	if type(b) == "number" then 
		self.x = self.x - b 
		self.y = self.y - b
	elseif type(b) == "table" and b.x and b.y then
		self.x = self.x - b.x
		self.y = self.y - b.y
	end
	return self
end

function v2:__mul(b)
	if type(b) == "number" then 
		self.x = self.x * b 
		self.y = self.y * b
	elseif type(b) == "table" and b.x and b.y then
		self.x = self.x * b.x
		self.y = self.y * b.y
	end
	return self
end

function v2:__div(b)
	if type(b) == "number" then 
		self.x = self.x / b 
		self.y = self.y / b
	elseif type(b) == "table" and b.x and b.y then
		self.x = self.x / b.x
		self.y = self.y / b.y
	end
	return self
end

function v2:__idiv(b)
	if type(b) == "number" then 
		self.x = self.x // b 
		self.y = self.y // b
	elseif type(b) == "table" and b.x and b.y then
		self.x = self.x // b.x
		self.y = self.y // b.y
	end
	return self
end

function v2:__mod(b)
	if type(b) == "number" then 
		self.x = self.x % b 
		self.y = self.y % b
	elseif type(b) == "table" and b.x and b.y then
		self.x = self.x % b.x
		self.y = self.y % b.y
	end
	return self
end

function v2:__pow(b)
	if type(b) == "number" then 
		self.x = self.x ^ b 
		self.y = self.y ^ b
	elseif type(b) == "table" and b.x and b.y then
		self.x = self.x ^ b.x
		self.y = self.y ^ b.y
	end
	return self
end

function v2:__tostring(b)
	return "["..self.x..","..self.y.."]"
end

function v2:__concat(b)
	return self:__tostring()..tostring(b)
end

--compare operator

function v2:__eq(b)
	if type(b) == "number" then 
		return self.x == b and self.y == b
	elseif type(b) == "table" and b.x and b.y then
		return self.x == b.x and self.y == b.y
	end
	return false
end

function v2:__lt(b)
	if type(b) == "number" then 
		return self.x < b and self.y < b
	elseif type(b) == "table" and b.x and b.y then
		return self.x < b.x and self.y < b.y
	end
	return false
end

function v2:__le(b)
	if type(b) == "number" then 
		return self.x <= b and self.y <= b
	elseif type(b) == "table" and b.x and b.y then
		return self.x <= b.x and self.y <= b.y
	end
	return false
end

function v2:toArray()
	return {x,y}
end

vec2 = Class:new(v2)