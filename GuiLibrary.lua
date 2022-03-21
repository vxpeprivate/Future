-- // New gui library for future roblox.
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local HTTPSERVICE = game:GetService("HttpService")
local STARTERGUI = game:GetService("StarterGui")
local COREGUI = game:GetService("CoreGui")
local PLAYERS = game:GetService("Players")
local getcustomasset = getsynasset or getcustomasset
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local chatchildaddedconnection
local GuiLibrary = {
    ["ColorTheme"] = {["H"] = 1, ["S"] = 1, ["V"] = 0.7}, 
    ["Objects"] = {}, 
    ["Signals"] = {}, 
    ["Rainbow"] = false,
    ["RainbowSpeed"] = 10,
    ["WindowX"] = 40,
    ["Connections"] = {},
    ["ClickSounds"] = true,
    ["GuiKeybind"] = "RightShift",
    ["CurrentConfig"] = "default",
    ["AllowNotifications"] = true,
    ["HUDEnabled"] = true
}

local ScreenGui = Instance.new("ScreenGui", gethui and gethui() or COREGUI)
ScreenGui.Name = "FutureUI"
local ClickGUI = Instance.new("Frame", ScreenGui)
ClickGUI.Size = UDim2.new(1,0,1,0)
ClickGUI.BackgroundTransparency = 1
ClickGUI.Name = "ClickGUI"
ClickGUI.Visible = false
GuiLibrary["ScreenGui"] = ScreenGui
GuiLibrary["ClickGUI"] = ClickGUI
makefolder("Future")
makefolder("Future/assets")
makefolder("Future/configs")
makefolder("Future/configs/"..tostring(shared.FuturePlaceId or game.PlaceId))

local function requesturl(url, bypass) 
    if isfile(url) then 
        return readfile(url)
    end
    local repourl = bypass and "https://raw.githubusercontent.com/joeengo/" or "https://raw.githubusercontent.com/joeengo/Future/main/"

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

local function colortotable(color)
    if color:ToHSV() then
        local h,s,v = color:ToHSV()
        return {h=h,s=s,v=v}
    else
        local r,g,b = color.R, color.G, color.B
        return {r=r,g=g,b=b}
    end
end

local function tabletocolor(tab)
    if tab.v then 
        return Color3.fromHSV(tab.h, tab.s, tab.v)
    else
        return Color3.fromRGB(tab.r, tab.g, tab.b)
    end
end

local function RelativeXY(GuiObject, location)
    local x, y = location.X - GuiObject.AbsolutePosition.X, location.Y - GuiObject.AbsolutePosition.Y
    local x2 = 0
    local xm, ym = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
    x2 = math.clamp(x, 4, xm - 6)
    x = math.clamp(x, 0, xm)
    y = math.clamp(y, 0, ym)
    return x, y, x/xm, y/ym, x2/xm
end

local function dragGUI(gui, dragpart)
    spawn(function()
        local dragging
        local dragInput
        local dragStart = Vector3.new(0,0,0)
        local startPos
        local function update(input)
            local delta = input.Position - dragStart
            local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (delta.X), startPos.Y.Scale, startPos.Y.Offset + (delta.Y))
            game:GetService("TweenService"):Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
        end
        dragpart.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch and dragging == false then
                    dragStart = input.Position
                    local delta = (input.Position - dragStart)
                    if delta.Y <= 30 then
                        dragging = ClickGUI.Visible
                        startPos = gui.Position
                        
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                            end
                        end)
                    end
                end
        end)
        dragpart.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end)
end
local SignalLib = loadstring(requesturl("roblox/main/SignalLib.lua", true))()
local function createsignal(name) 
    local signal = SignalLib.new()
    GuiLibrary["Signals"][name] = signal
    return signal
end
local onDestroySignal = createsignal("onDestroy")
-- // Color Management
local updatecolor = createsignal("UpdateColor")
spawn(function() 
    local i = 0
    repeat
        if GuiLibrary["Rainbow"] then
            local h,s,v= GuiLibrary.ColorTheme.H,GuiLibrary.ColorTheme.S,GuiLibrary.ColorTheme.V
            GuiLibrary["ColorTheme"] = {H=i, S=s, V=v}
            GuiLibrary["Signals"]["UpdateColor"]:Fire(GuiLibrary["ColorTheme"])
            i = i + 0.000025 * (GuiLibrary["RainbowSpeed"]*2.5)
            if i > 1 then 
                i = 0
            end
        end
        task.wait()
    until not shared.Future
end)

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

local function playclicksound() 
    if GuiLibrary["ClickSounds"] then
        playsound(getasset("Future/assets/click.mp3"))
    end
end

local function textbound(instance, xadd, yadd) 
    local xadd,yadd = xadd or 0,yadd or 0
    if not instance.ClassName:find("Text") then return end
    local function doIt()
        local vec = game:GetService("TextService"):GetTextSize(instance.Text, instance.TextSize, instance.Font, Vector2.new(99999, 99999))
        instance.Size = UDim2.new(0, vec.X+xadd, 0, vec.Y+yadd)
    end
    doIt()
    local connection = instance:GetPropertyChangedSignal("Text"):Connect(doIt)
    return connection
end
GuiLibrary["GetColor"] = function() 
    return Color3.fromHSV(GuiLibrary.ColorTheme.H, GuiLibrary.ColorTheme.S, GuiLibrary.ColorTheme.V)
