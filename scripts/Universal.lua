repeat wait() until game:IsLoaded()
local GuiLibrary = shared.Future.GuiLibrary
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WORKSPACE = game:GetService("Workspace")
local PLAYERS = game:GetService("Players")
local COREGUI = game:GetService("CoreGui")
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
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) and (plr.Character:FindFirstChild("HumanoidRootPart"))) then
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
local function BindToRenderStepped(name, func)
	if RenderStepTable[name] == nil then
		RenderStepTable[name] = game:GetService("RunService").RenderStepped:connect(func)
	end
end
local function UnbindFromRenderStepped(name)
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

local function getCharacters() 
    local t = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) then
            t[v.Name] = v.Character
        end
    end
    return t
end

local function getColorFromPlayer(v) 
    if v.Team ~= nil then return v.TeamColor.Color end
end

local function getPlrNearMouse(max)
    local max = max or 99999999999999
    local nearestval, nearestnum = nil,max
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local pos, vis = WORKSPACE.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            if vis and pos then 
                local diff = (UIS:GetMouseLocation() - Vector2.new(pos.X, pos.Y)).Magnitude
                if diff < nearestnum then 
                    nearestnum = diff 
                    nearestval = v
                end
            end
        end
    end
    return nearestval
end

local function getAimAt(pos)
    return WORKSPACE.CurrentCamera:WorldToScreenPoint(pos)
end

local function aimAt(pos,smooth)
    local smooth = smooth +1
    local targetPos = WORKSPACE.CurrentCamera:WorldToScreenPoint(pos)
    local mousePos = WORKSPACE.CurrentCamera:WorldToScreenPoint(mouse.Hit.p)
    mousemoverel((targetPos.X-mousePos.X)/smooth,(targetPos.Y-mousePos.Y)/smooth)
end


-- // CombatWindow

do 
    local smoothaim = {["Enabled"] = false}
    local smoothaimfov = {["Value"] = 40 }
    local smoothaimsmoothness = {["Value"] = 0}
    local smoothaimpart = {["Value"] ="Root"}
    local smoothaimheld = {["Value"] = "LMB"}

    smoothaim = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "SmoothAim",
        ["Function"] = function(callback) 
            if callback then 
                BindToStepped("SmoothAim", function() 
                    local aimpart = smoothaimpart["Value"] == "Root" and "HumanoidRootPart" or "Head"
                    local plr = getPlrNearMouse(smoothaimfov["Value"] * 10)
                    if plr and isAlive(plr) and UIS:IsMouseButtonPressed(smoothaimheld["Value"] == "LMB" and 0 or 1) then 
                        aimAt(plr.Character[aimpart].Position, smoothaimsmoothness["Value"])
                    end
                end)
            else
                UnbindFromStepped("SmoothAim")
            end
        end
    })
    smoothaimpart = smoothaim.CreateSelector({
        ["Name"] = "Part",
        ["Function"] = function() end, 
        ["List"] = {"Root", "Head"}
    })
    smoothaimheld = smoothaim.CreateSelector({
        ["Name"] = "Held",
        ["Function"] = function() end, 
        ["List"] = {"LMB", "RMB"}
    })
    smoothaimsmoothness = smoothaim.CreateSlider({
        ["Name"] = "Smoothness",
        ["Function"] = function(value) end,
        ["Min"] = 1,
        ["Max"] = 50,
        ["Round"] = 0,
    })
    smoothaimfov = smoothaim.CreateSlider({
        ["Name"] = "FOV",
        ["Function"] = function() end,
        ["Min"] = 1,
        ["Max"] = 100,
        ["Round"] = 0,
    })
end

-- // ExploitsWindow

