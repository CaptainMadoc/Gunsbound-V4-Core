ui = {
	elements = {}
}



function ui:lateInit()
	for i,v in pairs(self.elements) do
		if self.elements[i].init then
			self.elements[i]:init()
		end
	end
end

function ui:update()
	local SetElements = {}
	for i,v in pairs(self.elements) do
		if self.elements[i].update then
			SetElements[i] = self.elements[i]:draw()
		end
	end
	activeItem.setScriptedAnimationParameter("elements", SetElements)
end

function ui:newElement(table)
	local newUUID = sb.makeUuid()..sb.makeUuid()
	self.elements[newUUID] = table
	return newUUID
end

addClass("ui")