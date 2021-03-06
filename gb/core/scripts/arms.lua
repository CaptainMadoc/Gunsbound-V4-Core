include "config"
include "animator"
include "transforms"
include "portrait"
include "vec2"
include "tableutil"
include "updateable"

-- OLD 2018 code --

local transformationsgroups = {}

local function eqmat(a,b)
	if #a ~= #b then return false end
	for i=1,#a do
		if a[i] ~= b[i] then
			return false 
		end
	end
	return true
end

local function setTransformations(name, mat)
	if not transformationsgroups[name] or not eqmat(transformationsgroups[name], mat) then
		if animator.hasTransformationGroup(name) then
			animator.resetTransformationGroup(name) 
			animator.scaleTransformationGroup(name, {mat[1], mat[2]}, {mat[3], mat[4]})
			animator.rotateTransformationGroup(name, math.rad(mat[5]), {mat[6], mat[7]})
			animator.translateTransformationGroup(name,{mat[8], mat[9]})
		end
		transformationsgroups[name] = mat
	end
end

local function lerp(a,b,r)
	return a + (b - a) * r
end

local function whatlayer(dir, arm)
	if arm == "alt" then dir = -dir end

	if dir > 0 then
		return "front"
	else
		return "back"
	end
end

local function calculateTransform(tab) -- legacy code
	local new = {
		scale = tab.scale or vec2(vec2(0)),
		scalePoint = tab.scalePoint or vec2(vec2(0)),
		position = (tab.position or vec2(vec2(0))) * (tab.scale or vec2(vec2(0))),
		rotation = tab.rotation or 0,
		rotationPoint = lerp(tab.scalePoint, tab.rotationPoint, tab.scale)
	}
	return new
end

arms = {
	curdirection = 2,
	inited = false,
	twohand_current = false,
	twohand_target = false,
	cropA1 = "?crop=0;0;24;43",
	cropA2 = "?crop=23;0;27;43",
	cropA3 = "?crop=26;0;43;43",
	fullbright = true
}

local function speciesFullbright(specie)
	if not specie then return false end
	local speciesConfig = root.assetJson("/species/"..specie..".species")
	if speciesConfig and speciesConfig.humanoidOverrides and speciesConfig.humanoidOverrides.bodyFullbright then
		return speciesConfig.humanoidOverrides.bodyFullbright
	end
	return false
end

