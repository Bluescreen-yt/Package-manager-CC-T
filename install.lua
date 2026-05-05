-- wget run https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/main/install.lua

if fs.exists("/bin/pckg") then
    print("pckg is already installed! updating..")
    local pckgCodeFile = fs.open("/bin/pckg", "r")
    local pckgCode = pckgCodeFile.readAll()
    pckgCodeFile.close()
else
    local pckgCode = http.get("https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/main/main.lua")
end


local pckg = load(pckgCode.readAll())
pckgCode.close()

pckg = pckg()

pckg.init_enums()
pckg.init_config()
pckg.dbContent = { -- minimal db with pckg
    ["pckg"]={
        latest="X",
        X="https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/main/pkg.json"
    }
}
pckg.install("pckg", "X")
