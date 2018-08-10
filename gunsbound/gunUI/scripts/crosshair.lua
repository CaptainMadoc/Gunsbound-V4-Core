module = {
	inAccuracy = 0,
	muzzleDistance = {0,0}
}

function circle(d,steps)
	local pos = {d,0}
	local pol = {}
	for i=1,steps do
		table.insert(pol,pos)
		pos = vec2.rotate(pos, math.rad(360 / steps))
	end
	return pol
end


function module:refreshData()
    self.inAccuracy = animationConfig.animationParameter("inAccuracy")
    self.muzzleDistance = animationConfig.animationParameter("muzzleDistance")
end

function module:init()
    self:refreshData()
end

function module:update(dt)
	self:refreshData()

	local distance = (math.abs(self["muzzleDistance"][2]) + math.abs(self["muzzleDistance"][1])) / 2
	local cir = circle((0.125 + (self["inAccuracy"] / 45) * distance) ,16)

	for i=2,#cir do
		localAnimator.addDrawable({line = {cir[i - 1], cir[i]},width = 1, color = {255,255,255,72},fullbright = true, position = activeItemAnimation.ownerAimPosition()}, "overlay")
	end
	localAnimator.addDrawable({line = {cir[1], cir[#cir]},width = 1, color = {255,255,255,72},fullbright = true, position = activeItemAnimation.ownerAimPosition()}, "overlay")
end

function module:uninit()

end