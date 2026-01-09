-----------------------------------------------
--
--                      Setup
--
-----------------------------------------------


-- pckg - simple package manager v0.3

local pckg = {} -- register all functions in pckg so it can be required by other program

pckg.IsLive = arg[0] == "pastebin" or arg[0] == "wget" -- checks if program is running ( throught pastebin / wget run {link})
pckg.IsRunning = arg[0] == "pckg" -- checks if its app itself running


-----------------------------------------------
--
--                      functions
--
-----------------------------------------------

function pckg.GetHttps(url) -- quick one line for getting https raw data
    local httpsReq = https.get(url)
    local response = httpsReq.readAll()
    https.close()
    return response
end

function pckg.GetPckgHeader(line) -- check for package header

    local Headers = { -- headers
        ["__pckg_info__"]="package info", -- info about package
        ["__pckg_files__"]="package files", -- list of files
        ["__pckg_requirements__"]="package requirements", -- list of requirements for package
        ["__pckg_startup_cmd__"]="startup cmd", -- list of commands to run on startup
        ["__pckg_run_cmd__"]="run cmd", -- list of commands to run after installation
        ["__pckg_standard_header__"]="psh" -- check if even reading the package file
    }

    return Headers[line]
end

function pckg.CollectDataFromPckg( content ) -- collect data from PCKG file 
    local readingHeaderData
    local data = {}

    data.isPckg = false -- Is this file an pckg file?
    data.files = {} -- list of files
    data.run = {} -- list of sommands to run after installation

    data.type = "program" -- default type of pckg is program, there are also: lib, 

    for line in string.gmath(Content, "[^\n]-)\n") do -- for every line in content do
        local header = pckg.GetPckgHeader( line ) -- check it current line is header
        
        if header then
            readingHeaderData = Header -- if line is header then set to the ttpe of header
            if readingHeaderData=="psh" then data.isPckg = true end -- verifies if we are reading actual pckg file and not other file

        elseif readingHeaderData=="startup cmd" then


        elseif readingHeaderData=="package requirements" then
            local required_pckg_name, required_pckg_version = string.match("^([%s%-]+)=(.+)")
            table.insert(data.requirements, )
      

        elseif readingHeaderData=="run cmd" then
            table.insert(data.run, line)

        elseif readingHeaderData=="package info" then -- if reading currently
            local _key, _value = string.match(line, "^([%s%.%-]+): (.+)$") -- extract key and value from data
            data[_key] = _value 
        end
    end
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


-----------------------------------------------
--
--                      commands
--
-----------------------------------------------

function pckg.InstallPCKG(FuncArgs) -- install package (PCKG is custom file format for packaged data needed to install program (links etc) )
    if FuncArgs.Content then pckgPath = FuncArgs.Content or '' -- check for Content ( content of pckg file )
    if FuncArgs.Prefixes then Prefixes = FuncArgs.Prefixes or false -- check for prefixes
    if FuncArgs.Verbose then Verbose = FuncArgs.Verbose or false -- check for verbose
    
    local pckgInfo = pckg.CollectDataFromPckg(Content)
    
    
end







local command = table.concat(arg, ' ')
local tokenizedCommand = pckg.tokenize(command)

for i, v in pairs(tokenizedCommand) do
    print(v.type, v.content, v.prefix)
end
