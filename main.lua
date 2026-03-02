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

pckg.dev = true
pckg.IsLive = arg[0] == "pastebin" or arg[0] == "wget" -- checks if program is running ( throught pastebin / wget run {link})
pckg.IsRunning = arg[0] == "pckg" -- checks if its app itself running

function pckg.vprint(v, ...)
    if v then print(...) end
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
        ["desc"] = 'reinstall'
    },

    ["i"] = {
        ["desc"] = 'install'
    },

    ["u"] = {
        ["desc"] = 'uninstall'
    },

    ["o"] = {
        ["desc"] = 'overite installation path',
        ["word"] = true
    },

    ["h"] = {
        ["desc"] = 'displays this message',
        ['func'] = function (...)
            for prefix, data in pairs(pckg.prefixes) do
                print('    '..prefix..' - '..data)
            end
        end
    }
}

-- tokenizer
function isToken(token, type) -- check if token's type
    return token and token.type==type
end

function pckg.tokenize(cmd) -- tokenize the command (pckg -i package -b branch -v version)
    local tokens = {} -- initilize token table
    local lastToken

    for word in string.gmatch(cmd, "%S+") do -- for words in cmd do:
        local token = {}

        if word:sub(1, 1) == "-" then -- check if the word starts with -
            token.type = 'prefix' -- create  token with type 'prefix' and value of prefix
            token.prefix = word:sub(2)
        else
            token.content = word
            token.type = 'word'
        end

        if isToken(lastToken, 'prefix') then -- check if last token is prefix

            local lastPrefixInfo = pckg.prefixes[lastToken.prefix] -- get last prefix info

            if lastPrefixInfo and lastPrefixInfo.word then -- check if last prefix info
                lastToken.content = word -- set last prefix content to current word if it needs word
            else
                table.insert(tokens, token)

            end

            else
            table.insert(tokens, lastToken)
            table.insert(tokens, token)
        end


        lastToken = token

    end

    return tokens
end

function pckg.InstallPCKG(FuncArgs) -- install package (PCKG is custom file format for packaged data needed to install program (links etc) )
    local pckgInfo, Prefixes, Verbose, InstallPath
    local TypeToInstallDir = {
        ["program"]="bin/%s/",
        ["library"]="lib/%s/",
        ["driver"]="boot/modules/%s/",
        ["root"]="/"
    }

    if FuncArgs.pckgInfo then pckgInfo = FuncArgs.pckgInfo or false end -- check for Content ( content of pckg file )
    if FuncArgs.Prefixes then Prefixes = FuncArgs.Prefixes or false end -- check for prefixes
    if FuncArgs.Verbose then Verbose = FuncArgs.Verbose or false end -- check for verbose
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
            if not fileContent then pckg.vprint(Verbose, "Error getting: "..fileUrl.." file: "..filePath) end
            file.write(fileContent)
            file.close()
        end

        for requirement in pairs(pckgInfo.requirements) do
            
            -- requirement.name
            -- requirement.version
        end



    else
        print("the .pckg file might be corrupted...")
        pckg.dprint(pckgInfo, pckgInfo.isPckg, InstallPath)
    end
    
    
end

-----------------------------------------------
--
--                      commands
--
-----------------------------------------------






local command = table.concat(arg, ' ')
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