local pckg = require("main")
pckg.fullinit()
pckg.debugLevel = pckg.debugLevels.debug

local commands
commands = {
    update=function (pkg)
        pckg.remove(pkg)
        pckg.install(pkg)
    end,
    createStartupFile=function ()
        if fs.exists("/startup.lua") then
            print("startup.lua already exists! are you sure you want to overite it? (y/n)")
            local response = os.pullEvent("key")
            if not keys.getName(response[2]) == "y" then
                print("if you want to load aliases, run 'pckg loadAliases'")
                return
            end
            
        end

        local startupFile = fs.open("/startup.lua", "w")
        startupFile.write('shell.run("/bin/pckg/run.lua", "loadAliases")')
        startupFile.close()
        print("done! pckg will now load aliases on startup! :p")
    end,
    install=pckg.install,
    remove=pckg.remove,
    loadAliases=function ()
        -- for command, _ in pairs(commands) do
        --     shell.setAlias("pckg "..command, "/bin/pckg/run.lua "..command)
        -- end
    pckg.loadAliases()
    end,

    help=nil,
    list=function ()
        for _, pkg in ipairs(pckg.list()) do
            print(pkg)
        end
    end,
    listAll=function ()
        local Packages = pckg.listAll()

        for _, package in pairs(Packages) do
            print(package)
        end
    end,
    sync=pckg.sync,
}

if not arg[1] then
    commands.help()
end

commands[arg[1]](table.unpack(arg, 2))
