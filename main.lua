local pckgManager = {}

function pckgManager.init_enums()
    pckgManager.debugLevels = { debug=0, warnings=1, errors=2, none=3 } -- enum for debugging level (debugLevel)
    pckgManager.printLevel = { message=0, warning=1, error=2} -- print level for pckgManager.print function
    
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


local function prettyPrint(level, text ) -- pretty print msgs
    local levelData = {
        [0]={ icon="*", color="8" },
        [1]={ icon="?", color="1" },
        [2]={ icon="!", color="e" },
    }

    local Pre = " "..levelData[level].icon.." "
    local PreColor = string.rep(levelData[level].color, #Pre)
    local msg = " " .. text
    local fullMsg = Pre .. msg

    term.blit( -- print
        fullMsg,  -- message
        string.rep("0", #fullMsg), -- foreground ( full white )
        PreColor .. string.rep("7", #msg) -- background ( msg color + gray )
    )

    print() -- new line
end


function pckgManager.print(level, text ) -- print
    if level>=pckgManager.debugLevel then -- check if level of message is lower or eq to debug level
        prettyPrint(level, text)
    end
end


function pckgManager.init() -- init (load db etc etc)
    pckgManager.print(pckgManager.printLevel.message, "pckgManager.init() - start" )

    if fs.exists(pckgManager.dbPath) then -- if db exists load it
        pckgManager.print(pckgManager.printLevel.message, "db file found." )
    
        local DB_FILE = fs.open(pckgManager.dbPath, 'r') -- open db file

        pckgManager.dbContent = textutils.unserializeJSON(DB_FILE.readAll()) -- load db content
        DB_FILE.close() -- close file
    else -- if no db file found
        pckgManager.print(pckgManager.printLevel.warning, "no db file found" )
    end

    pckgManager.print(pckgManager.printLevel.message, "pckgManager.init - end" )
end


function pckgManager.install(package, version) -- install package
    pckgManager.print(pckgManager.printLevel.message, "pckgManager.install( '"..package or "nil" .."', '".. version or "nil" .."' ) - start" )
    if not package then
        pckgManager.print(pckgManager.printLevel.error, "No package specified" )
        return 1, "no package specified"
    else
        pckgManager.print(pckgManager.printLevel.message, "package: "..package)
    end
    if not version then
        pckgManager.print(pckgManager.printLevel.warning, "No version specified, installing latest" )
        version="latest"
    else
        pckgManager.print(pckgManager.printLevel.message, "version: "..version )
    end

    local pckgDB = pckgManager.dbContent[package]
    if not pckgDB then
        pckgManager.print(pckgManager.printLevel.error, "package "..package.." not found" )
        return 2, "package not found"
    else
        pckgManager.print(pckgManager.printLevel.message, "package found" )
    end

    if version == "latest" then
        version = pckgDB.latest

        if not version then
            pckgManager.print(pckgManager.printLevel.error, "could not get latest version" )
            return 3, "could not get latest version"
        end
    end



    local pckg_data = pckgDB[version]
    if not pckg_data then
        pckgManager.print(pckgManager.printLevel.error, "could not get "..version.." version of the package "..package )
        return 4, "failed to retrive version data"
    end

    


    pckgManager.print(pckgManager.printLevel.message, "pckgManager.install - end" )
end


function pckgManager.remove(package) -- remove packages
    
end


function pckgManager.list() -- list all installed packages
    
end


function pckgManager.search(package) -- search for package in db
    
end


function pckgManager.sync() -- sync db from sources
    
end


return pckgManager