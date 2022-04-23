-- Prophunt for future!

repeat wait() until game:IsLoaded()
local GuiLibrary = shared.Future.GuiLibrary
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WORKSPACE = game:GetService("Workspace")
local PLAYERS = game:GetService("Players")
local lplr = PLAYERS.LocalPlayer
local mouse = lplr:GetMouse()
local cam = WORKSPACE.CurrentCamera
local getcustomasset = getsynasset or getcustomasset
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local state = function() return workspace.MatchDocument:GetAttribute("matchState") end

local function requesturl(url, bypass) 
    if isfile(url) and shared.FutureDeveloper then 
        return readfile(url)
    end
    local repourl = bypass and "https://raw.githubusercontent.com/joeengo/" or "https://raw.githubusercontent.com/joeengo/Future/main/"
    local url = url:gsub("Future/", "")
    local req = requestfunc({
        Url = repourl..url,
        Method = "GET"
    })
    if req.StatusCode == 404 then error("404 Not Found") end
    return req.Body
end 

local function getasset(path)
	if not isfile(path) then
		local req = requestfunc({
			Url = "https://raw.githubusercontent.com/joeengo/Future/main/"..path:gsub("Future/assets", "assets"),
			Method = "GET"
		})
        print("[Future] downloading "..path.." asset.")
		writefile(path, req.Body)
        print("[Future] downloaded "..path.." asset successfully!")
	end
	return getcustomasset(path) 
end

local HeartbeatTable = {}
local RenderStepTable = {}
local SteppedTable = {}
local function isAlive(plr)
    local plr = plr or lplr
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid")) or (plr.Character:FindFirstChild("HumanoidRootPart"))) then
        return true
    end
end

local function BindToHeartbeat(name, func)
    if HeartbeatTable[name] == nil then
        HeartbeatTable[name] = game:GetService("RunService").Heartbeat:connect(func)
    end
end
local function UnbindFromHeartbeat(name)
    if HeartbeatTable[name] then
        HeartbeatTable[name]:Disconnect()
        HeartbeatTable[name] = nil
    end
end
local function BindToRenderStep(name, func)
	if RenderStepTable[name] == nil then
		RenderStepTable[name] = game:GetService("RunService").RenderStepped:connect(func)
	end
end
local function UnbindFromRenderStep(name)
	if RenderStepTable[name] then
		RenderStepTable[name]:Disconnect()
		RenderStepTable[name] = nil
	end
end
local function BindToStepped(name, func)
	if SteppedTable[name] == nil then
		SteppedTable[name] = game:GetService("RunService").Stepped:connect(func)
	end
end
local function UnbindFromStepped(name)
	if SteppedTable[name] then
		SteppedTable[name]:Disconnect()
		SteppedTable[name] = nil
	end
end

