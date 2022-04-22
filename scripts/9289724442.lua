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

local function getColorFromPlayer(v) 
    if v.Team ~= nil then return v.TeamColor.Color end
end
 
local function getPlrProps() 
    local p = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and (v.Character:FindFirstChild("Head") == nil or (v.Team ~= nil and v.Team.Name == "Hider")) then 
            p[v.Name] = v.Character
        end
    end
    return p
end

local function isProp(plr) 
    return plr.Team ~= nil and plr.Team.Name == "Hider"
end

setsimulationradius(1000000000) -- // cool thing for network ownership kek

local function forceReset() 
    local requestSelfDamage = game:GetService("ReplicatedStorage")["events-@easy-games/damage:shared/damage-networking@DamageNetEvents"].requestSelfDamage
    requestSelfDamage:FireServer(1000)
end

local function killall() 
    for i = 1, 10 do 
        for i,v in next, getPlrProps() do 
            pcall(function()
                local args = {
                    [1] = lplr.Character.HumanoidRootPart.CFrame.p,
                    [2] = CFrame.lookAt(lplr.Character.HumanoidRootPart.CFrame.p, v.HumanoidRootPart.CFrame.p).lookVector * (v.HumanoidRootPart.CFrame.p - lplr.Character.HumanoidRootPart.CFrame.p).magnitude,
                    [3] = {
                        ["instance"] = v.HumanoidRootPart,
                        ["normal"] = Vector3.new(1, 0, 0),
                        ["position"] = v.HumanoidRootPart.Position
                    },
                    [4] = 0,
                    [5] = false
                }
                game:GetService("ReplicatedStorage")["events-shared/networking@NetEvents"].shoot:FireServer(unpack(args))
            end)
        end
    end
end

do 
    local PropKill = {["Enabled"] = false}; PropKill = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoWin",
        ["Function"] = function(callback) 
            spawn(function()
                repeat task.wait(0.05) 
                    if isAlive() then
                        if lplr.Team ~= nil and (lplr.Team.Name:find("Hider")) then 
                            forceReset()
                        elseif lplr.Team ~= nil then
                            killall()
                            if (state() == 2) then 
                                game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({["queueType"] = "vanilla"})
                                break
                            end
                        end
                    end
                until PropKill["Enabled"] == false
            end)
        end
    })
end

