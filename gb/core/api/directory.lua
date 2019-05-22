local _itemDirectory = false

function itemDirectory(name)
    if _itemDirectory then return _itemDirectory end
	local itemConfig = root.itemConfig({name = name or item.name(), count = 1})
	_itemDirectory = itemConfig.directory or "/"
end

function directory(path, default)
    if path:sub(1,1) == "/" then return path end
    if not default then default = itemDirectory() end
    return default..path
end