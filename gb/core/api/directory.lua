include "configInstance"

function directory(path, default)
    if path:sub(1,1) == "/" then return path end
    if not default then default = configInstance.directory or "/" end
    return default..path
end