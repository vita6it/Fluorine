local _ENV = (getgenv or getrenv or getfenv)()

local Utils = {}
local Settings = {}
local Threads = {}
local Fallback = {}
local Active = {}

local Owner = "vita6it"
local Repository = "Fluorine"

local function fetch(file)
    local URL = string.format(
        "https://raw.githubusercontent.com/%s/%s/main/%s",
        Owner, Repository, file
    )

    warn("Fetch : ", file)

    return loadstring(game:HttpGet(URL))()
end

local function AddModule(Name, Module)
    do Utils[Name] = Module()
        return Utils[Name]
    end
end

local Library = fetch("Library.lua")

local TeleportService = game:GetService('TeleportService')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

Utils.Library = Library

AddModule("Connections", function()
    local Connections = {}
    local Cached = _ENV.Connections or {}

    do
        _ENV.Connections = Cached

        for i = 1, #Cached do
            Cached[i]:Disconnect()
        end

        table.clear(Cached)
    end

    function Connections.Connect(Instance, Callback)
        local Connection = Instance:Connect(Callback)

        table.insert(Cached, Connection)

        return Connection
    end 

    return Connections
end)

AddModule("Configurations", function()
    local Configurations = {}
    local Files = "Fluorine"

    local makefolder = makefolder or function( ... ) return ... end
    local writefile = writefile or function( ... ) return ... end
    local isfolder = isfolder or function( ... ) return ... end
    local readfile = readfile or function( ... ) return ... end
    local isfile = isfile or function( ... ) return ... end

    Configurations.Files = Files or "Fluorine"
    Configurations.Set = `{Files}/settings`
    Configurations.FullPaths = `{Configurations.Set}/{PlaceId}.json`
    Configurations.Paths = { Files, Configurations.Set }

    do
        function Configurations:Folder()
            for i = 1, #self.Paths do
                local str = self.Paths[i]

                if not isfolder(str) then
                    makefolder(str)
                end
            end
        end

        function Configurations:Default(index, value)
            if Settings[index] == nil then
                Settings[index] = value
            end
        end

        function Configurations:Save(index, value)
            if index ~= nil then
                Settings[index] = value
            end

            if not isfolder(Files) then
                makefolder(Files)
            end

            if not isfolder(Configurations.Set) then
                makefolder(Configurations.Set)
            end

            writefile(Configurations.FullPaths, HttpService:JSONEncode(Settings))
        end

        function Configurations:Load()
            if not isfile(Configurations.FullPaths) then
                self:Save()
            end

            local Reader = readfile(Configurations.FullPaths) do
                return HttpService:JSONDecode(Reader) 
            end
        end 
    end

    do Configurations:Folder()
        Configurations:Default("Success", true)
    end

    return Configurations
end)

AddModule("NewOption", function()
    local ACTOR_HASHER = tostring(os.clock() + math.random()) do
        _ENV.ACTOR_HASHER = ACTOR_HASHER
    end
    
    local function While(a, b, c, d)
        while a do
            local t = tick()

            if c then c() end
            if d and d() then break end

            repeat
                RunService.Heartbeat:Wait()
            until tick() - t >= (b or 0.1)
        end
    end

    local function NewOption(Tag, Function, Time)
        Threads[Tag] = function(Value)
            While(Value, Time or 0.1, Function, function()
                return not Value or _ENV.ACTOR_HASHER ~= ACTOR_HASHER
            end)
        end
    end

    return NewOption
end)

AddModule("Plugins", function()
    local Plugins = {}

    local Configurations = Utils.Configurations

    function Plugins.new(Info)
        Plugins['Base'] = Library:App({
            Title = Info[1],
            Footer = Info[2],
            Logo = Info[3],
            Width = 150
        })

        return Plugins['Base']
    end

    function Plugins:Tabs(Info)
        return self['Base']:MakeTab({
            Title = Info[1],
            Icon = Info[2]
        })
    end

    function Plugins:Section(Tab, Info)
        return Tab:Section(Info)
    end

    function Plugins:Button(Section, Info, Callback)
        return Section:Button({
            Title = Info[1],
            Description = Info[2] or nil,
            Callback = Callback,
        })
    end

    function Plugins:Toggle(Section, Info, Flag, Callback)
        local function OnChanged(value)
            if value then
                Active[Flag] = task.spawn(function()
                    if Threads[Flag] then Threads[Flag](Settings[Flag]) end
                end)
            else
                if Active[Flag] then
                    task.cancel(Active[Flag])
                    Active[Flag] = nil
                end
            end

            if Callback then Callback(value) end
        end
        
        Fallback[Flag] = Section:Toggle({
            Title = Info,
            Value = Settings[Flag],
            Callback = function(value)
                Settings[Flag] = value
                Configurations:Save(Flag, value)

                OnChanged(value)
            end,
        })

        return Fallback[Flag]
    end

    function Plugins:Slider(Section, Title, Values, Flag, Callback)
        return Section:Slider(Flag, {
            Title = Title,
            Min = Values[1],
            Max = Values[2],
            Value = Settings[Flag],
            Rounding = Values[3] or 0,
            Callback = function(value)
                Settings[Flag] = value
                Configurations:Save(Flag, value)

                if Callback then Callback(value) end
            end,
        })
    end

    return Plugins
end)

do
    for Save, Value in Utils.Configurations:Load() do
        Settings[Save] = Value
    end

    Utils.Settings = Settings 
end

return Utils
