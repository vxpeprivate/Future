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
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) or (plr.Character:FindFirstChild("HumanoidRootPart"))) then
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
    if v.Team ~= nil then return v.TeamColor end
end

-- // CombatWindow

local ReachHitBoxes = {["Value"] = 1}
local ReachHitBoxesPart = {["Value"] = "Root"}
local Reach = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
    ["Name"] = "Reach",
    ["Function"] = function(callback) 
        if callback then 
            BindToStepped("Reach", function() 
                local part = ReachHitBoxesPart.Value == "Root" and "HumanoidRootPart" or "Head"
                for i,v in next, PLAYERS:GetPlayers() do 
                    if isAlive(v) and v~=lplr then 
                        v.Character:FindFirstChild(part).Size = Vector3.new(ReachHitBoxes.Value + 2, ReachHitBoxes.Value + 2, ReachHitBoxes.Value + 2)
                    end
                end
            end)
        else
            UnbindFromStepped("Reach")
            for i,v in pairs(PLAYERS:GetPlayers()) do
				if isAlive(v) then
					v.Character:FindFirstChild("Head").Size = Vector3.new(1, 1, 1)
                    v.Character:FindFirstChild("HumanoidRootPart").Size = Vector3.new(2, 2, 1)
				end
			end
        end
    end,
})
ReachHitBoxesPart = Reach.CreateSelector({
    ["Name"] = "HitboxPart",
    ["List"] = {"Root", "Head"},
    ["Function"] = function() end,
})
ReachHitBoxes = Reach.CreateSlider({
    ["Name"] = "HitboxAdd",
    ["Min"] = 1,
    ["Max"] = 20,
    ["Round"] = 1, 
    ["Function"] = function() end,
})

-- // ExploitsWindow

local fakelagsend = {["Enabled"] = false}
local fakelagreceive = {["Enabled"] = false}
local fakelag = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
    ["Name"] = "FakeLag",
    ["Function"] = function(callback) 
        if callback then
            if fakelagsend["Enabled"] then 
                BindToHeartbeat("SendFakeLag", function() 
                    if isAlive() then
                        sethiddenproperty(lplr.Character.HumanoidRootPart, "NetworkIsSleeping", true)
                    end
                end)
            end
            if fakelagreceive["Enabled"] then 
                settings().Network.IncomingReplicationLag = 99999999999999999
            end
        else
            settings().Network.IncomingReplicationLag = 0
            UnbindFromHeartbeat("SendFakeLag")
        end
    end,
})
fakelagsend = fakelag.CreateToggle({
    ["Name"] = "Sending",
    ["Function"] = function() end,
})
fakelagreceive = fakelag.CreateToggle({
    ["Name"] = "Recieving",
    ["Function"] = function() end,
})

local mouseconnection
local ClickTP = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
    ["Name"] = "ClickTP",
    ["Function"] = function(callback) 
        if callback then 
            mouseconnection = mouse.Button1Down:Connect(function()
                if isAlive() and mouse.Target then 
                    lplr.Character.HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
                end
            end)
        else
            if mouseconnection then 
                mouseconnection:Disconnect()
                mouseconnection = nil
            end
        end
    end
})

-- // MovementWindow

local speedval = {["Value"] = 40}
local speed = {["Enabled"] = false}
speed = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
    ["Name"] = "Speed",
    ["Function"] = function(callback)
        if callback then
            BindToStepped("Speed", function()
                if isAlive() then
                    local velo = lplr.Character.Humanoid.MoveDirection * speedval["Value"]
                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(velo.x, lplr.Character.HumanoidRootPart.Velocity.y, velo.z)
                end
            end)
        else
            UnbindFromStepped("Speed")
        end
    end
})
speedval = speed.CreateSlider({
    ["Name"] = "Speed",
    ["Min"] = 1,
    ["Max"] = 150,
    ["Round"] = 0,
    ["Function"] = function() end
})

local flyup
local flydown
local flydownconnection
local flyupconnection
local vertspeed = {["Value"] = 40}
local verttoggle = {["Enabled"] = false}
local vertbind = {["Value"] = "LShift"}
local flyspeed = {["Value"] = 40}
local fly = {["Enabled"] = false}
fly = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
    ["Name"] = "Flight",
    ["Function"] = function(callback)
        if callback then
            BindToStepped("Fly", function()
                if isAlive() then
                    local updirection = 0
                    if UIS:GetFocusedTextBox()==nil then
                        updirection = flyup and vertspeed["Value"] or flydown and -vertspeed["Value"] or 0
                    end
                    local MoveDirection = lplr.Character.Humanoid.MoveDirection * flyspeed["Value"]
                    lplr.Character.HumanoidRootPart.Velocity = Vector3.new(MoveDirection.X, verttoggle["Enabled"] and (updirection) or 0, MoveDirection.z)
                end
            end)
            flyupconnection = UIS.InputBegan:connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    flyup = true
                end
                if input.KeyCode == (vertbind.Value == "LShift" and Enum.KeyCode.LeftShift or Enum.KeyCode.LeftControl) then
                    flydown = true
                end
            end)
            flydownconnection = UIS.InputEnded:connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    flyup = false
                end
                if input.KeyCode == (vertbind.Value == "LShift" and Enum.KeyCode.LeftShift or Enum.KeyCode.LeftControl) then
                    flydown = false
                end
            end)
        else
            flyup = false
            flydown = false
            UnbindFromStepped("Fly")
            if flyupconnection then
                flyupconnection:Disconnect()
                flyupconnection=nil
            end
            if flydownconnection then
                flydownconnection:Disconnect()
                flydownconnection=nil
            end
        end
    end
})
flyspeed = fly.CreateSlider({
    ["Name"] = "Speed",
    ["Min"] = 1,
    ["Max"] = 300,
    ["Function"] = function() end
})
verttoggle = fly.CreateToggle({
    ["Name"] = "Vertical",
    ["Function"] = function() end
})
vertbind = fly.CreateSelector({
    ["Name"] = "VBind",
    ["Function"] = function() end,
    ["List"] = {"LShift", "LCtrl"},
})
vertspeed = fly.CreateSlider({
    ["Name"] = "VSpeed",
    ["Min"] = 1,
    ["Max"] = 300,
    ["Function"] = function() end
})

