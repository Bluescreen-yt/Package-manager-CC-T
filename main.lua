-------------------------------------------------------------------------------------------------------------
-- simple PaCKaGe manager v0.3 made by cardboard os dev team 
--
-- join our discord for news and updates + guides and welcoming community: dsc.gg/cardboardos
--
-------------------------------------------------------------------------------------------------------------



local pckgManager = {} -- definition of pckgmanager

function pckgManager.header() -- header
    pckgManager.print(pckgManager.printLevel.message, "====================================================================================" ) -- separator
    pckgManager.print(pckgManager.printLevel.message, "pckg v"..pckgManager.version ) -- version of pckg
    pckgManager.print(pckgManager.printLevel.message, "made by cardboard os dev team" ) -- dev team info
    pckgManager.print(pckgManager.printLevel.message, "thank you for using pckg! have a nice day ;p" )
    pckgManager.print(pckgManager.printLevel.message, "https://github.com/Bluescreen-yt/Package-manager-CC-T" ) -- link to github
    pckgManager.print(pckgManager.printLevel.message, "feel free to modify / help us out with code" ) 
    pckgManager.print(pckgManager.printLevel.message, "any help / feedback / idea is appreciated!" )
    pckgManager.print(pckgManager.printLevel.message, "join our discord for news and updates + guides and welcoming community: dsc.gg/cardboardos" ) -- discord info
    pckgManager.print(pckgManager.printLevel.message, "====================================================================================" )
end 

function pckgManager.setup() -- setup function ( setup whole project automatically ) with creating sources file

    pckgManager.init_enums() -- initalize default enums
    pckgManager.init_config() -- initialize default config 

    if not fs.exists("/bin/pckg/plugins/") then -- check for /etc/pckg folder
        pckgManager.print(pckgManager.printLevel.message, "creating /bin/pckg/plugins/ folder" )
        fs.makeDir("/bin/pckg/plugins/") -- create it if not found
    end

    if fs.exists(pckgManager.sourcesFile) then -- check for file with list of sources
        pckgManager.print(pckgManager.printLevel.success, "sources file found. no need for setup." ) -- inform user

        pckgManager.loadDB()
        return true -- return  true since source file already exists 
    end

    local defaultSources = {} -- create minimal / basic sources file
    table.insert(defaultSources, "https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/main/core.json") -- pckg
    table.insert(defaultSources, "https://raw.githubusercontent.com/Bluescreen-yt/CardBoard-OS-CCT/refs/heads/main/core.json") -- cbos

    local file = table.concat( defaultSources, "\n") -- file content

    local sourcesFile = fs.open(pckgManager.sourcesFile, 'w') -- open sourcesFile
    sourcesFile.write(file) -- write to file
    sourcesFile.close() -- close it
    
    pckgManager.loadDB()
    return true -- return true

    -- to do: add exception handling ( just in case ) -bs
end

function pckgManager.init_enums() -- initialize enums
    pckgManager.debugLevels = { debug=0, successes=1, warnings=2, errors=3, none=4 } -- enum for debugging level (debugLevel)
    pckgManager.printLevel = { message=0, success=1, warning=2, error=3} -- print level for pckgManager.print function

    pckgManager.version = 0.3 -- pckg version
    pckgManager.name = "pckg" -- pckg name
    
end

function pckgManager.run( pckg, ... ) -- run pckg with args
    -- to do: add function to run packages with arguments -bs
end