local function ferror(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    GuiLibrary["CreateNotification"]("<font color='rgb(255, 10, 10)'>[ERROR]"..str.."</font>")
    error("[Future]"..str)
end

local function fwarn(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    warn("[Future]"..str)
    GuiLibrary["CreateNotification"]("<font color='rgb(255, 255, 10)'>[WARNING] "..str.."</font>")
end

local function fprint(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    print("[Future]"..str)
    GuiLibrary["CreateNotification"]("<font color='rgb(200, 200, 200)'>"..str.."</font>")
end

local Flamework = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
repeat task.wait() until Flamework.isInitialized
local PS = lplr.PlayerScripts
local RS = game:GetService("ReplicatedStorage")
local dependencies = {
    -- normal dependencys:
    ClientHandler = require(RS.TS.networking),
    ItemMeta = require(RS.TS.item["item-meta"]).ProphuntItemMeta,
    GunController = require(PS.TS.controllers.game.items.gun["gun-controller"]),
    VelocityUtil = require(RS.rbxts_include["node_modules"]["@easy-games"]["game-core"].out.shared.util["velocity-util"]).VelocityUtil,
    ClientSyncEvents = require(PS.TS["client-sync-events"]).ClientSyncEvents,
    HighlightController = require(PS.TS.controllers.global.highlight["highlight-controller"]).HighlightController,
    WorldIndicatorController = require(RS.rbxts_include["node_modules"]["@easy-games"]["game-core"].out.client.controllers.indicators["world-indicator-controller"]).WorldIndicatorController,
    DamageIndicatorController = require(PS.TS.controllers.game.combat["damage-indicator-controller"]).DamageIndicatorController,

    -- flamework dependencys:
    InventoryHandlerF = Flamework.resolveDependency("client/controllers/game/active-item/active-item-manager-controller@ActiveItemManagerController"),
    GunControllerF = Flamework.resolveDependency("client/controllers/game/items/gun/gun-controller@GunController"),
    ShiftLockControllerF = Flamework.resolveDependency("client/controllers/global/camera/shift-lock-controller@ShiftLockController"),
    ProjectileControllerF = Flamework.resolveDependency("@easy-games/projectile:client/controllers/projectile-controller@ProjectileController"),
    CombatControllerF = Flamework.resolveDependency("client/controllers/game/combat/combat-controller@CombatController"),
    SwordControllerF = Flamework.resolveDependency("client/controllers/game/items/sword/sword-controller@SwordController"),
    AmmoControllerF = Flamework.resolveDependency("client/controllers/game/ammo/ammo-controller@AmmoController"),


}


local function getColorFromPlayer(v) 
    if v.Team ~= nil then return v.TeamColor.Color end
end
 
local function getPlrProps() 
    local p = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and (v.Character:FindFirstChild("Head") == nil or (v.Team ~= nil and v.Team.Name == "Hider")) then 
            p[v.Name] = v
        end
    end
    return p
end

local function isProp(plr) 
    return plr.Team ~= nil and plr.Team.Name == "Hider"
end

local function canBeTargeted(plr, doTeamCheck) 
    if isAlive(plr) and plr~=lplr and (doTeamCheck and plr.Team ~=lplr.Team or not doTeamCheck) then 
        return true
    end
    return false
end

local function requestSelfDamage(health) 
    local requestSelfDamage = game:GetService("ReplicatedStorage")["events-@easy-games/damage:shared/damage-networking@DamageNetEvents"].requestSelfDamage
    requestSelfDamage:FireServer(health)
end

local function getInventory() 
    return dependencies.InventoryHandlerF.inventoryController:getPlayerInventory()~=nil 
    and dependencies.InventoryHandlerF.inventoryController:getPlayerInventory():getAllItems() 
    or {}
end

local function getAllPlrsNear()
    if not isAlive() then return {} end
    local t = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                pcall(function()
                    table.insert(t, (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude, v) 
                end)
            end
        end
    end
    return t
end

local function playsound(id, volume) 
    local sound = Instance.new("Sound")
    sound.Parent = workspace
    sound.SoundId = id
    sound.PlayOnRemove = true 
    if volume then 
        sound.Volume = volume
    end
    sound:Destroy()
end

local function playanimation(id) 
    if isAlive() then 
        local animation = Instance.new("Animation")
        animation.AnimationId = id
        local animatior = lplr.Character.Humanoid.Animator
        animatior:LoadAnimation(animation):Play()
    end
end

local function getSword()
    local items = getInventory()
    for i,v in pairs(items) do 
		if v.item:find("sword") or v.item:find("pan") or v.item:find("bat") then 
			return v
		end
	end
end

local function killall() 
    for i = 1, 10 do 
        for i,v in next, getPlrProps() do 
            pcall(function()
                local args = {
                    v.Character.HumanoidRootPart.Position, -- bedwars dev iq = 0
                    CFrame.lookAt(lplr.Character.HumanoidRootPart.CFrame.p, v.Character.HumanoidRootPart.CFrame.p).lookVector * (v.Character.HumanoidRootPart.CFrame.p - lplr.Character.HumanoidRootPart.CFrame.p).magnitude,
                    {
                        ["instance"] = v.Character.HumanoidRootPart,
                        ["normal"] = Vector3.new(1, 0, 0),
                        ["position"] = v.Character.HumanoidRootPart.Position
                    },
                    math.random(),
                    false
                }
                dependencies.ClientHandler.NetEvents.client.shoot(unpack(args))  
            end)
        end
    end
end

do 
    local aura = {["Enabled"] = false}
    local auraswing = {["Enabled"] = false}
    local auraswingsound = {["Enabled"] = false}    
    local soundtick = tick()
    local auradist = {["Value"] = 14 }
    aura = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Aura",
        ["Function"] = function(callback) 
            spawn(function()
                repeat wait() 
                    for i,v in next, getAllPlrsNear() do 
                        if isAlive() and canBeTargeted(v) and (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude < auradist["Value"] then 
                            local weapon = getSword()
                            if weapon ~= nil then
                                dependencies.ClientHandler.NetFunctions.client.swordHit:invoke(weapon.item, v.Character, {isRaycast = true}, 0)
                                if auraswingsound["Enabled"] then 
                                    if soundtick < tick()+0.1 then
                                        playsound("rbxassetid://6760544639")
                                        soundtick = tick()
                                    end
                                end
                            end
                        end
                    end
                until aura["Enabled"] == false
            end)
        end,
    })
    auraswingsound = aura.CreateToggle({
        ["Name"] = "SwingSound",
        ["Function"] = function() end,
    })
    auradist = aura.CreateSlider({
        ["Name"] = "Range",
        ["Function"] = function() end,
        ["Min"] = 1,
        ["Max"] = 14,
        ["Default"] = 14
    })

end

do 
    local old = dependencies.VelocityUtil.applyVelocity
    local Velocity = {["Enabled"] = false}; Velocity = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Velocity",
        ["Function"] = function(callback) 
            dependencies.VelocityUtil.applyVelocity = callback and function(...) end or old
        end
    })
end



do 
    local PropKill = {["Enabled"] = false}; PropKill = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "KillProps",
        ["Function"] = function(callback) 
            if callback then
                spawn(function()
                    killall()
                end)
                if PropKill["Enabled"] then
                    PropKill["Toggle"](false, true)
                end
            end
        end
    })
