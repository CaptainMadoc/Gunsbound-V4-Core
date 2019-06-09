include "directory"

local _config = config
local _parameters = {}
config = {}

local inited = false
local function init()
	if item then
		_parameters = item.descriptor()
	else
		_parameters = _config.getParameter("", {})
	end
end

local function save(i)
	if activeItem then
		if not i then
			
			for i,v in pairs(_parameters) do
				activeItem.setInstanceValue(i, v)
			end
		end
	end
end

function config:getAnimation()
	if not inited then inited = true init() end

	local animation = self["animation"]
	if type(animation) == "string" then
		animation = root.assetJson(directory(animation), {})
	end
	
	local animationCustom = self["animationCustom"]
	return sb.jsonMerge(animation or {}, animationCustom or {})
end

setmetatable(config,
	{
		__newindex = function(t, key, value)
			if not inited then inited = true init() end
			_parameters[key] = value
			--saving here
		end,
		__index = function(t, key)
			if not inited then inited = true init() end
			return _parameters[key] or _config.getParameter(key)
		end
	}
)