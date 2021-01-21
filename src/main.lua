local HttpService = game:GetService("HttpService")
local function DeepCopy(tbl)
    if type(tbl) ~= "table" then
		return tbl
	end
	return HttpService:JSONDecode(HttpService:JSONEncode(tbl))
end
local function QuickValue(Value, Parent)
	local TypeofThing = nil
	if type(Value) == "boolean" then
		TypeofThing = "BoolValue"
	elseif type(Value) == "number" then
		TypeofThing = "NumberValue"
	elseif type(Value) == "string" then
		TypeofThing = "StringValue"
	elseif typeof(Value) == "BrickColor" then
		TypeofThing = "BrickColorValue"
	elseif typeof(Value) == "CFrame" then
		TypeofThing = "CFrameValue"
	elseif typeof(Value) == "Color3" then
		TypeofThing = "Color3Value"
	elseif typeof(Value) == "Ray" then
		TypeofThing = "RayValue"
	elseif typeof(Value) == "Vector3" then
		TypeofThing = "Vector3Value"
	elseif typeof(Value) == "Instance" then
		TypeofThing = "ObjectValue"
	end
	
	if not TypeofThing then
		warn("Value type not supported")
		return
	end
	
	local ins = Instance.new(TypeofThing)
	ins.Value = Value
	if Parent then
		ins.Parent = Parent
	end
	
	return ins
end
local function QuickDefault(Value)
	local TypeofThing = nil
	if type(Value) == "boolean" then
		TypeofThing = false
	elseif type(Value) == "number" then
		TypeofThing = 0.0
	elseif type(Value) == "string" then
		TypeofThing = ''
	elseif typeof(Value) == "BrickColor" then
		TypeofThing = BrickColor.new('Medium stone grey')
	elseif typeof(Value) == "CFrame" then
		TypeofThing = CFrame.new()
	elseif typeof(Value) == "Color3" then
		TypeofThing = Color3.fromRGB(0,0,0)
	elseif typeof(Value) == "Ray" then
		TypeofThing = {{0, 0, 0}, {0, 0, 0}}
	elseif typeof(Value) == "Vector3" then
		TypeofThing = Vector3.new(0, 0, 0)
	elseif typeof(Value) == "Instance" then
		TypeofThing = nil
	end
	
	if not TypeofThing then
		warn("Value type not supported")
		return
	end
	
	return TypeofThing
end
local Leaderstats = {
	Level = 1,
	Cash = 0
}
local DefaultSave = {
	Cash = 0, 
    Level = 1,
    Inventory = {}
}
local SaveKey = 'TESTING_0001'
local DataStoreModule = require(script.Parent.dataModule)

--// Main Loop
local Saving = {
    UPDATE_INTERVAL = 60,
    REMOVE_SCAN_INTERVAL = 0.02,
    DEBUG_SAVE = false,
    Storage = {}
}
Saving._defaultSave = DefaultSave
Saving._saveKey = SaveKey
Saving._leaderStats = Leaderstats
local SavedDataStore = game:GetService('DataStoreService'):GetDataStore(Saving._saveKey)

coroutine.wrap(function()
    if game:GetService('RunService'):IsStudio() then
        Saving.DEBUG_SAVE = true
        wait(1)
    end
end)()

function Saving:CheckStorages()
    coroutine.wrap(function()
        while wait(Saving.REMOVE_SCAN_INTERVAL) do
            for PlayerKey, _ in pairs(Saving.Storage) do
                if not game.Players:GetPlayerByUserId(tonumber(PlayerKey)) then
                    coroutine.wrap(function()
                        Saving.SaveToDataStore(PlayerKey, Saving.Storage[PlayerKey])
                        Saving.Storage[PlayerKey] = nil
                    end)()
                end
            end
        end
    end)()
end