end

do
    if not isfile("Future/autowintimes.txt") then 
        writefile("Future/autowintimes.txt", "")
    end
    
    local messages = {}

    local timeStart = nil
    local PropKill = {["Enabled"] = false}; PropKill = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoWin",
        ["Function"] = function(callback) 
            spawn(function()
                repeat task.wait()
                    if PropKill["Enabled"] == false then break end 
                    if isAlive() then
                        if lplr.Team ~= nil and (lplr.Team.Name:find("Hider")) then 
                            requestSelfDamage(1000)
                        elseif lplr.Team ~= nil then
                            timeStart = timeStart or WORKSPACE:GetServerTimeNow()
                            killall()
                            task.wait(0.05)
                            if (state() == 2) then 
                                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Future AutoWin is simply the best, goto engoalt.github.io today!","All")
                                game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({["queueType"] = "vanilla"})
                                GuiLibrary["CreateNotification"]("AutoWin completed in ".. tostring(WORKSPACE:GetServerTimeNow() - timeStart) .. "s")
                                appendfile("Future/autowintimes.txt", tostring(WORKSPACE:GetServerTimeNow() - timeStart).."\n")
                                break
                            end
                        end
                    end
                until PropKill["Enabled"] == false
            end)
        end
    })
end

--[[
do
    if not isfile("Future/autowintimes.txt") then 
        writefile("Future/autowintimes.txt", "")
    end
    
    local timeStart = nil
    local PropKill = {["Enabled"] = false}; PropKill = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoWinRewrite",
        ["Function"] = function(callback) 
            spawn(function()
                repeat task.wait() until state() == 1
                if isProp(lplr) then 
                    repeat task.wait()
                    requestSelfDamage(1000)
                    until not isProp(lplr)
                end
                repeat task.wait() until isAlive() and not isProp(lplr)
                timeStart = timeStart or WORKSPACE:GetServerTimeNow()
                repeat task.wait(0.05) 
                    killall()
                until state() == 2 
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Future AutoWin is simply the best, visit dsc.gg/engo in google now!","All")
                game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({["queueType"] = "vanilla"})
                pcall(function()
                    GuiLibrary["CreateNotification"]("AutoWin completed in ".. tostring(WORKSPACE:GetServerTimeNow() - timeStart) .. "s")
                    appendfile("Future/autowintimes.txt", tostring(WORKSPACE:GetServerTimeNow() - timeStart).."\n")
                end)
            end)
        end
    })
end]]


do 
    local AutoSwapProp = {["Enabled"] = false}; AutoSwapProp = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoProp",
        ["Function"] = function(callback) 
            if callback and lplr.Team ~= nil then 
                spawn(function()
                    repeat task.wait() 
                            for i,v in pairs(WORKSPACE.Map.Props:children()) do --//credits to my friend liam lol
                                if isAlive() then
                                    task.wait(1)
                                    local oldhrp = lplr.Character.HumanoidRootPart.CFrame
                                    local old = cam.CFrame
                                    game:GetService("ReplicatedStorage")["events-shared/networking@NetEvents"].disguiseProp:FireServer(v.Name, v)
                                    cam.CFrame = old
                                    lplr.Character.HumanoidRootPart.CFrame = oldhrp
                                    if AutoSwapProp["Enabled"] == false then break end
                                end
                            end
                    until AutoSwapProp["Enabled"] == false
                end)
            end
        end
    })
end