do 
    local phase = {["Enabled"] = false}
    local phasemode = {["Value"] = ""}
    local phaseconnection 
    local cachedparts = {}

    phase = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Phase",
        ["Function"] = function(callback) 
            if callback then 
                if phasemode["Value"] == "Normal" then
                    if isAlive() then
                        for i,v in next, lplr.Character:GetDescendants() do 
                            if v:IsA("BasePart") then 
                                v.CanCollide = false
                            end
                        end
                    end
                else
                    BindToStepped("Phase", function() 
                        if isAlive() then
                            local raycastparameters = RaycastParams.new()
                            raycastparameters.FilterType = Enum.RaycastFilterType.Blacklist
                            raycastparameters.FilterDescendantsInstances = getCharacters()
                            local ray = WORKSPACE:Raycast(lplr.Character.HumanoidRootPart.CFrame.Position, lplr.Character.Humanoid.MoveDirection, raycastparameters)
                            local dir = (ray and ray.Normal.Z ~= 0) and "Z" or "X"
                            if ray and ray.Instance and ray.Instance.Size[dir] < 5 then 
                                lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + (ray.Normal * (-(ray.Instance.Size[dir]) - 2))
                            end
                        end
                    end)
                end
            else
                for i,v in next, cachedparts do 
                    v.part.CanCollide = v.old
                end
                cachedparts = {}
                UnbindFromStepped("Phase")
            end
        end,
    })
    phasemode = phase.CreateSelector({
        ["Name"] = "Mode",
        ["Function"] = function()
            if phase.Enabled then
                phase.Toggle()
                phase.Toggle()
            end
        end,
        ["List"] = {"Normal", "AC"}
    })
end

do
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
end

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

-- // MiscWindow
do 
    local AntiAFK = GuiLibrary["Objects"]["MiscellaneousWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AntiAFK",
        ["Function"] = function(callback) 
            if callback then 
                for i,v in next, getconnections(lplr.Idled) do
                    v:Disable()
                end
            else
                for i,v in next, getconnections(lplr.Idled) do
                    v:Enable()
                end
            end
        end,
    })
end 

do 
    local bav
    local antiaimspeed = {["Value"] = 0}
    local function createbav() 
        spawn(function() 
            repeat wait() until isAlive()
            bav = bav or Instance.new("BodyAngularVelocity", lplr.Character.HumanoidRootPart)
            bav.AngularVelocity = Vector3.new(0, antiaimspeed["Value"], 0)
            bav.MaxTorque = Vector3.new(0, 9999999999999999999999, 0)
        end)
    end
    local antiaimcharadded
    local AntiAim = GuiLibrary["Objects"]["MiscellaneousWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AntiAim",
        ["Function"] = function(callback) 
            if callback then 
                createbav()
                antiaimcharadded = lplr.CharacterAdded:connect(createbav)
            else
                if antiaimcharadded then 
                    antiaimcharadded:Disconnect()
                    antiaimcharadded = nil
                end
                if bav then 
                    bav:Destroy()
                    bav = nil
                end
            end
        end,
    })
    antiaimspeed = AntiAim.CreateSlider({
        ["Name"] = "Speed",
        ["Function"] = function(value)
            if bav then bav.AngularVelocity = Vector3.new(0, value, 0) end
        end,
        ["Min"] = 1,
        ["Max"] = 100,
        ["Round"] = 0,
    })
end

do 
    local autoreconnectdelay = {["Value"] = 0}
    local AutoReconnect={["Enabled"] = false}; AutoReconnect = GuiLibrary["Objects"]["MiscellaneousWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoReconnect",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function() 
                    repeat wait() until AutoReconnect["Enabled"]==false or #COREGUI.RobloxPromptGui.promptOverlay:GetChildren() ~= 0
                    if AutoReconnect["Enabled"] then 
                        wait(autoreconnectdelay["Value"])
                        game:GetService("TeleportService"):Teleport(game.PlaceId)
                    end
                end)
            end
        end,
    })
    autoreconnectdelay = AutoReconnect.CreateSlider({
        ["Name"] = "Delay (s)",
        ["Function"] = function(value) end,
        ["Min"] = 0,
        ["Max"] = 30,
        ["Round"] = 0,
    })
end

