include "itemInstance"
include "tableutil"

_nestedmodules = {}
function module(path)
	if _included[path] then
		return nil
	end
	if _nestedmodules[path] then
		return table.copy(_nestedmodules[path])
	end
	
	local m = nil
	if module then
		m = module
		module = nil
	end

	require(itemInstance:path(path))
	if module then
		_nestedmodules[path] = table.copy(module)
	end

	if m then
		module = m
	end
	return table.copy(_nestedmodules[path])
end