-----------------------------------------------
--
--                      Setup
--
-----------------------------------------------

-- cardboard os admin permisions request
if NotCraftOsGlobals then
    local RealGlobals = __request_craftos_globals__()
    if RealGlobals then
        _G = RealGlobals
    else
        print("pckg will not work without craft os globals. please re run pckg")
        goto exit
    end
end

-- pckg - simple package manager v0.3

local pckg = {} -- register all functions in pckg so it can be required by other program

pckg.version = 0.3
pckg.versiomnName = "3.0 - dev"
pckg.dev = true
pckg.IsLive = arg[0] == "pastebin" or arg[0] == "wget" -- checks if program is running ( throught pastebin / wget run {link})
pckg.IsRunning = arg[0] == "pckg" -- checks if its app itself running
pckg.verbose = true

pckg.root = "/"
pckg.dbType = "offline"
pckg.dbPath = "%s/etc/pckg/packages.pckgdb"


function pckg.vprint(...)
    if pckg.verbose then print(...) end
end

function pckg.dprint(...)
    pckg.vprint(pckg.dev, ... )
end

-----------------------------------------------
--
--                      functions
--
-----------------------------------------------

function pckg.GetHttps(url) -- quick one line for getting https raw data
    if not url then pckg.dprint("CANNOT request nil") return nil end
    local httpsReq = http.get(url)
    local response = httpsReq.readAll()
    httpsReq.close()
    return response
end


-----------------------------------------------
--
--                      prefixes
--
-----------------------------------------------

-- prefixes
pckg.prefixes = { -- info about prefixes

    -- ["prefix"] = {
    --     ["desc"] = 'short info about prefix)',
    --     ["word"] = needs word? -prefix {word}
    -- },


    ["b"] = {
        ["desc"] = 'specifies branch ( stable by default )',
        ["word"] = true
    },

    ["v"] = {
        ["desc"] = 'specifies version ( latest by default )',
        ["word"] = true
    },

    ["r"] = {
        ["desc"] = 'remove'
    },

    ["i"] = {
        ["desc"] = 'install'
    },

    ["ri"] = {
        ["desc"] = 'reinstall'
    },

    ["oi"] = {
        ["desc"] = 'overite installation path',
        ["word"] = true
    },

    ["or"] = {
        ["desc"] = 'overite root path',
        ["word"] = true
    },

    ["odbt"] = {
        ["desc"] = 'overite database type ( offline by default )',
        ["word"] = true
    },

    ["odbp"] = {
        ["desc"] = 'overite database path ( %s/etc/pckg/packages.pckgdb by default )',
        ["word"] = true
    },

    ["h"] = {
        ["desc"] = 'displays this message',
        ['func'] = function (...)
            for prefix, data in pairs(pckg.prefixes) do
                print('    '..prefix..' - '..data)
            end
        end
    },

    ['y'] = {
       ["desc"]="answers yes to every question"
    },

    ["V"] = {
        ["desc"] = 'outputs pckg version',
        ['func'] = function (...)
            print('pckg made by: bluescreen_yt, dedicated for cardboard os')
            print('please contant author if you find any bugs / issues / suggest new features or want to contrubute')
            print('version: '..pckg.versiomnName)
        end
    }
}

-- tokenizer
function isToken(token, type) -- check if token's type
    return token and token.type==type
end

function pckg.tokenize(cmd) -- tokenize the command (pckg -i package -b branch -v version)
    local words = {} -- initilize token table
    local currentWord = ''
    local connected = false

    for i=1, #cmd do -- for every letter in command
        local char = cmd:sub(i,i) -- get current letter 
        
        if char == '"' then -- check if current letter is an quote if yes flip connected var
            connected = not connected -- FLIP
            
            if  not connected then -- if end quote set char to space
                char = ' '
            end
        end

        if char == ' ' and not connected then -- check if current letter is an whitespace, and if the words are not connected with quotes
            if currentWord~="" then table.insert(words , currentWord) end
            
            currentWord = ''
        else
            if char ~= '"' then
              currentWord = currentWord..char
            end
        end
    end

    local idx=0
    
  while idx<#words do
        idx=idx+1
        local word = words[idx]
        local prefixData = pckg.prefixes[word]

        if prefixData then 
            local requiresWord = prefixData.word
            if requiresWord then
  end

    return words
end


function pckg.InstallPCKG(FuncArgs) -- install package (PCKG is custom file format for packaged data needed to install program (links etc) )
    local pckgInfo, Prefixes, Verbose, InstallPath
    local TypeToInstallDir = {
        ["program"]="bin/%s/",
        ["library"]="lib/%s/",
        ["driver"]="boot/modules/%s/",
        ["root"]="/%s"
    }

    if FuncArgs.pckgInfo then pckgInfo = FuncArgs.pckgInfo or false end -- check for Content ( content of pckg file )
    if FuncArgs.Prefixes then Prefixes = FuncArgs.Prefixes or false end -- check for prefixes
    if FuncArgs.OverideInstallPath then InstallPath = FuncArgs.OverideInstallPath else InstallPath = nil end -- check for path overide

    if pckgInfo and pckgInfo.name and not InstallPath then
        InstallPath = string.format(TypeToInstallDir[pckgInfo.type], pckgInfo.name) -- set default dir path
        pckg.dprint("no InstallPath overide, package type: "..pckgInfo.type.." InstallPath: "..InstallPath)
    end
    
    
    if pckgInfo and pckgInfo.isPckg and InstallPath then
        for filePath, fileUrl in pairs(pckgInfo.files) do
            local filePath = fs.combine(InstallPath, filePath)
            
            local file = fs.open(filePath, 'w')
            
            pckg.dprint("Requesting: "..fileUrl.." for file: "..filePath)
            local fileContent = pckg.GetHttps(fileUrl)
            if not fileContent then pckg.vprint("Error getting: "..fileUrl.." file: "..filePath) end
            file.write(fileContent)
            file.close()
        end

        for requirement in pairs(pckgInfo.requirements) do
            
            -- requirement.name
            -- requirement.version
        end



    else
        pckg.vprint("the .pckg file might be corrupted...")
        pckg.dprint(pckgInfo, pckgInfo.isPckg, InstallPath)
    end
    
    
end

-----------------------------------------------
--
--                      commands
--
-----------------------------------------------






local command = 'pckg testing "hello world"lol abc'--table.concat(arg, ' ')
local tokenizedCommand = pckg.tokenize(command)

if #tokenizedCommand==0 then
    print('Nothing to do')
    print('add -h prefix to display guide')
    goto exit
end



for i, v in pairs(tokenizedCommand) do

    print(v.type, v.content, v.prefix)
end


::exit::
