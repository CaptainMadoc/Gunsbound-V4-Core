_included = {}
function include(util)
	require("/gb/core/api/"..util..".lua")
	_included["/gb/core/api/"..util..".lua"] = true
end

function init()
	include "configInstance" --needed to load certain configs
	configInstance:init()
	require(configInstance.gunScript or "/gb/systems/default.lua")
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
	configInstance:uninit()
end