do 
    local spammer = {["Enabled"] = false}
    local spammerdelay = {["Value"] = 0}
    local spammerfile = {["Value"] = ""}
    local messagetable = {}
    local looping
    spammer = GuiLibrary["Objects"]["MiscellaneousWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Spammer",
        ["Function"] = function(callback)
            if callback then
                if spammerfile["Value"] ~= "" and isfile("Future/"..spammerfile["Value"]) then
                    messagetable = readfile(("Future/"..spammerfile["Value"])):split("\n")
                    if not looping then
                        spawn(function() 
                            repeat 
                                if spammer["Enabled"] then
                                    local v = messagetable[
                                        math.random(1, #messagetable)
                                    ]   
                                    if v~= nil and v~="" then
                                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(v:gsub("%s+", ""),"All")
                                        wait(spammerdelay["Value"])
                                    end
                                else
                                    wait()
                                end
                            until shared.Future == nil
                        end)
                        looping = true
                    end
                elseif spammer["Enabled"] then
                    local value = value==nil and "" or value
                    fprint("Future/"..value.." is not a valid file, please make sure it is in your workspace folder and you include the file extension")
                end
            end
        end
    })
    spammerfile = spammer.CreateTextbox({
        ["Name"] = "file.txt",
        ["Function"] = function(value)
            if value ~= "" and isfile("Future/"..value) then 
                messagetable = readfile(("Future/"..value)):split("\n")
                if spammer["Enabled"] then 
                    spammer.Toggle(nil, true)
                    spammer.Toggle(nil, true)
                end
            elseif value ~= "" and spammer.Enabled then
                fprint("Future/"..value.." is not a valid file, please make sure it is in your workspace folder and you include the file extension")
            end
        end
    })
    spammerdelay = spammer.CreateSlider({
        ["Name"] = "Delay (s)",
        ["Function"] = function(value) end,
        ["Min"] = 0,
        ["Max"] = 30,
        ["Round"] = 0,
    })
end

-- // MovementWindow

do 
    local autowalk = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoWalk",
        ["Function"] = function(callback) 
            if callback then 
                BindToRenderStepped("AutoWalk", function()
                    if isAlive() then
                        lplr.Character.Humanoid:Move(Vector3.new(0, 0, -1), true)
                    end
                end)
            else
                UnbindFromRenderStepped("AutoWalk")
            end
        end
    })
end

do 
    local oldmovefunc
    local safewalk = {["Enabled"] = false}
    safewalk = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "SafeWalk",
        ["Function"] = function(callback) 
            if callback then 
                local controls = require(lplr.PlayerScripts.PlayerModule).controls
                oldmovefunc = controls.moveFunction
                controls.moveFunction = function(self, movedir, ...)
                    if isAlive() then
                        local param = RaycastParams.new()
                        param.FilterDescendantsInstances = getCharacters()
                        param.FilterType = Enum.RaycastFilterType.Blacklist
                        local ray = WORKSPACE:Raycast(lplr.Character.HumanoidRootPart.Position + (movedir*2), Vector3.new(0, -9999999999, 0), param)
                        if ray == nil then 
                            movedir = Vector3.new(0,0,0)
                        end
                    end
                    return oldmovefunc(self, movedir, ...)
                end
            else
                if oldmovefunc then
                    local controls = require(lplr.PlayerScripts.PlayerModule).controls
                    controls.moveFunction = oldmovefunc
                end
            end
        end
    })
end

do
    local speedval = {["Value"] = 40}
    local speedmode = {["Enabled"] = false}
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
end

do
    local flyup
    local flydown
    local flydownconnection
    local flyupconnection
    local vertspeed = {["Value"] = 40}
    local verttoggle = {["Enabled"] = false}
    local vertbind = {["Value"] = "LShift"}
    local flyspeed = {["Value"] = 40}
    local flyglide = {["Value"] = 10}
    local fly = {["Enabled"] = false}
    fly = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Flight",
        ["Function"] = function(callback)
            if callback then
                BindToStepped("Fly", function()
                    if isAlive() then
                        local updirection = 1.125 - flyglide["Value"]
                        if UIS:GetFocusedTextBox()==nil then
                            updirection = flyup and vertspeed["Value"] or flydown and -vertspeed["Value"] or 1.125 - flyglide["Value"]
                        end
                        local MoveDirection = lplr.Character.Humanoid.MoveDirection * flyspeed["Value"]
                        lplr.Character.HumanoidRootPart.Velocity = Vector3.new(MoveDirection.X, verttoggle["Enabled"] and (updirection) or 1.125 - flyglide["Value"], MoveDirection.Z)
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
                end
                if flydownconnection then
                    flydownconnection:Disconnect()
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
    flyglide = fly.CreateSlider({
        ["Name"] = "Glide",
        ["Min"] = -100,
        ["Max"] = 100,
        ["Function"] = function() end
    })
end

do
    local oldJumpPower
    local HighJumpHeight = {["Value"] = 0}
    local HighJumpMode = {["Value"] = "Normal"}
    local highjumpconnection
    local HighJump = {["Enabled"] = false}
    HighJump = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "HighJump",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    repeat wait() until isAlive() or not HighJump["Enabled"]
                    if HighJump["Enabled"] then
                        highjumpconnection = lplr.Character.Humanoid.Jumping:Connect(function() 
                            if HighJumpMode["Value"] == "Velocity" then 
                                lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, lplr.Character.HumanoidRootPart.Velocity.Y + HighJumpHeight["Value"], lplr.Character.HumanoidRootPart.Velocity.Z)
                            elseif HighJumpMode["Value"] == "TP" then
                                lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0,HighJumpHeight["Value"],0)
                            end
                        end)
                    end
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
end
 
