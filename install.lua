-- wget run https://raw.githubusercontent.com/Bluescreen-yt/Package-manager-CC-T/refs/heads/main/install.lua

local pckgCode
local Branch = "dev"

if fs.exists("/bin/pckg") then
    print("pckg is already installed! updating..")
    local pckgCode = fs.open("/bin/pckg/main.lua", "r")

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
pckg.header()
pckg.install("pckg", "X")
shell.setAlias("pckg", "/bin/pckg/run.lua")
print("don't worry about warning above. alias has been set up correctly.")
print("pckg installed successfully! you can now use pckg")
print("have fun using pckg :p")