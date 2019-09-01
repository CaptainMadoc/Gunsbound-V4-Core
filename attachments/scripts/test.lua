include "directory"
include "vec2"
include "animator"

module = {}
module.storage = {}
module.config = {}
module.transform = {}
module.directory = "/"
module.partName = ""
module.anchorPart = ""
module.name = {}

function module:init()
    sb.logInfo("TEST ATTACHMENT WORKING")
    animator.setPartTag(self.partName, "partImage", directory(self.config.image, self.directory) or "/assetmissing.png")
    self:updateTransform()
end

function module:update(dt)
    self:updateTransform()
end

function module:updateTransform()
    animator.resetTransformationGroup(self.transform)

    --reverse scale applied from parent aka "gun"
    local r = (animator.transformPoint({1,0},self.partName) - animator.transformPoint({0,0},self.partName)):angle()
    local a = animator.transformPoint({0,0},self.partName)
    local b = animator.transformPoint({1,1},self.partName)
    local cs = vec2(1,1) / ((b - a):rotate(-r - math.rad(-90)))
    animator.scaleTransformationGroup(self.transform, cs)
    --

    animator.scaleTransformationGroup(self.transform, self.config.scale or 1)
    animator.translateTransformationGroup(self.transform, self.config.offset or vec2(0,0))
end

function module:uninit()

end