do 
    local LongJumpThrust
    local LongJumpPower = {["Value"] = 0}
    local LongJumpMode = {["Value"] = "Normal"}
    local LongJumpconnection
    local LongJump = {["Enabled"] = false}
    LongJump = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "LongJump",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    repeat wait() until isAlive() or not LongJump["Enabled"]
                    if LongJump["Enabled"] then
                        if LongJumpMode["Value"]:find("Velo") then 
                            LongJumpconnection = lplr.Character.Humanoid.Jumping:Connect(function(  ) 
                                local old = lplr.Character.HumanoidRootPart.Velocity
                                local new = (old * LongJumpPower["Value"]) / 2.5
                                local y = LongJumpMode["Value"] == "VeloFlat" and old.Y / 2 or old.Y
                                lplr.Character.HumanoidRootPart.Velocity = Vector3.new(new.X, y, new.X)
                            end)
                        elseif LongJumpMode["Value"] == "Normal" then
                            LongJumpThrust = Instance.new("BodyThrust")
                            LongJumpThrust.Force = Vector3.new(0, -1500, -(LongJumpPower["Value"] * 750))
                            LongJumpThrust.Parent = lplr.Character.HumanoidRootPart
                        end
                    end
                end)
            else
                if LongJumpconnection then 
                    LongJumpconnection:Disconnect()
                    LongJumpconnection = nil
                end
                if LongJumpThrust then 
                    LongJumpThrust:Destroy()
                    LongJumpThrust = nil
                end
            end
        end
    })
    LongJumpMode = LongJump.CreateSelector({
        ["Name"] = "Mode",
        ["Function"] = function() 
            if LongJump["Enabled"] then 
                for i = 1, 2 do 
                    LongJump.Toggle(nil, true)
                end
            end
        end,
        ["List"] = {"Normal", "Velo", "VeloFlat"}
    })
    LongJumpPower = LongJump.CreateSlider({
        ["Name"] = "Power",
        ["Min"] = 1, 
        ["Max"] = 10, 
        ["Default"] = 2,
        ["Round"] = 0,
        ["Function"] = function() end
    })
end

-- // renderwindow