end
GuiLibrary["CreateNotification"] = function(content)
    if GuiLibrary["AllowNotifications"] then
        chatchildaddedconnection = chatchildaddedconnection or PLAYERS.LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame["Frame_MessageLogDisplay"].Scroller.ChildAdded:Connect(function(child) 
            if child:FindFirstChildOfClass("TextLabel").Text:find("[Future]") then 
                child:FindFirstChildOfClass("TextLabel").RichText = true
            end
        end)
        STARTERGUI:SetCore("ChatMakeSystemMessage", {["Text"] = "\n<font color='rgb(255, 85, 85)'>[Future]</font> <font color='rgb(200,200,200)'>"..tostring(content).."</font>"})
    end
end
local exclusionList = {"ConfigOptionsButton", "DestructOptionsButton", "HUDOptionsButton", "ColorsOptionsButton"}
local exclusionList2 = {"ConfigOptionsButton", "DestructOptionsButton", "HUDOptionsButton", "ClickGuiOptionsButton", "ColorsOptionsButton"}
GuiLibrary["SaveConfig"] = function(name) 
    local name = (name == nil or name == "") and "default" or name
    local config = {}
    for i,v in next, GuiLibrary["Objects"] do 
        if v.Type == "OptionsButton" and not table.find(exclusionList2, i) then 
            config[i] = {["Enabled"] = v.API.Enabled, ["Keybind"] = v.API.Keybind, ["Type"] = v.Type, ["Window"] = v.Window}
        elseif v.Type == "Toggle" and not table.find(exclusionList2, v.OptionsButton) then
            config[i] = {["Enabled"] = v.API.Enabled, ["Type"] = v.Type, ["OptionsButton"] = v.OptionsButton, ["Window"] = v.Window}
        elseif v.Type == "Slider" and not table.find(exclusionList2, v.OptionsButton) then
            config[i] = {["Value"] = v.API.Value, ["Type"] = v.Type, ["OptionsButton"] = v.OptionsButton, ["Window"] = v.Window}
        elseif v.Type == "Selector" and not table.find(exclusionList2, v.OptionsButton) then
            config[i] = {["Value"] = v.API.Value, ["Type"] = v.Type, ["OptionsButton"] = v.OptionsButton, ["Window"] = v.Window}
        elseif v.Type == "Textbox" and not table.find(exclusionList2, v.OptionsButton) then
            config[i] = {["Value"] = v.API.Value, ["Type"] = v.Type, ["OptionsButton"] = v.OptionsButton, ["Window"] = v.Window}
        end
    end
    local guiconfig = {
        ["AllowNotifications"] = GuiLibrary.AllowNotifications,
        ["HUDEnabled"] = GuiLibrary.HUDEnabled, 
        ["ColorTheme"] = GuiLibrary.ColorTheme, 
        ["Rainbow"] = GuiLibrary.Rainbow, 
        ["RainbowSpeed"] = GuiLibrary.RainbowSpeed, 
        ["ClickSounds"] = GuiLibrary.ClickSounds, 
        ["GuiKeybind"] = GuiLibrary.GuiKeybind
    }
    makefolder("Future/configs")
    makefolder("Future/configs/"..tostring(shared.FuturePlaceId or game.PlaceId))
    writefile("Future/configs/"..tostring(shared.FuturePlaceId or game.PlaceId).."/"..name..".json", HTTPSERVICE:JSONEncode(config))
    writefile("Future/configs/GUIconfig.json", HTTPSERVICE:JSONEncode(guiconfig))
end
GuiLibrary["LoadOnlyGuiConfig"] = function() 
    if isfile("Future/configs/GUIconfig.json") then 
        local success, config = pcall(function() 
            local x = readfile("Future/configs/GUIconfig.json")
            return HTTPSERVICE:JSONDecode(x)
        end)
        if success then 
            for i,v in next, config do 
                GuiLibrary[i] = v
            end
            for i,v in next, GuiLibrary.Objects do 
                if i == "HUDOptionsButton" then 
                    v.API.Toggle(config.HUDEnabled, true)
                elseif i == "ClickGuiOptionsButton" then
                    v.API.SetKeybind(config.GuiKeybind)
                elseif i == "HUDOptionsButtonNotificationsToggle" and v.OptionsButton == "HUDOptionsButton" and v.Window == "OtherWindow" then
                    v.API.Toggle(config.AllowNotifications, true)
                elseif i == "ClickGuiOptionsButtonClickSoundsToggle" and v.OptionsButton == "ClickGuiOptionsButton" and v.Window == "OtherWindow" then
                    v.API.Toggle(config.ClickSounds, true)
                elseif i == "ColorsOptionsButtonHueSlider" and v.OptionsButton == "ColorsOptionsButton" and v.Window == "OtherWindow" then
                    v.API.Set(config.ColorTheme.H / 0.002777777777777)
                elseif i == "ColorsOptionsButtonSaturationSlider" and v.OptionsButton == "ColorsOptionsButton" and v.Window == "OtherWindow" then
                    v.API.Set(config.ColorTheme.S * 100)
                elseif i == "ColorsOptionsButtonLightnessSlider" and v.OptionsButton == "ColorsOptionsButton" and v.Window == "OtherWindow" then
                    v.API.Set(config.ColorTheme.V * 100)
                elseif i == "ColorsOptionsButtonRainbowToggle" and v.OptionsButton == "ColorsOptionsButton" and v.Window == "OtherWindow" then
                    v.API.Toggle(config.Rainbow, true)
                elseif i == "ColorsOptionsButtonRBSpeedSlider" and v.OptionsButton == "ColorsOptionsButton" and v.Window == "OtherWindow" then
                    v.API.Set(config.RainbowSpeed)
                end
            end
        else
            warn("[FUTURE] Failed to load GUIconfig.json config file")
        end
    else
        for i,v in next, GuiLibrary.Objects do 
            if i == "ClickGuiOptionsButton" then
                v.API.SetKeybind("RightShift")
            elseif i == "ColorsOptionsButtonHueSlider" and v.OptionsButton == "ColorsOptionsButton" and v.Window == "OtherWindow" then
                v.API.Set(360)
            elseif i == "ColorsOptionsButtonSaturationSlider" and v.OptionsButton == "ColorsOptionsButton" and v.Window == "OtherWindow" then
                v.API.Set(100)
            elseif i == "ColorsOptionsButtonLightnessSlider" and v.OptionsButton == "ColorsOptionsButton" and v.Window == "OtherWindow" then
                v.API.Set(70)
            end
        end
    end