function Saving:UpdateData()
    coroutine.wrap(function()
        while true do
            wait(10)
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr.Parent ~= nil then
                    coroutine.wrap(function()
                        Saving.SaveToDataStore(Saving:ConvertToPlayerKey(plr), Saving.Storage[Saving:ConvertToPlayerKey(plr)])
                    end)()
                    wait(Saving.UPDATE_INTERVAL / math.max(#game.Players:GetPlayers(), 1))
                end
            end
        end
    end)()
end

function Saving:CreateLeaderstats(plr)
    local PlayerKey = Saving:ConvertToPlayerKey(plr)
        
    local LS = Instance.new('Folder', plr)
    LS.Name = 'leaderstats'
        
    coroutine.wrap(function()
        while wait() do
            if not plr and Saving.Storage[PlayerKey] ~= nil then
                break
            end
                
            local result = { pcall(function()
                for i, v in pairs(Saving._leaderStats) do
                    if not plr then
                        break
                    end
                    
                    if not LS:FindFirstChild(i) then
                        local Val = QuickValue(v, LS)
                        Val.Name = i
                        Val.Value = Saving.Storage[PlayerKey][i] or QuickDefault(Saving._leaderStats[v])
                    end
                end
                    
                for _, obj in ipairs(LS:GetChildren()) do
                    if not plr then
                        break
                    end

                    obj.Value = Saving.Storage[PlayerKey][obj.Name] or QuickDefault(Saving._leaderStats[obj.Name])
                end
            end) }
                
            if not result[1] then
                print(result[2])
            end
        end
    end)()
end

-- Turning the playerId into a string for the data
function Saving:ConvertToPlayerKey(plr)
    return tostring(plr.UserId)
end

-- Setting the setting
function Saving:setSetting(settingName, settingValue)
    if not (settingName and settingValue and type(settingName) == 'string') then
        error('setSetting had invalid parameters.\nP1 - settingName: string\nP2 - settingValue: unknown', 2)
    end
    local realSetting = '_' .. settingName

    if Saving[realSetting] and type(Saving[realSetting]) ~= 'function' then
        Saving[realSetting] = settingValue
    else
        if Saving[realSetting] then
            error('Attempt to index setting ' ..settingName..' which is not an editable field.');
        else
            error('Attempt to index setting ' ..settingName..' which is not a valid setting!');
        end
    end
end

function Saving:CreateData(plr)
    local PlayerKey = Saving:ConvertToPlayerKey(plr)

    while Saving.Storage[PlayerKey] ~= nil do
        game:GetService('RunService').Heartbeat:Wait()
    end
    
    local savedData, success = DataStoreModule.Get(SavedDataStore, PlayerKey)
    
    if not success then
        plr:Kick('ROBLOX FAILED TO LOAD YOUR DATA. FOR YOUR SAFETY, YOU HAVE BEEN KICKED FROM THE GAME. Try To Rejoin :D')
        return
    end
    
    if savedData then
        local function scanForNewFields(blueprint, scanTarget)
            for key, value in pairs(blueprint) do 
                if not scanTarget[key] then
                    scanTarget[key] = DeepCopy(value)
                elseif type(value) == 'table' then
                    scanForNewFields(value, scanTarget[key])
                end
            end
        end
        scanForNewFields(DefaultSave, savedData)
    end
    
    if not savedData then
        savedData = DeepCopy(DefaultSave)
    end
    
    Saving.Storage[PlayerKey] = savedData
end

-- Getting Player Data
function Saving:Get(plr)
    return Saving.Storage[Saving:ConvertToPlayerKey(plr)]
end

function Saving:WaitForSave(plr, Interval)
    if Saving.DEBUG_SAVE then
        print('You Can Not Save In Studio :D')
        return
    end	

    Interval = Interval or 5
    
    local Data = Saving.Get(plr)
    local StartTick = tick()
    
    if not Data then
        while true do
            wait()
            Data = Saving.Get(plr)
            if Data ~= nil then
                break
            end
            
            if Interval < tick() - StartTick then
                break
            end
        end
    end
    
    if not Data then
        print('Saving.WaitForSave timed out for player', plr.Name)
    end
    return Data
end

local Stored = {}
function Saving:SaveToDataStore(PlayerKey, CurrentData)
    if Saving.DEBUG_SAVE then
        print('You Can Not Save In Studio :D')
        return
    end
    
    if Stored[PlayerKey] == true then
        return
    end
    
    Stored[PlayerKey] = true
    DataStoreModule.Set(SavedDataStore, PlayerKey, (CurrentData or Saving.Storage[PlayerKey]))
    Stored[PlayerKey] = false
end

function Saving:run()
    coroutine.wrap(function()
        Saving:CheckStorages()
        Saving:UpdateData()
        
        game.Players.PlayerAdded:Connect(function(plr)
            Saving:CreateData(plr)
            Saving:CreateLeaderstats(plr)
        end)
        
        for _, plr in ipairs(game.Players:GetPlayers()) do
            coroutine.wrap(function()
                Saving:SaveToDataStore(Saving:ConvertToPlayerKey(plr), Saving.Storage[Saving:ConvertToPlayerKey(plr)])
            end)()
        end
        
        game:BindToClose(function()
            for _, plr in ipairs(game.Players:GetPlayers()) do
                coroutine.wrap(function()
                    Saving:SaveToDataStore(Saving:ConvertToPlayerKey(plr), Saving.Storage[Saving:ConvertToPlayerKey(plr)])
                end)()
            end
        end)
    end)()
end

return Saving