do 
    local breadcrumbs = {["Enabled"] = false}
    local breadcrumbsmode = {["Value"] = "Ball"}
    local breadcrumbsfolder = Instance.new("Folder", WORKSPACE)
    local breadcrumbstransparency = {["Value"] = 0}
    local breadcrumbstimeout = {["Value"] = 0}
    local cachedpos

    local breadcrumbstrail
    local breadcrumbsconnection
    local attachment1, attachment2

    breadcrumbs = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Breadcrumbs",
        ["Function"] = function(callback) 
            --// line mode:
            if callback and breadcrumbsmode["Value"] == "Line" then 
                spawn(function()
                    repeat wait() until isAlive()
                    breadcrumbstrail = Instance.new("Trail", lplr.Character.HumanoidRootPart)
                    breadcrumbstrail.Color = ColorSequence.new(GuiLibrary.GetColor(), GuiLibrary.GetColor())
                    GuiLibrary["Signals"]["UpdateColor"]:connect(function() 
                        if breadcrumbstrail then
                            breadcrumbstrail.Color = ColorSequence.new(GuiLibrary.GetColor(), GuiLibrary.GetColor())
                        end
                    end)
                    attachment1, attachment2 = Instance.new("Attachment", lplr.Character.HumanoidRootPart), Instance.new("Attachment", lplr.Character.HumanoidRootPart)
                    attachment1.Position = Vector3.new(0,-1.4,0)
                    attachment2.Position = Vector3.new(0,-1.6,0)
                    breadcrumbstrail.Attachment0 = attachment1
                    breadcrumbstrail.Attachment1 = attachment2
                    breadcrumbstrail.Lifetime = breadcrumbstimeout["Value"]
                    breadcrumbstrail.Transparency = NumberSequence.new(math.clamp(breadcrumbstransparency["Value"]/100 - 0.1, 0, 1), math.clamp(breadcrumbstransparency["Value"]/100 + 0.1, 0, 1))
                    breadcrumbstrail.WidthScale = NumberSequence.new(1,1)
                    breadcrumbsconnection = lplr.CharacterAdded:connect(function()
                        repeat wait() until isAlive()
                        breadcrumbstrail.Parent = lplr.Character.HumanoidRootPart
                    end)
                end)
            else
                if breadcrumbsconnection then 
                    breadcrumbsconnection:Disconnect()
                    breadcrumbsconnection = nil
                end
                if breadcrumbstrail then 
                    breadcrumbstrail:Destroy()
                    breadcrumbstrail = nil
                end
                if attachment1 then 
                    attachment1:Destroy()
                    attachment1 = nil
                end
                if attachment2 then 
                    attachment2:Destroy()
                    attachment2 = nil
                end
            end
            -- // ball mode:
            if breadcrumbsmode["Value"] == "Ball" then
                spawn(function()
                    repeat wait()
                        if isAlive() and (cachedpos ~= nil and (lplr.Character.HumanoidRootPart.Position - cachedpos).Magnitude > 1.5 or cachedpos==nil) and breadcrumbsmode["Value"] == "Ball" then
                            cachedpos = lplr.Character.HumanoidRootPart.Position
                            local newBreadcrumb = Instance.new("Part", breadcrumbsfolder)
                            local newBreadcrumbSS = Instance.new("SelectionSphere", newBreadcrumb)
                            newBreadcrumb.Anchored = true
                            newBreadcrumb.CFrame = lplr.Character.HumanoidRootPart.CFrame - Vector3.new(0, 1.5, 0)
                            newBreadcrumb.CanCollide = false
                            newBreadcrumb.Size = Vector3.new(0,0,0)
                            newBreadcrumb.Transparency = 1 
                            newBreadcrumbSS.Transparency = breadcrumbstransparency["Value"]/100
                            newBreadcrumbSS.Adornee = newBreadcrumb
                            newBreadcrumbSS.Color3 = GuiLibrary["GetColor"]()
                            GuiLibrary["Signals"]["UpdateColor"]:connect(function(color) 
                                newBreadcrumbSS.Color3 = GuiLibrary["GetColor"]()
                            end)
                            game:GetService("Debris"):AddItem(newBreadcrumb, breadcrumbstimeout["Value"])
                        end
                    until breadcrumbs["Enabled"] == false
                    breadcrumbsfolder:ClearAllChildren()
                end)
            end
        end,
    })

    breadcrumbsmode = breadcrumbs.CreateSelector({
            ["Name"] = "Mode",
            ["Function"] = function()
                if breadcrumbs["Enabled"] then 
                    breadcrumbs.Toggle(nil, true)
                    breadcrumbs.Toggle(nil ,true)
                end
            end,
            ["List"] = {"Ball", "Line"}
        })

    breadcrumbstransparency = breadcrumbs.CreateSlider({
        ["Name"] = "Transparency",
        ["Function"] = function(value) 
            for i,v in next, breadcrumbsfolder:GetChildren() do
                v:FindFirstChildOfClass("SelectionSphere").Transparency = value/100
            end
            if breadcrumbstrail then 
                breadcrumbstrail.Transparency = NumberSequence.new(math.clamp(breadcrumbstransparency["Value"]/100 - 0.1, 0, 1), math.clamp(breadcrumbstransparency["Value"]/100 + 0.1, 0, 1))
            end
        end,
        ["Min"] = 0, ["Max"] = 100, ["Round"] = 0, ["Default"] = 0
    })

    breadcrumbstimeout = breadcrumbs.CreateSlider({
        ["Name"] = "Timeout",
        ["Function"] = function(value) 
        
        end,
        ["Min"] = 0, ["Max"] = 120, ["Round"] = 1, ["Default"] = 5
    })