end
GuiLibrary["LoadConfig"] = function(name) 
    local name = name or "default"
    if isfile("Future/configs/"..tostring(shared.FuturePlaceId or game.PlaceId).."/"..name..".json") then 
        print("[Future] Loading configuration "..name)
        local success, config = pcall(function() 
            local x = readfile("Future/configs/"..tostring(shared.FuturePlaceId or game.PlaceId).."/"..name..".json")
            return HTTPSERVICE:JSONDecode(x)
        end)
        if success then 
            -- // turn off all modules incase they are switching configs (to prevent the old configs settings staying)
            for i,v in next, GuiLibrary.Objects do 
                if v.Type == "Toggle" and not table.find(exclusionList2, i) then 
                    if v.Enabled then 
                        v.API.Toggle(false, true)
                    end
                end
                if v.Type == "OptionsButton" and not table.find(exclusionList2, i) then 
                    if v.Enabled then 
                        v.API.Toggle(false, true)
                    end
                end
            end
            for i,v in next, config do 
                if GuiLibrary["Objects"][i] then 
                    local API = GuiLibrary["Objects"][i]["API"]
                    if v.Type == "Toggle" and GuiLibrary["Objects"][i].OptionsButton == v.OptionsButton and not table.find(exclusionList2, v.OptionsButton) then
                        API.Toggle(v.Enabled, true)
                    elseif v.Type == "Slider" and GuiLibrary["Objects"][i].OptionsButton == v.OptionsButton and not table.find(exclusionList2, v.OptionsButton) then
                        API.Set(v.Value)
                    elseif v.Type == "Selector" and GuiLibrary["Objects"][i].OptionsButton == v.OptionsButton and  not table.find(exclusionList2, v.OptionsButton) then
                        API.Select(v.Value)
                    elseif v.Type == "Textbox" and GuiLibrary["Objects"][i].OptionsButton == v.OptionsButton and  not table.find(exclusionList2, v.OptionsButton) then
                        API.Set(v.Value)
                    elseif v.Type == "OptionsButton" and GuiLibrary["Objects"][i].Window == v.Window and not table.find(exclusionList2, i) then 
                        if v.Enabled then
                            API.Toggle(v.Enabled, true)
                        end
                        API.SetKeybind(v.Keybind)
                    end
                end
            end
        else
            warn("[FUTURE] Failed to load "..tostring(shared.FuturePlaceId or game.PlaceId)..".json config file\nplease report this in the discord!\n("..config..")")
        end
    end
    --GuiLibrary["LoadOnlyGuiConfig"]()
end
GuiLibrary["RemoveObject"] = function(name) 
    if GuiLibrary.Objects[name] then 
        GuiLibrary.Objects[name].Instance:Destroy()
        GuiLibrary.Objects[name] = nil
        GuiLibrary.UpdateWindows()
    end
