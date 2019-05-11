_included = {}
function include(util)
	require("/gb/core/api/"..util..".lua")
	_included["/gb/core/api/"..util..".lua"] = true
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