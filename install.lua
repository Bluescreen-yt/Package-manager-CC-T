local pckgCode = http.get("https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/main/main.lua")
print(pckgCode.readAll())
local pckg = loadstring(pckgCode.readAll())
pckgCode.close()

pckg.init_config()
pckg.dbContent = { -- minimal db with pckg
    ["pckg"]={
        latest="X",
        X="https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/main/pkg.json"
    }
}
pckg.install("pckg", "X")