local oldJumpPower
local HighJumpHeight = {["Value"] = 0}
local HighJumpMode = {["Value"] = "Normal"}
local highjumpconnection
local HighJump = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
    ["Name"] = "HighJump",
    ["Function"] = function(callback) 
        if callback then 
            spawn(function()
                repeat wait() until isAlive() or not HighJump["Enabled"]
                highjumpconnection = lplr.Character.Humanoid.Jumping:Connect(function() 
                    if HighJumpMode["Value"] == "Velocity" then 
                        lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, lplr.Character.HumanoidRootPart.Velocity.Y + HighJumpHeight["Value"], lplr.Character.HumanoidRootPart.Velocity.Z)
                    elseif HighJumpMode["Value"] == "TP" then
                        lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0,HighJumpHeight["Value"],0)
                    end
                end)
            end)
        else
            if highjumpconnection then 
                highjumpconnection:Disconnect()
                highjumpconnection = nil
            end
        end
    end
})
HighJumpMode = HighJump.CreateSelector({
    ["Name"] = "Mode",
    ["Function"] = function() 
    end,
    ["List"] = {"TP", "Velocity"}
})
HighJumpHeight = HighJump.CreateSlider({
    ["Name"] = "Height",
    ["Min"] = 1, 
    ["Max"] = 100, 
    ["Default"] = 25,
    ["Round"] = 0,
    ["Function"] = function() end
})
 
-- // renderwindow

local CHAMS = {["Enabled"] = false}
local CHAMSOutline = {["Enabled"] = false}
local CHAMSWalls = {["Enabled"] = false}
local ChamsFolder = Instance.new("Folder", GuiLibrary["ScreenGui"])
local CHAMSTransparency = {["Value"] = 0}
local CHAMSTeamCheck = {["Enabled"] = true}
ChamsFolder:ClearAllChildren()
CHAMS = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
    ["Name"] = "Chams",
    ["Function"] = function(callback) 
        if callback then
            BindToStepped("Chams", function()
                for i,v in next, PLAYERS:GetPlayers() do 
                    if isAlive(v) and v~=lplr and (CHAMSTeamCheck["Enabled"] and v.Team ~= lplr.Team or not CHAMSTeamCheck["Enabled"]) then
                        local highlight
                        if not ChamsFolder:FindFirstChild(v.Name) then
                            highlight = Instance.new("Highlight", ChamsFolder)
                        else
                            highlight = ChamsFolder:FindFirstChild(v.Name)
                        end
                        highlight.Adornee = v.Character
                        highlight.Name = v.Name
                        highlight.FillColor = CHAMSTeamCheck["Enabled"] and getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                        highlight.OutlineColor = GuiLibrary["GetColor"]()
                        highlight.OutlineTransparency = CHAMSOutline["Enabled"] and 0 or 1
                        highlight.FillTransparency = CHAMSTransparency["Value"]/100
                        highlight.DepthMode = CHAMSWalls["Enabled"] and 1 or 0
                    end
                end
            end)
        else
            ChamsFolder:ClearAllChildren()
            UnbindFromStepped("Chams")
        end
    end,
})
CHAMSTransparency = CHAMS.CreateSlider({
    ["Name"] = "Transparency",
    ["Function"] = function() end,
    ["Min"] = 0,
    ["Max"] = 100,
    ["Default"] = 0,
    ["OnInputEnded"] = true
})
CHAMSOutline = CHAMS.CreateToggle({
    ["Name"] = "Outline",
    ["Function"] = function() end
}) 
CHAMSTeamCheck = CHAMS.CreateToggle({
    ["Name"] = "TeamCheck",
    ["Function"] = function() end,
})
CHAMSWalls = CHAMS.CreateToggle({
    ["Name"] = "WallCheck",
    ["Function"] = function() end
})

-- // WorldWindow

local cachedparts = {}
local wallhackopacity = {["Value"] = 0}
local Wallhack = {["Enabled"] = false}
local WallhackConnection
local function refreshwallhack(callback) 
    if Wallhack.Enabled or callback==true then
        for i,v in next, WORKSPACE:GetDescendants() do 
            if v:IsA("BasePart") then
                table.insert(cachedparts, v)
                v.LocalTransparencyModifier = wallhackopacity["Value"] / 255
            end
        end
    end
end
Wallhack = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
    ["Name"] = "Wallhack",
    ["Function"] = function(callback) 
        if callback then 
            refreshwallhack(true)
            WallhackConnection = WORKSPACE.DescendantAdded:Connect(function(v) 
                if v:IsA("BasePart") and not table.find(cachedparts, v) then 
                    table.insert(cachedparts, v)
                    v.LocalTransparencyModifier = wallhackopacity["Value"] / 255
                end
            end)
        else
            for i,v in next, cachedparts do 
                v.LocalTransparencyModifier = 0
                cachedparts[i] = nil
            end
            if WallhackConnection then 
                WallhackConnection:Disconnect() 
                WallhackConnection = nil 
            end
        end
    end,
})
wallhackopacity = Wallhack.CreateSlider({
    ["Name"] = "Opacity",
    ["Function"] = function(value)
        refreshwallhack()
    end,
    ["Min"] = 0,
    ["Max"] = 255
})
