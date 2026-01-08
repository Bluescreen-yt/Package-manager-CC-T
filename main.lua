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

function pckg.GetHttps(url)
    local httpsReq = https.get(url)

    local response = httpsReq.readAll()

    https.close()
end

function pckg.GetPckgHeader(line)
    local Headers = {
        "__PCKG_DATA__"
    }
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
    
    local ReadingHeaderData
    
    for line in string.gmath(Content, "[^\n]-)\n") do -- for every line in content do
        local Header = pckg.GetPckgHeader(line)
        if Header then 
            ReadingHeaderData = Header
        end


    end
end







local command = table.concat(arg, ' ')
local tokenizedCommand = pckg.tokenize(command)

for i, v in pairs(tokenizedCommand) do
    print(v.type, v.content, v.prefix)
end