function pckgManager.init_config() -- initial default config

    pckgManager.usePineStore = true -- use pinestore? if enabled: searches pinestore for packages


    -- Database
    pckgManager.dbPath    = "/etc/pckg/db.json" -- path to db (the db file contains all packages that are listed in sourcesFile, AND DOES NOT INCLUDE PINESTORE projects )
    pckgManager.dbContent = {} -- the content of db (the one with every package)
    pckgManager.sourcesFile = "/etc/pckg/sources.txt" -- path to sources file ( the file that will be used to update db ) contains links to core.json files (raw) 
    -- to do: add more ( user friendly ) ways to save links like github link to repo -bs

    -- Install paths
    pckgManager.installPaths = { -- this table contains paths to `different` types of packages like applications or services
        application="/bin/", -- application
        service="/services/", -- service
        test="/tests/", -- startup test
        library="/libs/" -- library
    }

    -- installed packages db
    pckgManager.installeddb = {} -- db containing ALL installed packages on pc
    pckgManager.installeddbPath = "/etc/pckg/installed.json" -- path to db with installed packages ( just so package manager doesnt need to scan FOR ALL packages in ALL directories on pc just to run / require it or just do any operation) (/etc/pckg/installed.json by default)

    -- aliases
    pckgManager.aliasPath = "/etc/pckg/alias.json" -- path to file with aliases (/etc/pckg/alias.json by default)
    pckgManager.aliases = {} --all loaded aliases

    -- dev stuff
    pckgManager.debugLevel = pckgManager.debugLevels.debug -- debug level (debug by default)

end

function pckgManager.fullinit() -- full init (minimal config without checking for sources file)
    pckgManager.init_enums()
    pckgManager.init_config()
    pckgManager.loadDB()
    pckgManager.loadCustomTypes()
    pckgManager.PMNG.loadPlugins()
end