function arms:init()
	activeItem.setFrontArmFrame("rotation?scale=0")
	activeItem.setBackArmFrame("rotation?scale=0")
	self:resetArm("R")
	self:resetArm("L")
	self.twohand_current = config.twoHanded
	self.twohand_target = self.twohand_current
	self.twohand = self.twohand_current
	
	self.specie = world.entitySpecies(activeItem.ownerEntityId())
	if not self.specie then	return end -- some how it errors due probably the player is still beaming in
	
	--get portraits parts 
	local port = portrait:new(activeItem.ownerEntityId())

	--get skin directives
	self.directives = port:skinDirectives()
	
	local armSize = vec2(43) / vec2(8)
	local ratioSize = vec2(1)

	if port:parts().FrontArm then
		local image = port:image("FrontArm")
		local size = vec2(root.imageSize(image..":rotation"))
		if size[1] < 43 then
			ratioSize = size / 43
			armSize = size / (vec2(8) * ratioSize)
			self.cropA1 = "?crop=0;0;"..math.floor(24 * ratioSize[1])..";"..math.floor(43 * ratioSize[2])
			self.cropA2 = "?crop="..math.floor(23 * ratioSize[1])..";0;"..math.floor(27 * ratioSize[1])..";"..math.floor(43 * ratioSize[2])
			self.cropA3 = "?crop="..math.floor(26 * ratioSize[1])..";0;"..math.floor(43 * ratioSize[1])..";"..math.floor(43 * ratioSize[2])
		end
	end

	if port:parts().FrontArmArmor then 
		self.directory = port:image("FrontArmArmor")
		self.armordirectives = port:directives("FrontArmArmor")
	end
	
	if port:parts().BackArmArmor then
		self.Bdirectory = port:image("BackArmArmor")
		self.Barmordirectives = port:directives("BackArmArmor")
	end
	
	--humanoid config for offsets
	local humanoidConfig = root.assetJson("/humanoid.config")

	--if we have found the species config then we could use his humanoid config
	local speciesConfig = root.assetJson("/species/"..self.specie..".species")

	if speciesConfig and speciesConfig.humanoidConfig then
		if type(speciesConfig.humanoidConfig) == "string" then
			humanoidConfig = root.assetJson(speciesConfig.humanoidConfig)
		else
			humanoidConfig = speciesConfig.humanoidConfig
		end
	end


	local armCenter = armSize / (vec2(-2) / ratioSize)
	
	--bunch of calculation offset from the humanoid
	local frontArmRotationCenter = vec2(humanoidConfig.frontArmRotationCenter) / vec2(8)
	local frontArmHandPosition = vec2(humanoidConfig.frontHandPosition) / vec2(-8)
	
	local backArmHandPosition = vec2(humanoidConfig.backArmOffset) / vec2(8)
	local backArmRotationCenter = vec2(humanoidConfig.backArmRotationCenter) / vec2(8)
	

	local transformsArm = {
		R_hand = {position = vec2(26 * 0.125, 0)},
		R_arm1 = {},
		R_arm2 = {position = vec2(23 * 0.125, 0)}
	}
	
	--current item animation config
	local animations = config:getAnimation()
	local animationTranformationGroup = animations.transformationGroups or {} 
	--

	--fold this if its long
	local createTransform = function ()

		transforms:addCustom("R_arm1", table.vmerge({rotation = 0}, (animationTranformationGroup.R_arm1 or {}).transform or {} ),
			function(thisTransform) 
				name = "R_arm1"
				local setting = {
					position = frontArmHandPosition,
					rotationPoint = ((frontArmRotationCenter - armCenter) + frontArmHandPosition),
					rotation = thisTransform.rotation or 0,
					scale = vec2(1),
					scalePoint = vec2(0),
				}

				local rotationPointComp = setting.rotationPoint - setting.position
				setTransformations(name, 
					{
						setting.scale[1], setting.scale[2], setting.scalePoint[1], setting.scalePoint[2],
						setting.rotation, rotationPointComp[1], rotationPointComp[2],
						setting.position[1], setting.position[2]
					}
				)
			end
		)

		transforms:addCustom("R_arm2", table.vmerge({rotation = 0}, (animationTranformationGroup.R_arm2 or {}).transform or {}),
			function(thisTransform)
				local name = "R_arm2"
				local setting  = calculateTransform({
					position = vec2(23 * 0.125,0),
					rotationPoint = vec2(0,17 * 0.125 + 0.0625),

					rotation = thisTransform.rotation or 0,

					scale = vec2(1),
					scalePoint = vec2(0),
				})

				setTransformations(name, 
					{
						setting.scale[1], setting.scale[2], setting.scalePoint[1], setting.scalePoint[2],
						setting.rotation, setting.rotationPoint[1], setting.rotationPoint[2],
						setting.position[1], setting.position[2]
					}
				)
			end
		)

		transforms:addCustom("R_hand", table.vmerge({rotation = 0}, (animationTranformationGroup.R_hand or {}).transform or {}),
			function(thisTransform)
				local name = "R_hand"
				local setting  = calculateTransform({
					position = vec2(0.375,0),
					rotationPoint = vec2(0.125,18 * 0.125),

					rotation = thisTransform.rotation or 0,

					scale = vec2(1),
					scalePoint = vec2(0),
				})

				setTransformations(name, 
					{
						setting.scale[1], setting.scale[2], setting.scalePoint[1], setting.scalePoint[2],
						setting.rotation, setting.rotationPoint[1], setting.rotationPoint[2],
						setting.position[1], setting.position[2]
					}
				)
			end
		)

		transforms:addCustom("L_arm1", table.vmerge({rotation = 0}, (animationTranformationGroup.L_arm1 or {}).transform or {}),
			function(thisTransform)
				local name = "L_arm1"
				local setting  = {
					position = frontArmHandPosition,
					rotationPoint = (frontArmRotationCenter - armCenter) + frontArmHandPosition,

					rotation = thisTransform.rotation or 0,

					scale = vec2(1),
					scalePoint = vec2(0),
				}

				local rotationPointComp = setting.rotationPoint - setting.position
				setTransformations(name, 
					{
						setting.scale[1], setting.scale[2], setting.scalePoint[1], setting.scalePoint[2],
						setting.rotation, rotationPointComp[1], rotationPointComp[2],
						setting.position[1], setting.position[2]
					}
				)
			end
		)

		transforms:addCustom("L_arm2", table.vmerge({rotation = 0}, (animationTranformationGroup.L_arm2 or {}).transform or {}),
			function(thisTransform)
				local name = "L_arm2"
				local setting  = calculateTransform({
					position = vec2(23 * 0.125,0),
					rotationPoint = vec2(0,17 * 0.125 + 0.0625),

					rotation = thisTransform.rotation or 0,

					scale = vec2(1),
					scalePoint = vec2(0),
				})

				setTransformations(name, 
					{
						setting.scale[1], setting.scale[2], setting.scalePoint[1], setting.scalePoint[2],
						setting.rotation, setting.rotationPoint[1], setting.rotationPoint[2],
						setting.position[1], setting.position[2]
					}
				)
			end
		)

		transforms:addCustom("L_hand", table.vmerge({rotation = 0}, (animationTranformationGroup.L_hand or {}).transform or {}),
			function(thisTransform)
				local name = "L_hand"
				local setting  = calculateTransform({
					position = vec2(0.375,0),
					rotationPoint = vec2(0.125,18 * 0.125),

					rotation = thisTransform.rotation or 0,

					scale = vec2(1,1),
					scalePoint = vec2(0,0),
				})

				setTransformations(name, 
					{
						setting.scale[1], setting.scale[2], setting.scalePoint[1], setting.scalePoint[2],
						setting.rotation, setting.rotationPoint[1], setting.rotationPoint[2],
						setting.position[1], setting.position[2]
					}
				)
			end
		)

		transforms:addCustom("L_offset", table.vmerge({position = vec2(0)}, (animationTranformationGroup.L_offset or {}).transform or {}),
			function(tt) 
				local name = "L_offset"
				setTransformations(name, 
					{
						1, 1, 0, 0,
						0, 0, 0,
						tt.position[1], tt.position[2]
					}
				)
			end
		)

		transforms:addCustom("R_offset", table.vmerge({position = vec2(0)}, (animationTranformationGroup.R_offset or {}).transform or {}),
			function(tt) 
				local name = "R_offset"
				setTransformations(name, 
					{
						1, 1, 0, 0,
						0, 0, 0,
						tt.position[1], tt.position[2]
					}
				)
			end
		)

		transforms:addCustom("globalArms", table.vmerge({position = armCenter, rotation = 0, rotationPoint = vec2(0)}, (animationTranformationGroup.global or {}).transform or {}),
			function(thisTransform)
				local name = "globalArms"
				local setting  = calculateTransform({
					position = thisTransform.position or vec2(0),
					scale = thisTransform.scale or vec2(1),
					scalePoint = thisTransform.scalePoint or vec2(0),
					rotation = thisTransform.rotation or 0,
					rotationPoint = thisTransform.rotationPoint or vec2(0)
				})
				
				setTransformations(name, 
					{
						setting.scale[1], setting.scale[2], setting.scalePoint[1], setting.scalePoint[2],
						setting.rotation, setting.rotationPoint[1], setting.rotationPoint[2],
						setting.position[1], setting.position[2]
					}
				)
			end
		)
	end

	self.fullbright = speciesFullbright(self.specie)

	createTransform()
	self.inited = true
