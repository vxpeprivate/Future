local GuiLibrary = shared.Future.GuiLibrary
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local PLAYERS = game:GetService("Players")
local lplr = PLAYERS.LocalPlayer
local getcustomasset = getsynasset or getcustomasset
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport

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

local n = GuiLibrary.Objects.MiscellaneousWindow.API.CreateOptionsButton({
    ["Name"] = "Notif",
    ["Function"] = GuiLibrary["CreateNotification"],
})

n.CreateToggle({["Name"] = "tog", ["Function"] = function() end})
n.CreateSlider({["Name"] = "slid", ["Function"] = function() end, Min = 0, Max = 16})
n.CreateSelector({["Name"] = "sele", ["Function"] = function() end, List = {"a", "b", "c", "d"}})
n.CreateTextbox({["Name"] = "box", ["Function"] = function() end})