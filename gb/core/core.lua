require "/gb/core/itemInstance.lua"

_nestedmodules = {}
function module(path)
	if _nestedmodules[path] then
		return _nestedmodules[path]
	end
	local m = nil
	if module then
		m = module
		module = nil
	end
	require(itemInstance:path(path))
	if module then
		_nestedmodules[path] = module
	end
	if m then
		module = m
	end
	return _nestedmodules[path]
end

function init()
	itemInstance:init()
end

update_lastInfo = {}
update_info = {}
function update(...)
	update_lastInfo = update_info
	update_info = {...}
end

function activate(...)

end

function uninit()
	itemInstance:uninit()
end