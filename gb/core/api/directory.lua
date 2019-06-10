include "config"
include "itemConfig"

function directory(path, default)
	if path:sub(1,1) == "/" then return path end
	if not default then default = config.directory or itemDirectory(item.name()) or "/" end
	return default..path
end