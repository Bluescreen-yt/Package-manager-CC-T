local pckg = require("main")
pckg.fullinit()
pckg.debugLevel = pckg.debugLevels.none

local commands = {
    update=nil,
    install=nil,
    remove=nil,
    list=pckg.list,
    listAll=function ()
        local Packages = pckg.listAll()

        for _, package in pairs(Packages) do
            print(package)
        end
    end,
    sync=pckg.sync,
}

commands[args[1]](table.unpack(args, 2))