end



do
    local chams = {["Enabled"] = false}
    local chamsoutline = {["Enabled"] = false}
    local chamswalls = {["Enabled"] = false}
    local chamsfolder = Instance.new("Folder", GuiLibrary["ScreenGui"]); chamsfolder.Name = "Chams"
    local chamstransparency = {["Value"] = 0}
    local chamsteamcheck = {["Enabled"] = true}
    local chamslplr = {["Enabled"] = false}

    local chamsplayeraddedconnection
    local chamsplayerremovingconnection
    local chamscharacteraddedconnections = {}

    local function addHighlight(plr)
        spawn(function()
            repeat wait() until isAlive(plr)
            if (chamsteamcheck["Enabled"] and plr.Team ~= lplr.Team or not chamsteamcheck["Enabled"]) and (not chamslplr["Enabled"] and plr ~= lplr or chamslplr["Enabled"]) then
                local highlight
                if not chamsfolder:FindFirstChild(plr.Name) then
                    highlight = Instance.new("Highlight", chamsfolder)
                else
                    highlight = chamsfolder:FindFirstChild(plr.Name)
                end
                highlight.Adornee = plr.Character
                highlight.Name = plr.Name
                highlight.FillColor = chamsteamcheck["Enabled"] and getColorFromPlayer(plr) or GuiLibrary["GetColor"]()
                GuiLibrary["Signals"]["UpdateColor"]:connect(function()
                    highlight.FillColor = chamsteamcheck["Enabled"] and getColorFromPlayer(plr) or GuiLibrary["GetColor"]()
                end)
                highlight.OutlineColor = Color3.new(1,1,1)
                highlight.OutlineTransparency = chamsoutline["Enabled"] and 0 or 1
                highlight.FillTransparency = chamstransparency["Value"]/100
                highlight.DepthMode = chamswalls["Enabled"] and 1 or 0
            end
        end)
    end

    local function removeHighlight(plr) 
        if chamsfolder:FindFirstChild(plr.Name) then 
            chamsfolder:FindFirstChild(plr.Name):Destroy()
        end
    end

    chams = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Chams",
        ["Function"] = function(callback) 
            if callback then
                for i,v in next, PLAYERS:GetPlayers() do 
                    addHighlight(v)
                    chamscharacteraddedconnections[v.Name] = v.CharacterAdded:connect(function(char) 
                        addHighlight(v)
                    end)
                end 
                chamsplayeraddedconnection = PLAYERS.PlayerAdded:connect(function(plr)
                    addHighlight(plr)
                    chamscharacteraddedconnections[plr.Name] = plr.CharacterAdded:connect(function(char) 
                        addHighlight(plr)
                    end)
                end)
                chamsplayerremovingconnection = PLAYERS.PlayerRemoving:connect(function(plr) 
                    removeHighlight(plr)
                end)
            else
                if chamsplayeraddedconnection then
                    chamsplayeraddedconnection:Disconnect()
                    chamsplayeraddedconnection = nil
                end
                if chamsplayerremovingconnection then
                    chamsplayerremovingconnection:Disconnect()
                    chamsplayerremovingconnection = nil
                end
                if #chamscharacteraddedconnections > 0 then 
                    for i,v in next, chamscharacteraddedconnections do 
                        v:Disconnect()
                        chamscharacteraddedconnections[i] = nil
                    end
                end
                chamscharacteraddedconnections = {}
                chamsfolder:ClearAllChildren()
            end
        end,
    })
    chamstransparency = chams.CreateSlider({
        ["Name"] = "Transparency",
        ["Function"] = function()
            for i,v in next, chamsfolder:GetChildren() do
                if v:IsA("Highlight") then
                    v.FillTransparency = chamstransparency["Value"]/100
                end
            end
        end,
        ["Min"] = 0,
        ["Max"] = 100,
        ["Default"] = 0,
        ["OnInputEnded"] = false
    })
    chamsoutline = chams.CreateToggle({
        ["Name"] = "Outline",
        ["Function"] = function(callback)
            for i,v in next, chamsfolder:GetChildren() do
                if v:IsA("Highlight") then
                    v.OutlineTransparency = callback and 0 or 1
                end
            end
        end
    }) 
    chamsteamcheck = chams.CreateToggle({
        ["Name"] = "TeamCheck",
        ["Function"] = function() end,
        ["Default"] = true
    })
    chamswalls = chams.CreateToggle({
        ["Name"] = "WallCheck",
        ["Function"] = function(callback) 
            for i,v in next, chamsfolder:GetChildren() do
                if v:IsA("Highlight") then
                    v.DepthMode = callback and 1 or 0
                end
            end
        end
    })
    chamslplr = chams.CreateToggle({
        ["Name"] = "Self",
        ["Function"] = function(callback)
            local func = callback and addHighlight or removeHighlight
            if chams.Enabled then
                func(lplr)
            end
        end,
    })
