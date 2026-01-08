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
--                      prefixes
--
-----------------------------------------------

pckg.prefixes = {
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


function pckg.tokenize(cmd) -- tokenize the command (pckg -i package -b branch -v version)
    local tokens = {} -- initilize token table
    local lastToken

    for word in string.gmatch(cmd, "%S+") do -- for words in cmd do:
        local token = {}

        if word:sub(1, 1) == "-" then -- check if the word starts with -
            token.type = 'prefix' -- create  token with type 'prefix' and value of prefix
            token.prefix = word:sub(1)
        else
            token.content = word
            token.type = 'word'
        end

        if lastToken and lastToken.type=='prefix' then -- check if last token is prefix
          
          local lastPrefixInfo = pckg.prefixes[lastToken.prefix] -- get last prefix info
          
          if lastPrefixInfo and lastPrefixInfo.word then -- chwck if last prefix info
            lastToken.content = word -- set last prefix content to current word if it needs word
          else
            table.insert(tokens, token)

          end
        
        else
          table.insert(tokens, token)

        end
    end
end


-----------------------------------------------
--
--                      commands
--
-----------------------------------------------







