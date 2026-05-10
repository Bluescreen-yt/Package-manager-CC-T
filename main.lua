-------------------------------------------------------------------------------------------------------------
-- simple PaCKaGe manager v0.3 made by cardboard os dev team 
--
-- join our discord for news and updates + guides and welcoming community: dsc.gg/cardboardos
--
-------------------------------------------------------------------------------------------------------------
-- #### ####      ###  ####
-- #### ## #      ## # ## # # 
--  ##  ## #      ## # ## #  
--  ##  ####      ###  #### #
--           ( to do: )
--
--
--
--
--
--
--
--
-------------------------------------------------------------------------------------------------------------

local pckgManager = {}

function pckgManager.header()
    pckgManager.print(pckgManager.printLevel.message, "====================================================================================" )
    pckgManager.print(pckgManager.printLevel.message, "pckg v"..pckgManager.version )
    pckgManager.print(pckgManager.printLevel.message, "made by cardboard os dev team" )
    pckgManager.print(pckgManager.printLevel.message, "thank you for using pckg! have a nice day ;p" )
    pckgManager.print(pckgManager.printLevel.message, "https://github.com/Bluescreen-yt/Package-manager-CC-T" )
    pckgManager.print(pckgManager.printLevel.message, "feel free to modify / help us out with code" )
    pckgManager.print(pckgManager.printLevel.message, "any help / feedback / idea is appreciated!" )
    pckgManager.print(pckgManager.printLevel.message, "join our discord for news and updates + guides and welcoming community: dsc.gg/cardboardos" )
    pckgManager.print(pckgManager.printLevel.message, "====================================================================================" )
end

function pckgManager.setup()

    pckgManager.init_enums()
    pckgManager.init_config()

    if fs.exists(pckgManager.sourcesFile) then
        pckgManager.print(pckgManager.printLevel.success, "sources file found. no need for setup." )
        return true
    end

    local defaultSources = {}
    table.insert(defaultSources, "https://raw.githubusercontent.com/Bluescreen-yt/bluesPackages/refs/heads/main/core.json")

    local file = ""
    for _, source in ipairs(defaultSources) do
        file = file .. source .. "\n"
    end

    local sourcesFile = fs.open(pckgManager.sourcesFile, 'w')
    sourcesFile.write(file)
    sourcesFile.close()
    return true
end

function pckgManager.init_enums()
    pckgManager.debugLevels = { debug=0, successes=1, warnings=2, errors=3, none=4 } -- enum for debugging level (debugLevel)
    pckgManager.printLevel = { message=0, success=1, warning=2, error=3} -- print level for pckgManager.print function

    pckgManager.version = 0.3
    pckgManager.name = "pckg"
    
end


function pckgManager.init_config() -- initial default config

    -- Database
    pckgManager.dbPath    = "/etc/pckg/db.json" -- path to db
    pckgManager.dbContent = {} -- content in db
    pckgManager.sourcesFile = "/etc/pckg/sources.txt" -- path to sources file

    -- Install paths
    pckgManager.installPaths = {
        application="/bin/", -- application
        service="/services/", -- service
        test="/tests/", -- startup test
        library="/libs/" -- library
    }

    -- installed packages db
    pckgManager.installeddb = {}
    pckgManager.installeddbPath = "/etc/pckg/installed.json"

    -- aliases
    pckgManager.aliasPath = "/etc/pckg/alias.json" -- path to file with aliases
    pckgManager.aliases = {} --all loaded aliases

    -- dev stuff
    pckgManager.debugLevel = pckgManager.debugLevels.debug -- debug level

end

function pckgManager.fullinit()
    pckgManager.init_enums()
    pckgManager.init_config()
    pckgManager.loadDB()
end


