--requires ui.lua

gun_ui = {
	elementID = ""
}

function gun_ui:createElement_FireMode()
	local element = {}

	function element:init()

	end

	function element:draw()
		
	end

	return element
end

function gun_ui:init()
	self.elementID = ui:newElement(self:createElement_FireMode())
end


addClass("gun_ui")