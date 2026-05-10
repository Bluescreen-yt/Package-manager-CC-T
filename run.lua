local PCKG_LOCK = "/etc/pckg/.pckg_lock"

if not fs.exists(PCKG_LOCK) then

fs.open(PCKG_LOCK, "w").close()

function Tokenize()
    local Base = table.concat(arg or {'',''}, " ")
    local Tokens = {}
    local CurrentToken = ""
    local InQuotes = false

    for i = 1, #Base do
        local CurrentCharacter = Base:sub(i, i)
        

    
    end



end

local pckg = require("main")
pckg.init_enums()
pckg.init_config()
pckg.debugLevel = pckg.debugLevels.debug
pckg.loadDB()

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

    help=function ()
        print("pckg - package manager for cc:tweaked")
        print("commands:")
        print("install <package> or pckg install <package>=<version> - installs a package")
        print("remove <package> - removes a package")
        print("update <package> or pckg update <package>=<version> - updates a package")
        print("list - lists installed packages")
        print("listAll - lists all available packages")
        print("sync - syncs the package database with online sources")
    end,
    list=function ()
        for _, pkg in ipairs(pckg.list()) do
            print(package.pkg, '-', package.v)
        end
    end,
    listAll=function ()
        local Packages = pckg.listAll()

        for _, package in pairs(Packages) do
            print(package.pkg, '-', package.v)
        end
    end,
    sync=pckg.sync,
}

local success, err = pcall(function () -- just in case

    local cmd = commands[arg[1] or "help"] or commands.help
    
    cmd(table.unpack(arg, 2))

end)

if not success then
    print("error: "..err)
    print("use 'pckg help' for a list of commands")
end

pckg.saveDB()

fs.delete(PCKG_LOCK)
else
    print("pckg is already running! wait for it to run, if thats an error delete the lock file at "..PCKG_LOCK.." report it to developers")
end

