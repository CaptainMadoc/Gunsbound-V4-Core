include "itemInstance"

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