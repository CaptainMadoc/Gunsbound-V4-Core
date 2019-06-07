

--nil if the item does not exist anymore
function itemConfig(name, parameters)
	if not name then return end
	local c = root.itemConfig({name = name, count = 1})
	if c.config then
		return sb.jsonMerge(c.config, parameters or {})
	end
	return nil
end