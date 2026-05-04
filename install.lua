local pckgCode = http.request("https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/main/main.lua")
local pckg = load(pckgCode)

pckg.init_config()
pckg.dbContent = { -- minimal db with pckg
    ["pckg"]={
        latest="X",
        X="path to newest pkg.json"
    }
}
pckg.install("pckg", "X")
