updateable = {}
updateable.list = {}
updateable.hasInited = false

function updateable:add(name)
	self.list[#self.list + 1] = name
end

function updateable:init()
	for i=1,#self.list do
		local name = self.list[i]
		if type(_ENV[name]) == "table" and _ENV[name].init then
			_ENV[name]:init()
		end
	end
	self.hasInited = true
end

function updateable:update(...)
	for i=1,#self.list do
		local name = self.list[i]
		if type(_ENV[name]) == "table" and _ENV[name].update then
			_ENV[name]:update(...)
		end
	end
end

function updateable:uninit()
	for i=1,#self.list do
		local name = self.list[i]
		if type(_ENV[name]) == "table" and _ENV[name].uninit then
			_ENV[name]:uninit()
		end
	end
end

function updateable:activate(...)
	for i=1,#self.list do
		local name = self.list[i]
		if type(_ENV[name]) == "table" and _ENV[name].activate then
			_ENV[name]:activate(...)
		end
	end
end

local oldinit = init or function() end
local oldupdate = update or function() end
local olduninit = uninit or function() end
local oldactivate = activate or function() end

function init(...)
	oldinit(...)
	if not updateable.hasInited then
		updateable:init(...)
	end
end

function update(...)
	oldupdate(...)
	updateable:update(...)
end

function uninit(...)
	olduninit(...)
	updateable:uninit(...)
end

function activate(...)
	oldactivate(...)
	updateable:activate()
end