-- WHY IS THERE ODD HEADER AND FOOTER HERE???
local pckgManager = {}

function pckgManager.header()
    pckgManager.print(pckgManager.printLevel.message, "pckg v"..pckgManager.version )
    pckgManager.print(pckgManager.printLevel.message, "made by cardboard os dev team" )
    pckgManager.print(pckgManager.printLevel.message, "thank you for using pckg! have a nice day" )
    pckgManager.print(pckgManager.printLevel.message, "https://github.com/Bluescreen-yt/Package-manager-CC-T" )
end

function pckgManager.setup()
    print(" INIT !!!!!!!!!!!! AUTORUN WORKS!")
end

function pckgManager.init_enums()
    pckgManager.debugLevels = { debug=0, success=1,warnings=2, errors=3, none=4 } -- enum for debugging level (debugLevel)
    pckgManager.printLevel = { message=0, success=1, warning=2, error=3} -- print level for pckgManager.print function

    pckgManager.version = 0.3
    
end


function pckgManager.init_config() -- initial default config

    -- Database
    pckgManager.dbPath    = "/etc/pckg/db.json" -- path to db
    pckgManager.dbContent = {} -- content in db

    -- Install paths
    pckgManager.installPaths = {
        application="/bin/", -- application
        service="/services/", -- service
        test="/tests/", -- startup test
        library="/libs/" -- library
    }



    -- dev stuff
    pckgManager.debugLevel = pckgManager.debugLevels.debug -- debug level

end

function pckgManager.fullinit()
    pckgManager.init_enums()
    pckgManager.init_config()
    pckgManager.header()
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

function pckgManager.info()
    return pckgManager.version
end


function pckgManager.print(level, text ) -- print
    if level>=pckgManager.debugLevel then -- check if level of message is lower or eq to debug level
        prettyPrint(level, text)
    end
end


function pckgManager.init() -- init (load db etc etc)
    pckgManager.print(pckgManager.printLevel.message, "pckgManager.init() - start" )

    if fs.exists(pckgManager.dbPath) then -- if db exists load it
        pckgManager.print(pckgManager.printLevel.success, "db file found." )
    
        local DB_FILE = fs.open(pckgManager.dbPath, 'r') -- open db file

        pckgManager.dbContent = textutils.unserializeJSON(DB_FILE.readAll()) -- load db content
        DB_FILE.close() -- close file
    else -- if no db file found
        pckgManager.print(pckgManager.printLevel.warning, "no db file found" )
    end

    pckgManager.print(pckgManager.printLevel.message, "pckgManager.init - end" )
end


function pckgManager.install(package, version) -- install package
    pckgManager.print(pckgManager.printLevel.message, "pckgManager.install( '"..package .."', '".. version .."' ) - start" )
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

    local files = {}
    local funcs={} -- funcs to run

    for file, url in pairs(pckgFileData.files) do
        -- make separate process for getting files cuz SPEED ( i think idk )
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


    for file, content in pairs(files) do
        pckgManager.print(pckgManager.printLevel.message, "saving file: "..file )
        local fileHandle = fs.open(file, 'w')
        fileHandle.write(content)
        fileHandle.close()
        pckgManager.print(pckgManager.printLevel.success, "file: "..file.." saved" )
    end

    if pckgFileData.autorun_file then
        local autorunPath = fileLocation .. pckgFileData.autorun_file

        pckgManager.print(pckgManager.printLevel.message, "autorun file: "..autorunPath )
        local success, result = pcall(
        
            function()
                local file = fs.open(autorunPath, 'r')
                local autorunCode = file.readAll()
                file.close()
                local autorunFunc = load(autorunCode)
                return autorunFunc()
            end
        
        )
            
        if (not success) and success ~= nil then
            pckgManager.print(pckgManager.printLevel.error, "failed to require autorun file" )

            print("Error: "..tostring(result))

            return 8, "failed to require autorun file"
        end

        if result[pckgFileData.autorun_function] then
            pckgManager.print(pckgManager.printLevel.message, "running autorun function..." )
            result[pckgFileData.autorun_function]()
            pckgManager.print(pckgManager.printLevel.success, "autorun function executed" )
        end
    end

    
    pckgManager.print(pckgManager.printLevel.message, "pckgManager.install - end" )
end


function pckgManager.remove(package) -- remove packages
    
    
end


function pckgManager.list() -- list all installed packages
    for _, t in pairs(pckgManager.installPaths) do
        local pckgs = fs.list(t)

        for _, pkg in pairs(pckgs) do
            print(pkg)
        end
    end
    
end


function pckgManager.search(package) -- search for package in db
    
    
end


function pckgManager.sync() -- sync db from sources

    
end

function pckgManager.listAll()
    local packages = {}
    
    for pckg, _ in pairs(pckgManager.dbContent) do
        table.insert(packages, pckg)
    end

    return packages
end



return pckgManager
