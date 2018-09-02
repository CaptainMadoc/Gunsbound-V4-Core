uimanager = {}

function uimanager:init()
end

function uimanager:lateinit()
	local uiShell =  config.getParameter("uiShell")
	if uiShell then
		activeItem.setScriptedAnimationParameter("uiShell", vDir(uiShell, selfItem.rootDirectory))
		
	end
end

function uimanager:update(dt)
	
	activeItem.setScriptedAnimationParameter("load", type(data.gunLoad))
	
	
	--to fix
	local t = false
	
	if data.gunLoad and data.gunLoad.parameters.fired then
		t = true
		activeItem.setScriptedAnimationParameter("fired", true)
	end
	
	if not t then
		activeItem.setScriptedAnimationParameter("fired", false)
	end
	
	activeItem.setScriptedAnimationParameter("fireSelect",  data.fireTypes[gun.fireMode])
	activeItem.setScriptedAnimationParameter("inAccuracy",  gun:inaccuracy())
	activeItem.setScriptedAnimationParameter("althanded",  activeItem.hand() == "alt")
	activeItem.setScriptedAnimationParameter("muzzleDistance",  world.distance(activeItem.ownerAimPosition(),gun:rel(animator.partPoint("gun", "muzzle_begin"))))

end

function uimanager:uninit()
end

addClass("uimanager", 620)