end
GuiLibrary["CreateWindow"] = function(argstable)
    local windowapi = {["Expanded"] = true, ["ExpandedOptionsButton"] = nil}

    local Window = Instance.new("Frame")
    local Window_2 = Instance.new("TextButton")
    local WindowTitle = Instance.new("TextLabel")
    local Expand = Instance.new("ImageButton")
    local ButtonContainer = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")
    Window.Name = argstable.Name.."Window"
    Window.Parent = ClickGUI
    Window.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Window.BackgroundTransparency = 0.250
    Window.BorderSizePixel = 0
    Window.Position = UDim2.new(0, GuiLibrary["WindowX"], 0, 25)
    GuiLibrary["WindowX"] = GuiLibrary["WindowX"] + (176 + 15)
    Window.Size = UDim2.new(0, 176, 0, 222)
    Window_2.Name = "Window_2"
    Window_2.Parent = Window
    Window_2.BackgroundColor3 = Color3.fromHSV(GuiLibrary["ColorTheme"].H, GuiLibrary["ColorTheme"].S, GuiLibrary["ColorTheme"].V)
    GuiLibrary["Signals"]["UpdateColor"]:connect(function(color) 
        Window_2.BackgroundColor3 = Color3.fromHSV(color.H, color.S, color.V)
    end)
    Window_2.BorderSizePixel = 0
    Window_2.Position = UDim2.new(-0.000213969834, 0, -0.00245500472, 0)
    Window_2.Size = UDim2.new(0, 176, 0, 27)
    Window_2.AutoButtonColor = false
    Window_2.Font = Enum.Font.SourceSans
    Window_2.Text = ""
    Window_2.TextColor3 = Color3.fromRGB(0, 0, 0)
    Window_2.TextSize = 14.000
    WindowTitle.Name = "WindowTitle"
    WindowTitle.Parent = Window_2
    WindowTitle.AnchorPoint = Vector2.new(0, 0.5)
    WindowTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    WindowTitle.BackgroundTransparency = 1.000
    WindowTitle.BorderSizePixel = 0
    WindowTitle.Position = UDim2.new(0, 6, 0.5, 0)
    WindowTitle.Size = UDim2.new(0, 130, 0, 20)
    WindowTitle.Font = Enum.Font.GothamBold
    WindowTitle.Text = argstable.Name
    WindowTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WindowTitle.TextSize = 19.000
    WindowTitle.TextWrapped = true
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    Expand.Name = "Expand"
    Expand.Parent = Window_2
    Expand.AnchorPoint = Vector2.new(0.5, 0.5)
    Expand.BackgroundTransparency = 1.000
    Expand.Position = UDim2.new(1, -14, 0.5, 1)
    Expand.Size = UDim2.new(0, 20, 0, 19)
    Expand.ZIndex = 1
    Expand.Image = getasset("Future/assets/arrow.png") --"rbxassetid://8904422926"
    Expand.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Expand.ScaleType = Enum.ScaleType.Fit
    Expand.Rotation = 180
    ButtonContainer.Name = "ButtonContainer"
    ButtonContainer.Parent = Window
    ButtonContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    ButtonContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonContainer.BackgroundTransparency = 1.000
    ButtonContainer.Position = UDim2.new(0.5, 0, 0, 48)
    ButtonContainer.Size = UDim2.new(0, 175, 0, 30)
    UIListLayout.Parent = ButtonContainer
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 1)

    windowapi["CreateOptionsButton"] = function(argstable) 
        local buttonapi = {["Enabled"] = false, ["Expanded"] = false, ["Keybind"] = nil, ["IsRecording"] = false}

        local OptionsButton = Instance.new("TextButton")
        local Name = Instance.new("TextLabel")
        local Gear = Instance.new("ImageLabel")
        local ChildrenContainer = Instance.new("Frame")
        local UIListLayout_2 = Instance.new("UIListLayout")
        local ModuleContainer = Instance.new("Frame")
        local UIListLayout_3 = Instance.new("UIListLayout")
        local Keybind = Instance.new("TextButton")
        local KeybindContainer = Instance.new("Frame")
        local UIListLayout_6 = Instance.new("UIListLayout")
        local Name_5 = Instance.new("TextLabel")
        OptionsButton.Name = argstable.Name.."OptionsButton"
        OptionsButton.Parent = ButtonContainer
        OptionsButton.BackgroundColor3 = Color3.fromHSV(GuiLibrary["ColorTheme"].H, GuiLibrary["ColorTheme"].S, GuiLibrary["ColorTheme"].V)
        GuiLibrary["Signals"]["UpdateColor"]:connect(function(color) 
            OptionsButton.BackgroundColor3 = Color3.fromHSV(color.H, color.S, color.V)
        end)
        OptionsButton.BackgroundTransparency = 0.700
        OptionsButton.BorderSizePixel = 0
        OptionsButton.AnchorPoint = Vector2.new(0.5, 0)
        OptionsButton.Position = UDim2.new(0.5, 0, 0, 0)
        OptionsButton.Size = UDim2.new(0, 168, 0, 30)
        OptionsButton.AutoButtonColor = false
        OptionsButton.Font = Enum.Font.SourceSans
        OptionsButton.Text = ""
        OptionsButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        OptionsButton.TextSize = 14.000
        OptionsButton.TextXAlignment = Enum.TextXAlignment.Left
        Name.Name = "Name"
        Name.Parent = OptionsButton
        Name.AnchorPoint = Vector2.new(0, 0.5)
        Name.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Name.BackgroundTransparency = 1.000
        Name.BorderSizePixel = 0
        Name.Position = UDim2.new(0.0350000001, 0, 0.5, 0)
        Name.Size = UDim2.new(0, 114, 0, 23)
        Name.Font = Enum.Font.GothamSemibold
        Name.Text = argstable.Name
        Name.TextColor3 = Color3.fromRGB(255, 255, 255)
        Name.TextSize = 19.000
        Name.TextXAlignment = Enum.TextXAlignment.Left
        Gear.Name ="Gear"
        Gear.Parent = OptionsButton
        Gear.AnchorPoint = Vector2.new(0, 0.5)
        Gear.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Gear.BackgroundTransparency = 1.000
        Gear.Position = UDim2.new(1, -23, 0.5, 0)
        Gear.Size = UDim2.new(0, 19, 0, 19)
        Gear.Image = getasset("Future/assets/gear.png") --"rbxassetid://8905804106"
        Gear.ImageColor3 = Color3.fromRGB(181, 181, 181)
        Gear.SliceScale = 0.000
        ChildrenContainer.Name = argstable.Name.."ChildrenContainer"
        ChildrenContainer.Parent = ButtonContainer
        ChildrenContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        ChildrenContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ChildrenContainer.BackgroundTransparency = 1.000
        ChildrenContainer.Position = UDim2.new(0.5, 0, 0, 48)
        ChildrenContainer.Size = UDim2.new(0, 175, 0, 30)
        ChildrenContainer.Visible = false
        UIListLayout_2.Parent = ChildrenContainer
        UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_2.Padding = UDim.new(0, 1)
        ModuleContainer.Name = "ModuleContainer"
        ModuleContainer.Parent = ChildrenContainer
        ModuleContainer.AnchorPoint = Vector2.new(0.5, 0.5)
        ModuleContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ModuleContainer.BackgroundTransparency = 1.000
        ModuleContainer.Position = UDim2.new(0.5, 0, -0.100000001, 48)
        ModuleContainer.Size = UDim2.new(0, 175, 0, 90)
        UIListLayout_3.Parent = ModuleContainer
        UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
        if not argstable.NoKeybind then
            Keybind.Name = "Keybind"
            Keybind.Parent = ChildrenContainer
            Keybind.BackgroundTransparency = 1.000
            Keybind.BorderSizePixel = 0
            Keybind.Position = UDim2.new(0.0171428565, 0, 0, 0)
            Keybind.Size = UDim2.new(0, 168, 0, 30)
            Keybind.AutoButtonColor = true
            Keybind.Font = Enum.Font.SourceSans
            Keybind.Text = ""
            Keybind.TextColor3 = Color3.fromRGB(0, 0, 0)
            Keybind.TextSize = 14.000
            Keybind.TextXAlignment = Enum.TextXAlignment.Left
            Keybind.BackgroundColor3 = Color3.fromHSV(GuiLibrary["ColorTheme"].H, GuiLibrary["ColorTheme"].S, GuiLibrary["ColorTheme"].V)
            GuiLibrary["Signals"]["UpdateColor"]:connect(function(color) 
                Keybind.BackgroundColor3 = Color3.fromHSV(color.H, color.S, color.V)
            end)
            KeybindContainer.Name = "KeybindContainer"
            KeybindContainer.Parent = Keybind
            KeybindContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            KeybindContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            KeybindContainer.BackgroundTransparency = 1.000
            KeybindContainer.BorderSizePixel = 0
            KeybindContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            KeybindContainer.Size = UDim2.new(0, 158, 0, 30)
            UIListLayout_6.Parent = KeybindContainer
            UIListLayout_6.FillDirection = Enum.FillDirection.Horizontal
            UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_6.VerticalAlignment = Enum.VerticalAlignment.Center
            Name_5.Name = "Name"
            Name_5.Parent = KeybindContainer
            Name_5.AnchorPoint = Vector2.new(0, 0.5)
            Name_5.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Name_5.BackgroundTransparency = 1.000
            Name_5.BorderSizePixel = 0
            Name_5.Position = UDim2.new(0, 0, 0.5, 0)
            Name_5.Size = UDim2.new(0, 76, 0, 23)
            Name_5.Font = Enum.Font.GothamSemibold
            Name_5.RichText = true
            Name_5.Text = "Keybind <font color='rgb(170,170,170)'>NONE</font>"
            Name_5.TextColor3 = Color3.fromRGB(255, 255, 255)
            Name_5.TextSize = 19.000
            Name_5.TextXAlignment = Enum.TextXAlignment.Left
        end

        buttonapi["Update"] = function()
            ModuleContainer.Size = not buttonapi.Expanded and UDim2.new(0, 175, 0, 35) or UDim2.new(0, 175, 0, UIListLayout_3.AbsoluteContentSize.Y-1)
            ChildrenContainer.Size = not buttonapi.Expanded and UDim2.new(0, 175, 0, 35) or UDim2.new(0, 175, 0, UIListLayout_2.AbsoluteContentSize.Y + 0)
        end
        windowapi.Update()

        buttonapi["Expand"] = function(boolean)
            local doExpand = boolean~=nil and boolean or not buttonapi.Expanded
            buttonapi.Expanded = doExpand
            ChildrenContainer.Visible = doExpand
            windowapi.Update()
            playclicksound()
        end

        buttonapi["Toggle"] = function(boolean, stopclick) 
            local doToggle = boolean
            if boolean==nil then doToggle = not buttonapi.Enabled end
            OptionsButton.BackgroundTransparency = doToggle and 0 or 0.7
            buttonapi.Enabled = doToggle
            argstable.Function(doToggle)
            if not stopclick then
                playclicksound()
            end
        end
        if (argstable.Default~=nil) and buttonapi.Enabled ~= argstable.Default then 
            buttonapi.Toggle(argstable.Default, true)
        end

        buttonapi["SetKeybind"] = function(key) 
            if key == nil then 
                Name_5.Text = "Keybind <font color='rgb(170,170,170)'>NONE</font>"
            else
                Name_5.Text = "Keybind <font color='rgb(170,170,170)'>"..key.."</font>"
            end
            buttonapi.Keybind = key or argstable["DefaultKeybind"]
            if argstable.OnKeybound then 
                argstable.OnKeybound(key)
            end
        end
        if not argstable.NoKeybind then
            local ExclusionsList = {"Unknown"}
            local bindconnection = UIS.InputBegan:Connect(function(input) 
                if buttonapi.IsRecording and not table.find(ExclusionsList, input.KeyCode.Name) and UIS:GetFocusedTextBox() == nil then
                    buttonapi["IsRecording"] = false
                    Keybind.BackgroundTransparency = 1
                    if (input.KeyCode.Name == "Escape") then
                        buttonapi.SetKeybind(argstable["DefaultKeybind"])
                    else
                        buttonapi.SetKeybind(input.KeyCode.Name)
                    end
                    return
                end
                if input.KeyCode.Name == buttonapi.Keybind then 
                    buttonapi.Toggle(nil, true)
                end
            end)
            table.insert(GuiLibrary.Connections, bindconnection)

            Keybind.MouseButton1Click:Connect(function()
                playclicksound()
                if buttonapi["IsRecording"] == false then
                    buttonapi["IsRecording"] = true
                    Name_5.Text = "Press a Key..."
                    Keybind.BackgroundTransparency = 0
                else
                    buttonapi["IsRecording"] = false
                    buttonapi.SetKeybind(buttonapi["Keybind"])
                    Keybind.BackgroundTransparency = 1
                end
            end)
        end
        OptionsButton.MouseButton2Click:Connect(buttonapi.Expand)
        OptionsButton.MouseButton1Click:Connect(buttonapi.Toggle)

        buttonapi["CreateToggle"] = function(argstable) 
            local toggleapi = {["Enabled"] = false}
            local Toggle = Instance.new("TextButton")
            local Name_4 = Instance.new("TextLabel")
            Toggle.Name = "Toggle"..argstable.Name
            Toggle.Parent = ModuleContainer
            Toggle.BackgroundColor3 = Color3.fromHSV(GuiLibrary["ColorTheme"].H, GuiLibrary["ColorTheme"].S, GuiLibrary["ColorTheme"].V)
            GuiLibrary["Signals"]["UpdateColor"]:connect(function(color) 
                Toggle.BackgroundColor3 = Color3.fromHSV(color.H, color.S, color.V)
            end)
            Toggle.BorderSizePixel = 0
            Toggle.BackgroundTransparency = 1
            Toggle.Position = UDim2.new(0.0171428565, 0, 0, 0)
            Toggle.Size = UDim2.new(0, 168, 0, 30)
            Toggle.AutoButtonColor = false
            Toggle.Font = Enum.Font.SourceSans
            Toggle.Text = ""
            Toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
            Toggle.TextSize = 14.000
            Toggle.TextXAlignment = Enum.TextXAlignment.Left
            Name_4.Name = "Name"
            Name_4.Parent = Toggle
            Name_4.AnchorPoint = Vector2.new(0, 0.5)
            Name_4.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Name_4.BackgroundTransparency = 1.000
            Name_4.BorderSizePixel = 0
            Name_4.Position = UDim2.new(0.0350000001, 0, 0.5, 0)
            Name_4.Size = UDim2.new(0, 114, 0, 23)
            Name_4.Font = Enum.Font.GothamSemibold
            Name_4.Text = argstable.Name
            Name_4.TextColor3 = Color3.fromRGB(255, 255, 255)
            Name_4.TextSize = 19.000
            Name_4.TextXAlignment = Enum.TextXAlignment.Left

            toggleapi["Toggle"] = function(boolean, skipclick) 
                local doToggle = boolean
                if boolean==nil then doToggle = not toggleapi.Enabled end
                Toggle.BackgroundTransparency = doToggle and 0 or 1
                argstable.Function(doToggle)
                toggleapi.Enabled = doToggle
                if not skipclick then
                    playclicksound()
                end
            end
            toggleapi["Instance"] = Toggle
            if (argstable.Default~=nil) and toggleapi.Enabled ~= argstable.Default then 
                toggleapi.Toggle(argstable.Default, true)
            end
            Toggle.MouseButton1Click:Connect(toggleapi.Toggle)
            GuiLibrary["Objects"][argstable.Name.."Toggle"] = {["API"] = toggleapi, ["Instance"] = Toggle, ["Type"] = "Toggle", ["OptionsButton"] = OptionsButton.Name, ["Window"] = Window.Name}
            return toggleapi
        end

        buttonapi["CreateSelector"] = function(argstable) 
            local selectorapi = {["Value"] = nil, ["List"] = {}}

            for i,v in next, argstable.List do 
                table.insert(selectorapi.List, v)
            end
            selectorapi["Value"] = argstable.Default or selectorapi.List[1]

            local function stringtablefind(table1, key)
                for i,v in next, table1 do 
                    if tostring(v) == tostring(key) then 
                        return i 
                    end
                end
            end

            local function getvalue(index) 
                local realindex
                if index > #selectorapi.List then
                    realindex = 1 
                elseif index < 1 then
                    realindex = #selectorapi.List
                else
                    realindex = index
                end
                return realindex
            end

            local Selector = Instance.new("TextButton")
            local SelectorContainer = Instance.new("Frame")
            local UIListLayout_6 = Instance.new("UIListLayout")
            local Name_5 = Instance.new("TextLabel")
            Selector.Name = argstable.Name.."Selector"
            Selector.Parent = ModuleContainer
            Selector.BackgroundColor3 = Color3.fromHSV(GuiLibrary["ColorTheme"].H, GuiLibrary["ColorTheme"].S, GuiLibrary["ColorTheme"].V)
            GuiLibrary["Signals"]["UpdateColor"]:connect(function(color) 
                Selector.BackgroundColor3 = Color3.fromHSV(color.H, color.S, color.V)
            end)
            Selector.BackgroundTransparency = 0
            Selector.BorderSizePixel = 0
            Selector.Position = UDim2.new(0.0171428565, 0, 0, 0)
            Selector.Size = UDim2.new(0, 168, 0, 30)
            Selector.AutoButtonColor = true
            Selector.Font = Enum.Font.SourceSans
            Selector.Text = ""
            Selector.TextColor3 = Color3.fromRGB(0, 0, 0)
            Selector.TextSize = 14.000
            Selector.TextXAlignment = Enum.TextXAlignment.Left
            SelectorContainer.Name = "SelectorContainer"
            SelectorContainer.Parent = Selector
            SelectorContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            SelectorContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SelectorContainer.BackgroundTransparency = 1.000
            SelectorContainer.BorderSizePixel = 0
            SelectorContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            SelectorContainer.Size = UDim2.new(0, 158, 0, 30)
            UIListLayout_6.Parent = SelectorContainer
            UIListLayout_6.FillDirection = Enum.FillDirection.Horizontal
            UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_6.VerticalAlignment = Enum.VerticalAlignment.Center
            Name_5.Name = "Name"
            Name_5.Parent = SelectorContainer
            Name_5.AnchorPoint = Vector2.new(0, 0.5)
            Name_5.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Name_5.BackgroundTransparency = 1.000
            Name_5.BorderSizePixel = 0
            Name_5.Position = UDim2.new(0, 0, 0.5, 0)
            Name_5.Size = UDim2.new(0, 76, 0, 23)
            Name_5.Font = Enum.Font.GothamSemibold
            Name_5.RichText = true
            Name_5.Text = argstable.Name.." <font color='rgb(170,170,170)'>"..tostring(selectorapi.Value).."</font>"
            Name_5.TextColor3 = Color3.fromRGB(255, 255, 255)
            Name_5.TextSize = 19.000
            Name_5.TextXAlignment = Enum.TextXAlignment.Left

            selectorapi["Select"] = function(_select) 
                if selectorapi.List[_select] or stringtablefind(selectorapi.List, _select) then
                    selectorapi["Value"] = selectorapi.List[_select] or selectorapi.List[stringtablefind(selectorapi.List, _select)]
                    Name_5.Text = argstable.Name.." <font color='rgb(170,170,170)'>"..tostring(selectorapi.Value).."</font>"
                    argstable.Function(selectorapi["Value"])
                end
            end
            selectorapi["SelectNext"] = function() 
                local newindex = table.find(selectorapi.List, selectorapi.Value) 
                if newindex then 
                    newindex = getvalue(newindex + 1)
                    selectorapi.Select(newindex)
                else
                    warn("[Future] NewIndex in selector ("..argstable.Name..") in function `SelectNext` was not found!")
                end
                playclicksound()
            end

            selectorapi["SelectPrevious"] = function() 
                local newindex = table.find(selectorapi.List, selectorapi.Value) 
                if newindex then 
                    newindex = getvalue(newindex - 1)
                    selectorapi.Select(newindex)
                else
                    warn("[Future] NewIndex in selector ("..argstable.Name..") in function `SelectPrevious` was not found!")
                end
                playclicksound()
            end

            Selector.MouseButton1Click:Connect(selectorapi.SelectNext)
            Selector.MouseButton2Click:Connect(selectorapi.SelectPrevious)

            GuiLibrary["Objects"][OptionsButton.Name..argstable.Name.."Selector"] = {["API"] = selectorapi, ["Instance"] = Selector, ["Type"] = "Selector", ["OptionsButton"] = OptionsButton.Name, ["Window"] = Window.Name}
            return selectorapi
        end

        buttonapi["CreateSlider"] = function(argstable) 
            local sliderapi = {["Value"] = argstable.Default or argstable.Min}
            local min, max, roundval = argstable.Min, argstable.Max, (argstable.Round or 2)
            local Slider = Instance.new("TextButton")
            local SliderFill = Instance.new("Frame")
            local SliderContainer = Instance.new("Frame")
            local UIListLayout_5 = Instance.new("UIListLayout")
            local Name_3 = Instance.new("TextLabel")
            Slider.Name = argstable.Name.."Slider"
            Slider.Parent = ModuleContainer
            Slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            Slider.BackgroundTransparency = 1.000
            Slider.BorderSizePixel = 0
            Slider.Position = UDim2.new(0.0171428565, 0, 0, 0)
            Slider.Size = UDim2.new(0, 168, 0, 30)
            Slider.AutoButtonColor = false
            Slider.Font = Enum.Font.SourceSans
            Slider.Text = ""
            Slider.TextColor3 = Color3.fromRGB(0, 0, 0)
            Slider.TextSize = 14.000
            Slider.TextXAlignment = Enum.TextXAlignment.Left
            SliderFill.Name = "SliderFill"
            SliderFill.Parent = Slider
            SliderFill.AnchorPoint = Vector2.new(0, 0.5)
            SliderFill.BackgroundColor3 = Color3.fromHSV(GuiLibrary["ColorTheme"].H, GuiLibrary["ColorTheme"].S, GuiLibrary["ColorTheme"].V)
            GuiLibrary["Signals"]["UpdateColor"]:connect(function(color) 
                SliderFill.BackgroundColor3 = Color3.fromHSV(color.H, color.S, color.V)
            end)
            SliderFill.BorderSizePixel = 0
            SliderFill.Position = UDim2.new(0, 0, 0.5, 0)
            SliderFill.Size = UDim2.new(0, 50, 0, 30)
            SliderContainer.Name = "SliderContainer"
            SliderContainer.Parent = Slider
            SliderContainer.AnchorPoint = Vector2.new(0.5, 0.5)
            SliderContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderContainer.BackgroundTransparency = 1.000
            SliderContainer.BorderSizePixel = 0
            SliderContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            SliderContainer.Size = UDim2.new(0, 158, 0, 30)
            UIListLayout_5.Parent = SliderContainer
            UIListLayout_5.FillDirection = Enum.FillDirection.Horizontal
            UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_5.VerticalAlignment = Enum.VerticalAlignment.Center
            Name_3.Name = "Name"
            Name_3.Parent = SliderContainer
            Name_3.AnchorPoint = Vector2.new(0, 0.5)
            Name_3.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Name_3.BackgroundTransparency = 1.000
            Name_3.BorderSizePixel = 0
            Name_3.RichText = true
            Name_3.Position = UDim2.new(0, 0, 0.5, 0)
            Name_3.Size = UDim2.new(0, 61, 0, 23)
            Name_3.Font = Enum.Font.GothamSemibold
            Name_3.Text = argstable.Name.."<font color='rgb(170,170,170)'>"..tostring(sliderapi["Value"]).."</font>"
            Name_3.TextColor3 = Color3.fromRGB(255, 255, 255)
            Name_3.TextSize = 19.000
            Name_3.TextXAlignment = Enum.TextXAlignment.Left
            
            local function slide(input)
                local sizeX = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
                SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                local value = math.floor( ((((max - min) * sizeX) + min) * (10^roundval))+0.5)/(10^roundval)
                sliderapi["Value"] = value
                Name_3.Text = argstable.Name.." <font color='rgb(170,170,170)'>"..tostring(value).."</font>"
                if not argstable["OnInputEnded"] then
                    argstable.Function(value)
                end
            end
            local sliding
            Slider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    slide(input)
                    playclicksound()
                end
            end)

            Slider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if argstable["OnInputEnded"] then
                        argstable.Function(sliderapi.Value)
                    end
                    sliding = false
                end
            end)

            UIS.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if sliding then
                        slide(input)
                    end
                end
            end)

            sliderapi["Set"] = function(value)
                local value = math.floor((math.clamp(value, min, max) * (10^roundval))+0.5)/(10^roundval)
                sliderapi["Value"] = value
                SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                Name_3.Text = argstable.Name.." <font color='rgb(170,170,170)'>"..tostring(value).."</font>"
                argstable.Function(value)
            end
            sliderapi.Set(sliderapi["Value"])

            GuiLibrary["Objects"][OptionsButton.Name..argstable.Name.."Slider"] = {["API"] = sliderapi, ["Instance"] = Slider, ["Type"] = "Slider", ["OptionsButton"] = OptionsButton.Name, ["Window"] = Window.Name}

            return sliderapi
        end

        buttonapi["CreateTextbox"] = function(argstable) 
            local textboxapi = {["Value"] = "", }

            local Textbox = Instance.new("TextButton")
            local RealTextbox = Instance.new("TextBox")
            Textbox.Name = argstable.Name.."Textbox"
            Textbox.Parent = ModuleContainer
            Textbox.BackgroundTransparency = 1.000
            Textbox.BorderSizePixel = 0
            Textbox.Position = UDim2.new(0.0171428565, 0, 0, 0)
            Textbox.Size = UDim2.new(0, 168, 0, 30)
            Textbox.AutoButtonColor = false
            Textbox.Font = Enum.Font.SourceSans
            Textbox.Text = ""
            Textbox.TextColor3 = Color3.fromRGB(0, 0, 0)
            Textbox.TextSize = 14.000
            Textbox.TextXAlignment = Enum.TextXAlignment.Left
            RealTextbox.Name = "RealTextbox"
            RealTextbox.Parent = Textbox
            RealTextbox.AnchorPoint = Vector2.new(0.5, 0.5)
            RealTextbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            RealTextbox.BackgroundTransparency = 1.000
            RealTextbox.Position = UDim2.new(0.51767838, 0, 0.5, 0)
            RealTextbox.Size = UDim2.new(0, 162, 0, 30)
            RealTextbox.ClearTextOnFocus = false
            RealTextbox.Font = Enum.Font.GothamSemibold
            RealTextbox.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
            RealTextbox.PlaceholderText = argstable.Name
            RealTextbox.Text = ""
            RealTextbox.TextColor3 = Color3.fromRGB(255, 255, 255)
            RealTextbox.TextSize = 19.000
            RealTextbox.TextXAlignment = Enum.TextXAlignment.Left

            textboxapi["Set"] = function(value) 
                local value = tostring(value)
                textboxapi["Value"] = value
                RealTextbox.Text = value
                argstable.Function(value)
            end

            RealTextbox.FocusLost:Connect(function()
                textboxapi.Set(RealTextbox.Text)
            end)

            GuiLibrary["Objects"][OptionsButton.Name..argstable.Name.."Textbox"] = {["API"] = textboxapi, ["Instance"] = Textbox, ["Type"] = "Textbox", ["OptionsButton"] = OptionsButton.Name, ["Window"] = Window.Name}
            return textboxapi
        end


        GuiLibrary["Objects"][argstable.Name.."OptionsButton"] = {["API"] = buttonapi, ["Instance"] = OptionsButton, ["Type"] = "OptionsButton", ["Window"] = Window.Name}
        return buttonapi
    end


    windowapi["Update"] = function()
        for i,v in next, GuiLibrary.Objects do 
            if v.Type == "OptionsButton" and v.Window == Window.Name then 
                v.API.Update()
            end
        end
        Window.Size = not windowapi.Expanded and UDim2.new(0, 176, 0, 35) or UDim2.new(0, 176, 0, UIListLayout.AbsoluteContentSize.Y + 37)
    end
    windowapi.Update()
    windowapi["Expand"] = function(boolean) 
        local doexpand = boolean~=nil and boolean or not windowapi["Expanded"]
        windowapi.Expanded = doexpand
        ButtonContainer.Visible = doexpand
        windowapi.Update()
        playclicksound()
    end
    Expand.MouseButton1Click:Connect(windowapi["Expand"])
    Window_2.MouseButton2Click:Connect(windowapi["Expand"])
    dragGUI(Window, Window_2)

    GuiLibrary["Objects"][argstable.Name.."Window"] = {["API"] = windowapi, ["Instance"] = Window, ["Type"] = "Window"}
    return windowapi
end

GuiLibrary["UpdateWindows"] = function() 
    for i,v in next, GuiLibrary.Objects do 
        if v.Type == "Window" then 
            v.API.Update()
        end
    end
end

onDestroySignal:Connect(function()
    GuiLibrary["ScreenGui"]:Destroy()
    for i,v in next, GuiLibrary.Connections do 
        v:Disconnect()
        GuiLibrary.Connections[i] = nil
    end
    if chatchildaddedconnection then 
        chatchildaddedconnection:Disconnect()
        chatchildaddedconnection = nil
    end
    shared.Future = nil
end)

return GuiLibrary