end


--[[ 
     - TODO -
    
// add team check and team color toggles

]]
do 
    local esp = {["Enabled"] = false}
    local espfolder = Instance.new("Folder", GuiLibrary["ScreenGui"])
    local espnames= {["Enabled"] = false}
    local espdisplaynames= {["Enabled"] = false}
    esp = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
        ["Name"] = "ESP",
        ["Function"] = function(callback) 
            if callback then 
                BindToStepped("ESP", function() 
                    for i,v in next, PLAYERS:GetPlayers() do 
                        if v~=lplr and isAlive(v) then
                            local plrespframe
                            if espfolder:FindFirstChild(v.Name) then 
                                plrespframe = espfolder:FindFirstChild(v.Name)
                                plrespframe.line2.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.line1.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.line3.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.line4.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.name.TextColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.name.Visible = espnames["Enabled"]
                            else
                                plrespframe = Instance.new("Frame", espfolder)
                                plrespframe.BackgroundTransparency = 1
                                plrespframe.Visible = false
                                plrespframe.Name = v.Name
                                plrespframe.BorderSizePixel = 0
                                local line1 = Instance.new("Frame", plrespframe)
                                line1.BorderSizePixel = 0
                                line1.Name = "line1"
                                line1.ZIndex = 99
                                line1.Size = UDim2.new(1, -2, 0, 1)
                                line1.Position = UDim2.new(0, 1, 0, 1)
                                line1.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line1.Parent = plrespframe
                                local line2 = Instance.new("Frame", plrespframe)
                                line2.BorderSizePixel = 0
                                line2.Name = "line2"
                                line2.ZIndex = 99
                                line2.Size = UDim2.new(1, -2, 0, 1)
                                line2.Position = UDim2.new(0, 1, 1, -2)
                                line2.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line2.Parent = plrespframe
                                local line3 = Instance.new("Frame", plrespframe)
                                line3.BorderSizePixel = 0
                                line3.Name = "line3"
                                line3.ZIndex = 99
                                line3.Size = UDim2.new(0, 1, 1, -2)
                                line3.Position = UDim2.new(0, 1, 0, 1)
                                line3.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line3.Parent = plrespframe
                                local line4 = Instance.new("Frame", plrespframe)
                                line4.BorderSizePixel = 0
                                line4.Name = "line4"
                                line4.ZIndex = 99
                                line4.Size = UDim2.new(0, 1, 1, -2)
                                line4.Position = UDim2.new(1, -2, 0, 1)
                                line4.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line4.Parent = plrespframe
                                local name = Instance.new("TextLabel", plrespframe)
                                local text = espdisplaynames["Enabled"] and v.DisplayName or v.Name
                                name.TextColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                name.BackgroundTransparency = 1
                                name.Size = UDim2.new(0, 1, 1, 2)
                                name.Position = UDim2.new(0.5, 0, -0.95, 0)
                                name.AnchorPoint = Vector2.new(0.5, 0)
                                name.RichText = true
                                name.Text = "<stroke color='#000000' thickness='1'>"..text.."</stroke>"
                                name.Visible = espnames["Enabled"]
                                name.Name = "name"
                                name.TextSize = 13
                                name.Font = Enum.Font.Code
                            end

                            local rootPos, rootVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
							local rootSize = (v.Character.HumanoidRootPart.Size.X * 1200) * (WORKSPACE.CurrentCamera.ViewportSize.X / 1920)
							local headPos, headVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position + Vector3.new(0, 1 + v.Character.Humanoid.HipHeight, 0))
							local legPos, legVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position - Vector3.new(0, 1 + v.Character.Humanoid.HipHeight, 0))
                            plrespframe.Visible = rootVis
                            plrespframe.name.Visible = espnames["Enabled"]
                            if rootVis then
                                local rootSize = rootSize * 0.75
                                plrespframe.Size = UDim2.new(0, rootSize / rootPos.Z, 0, (headPos.Y - legPos.Y))
                                plrespframe.Position = UDim2.new(0, rootPos.X - plrespframe.Size.X.Offset / 2, 0, (rootPos.Y - plrespframe.Size.Y.Offset / 2) - 36)
                            end
                        end
                    end
                    for i,v in next, espfolder:GetChildren() do 
                        if not PLAYERS:FindFirstChild(v.Name) or not isAlive(PLAYERS:FindFirstChild(v.Name)) then
                            v:Destroy()
                        end
                    end
                end)
            else
                UnbindFromStepped("ESP")
                espfolder:ClearAllChildren()
            end
        end
    })

    espnames = esp.CreateToggle({
        ["Name"] = "Names",
        ["Function"] = function() end,
    })

    espdisplaynames = esp.CreateToggle({
        ["Name"] = "UseDisplayNames",
        ["Function"] = function() end,
    })
