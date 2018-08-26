data = {} -- needed
datamanager = {
    savelist = {

    }
}

function datamanager:load(name, autosave)
    data[name] = config.getParameter(name)
    if autosave then
        table.insert(self.savelist, name)
    end
end

function datamanager:save(name)
    if data[name] then
        activeItem.setInstanceValue(name, data[name])
    end
end

function datamanager:uninit()
    for i,v in pairs(self.savelist) do
        self:save(v)
    end
end

addClass("weapon", 367)