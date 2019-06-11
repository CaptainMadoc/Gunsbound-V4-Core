include "directory"

ammoGroup = {}

--returns compatibleAmmo types
function ammoGroup:types()
	local compat = config.getParameter("compatibleAmmo", jarray())

	if type(compat) == "string" then
		compat = root.assetJson(directory(compat))
	end
	--error
	if not compat or #compat == 0 then
		compat = {"gbtestammo"}
	end

	return compat
end

--return true if player has compatible ammo
function ammoGroup:available()
	for i,v in pairs(self:types()) do
		local finditem = {name = v, count = 1}
		if type(v) == "table" then 
			finditem = v
		end
		if player.hasItem(finditem, true) then
			return true
		end
	end
	return false
end

--returns a array of ammos with item data
function ammoGroup:get(amount)
	local gotten = {}
	if not amount then 
		amount = 1
	end

	for i,v in pairs(self:types()) do
		if amount > 0 then

			local finditem = {name = v, count = 1}
			if type(v) == "table" then
				finditem = v
				finditem.count = 1
			end
			--player has ammo
			if player.hasItem(finditem) then
				finditem.count = amount

				--take the found item
				local con = player.consumeItem(finditem, true, true)
				if con then
					table.insert(gotten, con)
					--decrease the amount found
					amount = amount - con.count
				end

			end
		else
			break
		end
	end

	return gotten
end