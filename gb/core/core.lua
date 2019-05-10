_included = {}
function include(util)
	require("/gb/core/api/"..util..".lua")
	_included["/gb/core/api/"..util..".lua"] = true
end

_nestedmodules = {}
function module(path)
	if _included[path] then
		return nil
	end
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
	include "itemInstance" --needed to load certain configs
	itemInstance:init()
	require(itemInstance.gunScript or "/gb/systems/default.lua")
	if gun and gun.init then
		gun:init()
	end
end

update_lastInfo = {}
update_info = {}
update_lateInited = false
function update(...)
	update_lastInfo = update_info
	update_info = {...}
	if not update_lateInited and gun and gun.lateInit then
		update_lateInited = true
		gun:lateInit(...)
	end
	if gun and gun.update then
		gun:update(...)
	end
end

function activate(...)
	if gun and gun.activate then
		gun:activate(...)
	end
end

function uninit()
	if gun and gun.uninit then
		gun:uninit()
	end
	itemInstance:uninit()
end