local function prettyPrint(level, text, di) -- pretty print msgs
    local levelData = { -- info about levels of prints
        [0]={ icon="*", color="8" }, -- icon color (debug)
        [2]={ icon="?", color="1" }, -- warning
        [1]={ icon="V", color="d" }, -- success
        [3]={ icon="!", color="e" }, -- error
    }

    di = di or { currentline = "" }
    

    text = text .. di.currentline
    local Pre = " "..levelData[level].icon.." " -- prefix to message [>> ! <<< ERROR MESSAGE ]
    local PreColor = string.rep(levelData[level].color, #Pre) -- the color of prefix
    local msg = " " .. text .. " " -- message at end [ ! >>> ERROR <<<]
    local fullMsg = Pre .. msg -- full msg [ !  ERROR ]

    term.blit( -- print the message
        fullMsg,  -- message
        string.rep("0", #fullMsg), -- foreground ( full white )
        PreColor .. string.rep("7", #msg) -- background ( prefix color + gray )
    )

    print() -- new line
end

function pckgManager.getPackagesCount() -- get tottal count of packages FOUND ( pinestore NOT included )
    local count = 0
    for _, _ in pairs(pckgManager.dbContent) do -- for every package
        count = count + 1
    end
    return count
end

function pckgManager.info() -- get info about pckg
    return pckgManager.version, pckgManager.name, pckgManager.getPackagesCount()
end


function pckgManager.print( level, text, di) -- print
    if level>=pckgManager.debugLevel then -- check if level of message is lower or equal to debug level
        prettyPrint(level, text, di)
    end
end


function pckgManager.loadDB() -- load all db (installedDb, ContentDb, Aliases)
    parallel.waitForAll( -- load everything at same time for speed idk
        pckgManager.loadInstalled,
        pckgManager.loadContent,
        pckgManager.loadAliases
    )
end


function pckgManager.install(package, version) -- install package
    pckgManager.print(pckgManager.printLevel.message, "pckgManager.install( '"..( package or "nil" ) .."', '".. ( version or "nil" ) .."' ) - start" )
    if not package then -- if no package specified
        pckgManager.print(pckgManager.printLevel.error, "No package specified", debug.getinfo(1, "Sl"))
        return 1, "no package specified"
    else
        pckgManager.print(pckgManager.printLevel.message, "package: "..package)
    end
    
    -- to do: add check for version -bs
    if not version then -- if no version specified then set it to latest
        pckgManager.print(pckgManager.printLevel.warning, "No version specified, installing latest" )
        version="latest"
    else
        pckgManager.print(pckgManager.printLevel.message, "version: "..version )
    end

    if pckgManager.installeddb[package] then -- if package is already installed
        pckgManager.print(pckgManager.printLevel.warning, "package "..package.." is already installed")
        return 0, "package already installed"
    end

    -- to do: add pinestore check -bs
    local pckgDB = pckgManager.dbContent[package] -- get package from database
    if not pckgDB then
        pckgManager.print(pckgManager.printLevel.error, "package "..package.." not found", debug.getinfo(1, "Sl") )
        return 2, "package not found"
    else
        pckgManager.print(pckgManager.printLevel.success, "package found" )
    end

    if version == "latest" then
        pckgManager.print(pckgManager.printLevel.message, "getting latest version" )
        version = pckgDB.latest -- set package version to latest found

        if not version then -- if version is nil... then error 
            pckgManager.print(pckgManager.printLevel.error, "could not get latest version", debug.getinfo(1, "Sl") )
            return 3, "could not get latest version"
        end
    end

    pckgManager.print(pckgManager.printLevel.message, "getting version: "..version )
    local pckg_data = pckgDB[version] -- url info package info from selected version
    if not pckg_data then
        pckgManager.print(pckgManager.printLevel.error, "could not get "..version.." version of the package "..package, debug.getinfo(1, "Sl") )
        return 4, "failed to retrive version data"
    end

    pckgManager.print(pckgManager.printLevel.message, "retriving package data from url: "..pckg_data )
    local pckgFileRequest = http.get(pckg_data) -- get package info [pkg.json]
    local pckgFileContent = pckgFileRequest.readAll()
    pckgFileRequest.close()

    local pckgFileData = textutils.unserializeJSON(pckgFileContent)


    if not pckgFileData then
        pckgManager.print(pckgManager.printLevel.error, "failed to retrive package data from url: "..pckg_data, debug.getinfo(1, "Sl"))
        return 7, "failed to retrive package data"
    end


    local fileLocation = pckgManager.installPaths[pckgFileData.pckg_type]

    if not fileLocation then
        pckgManager.print(pckgManager.printLevel.error, "invalid package type: "..pckgFileData.pckg_type, debug.getinfo(1, "Sl"))
        return 6, "invalid package type"
    end

    fileLocation = fileLocation .. package .. "/" -- add package name to file location

    pckgManager.installeddb[package] = { -- add pckg to list of installed packages
        version = version,
        install_path = fileLocation,
        CustomTypes = pckgFileData.CustomTypes
    }

    local files = {}
    local funcs={} -- funcs to run

    for file, url in pairs(pckgFileData.files) do
        -- make separate process for getting files cuz SPEED ( i think idk )

        pckgManager.print(pckgManager.printLevel.message, "inserting download func for: "..file.." into funcs")

        table.insert(funcs, function() -- add func to funcs table
            
            pckgManager.print(pckgManager.printLevel.message, "retriving file: "..file.." from url: "..url )
            local fileRequest = http.get(url)

            if not fileRequest then
                pckgManager.print(pckgManager.printLevel.error, "failed to retrive file: "..file.." from url: "..url, debug.getinfo(1, "Sl") )
                return 5, "failed to retrive file"
            end

            local fileContent = fileRequest.readAll()
            fileRequest.close()


            -- file path logic
            -- @ - /PCKG-TYPE/packagename/ ( for example: @main.lua will be saved to /bin/packagename/main.lua if package type is application )
            -- # - /config/packagename/ ( for example: #main.lua will be saved to /config/packagename/main.lua )
            -- / - root

            local Paths = {
                ["@"]=fileLocation,
                ["#"]="/config/"..package.."/"
            }

            local filePath = (Paths[string.sub(file, 1, 1)] or Paths["@"]) .. string.sub(file, 2)

            files[filePath] = fileContent
            pckgManager.print(pckgManager.printLevel.success, "file: "..file.." retrived and saved to buffer" )
        end)
    end

    parallel.waitForAll(table.unpack(funcs)) -- run all funcs at same time

    files[fileLocation ..  "pkg.json"] = pckgFileContent -- add pkg.json

    for pckg, version in pairs(pckgFileData.requirements) do -- install all requirements
        pckgManager.install(pckg, version)
    end

    pckgManager.aliases[package] = {}

    funcs={function ()
        for alias, file in pairs(pckgFileData.aliases) do
        pckgManager.aliases[package][alias] = fileLocation .. file
        pckgManager.print(pckgManager.printLevel.success, "added "..alias.." to aliases" )
        end
    end}

    for file, content in pairs(files) do
        pckgManager.print(pckgManager.printLevel.message, "inserting save func for: "..file.." into funcs")

        table.insert(funcs, function() -- add func to funcs table

            pckgManager.print(pckgManager.printLevel.message, "saving file: "..file )
            local fileHandle = fs.open(file, 'w')
            fileHandle.write(content)
            fileHandle.close()
            pckgManager.print(pckgManager.printLevel.success, "file: "..file.." saved" )
        end)
    end

    parallel.waitForAll(table.unpack(funcs)) -- run all funcs at same time




    if pckgFileData.autorun_file then
        local autorunPath = fileLocation .. pckgFileData.autorun_file

        pckgManager.print(pckgManager.printLevel.message, "autorun file: "..autorunPath )
        local success, result = pcall(
        
            function()
                local file = fs.open(autorunPath, 'r')
                local autorunCode = file.readAll()
                file.close()
                local autorunCodeAsFunc = load(autorunCode)
                if not autorunCodeAsFunc then
                    pckgManager.print(pckgManager.printLevel.error, "failed to load autorun file: "..autorunPath, debug.getinfo(1, "Sl"))
                    return false, false
                end
                return autorunCodeAsFunc()
            end
        
        )

        if not (success and result) then
            pckgManager.print(pckgManager.printLevel.error, "file no found, or error with requiring it ( autorunCodeAsFunc is nil / false )", debug.getinfo(1, "Sl"))
            pckgManager.remove(package) -- remove package cuz failed to install ( just in case )

            return 8, "failed to require autorun file"
            
        end

        if (not success) and success ~= nil then
            pckgManager.print(pckgManager.printLevel.error, "failed to require autorun file", debug.getinfo(1, "Sl"))

            pckgManager.print(pckgManager.printLevel.error, "Error: "..tostring(result), debug.getinfo(1, "Sl"))

            pckgManager.remove(package) -- remove package cuz failed to install ( just in case )

            return 8, "failed to require autorun file"
        end

        if type(result)=="table" and result[pckgFileData.autorun_function] then
            pckgManager.print(pckgManager.printLevel.message, "running autorun function..." )
            
            local success, result = pcall(result[pckgFileData.autorun_function])
            if not success then
                pckgManager.print(pckgManager.printLevel.error, "failed to run autorun function", debug.getinfo(1, "Sl"))
                pckgManager.print(pckgManager.printLevel.error, "Error: "..tostring(result))

                pckgManager.remove(package) -- remove package cuz failed to install ( just in case )

                return 9, "failed to run autorun function"
            end
            pckgManager.print(pckgManager.printLevel.success, "autorun function executed" )
        else
            pckgManager.print(pckgManager.printLevel.warning, "autorun function not found" )
        end
    end

    
    -- local aliases = {}
    -- pckgManager.print(pckgManager.printLevel.success, "initialized pckgManager.aliases."..package )
    -- for alias, file in pairs(pckgFileData.aliases) do
    --     aliases[alias] = fileLocation .. file
    --     pckgManager.print(pckgManager.printLevel.success, "aliased: pckgManager.aliases."..package.."."..alias.." = "..fileLocation .. file )
    -- end

    -- pckgManager.aliases[package] = aliases

    pckgManager.print(pckgManager.printLevel.message, "pckgManager.install - end" )
end

function pckgManager.loadInstalled()
    local installedDbFile = fs.open(pckgManager.installeddbPath, 'r')
    if not installedDbFile then
        pckgManager.print(pckgManager.printLevel.warning, "no installed db file found" )
        return
    end

    pckgManager.installeddb = textutils.unserializeJSON(installedDbFile.readAll())
    installedDbFile.close()
end

function pckgManager.saveInstalled()
    local installeddbFile = fs.open(pckgManager.installeddbPath, 'w')
    installeddbFile.write(textutils.serializeJSON(pckgManager.installeddb))
    installeddbFile.close()
end

function pckgManager.remove(package) -- remove packages
    fs.delete(pckgManager.installeddb[package].install_path) -- delete package files
    pckgManager.installeddb[package] = nil -- remove from installed db

    
    print(pckgManager.aliases)
    print(pckgManager.aliases[package])
    for alias, _ in pairs(pckgManager.aliases[package]) do -- remove aliases
        shell.clearAlias(alias)
    end

    pckgManager.aliases[package] = nil
    pckgManager.saveAliases()
    pckgManager.saveInstalled()

    
end

function pckgManager.saveAliases() -- remove packages
    local aliasFile = fs.open(pckgManager.aliasPath, 'w')
    aliasFile.write(textutils.serializeJSON(pckgManager.aliases))
    aliasFile.close()
end


function pckgManager.list() -- list all installed packages
    local packages = {}
    
    for package, _ in pairs(pckgManager.installeddb) do
        table.insert(packages, {
            pkg=package,
            version=_.version
        })
    end

    return packages
    
end


function pckgManager.search(package) -- search for package in db
    
    
end

function pckgManager.loadContent()
    pckgManager.print(pckgManager.printLevel.message, "pckgManager.init() - start" )

    pckgManager.print(pckgManager.printLevel.message, "loading db file" )
    if fs.exists(pckgManager.dbPath) then -- if db exists load it
        pckgManager.print(pckgManager.printLevel.success, "db file found." )
    
        local DB_FILE = fs.open(pckgManager.dbPath, 'r') -- open db file

        pckgManager.dbContent = textutils.unserializeJSON(DB_FILE.readAll()) -- load db content
        DB_FILE.close() -- close file

        pckgManager.print(pckgManager.printLevel.success, "done loading db!")
    else -- if no db file found
        pckgManager.print(pckgManager.printLevel.warning, "no db file found" )
    end

end


function pckgManager.saveContent()
    local dbFile = fs.open(pckgManager.dbPath, 'w')
    dbFile.write(textutils.serializeJSON(pckgManager.dbContent))
    dbFile.close()
end


function pckgManager.sync() -- sync db from sources
    local sourcesFile = fs.open(pckgManager.sourcesFile, 'r')

    local sourcesData = {}

    while true do
        local line = sourcesFile.readLine()
        if not line then break end

        local SourceContent = http.get(line)
        if not SourceContent then
            pckgManager.print(pckgManager.printLevel.error, "failed to retrive source: "..line, debug.getinfo(1, "Sl"))
            return 9, "failed to retrive source"
        end

        local sourceData = textutils.unserializeJSON(SourceContent.readAll())
        SourceContent.close()

        table.insert(sourcesData, sourceData)
    end

    sourcesFile.close()

    for _, sourceData in pairs(sourcesData) do
        for pckg, data in pairs(sourceData) do
            local Data = {}
            
            for version, _URL in pairs(data) do -- merge version togheter to make big mass of versions avalible
                if version == "latest" then
                    if (not Data.latest) or tonumber(_URL) > tonumber(Data.latest) then
                        Data.latest = _URL
                    end
                else
                    Data[version] = _URL
                end
            end

            pckgManager.dbContent[pckg] = Data
            
        end
    end



    pckgManager.saveContent()

end

function pckgManager.loadAliases()
    for package, aliases in pairs(pckgManager.aliases) do
        for alias, file in pairs(aliases) do
            if shell then                
                shell.setAlias(alias, file)
                pckgManager.print(pckgManager.printLevel.success, "set alias: "..alias.." = "..file )
            else
                pckgManager.print(pckgManager.printLevel.warning, "shell not found, are you running with custom globals / env?" )
            end
        end
    end
end

function pckgManager.listAll()
    local packages = {}
    
    for pckg, _ in pairs(pckgManager.dbContent) do

        table.insert(packages, { pkg=pckg, version=_.version })
    end

    return packages
end

function pckgManager.saveDB()
    pckgManager.saveAliases()
    pckgManager.saveInstalled()
    pckgManager.saveContent()
end



-- custom types
function pckgManager.loadCustomTypes()
    pckgManager.installPaths = pckgManager.installPaths or {}
    for package, data in pairs(pckgManager.installeddb) do
        if data.CustomTypes then
            for type, path in pairs(data.CustomTypes) do
                pckgManager.installPaths[type] = path
            end
        end
    end
    
end











-- plugin stuff
pckgManager.PMNG = {}
pckgManager.PMNG.plugins = {} -- list of all loaded plugins
pckgManager.PMNG.pluginGlobals = {} -- to do: add plugin globals ( like pckgManager.PMNG.pluginGlobals.print = pckgManager.print ) -bs

function pckgManager.PMNG.Run(func, ...)
    local func = func or ""
    local args = {...}
    
    local funs = {}
    for _, plugin in pairs(pckgManager.PMNG.plugins) do
        if plugin[func] then
            table.insert(funs, function()
                return plugin[func](table.unpack(args)) -- waits for plugin and returns the value
            end)
        end
    end

    local results = parallel.waitForAll(table.unpack(funs)) -- run all plugins at same time and wait for them to finish

    for i, result in pairs(results) do

        pckgManager.print(pckgManager.printLevel.warning, "plugin "..i.." returned, function "..result.."func" )

    end

    return results
end

function pckgManager.PMNG.loadPlugin(path, plugin)
        local pluginPath = path .. "/" .. plugin .. "/main.lua"

        if not fs.exists(pluginPath) then
            return
        end

        local _pluginFile = fs.open(pluginPath, 'r')
        local pluginSource = _pluginFile.readAll()
        _pluginFile.close()

        pckgManager.PMNG.fromCode(pluginSource, plugin)

end

function pckgManager.PMNG.fromCode(code, codeName)

        local _PluginGlobals = setmetatable({}, { __index = _G })
        _PluginGlobals.pckgPrint = function( level, txt )
            pckgManager.print(level, "[ PLUGIN: "..plugin.." ] "..txt)
        end

        local _PluginPckgMng = setmetatable({}, { __index = pckgManager })

        _PluginGlobals.pckg = _PluginPckgMng

        local plugin = load(code, codeName, "t", _PluginGlobals)()
        
        table.insert(pckgManager.PMNG.plugins, plugin)
end

function pckgManager.PMNG.loadPlugins(pathOverride)
    path = pathOverride or "/bin/pckg/plugins"
    if not fs.exists(path) then pckgManager.print(pckgManager.printLevel.warning, "no plugins path found" ) return end

    local plugins = fs.list(path)
    if #plugins == 0 then pckgManager.print(pckgManager.printLevel.message, "no plugins found" ) return end

    pckgManager.print(pckgManager.printLevel.message, path.." plugins found. loading.." )
    local FUNCS = {}
    for _, plugin in pairs(plugins) do
        local func = function ()
            pckgManager.PMNG.loadPlugin(path, plugin)
        end

        table.insert(FUNCS, func)
    end

    parallel.waitForAll(table.unpack(FUNCS)) -- load all plugins at same time

    pckgManager.PMNG.Run("init")
end



-- pinestore support
pckgManager.PSI = {} -- Pine Store Support
pckgManager.PSI.API_URL = "https://pinestore.cc/api"


function pckgManager.PSI.getAllProjects()
    local r = http.get(pckgManager.PSI.API_URL.."/projects")
    local res = textutils.unserializeJSON(r.readAll())
    r.close()
    return res
end


-- RAW support




-- GITHUB / GITLAB support






-- for working with packages / library

function pckgManager.RequirePackage(pckg)
    if not pckg then return nil end

    if not pckgManager.installeddb[pckg] then
        pckgManager.print(pckgManager.printLevel.error, "package "..pckg.." is not installed" )
        return nil
    else
        pckgManager.print(pckgManager.printLevel.success, "package "..pckg.." is installed" )
        return require(pckgManager.installeddb[pckg].install_path, pckgManager.installeddb[pckg].version)
    end


    return pckgManager
end

return pckgManager