local function prettyPrint(level, text ) -- pretty print msgs
    local levelData = {
        [0]={ icon="*", color="8" },
        [2]={ icon="?", color="1" },
        [1]={ icon="V", color="d" },
        [3]={ icon="!", color="e" },
    }

    local Pre = " "..levelData[level].icon.." "
    local PreColor = string.rep(levelData[level].color, #Pre)
    local msg = " " .. text .. " "
    local fullMsg = Pre .. msg

    term.blit( -- print
        fullMsg,  -- message
        string.rep("0", #fullMsg), -- foreground ( full white )
        PreColor .. string.rep("7", #msg) -- background ( msg color + gray )
    )

    print() -- new line
end

function pckgManager.getPackagesCount()
    local count = 0
    for _, _ in pairs(pckgManager.dbContent) do
        count = count + 1
    end
    return count
end

function pckgManager.info()
    return pckgManager.version, pckgManager.name, pckgManager.getPackagesCount()
end


function pckgManager.print(level, text ) -- print
    if level>=pckgManager.debugLevel then -- check if level of message is lower or eq to debug level
        prettyPrint(level, text)
    end
end


function pckgManager.loadDB() -- init (load db etc etc)
    parallel.waitForAll( -- load everything at same time for speed
        pckgManager.loadInstalled,
        pckgManager.loadContent,
        pckgManager.loadAliases
    )


end


function pckgManager.install(package, version) -- install package
    pckgManager.print(pckgManager.printLevel.message, "pckgManager.install( '"..( package or "nil" ) .."', '".. ( version or "nil" ) .."' ) - start" )
    if not package then -- if no package specified
        pckgManager.print(pckgManager.printLevel.error, "No package specified" )
        return 1, "no package specified"
    else
        pckgManager.print(pckgManager.printLevel.message, "package: "..package)
    end
    if not version then -- if no version specified then set it to latest
        pckgManager.print(pckgManager.printLevel.warning, "No version specified, installing latest" )
        version="latest"
    else
        pckgManager.print(pckgManager.printLevel.message, "version: "..version )
    end

    local pckgDB = pckgManager.dbContent[package] -- get package from database
    if not pckgDB then
        pckgManager.print(pckgManager.printLevel.error, "package "..package.." not found" )
        return 2, "package not found"
    else
        pckgManager.print(pckgManager.printLevel.success, "package found" )
    end

    if version == "latest" then
        pckgManager.print(pckgManager.printLevel.message, "getting latest version" )
        version = pckgDB.latest

        if not version then
            pckgManager.print(pckgManager.printLevel.error, "could not get latest version" )
            return 3, "could not get latest version"
        end
    end

    pckgManager.print(pckgManager.printLevel.message, "getting version: "..version )
    local pckg_data = pckgDB[version]
    if not pckg_data then
        pckgManager.print(pckgManager.printLevel.error, "could not get "..version.." version of the package "..package )
        return 4, "failed to retrive version data"
    end

    pckgManager.print(pckgManager.printLevel.message, "retriving package data from url: "..pckg_data )
    local pckgFileRequest = http.get(pckg_data)
    local pckgFileContent = pckgFileRequest.readAll()
    pckgFileRequest.close()

    local pckgFileData = textutils.unserializeJSON(pckgFileContent)


    if not pckgFileData then
        pckgManager.print(pckgManager.printLevel.error, "failed to retrive package data from url: "..pckg_data )
        return 7, "failed to retrive package data"
    end


    local fileLocation = pckgManager.installPaths[pckgFileData.pckg_type]

    if not fileLocation then
        pckgManager.print(pckgManager.printLevel.error, "invalid package type: "..pckgFileData.pckg_type )
        return 6, "invalid package type"
    end

    fileLocation = fileLocation .. package .. "/" -- add package name to file location

    pckgManager.installeddb[package] = { -- add pckg to list of installed packages
        version = version,
        install_path = fileLocation
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
                pckgManager.print(pckgManager.printLevel.error, "failed to retrive file: "..file.." from url: "..url )
                return 5, "failed to retrive file"
            end

            local fileContent = fileRequest.readAll()
            fileRequest.close()

            local filePath = fileLocation .. file

            files[filePath] = fileContent
            pckgManager.print(pckgManager.printLevel.success, "file: "..file.." retrived and saved to buffer" )
        end)
    end

    parallel.waitForAll(table.unpack(funcs)) -- run all funcs at same time

    files[fileLocation ..  "pkg.json"] = pckgFileContent -- add pkg.json

    for pckg, version in pairs(pckgFileData.requirements) do -- install all requirements
        pckgManager.install(pckg, version)
    end

    funcs={}

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

    for alias, file in pairs(pckgFileData.aliases) do
        pckgManager.aliases[alias] = fileLocation .. file
        pckgManager.print(pckgManager.printLevel.success, "added "..alias.." to aliases" )
    end


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
                    pckgManager.print(pckgManager.printLevel.error, "failed to load autorun file: "..autorunPath )
                    return false, false
                end
                return autorunCodeAsFunc()
            end
        
        )

        if not (success and result) then
            pckgManager.print(pckgManager.printLevel.error, "file no found, or error with requiring it ( autorunCodeAsFunc is nil / false )")
            pckgManager.remove(package) -- remove package cuz failed to install ( just in case )

            return 8, "failed to require autorun file"
            
        end

        if (not success) and success ~= nil then
            pckgManager.print(pckgManager.printLevel.error, "failed to require autorun file" )

            pckgManager.print(pckgManager.printLevel.error, "Error: "..tostring(result))

            pckgManager.remove(package) -- remove package cuz failed to install ( just in case )

            return 8, "failed to require autorun file"
        end

        if type(result)=="table" and result[pckgFileData.autorun_function] then
            pckgManager.print(pckgManager.printLevel.message, "running autorun function..." )
            
            local success, result = pcall(result[pckgFileData.autorun_function])
            if not success then
                pckgManager.print(pckgManager.printLevel.error, "failed to run autorun function" )
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
        table.insert(packages, package)
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
            pckgManager.print(pckgManager.printLevel.error, "failed to retrive source: "..line )
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
            
            for _VERSION, _URL in pairs(data) do -- merge version togheter to make big mass of versions avalible
                if _VERSION == "latest" then
                    if (not Data.latest) or tonumber(_URL) > tonumber(Data.latest) then
                        Data.latest = _URL
                    end
                else
                    Data[_VERSION] = _URL
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
        table.insert(packages, pckg)
    end

    return packages
end

--- test
local function _test()
    pckgManager.init_enums()
    pckgManager.init_config()
    pckgManager.dbContent = { -- minimal db with pckg
        ["pckg"]={
            latest="X",
            X="https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/main/pkg.json"

        }
    }
    pckgManager.header()
    pckgManager.install("pckg", "X")
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

function pckgManager.saveDB()
    pckgManager.saveAliases()
    pckgManager.saveInstalled()
    pckgManager.saveContent()
end




return pckgManager