end

do 
    local norenderconnection
    local norender = {["Enabled"] = false}
    local norenderparticles = {["Enabled"] = false}
    local norendertextures
    local norendercache = {}

    norender = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
        ["Name"] = "NoRender",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    repeat wait() until isAlive()
                    local norendertypes = {
                        ["ParticleEmitter"] = {["Property"] = "Enabled", ["SetTo"] = false, ["Variable"] = norenderparticles},
                        ["Explosion"] = {["Property"] = "Visible", ["SetTo"] = false, ["Variable"] = norenderparticles},
                        ["Sparkles"] = {["Property"] = "Enabled", ["SetTo"] = false, ["Variable"] = norenderparticles},
                        ["Fire"] = {["Property"] = "Enabled", ["SetTo"] = false, ["Variable"] = norenderparticles},
                        ["Smoke"] = {["Property"] = "Enabled", ["SetTo"] = false, ["Variable"] = norenderparticles}, 
                    }
                    for i,v in next, WORKSPACE:GetDescendants() do 
                        if norendertypes[v.ClassName] and norendertypes[v.ClassName].Variable.Enabled then
                            local x = norendertypes[v.ClassName]
                            norendercache[#norendercache+1] = {Instance = v, Property = x.Property, Was = v[x.Property]}
                            v[x.Property] = x.SetTo
                        end
                    end
                    norenderconnection = WORKSPACE.DescendantAdded:Connect(function(v) 
                        if norendertypes[v.ClassName] and norendertypes[v.ClassName].Variable.Enabled then 
                            local x = norendertypes[v.ClassName]
                            norendercache[#norendercache+1] = {Instance = v, Property = x.Property, Was = v[x.Property]}
                            v[x.Property] = x.SetTo
                        end
                    end)
                end)
            else
                for i,v in next, norendercache do 
                    if v.Instance and v.Property then
                        v.Instance[v.Property] = v.Was
                    end
                end
                norendercache = {}
                if norenderconnection then 
                    norenderconnection:Disconnect()
                    norenderconnection = nil
                end
            end
        end
    })
    norenderparticles = norender.CreateToggle({
        ["Name"] = "Effects",
        ["Function"] = function()
            if norender.Enabled then
                norender.Toggle(nil, true)
                norender.Toggle(nil, true)
            end
        end
    })
end

local ViewClip = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
    ["Name"] = "ViewClip",
    ["Function"] = function(callback)
        if callback then
            lplr.DevCameraOcclusionMode = "Invisicam"
        else
            lplr.DevCameraOcclusionMode = "Zoom"
        end
    end,
})




-- // WorldWindow
do
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
        ["Max"] = 255,
    })
end