end

function arms:update(dt)
	if not self.inited then --failed getting humanoid config retrying
		self:init()
		return
	end
	
	if self.twohand_current ~= self.twohand_target then
		self:setTwoHandedGrip(self.twohand_target)
		self.twohand_current = self.twohand_target
	end
	
	local aim, direction = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())

	--knows to auto switch layers using animation zlevels
	if self.curdirection ~= direction then

		self.curdirection = direction

		local handhold = activeItem.hand()

		if self.hide then
			self:setFullArm("L", false, self.fullbright) -- it will hide it
			self:setFullArm("R", false, self.fullbright)
		elseif not self.twohand then --non two hand here
			animator.setAnimationState("left", whatlayer(direction, handhold))
			animator.setAnimationState("right", whatlayer(-direction, handhold))
			self:setFullArm("L", false, self.fullbright) -- it will hide it
			self:setFullArm("R", true, self.fullbright)
		else
			animator.setAnimationState("left", "back")
			animator.setAnimationState("right", "front")
			self:setFullArm("L", true, self.fullbright)
			self:setFullArm("R", true, self.fullbright)
		end
	end
end

--util
function arms:setArmorArm(side, img, crop)
	if crop then
		animator.setGlobalTag(side.."_af1", img..self.cropA1)
		animator.setGlobalTag(side.."_af2", img..self.cropA2)
		animator.setGlobalTag(side.."_handf", img..self.cropA3)
	else
		animator.setGlobalTag(side.."_af1", img)
		animator.setGlobalTag(side.."_af2", img)
		animator.setGlobalTag(side.."_handf", img)
	end
end

--API--

function arms:setTwoHandedGrip(bool)
	self.twohand = bool
	self.curdirection = -self.curdirection
	activeItem.setTwoHandedGrip(bool)
end

function arms:resetArm(side)
	animator.setGlobalTag(side.."_a1", "")
	animator.setGlobalTag(side.."_a2", "")
	animator.setGlobalTag(side.."_hand", "")
	animator.setGlobalTag(side.."_a1_FB", "")
	animator.setGlobalTag(side.."_a2_FB", "")
	animator.setGlobalTag(side.."_hand_FB", "")
end

function arms:setArm(side, img, crop, fullbright)
	local suffix = ""
	if fullbright then
		suffix = "_FB"
	end
	if crop then
		animator.setGlobalTag(side.."_a1"..suffix, img..self.cropA1)
		animator.setGlobalTag(side.."_a2"..suffix, img..self.cropA2)
		animator.setGlobalTag(side.."_hand"..suffix, img..self.cropA3)
	else
		animator.setGlobalTag(side.."_a1"..suffix, img)
		animator.setGlobalTag(side.."_a2"..suffix, img)
		animator.setGlobalTag(side.."_hand"..suffix, img)
	end
end

-- side = "back", show = true
function arms:setFullArm(side, show, fullbright)
	if show then
		self:setArm(side, "/humanoid/"..self.specie.."/frontarm.png:rotation"..self.directives, true, fullbright)
		if self.directory and self.armordirectives then
			self:setArmorArm(side, self.directory..":rotation"..self.armordirectives, true)
		else
			self:setArmorArm(side, "", false)
		end
	else
		self:setArm(side, "", false, fullbright)
		self:setArmorArm(side, "", false)
	end
end

updateable:add("arms")