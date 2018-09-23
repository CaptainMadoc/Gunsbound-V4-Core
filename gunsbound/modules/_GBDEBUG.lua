--this is a thing for a ui to test our current apis so, do not use this

_GBDEBUG = {
    enabled = false,
    nodes = {
        test = function() end
    },
    point = {}, --{}
    lines = {}, --{a = BeginPos, b = EndPos}
    texts = {}, --{text = "str", position = {}}
}

function _GBDEBUG:newtest()

end

function _GBDEBUG:init()
    message.setHandler("gbdebug", function(_, loc, ...)end)
end

addClass("_GBDEBUG")