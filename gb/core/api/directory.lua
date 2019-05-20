local _itemDirectory = false

function itemDirectory()
    if _itemDirectory then return _itemDirectory end
	local itemConfig = root.itemConfig({name = item.name(), count = 1})
	_itemDirectory = itemConfig.directory or "/"
end

function directory(path, default)
    if path:sub(1,1) == "/" then return path end
    if not default then default = itemDirectory() end
    return default..path
end