-- wget run https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/main/install.lua

local pckgCode
local Branch = "main"

if fs.exists("/bin/pckg") then
    print("pckg is already installed! updating..")
    pckgCode = fs.open("/bin/pckg/main.lua", "r")

    if not pckgCode then
        print("failed to read existing pckg code! updating with online version..")
        pckgCode = http.get("https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/"..Branch.."/main.lua")
    end
else
    pckgCode = http.get("https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/"..Branch.."/main.lua")
end


local pckg = load(pckgCode.readAll())
pckgCode.close()

pckg = pckg()

pckg.init_enums()
pckg.init_config()
pckg.dbContent = { -- minimal db with pckg
    ["pckg"]={
        latest="X",
        X="https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/"..Branch.."/pkg.json"

    }
}

pckg.install("pckg", "X")
shell.setAlias("pckg", "/bin/pckg/run.lua")
print()
pckg.header()
print()
print("pckg installed successfully! you can now use pckg")
print("have fun using pckg :p")
print()

pckg.saveDB()

if not fs.exists("/startup.lua") then
    print("do you want to create a startup.lua file to automatically load aliases on startup? (y/n)")
    local response = read()
    if string.lower(response) == "y" then
        shell.run("/bin/pckg/run.lua createStartupFile")
    else
        print("if you want to load aliases, run '/bin/pckg/run.lua loadAliases'")
    end
end 