do 
    local Value = {["Value"] = 1}
    local God = {["Enabled"] = false}; God = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "InstantHealth",
        ["Function"] = function(callback) 
            if callback then
                local num = tonumber(Value["Value"])
                if num == nil then num = 99999 end
                requestSelfDamage(-(num))
            end
        end
    })
    Value = God.CreateTextbox({
        ["Name"] = "Health",
        ["Function"] = function() end,
        ["Default"] = 99
    })
end

do 
    local GunMode = {["Enabled"] = false}; GunMode = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "GunMod",
        ["Function"] = function(callback) 
            if callback then 
                dependencies.GunControllerF.ammo = math.huge
                dependencies.ItemMeta.pistol.gun.fireRate = 0
                dependencies.ItemMeta.bow.ammo.maxClipSize = math.huge
                dependencies.ItemMeta.crossbow.ammo.maxClipSize = math.huge
                dependencies.ItemMeta.bow.projectileSource.cooldownId = nil
                dependencies.ItemMeta.crossbow.projectileSource.cooldownId = nil
                dependencies.ItemMeta.pistol.gun.aimcone.bulletSpread = 0
            else
                dependencies.GunControllerF.ammo = math.huge
                dependencies.ItemMeta.pistol.gun.fireRate = 0.14
                dependencies.ItemMeta.bow.ammo.maxClipSize = 2
                dependencies.ItemMeta.crossbow.ammo.maxClipSize = 5
                dependencies.ItemMeta.bow.projectileSource.cooldownId = "arrow"
                dependencies.ItemMeta.crossbow.projectileSource.cooldownId = "crossbow_arrow"
                dependencies.ItemMeta.pistol.gun.aimcone.bulletSpread = 0.015
            end          
        end
    })
end


do 
    local AutoLeave = {["Enabled"] = false}; AutoLeave = GuiLibrary["Objects"]["MiscellaneousWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoRequeue",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function() 
                    repeat task.wait() until state() == 2
                    if AutoLeave.Enabled then 
                        game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({["queueType"] = "vanilla"})
                    end
                end)
            end
        end
    })
end

do 
    local CoinGrab = {["Enabled"] = false}; CoinGrab = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
        ["Name"] = "CoinGrab",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function() 
                    repeat task.wait(0.25)
                        for i,v in next, WORKSPACE.GroundItems:GetChildren() do 
                            if isnetworkowner(v) and isAlive() then 
                                v.CFrame = lplr.Character.HumanoidRootPart.CFrame
                            end
                        end
                    until CoinGrab["Enabled"] == false
                end)
            end
        end,
    })
end

do
    local cached
    local FastCrate = {["Enabled"] = false}; FastCrate = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
        ["Name"] = "FastCrate",
        ["Function"] = function(callback) 
            for i,v in next, WORKSPACE:WaitForChild("Map"):WaitForChild("Configuration"):WaitForChild("Crates"):GetChildren() do 
                local proxPrompt = v.PromptLocation.OpenCrate
                cached = cached or proxPrompt.HoldDuration
                proxPrompt.HoldDuration = callback and 0 or cached
            end
        end,
    })
end

do 
    local old, old2, old3 = dependencies.HighlightController.highlight, dependencies.DamageIndicatorController.spawnDamageIndicator, dependencies.WorldIndicatorController.addIndicator
    local Lagger = {["Enabled"] = false}; Lagger = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "FPSLagger",
        ["Function"] = function(callback) 
            if callback then 
                dependencies.HighlightController.highlight = function(...) end
                dependencies.WorldIndicatorController.addIndicator = function(...) end
                dependencies.DamageIndicatorController.spawnDamageIndicator = function(...) end
                spawn(function() 
                    repeat task.wait(0.05)
                        spawn(function() 
                            repeat task.wait()
                                requestSelfDamage(0)
                            until Lagger["Enabled"] == false
                        end)
                    until Lagger["Enabled"] == false
                end)
            end
        end,
    })
end

do 
    local old, old2, old3 = dependencies.HighlightController.highlight, dependencies.DamageIndicatorController.spawnDamageIndicator, dependencies.WorldIndicatorController.addIndicator
    local Lagger = {["Enabled"] = false}; Lagger = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AntiFPSLagger",
        ["Function"] = function(callback) 
            if callback then 
                dependencies.HighlightController.highlight = function(...) end
                dependencies.WorldIndicatorController.addIndicator = function(...) end
                dependencies.DamageIndicatorController.spawnDamageIndicator = function(...) end
            else
                dependencies.HighlightController.highlight = old
                dependencies.WorldIndicatorController.addIndicator = old2
                dependencies.DamageIndicatorController.spawnDamageIndicator = old3
            end
        end,
    })
end