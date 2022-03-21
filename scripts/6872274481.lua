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
local bedwars = {} 

-- skid("vape")

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
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid")) and (plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) or (plr.Character:FindFirstChild("HumanoidRootPart"))) then
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

local function getremote(t)
    for i,v in next, t do 
        if v == "Client" then 
            return t[i+1]
        end
    end
end

local function getPlrNear(max)
    local returning, nearestnum = nil,max
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local diff = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if diff < nearestnum then 
                nearestnum = diff 
                nearestval = v
            end
        end
    end
    return returning
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

local function getAllPlrsNear()
    if not isAlive() then return {} end
    local t = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            if v.Character.HumanoidRootPart then table.insert(t, (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude, v) end
        end
    end
    return t
end

local function canBeTargeted(plr, doTeamCheck) 
    if isAlive(plr) and plr~=lplr and (doTeamCheck and plr.Team ~=lplr.Team or not doTeamCheck) then 
        return true
    end
    return false
end

local function getwool()
	for i5, v5 in pairs(bedwars["getInventory"](lplr)["items"]) do
		if v5["itemType"]:match("wool") or v5["itemType"]:match("grass") then
			return v5["itemType"], v5["amount"]
		end
	end	
	return nil
end

local function getItem(itemName)
	for i5, v5 in pairs(bedwars["getInventory"](lplr)["items"]) do
		if v5["itemType"] == itemName then
			return v5, i5
		end
	end
	return nil
end

local Flamework = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
repeat task.wait() until Flamework.isInitialized
local KnitClient = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"].knit.src).KnitClient
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
local InventoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil
bedwars = {
    ["AnimationUtil"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]).AnimationUtil,
    ["AngelUtil"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.kit.kits.angel["angel-kit"]),
    ["AppController"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
    ["BalloonController"] = KnitClient.Controllers.BalloonController,
    ["BlockController"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
    ["BlockController2"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
    ["BlockTryController"] = getrenv()._G[game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]],
    ["BlockEngine"] = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
    ["BlockEngineClientEvents"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents,
    ["BlockPlacementController"] = KnitClient.Controllers.BlockPlacementController,
    ["BedwarsKits"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.kit["bedwars-kit-shop"]).BedwarsKitShop,
    ["BlockBreaker"] = KnitClient.Controllers.BlockBreakController.blockBreaker,
    ["BowTable"] = KnitClient.Controllers.ProjectileController,
    ["ChestController"] = KnitClient.Controllers.ChestController,
    ["ClickHold"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.ui.lib.util["click-hold"]).ClickHold,
    ["ClientHandler"] = Client,
    ["ClientHandlerDamageBlock"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.remotes).BlockEngineRemotes.Client,
    ["ClientStoreHandler"] = require(game.Players.LocalPlayer.PlayerScripts.TS.ui.store).ClientStore,
    ["ClientHandlerSyncEvents"] = require(lplr.PlayerScripts.TS["client-sync-events"]).ClientSyncEvents,
    ["CombatConstant"] = require(game:GetService("ReplicatedStorage").TS.combat["combat-constant"]).CombatConstant,
    ["CombatController"] = KnitClient.Controllers.CombatController,
    ["ConsumeSoulRemote"] = getremote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
    ["ConstantManager"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].constant["constant-manager"]).ConstantManager,
    ["CooldownController"] = KnitClient.Controllers.CooldownController,
    ["damageTable"] = KnitClient.Controllers.DamageController,
    ["DaoRemote"] = getremote(debug.getconstants(debug.getprotos(KnitClient.Controllers.KatanaController.onEnable)[4])),
    ["DetonateRavenRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.RavenController).detonateRaven)),
    ["DropItem"] = getmetatable(KnitClient.Controllers.ItemDropController).dropItemInHand,
    ["DropItemRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.ItemDropController).dropItemInHand)),
    ["EatRemote"] = getremote(debug.getconstants(debug.getproto(getmetatable(KnitClient.Controllers.ConsumeController).onEnable, 1))),
    ["EquipItemRemote"] = getremote(debug.getconstants(debug.getprotos(shared.oldequipitem or require(game:GetService("ReplicatedStorage").TS.entity.entities["inventory-entity"]).InventoryEntity.equipItem)[3])),
    ["FishermanTable"] = KnitClient.Controllers.FishermanController,
    ["GameAnimationUtil"] = require(game:GetService("ReplicatedStorage").TS.animation["animation-util"]).GameAnimationUtil,
    ["GamePlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
    ["getEntityTable"] = require(game:GetService("ReplicatedStorage").TS.entity["entity-util"]).EntityUtil,
    ["getIcon"] = function(item, showinv)
        local itemmeta = bedwars["getItemMetadata"](item["itemType"])
        if itemmeta and showinv then
            return itemmeta.image
        end
        return ""
    end,
    ["getInventory"] = function(plr)
        local plr = plr or lplr
        local suc, result = pcall(function() return InventoryUtil.getInventory(plr) end)
        return (suc and result or {
            ["items"] = {},
            ["armor"] = {},
            ["hand"] = nil
        })
    end,
    ["getItemMetadata"] = require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta,
    ["GrimReaperController"] = KnitClient.Controllers.GrimReaperController,
    ["GuitarHealRemote"] = getremote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
    ["HighlightController"] = KnitClient.Controllers.EntityHighlightController,
    ["ItemTable"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
    ["JuggernautRemote"] = getremote(debug.getconstants(debug.getprotos(debug.getprotos(KnitClient.Controllers.JuggernautController.KnitStart)[1])[4])),
    ["KatanaController"] = KnitClient.Controllers.KatanaController,
    ["KatanaRemote"] = getremote(debug.getconstants(debug.getproto(KnitClient.Controllers.KatanaController.onEnable, 4))),
    ["KnockbackTable"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1),
    ["KnockbackTable2"] = require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil,
    ["LobbyClientEvents"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"].lobby.out.client.events).LobbyClientEvents,
    ["MissileController"] = KnitClient.Controllers.GuidedProjectileController,
    ["MinerRemote"] = getremote(debug.getconstants(debug.getprotos(debug.getproto(getmetatable(KnitClient.Controllers.MinerController).onKitEnabled, 1))[2])),
    ["MinerController"] = KnitClient.Controllers.MinerController,
    ["PickupRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.ItemDropController).checkForPickup)),
    ["PlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
    ["ProjectileMeta"] = require(game:GetService("ReplicatedStorage").TS.projectile["projectile-meta"]).ProjectileMeta,
    ["QueueMeta"] = require(game:GetService("ReplicatedStorage").TS.game["queue-meta"]).QueueMeta,
    ["QueryUtil"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil,
    ["prepareHashing"] = require(game:GetService("ReplicatedStorage").TS["remote-hash"]["remote-hash-util"]).RemoteHashUtil.prepareHashVector3,
    ["ProjectileRemote"] = getremote(debug.getconstants(debug.getupvalues(getmetatable(KnitClient.Controllers.ProjectileController)["launchProjectileWithValues"])[2])),
    ["RavenTable"] = KnitClient.Controllers.RavenController,
    ["RespawnController"] = KnitClient.Controllers.BedwarsRespawnController,
    ["RespawnTimer"] = require(lplr.PlayerScripts.TS.controllers.games.bedwars.respawn.ui["respawn-timer"]).RespawnTimerWrapper,
    ["ResetRemote"] = getremote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
    ["Roact"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["roact"].src),
    ["RuntimeLib"] = require(game:GetService("ReplicatedStorage")["rbxts_include"].RuntimeLib),
    ["ShieldRemote"] = getremote(debug.getconstants(debug.getprotos(getmetatable(KnitClient.Controllers.ShieldController).raiseShield)[1])),
    ["Shop"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop,
    ["ShopItems"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.getShopItem, 2),
    ["ShopRight"] = require(lplr.PlayerScripts.TS.controllers.games.bedwars.shop.ui["item-shop"]["shop-left"]["shop-left"]).BedwarsItemShopLeft,
    ["SpawnRavenRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.RavenController).spawnRaven)),
    ["SoundManager"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).SoundManager,
    ["SoundList"] = require(game:GetService("ReplicatedStorage").TS.sound["game-sound"]).GameSound,
    ["sprintTable"] = KnitClient.Controllers.SprintController,
    ["StopwatchController"] = KnitClient.Controllers.StopwatchController,
    ["SwingSword"] = getmetatable(KnitClient.Controllers.SwordController).swingSwordAtMouse,
    ["SwingSwordRegion"] = getmetatable(KnitClient.Controllers.SwordController).swingSwordInRegion,
    ["SwordController"] = KnitClient.Controllers.SwordController,
    ["TreeRemote"] = getremote(debug.getconstants(debug.getprotos(debug.getprotos(KnitClient.Controllers.BigmanController.KnitStart)[2])[1])),
    --["TripleShotMeta"] = require(game:GetService("ReplicatedStorage").TS.kit["triple-shot"]["triple-shot"]).TripleShot,
    ["TrinityRemote"] = getremote(debug.getconstants(debug.getproto(getmetatable(KnitClient.Controllers.AngelController).onKitEnabled, 1))),
    ["VictoryScreen"] = require(lplr.PlayerScripts.TS.controllers["game"].match.ui["victory-section"]).VictorySection,
    ["ViewmodelController"] = KnitClient.Controllers.ViewmodelController,
    ["WeldTable"] = require(game:GetService("ReplicatedStorage").TS.util["weld-util"]).WeldUtil,
    ["AttackRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"]))
}

for i,v in pairs(debug.getupvalues(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"])) do
    if tostring(v) == "AC" then
        bedwars["AttackHashTable"] = v
        for i2,v2 in pairs(v) do
            if i2:find("constructor") == nil and i2:find("__index") == nil and i2:find("new") == nil then
                bedwars["AttackHashFunction"] = v2
                bedwars["AttachHashText"] = i2
            end
        end
    end
end
local blocktable = bedwars["BlockController2"].new(bedwars["BlockEngine"], getwool())
bedwars["placeBlock"] = function(newpos, customblock)
    local placeblocktype = (customblock or getwool())
    blocktable.blockType = placeblocktype
    if bedwars["BlockController"]:isAllowedPlacement(lplr, placeblocktype, Vector3.new(newpos.X/3, newpos.Y/3, newpos.Z/3)) and getItem(placeblocktype) then
        return blocktable:placeBlock(Vector3.new(newpos.X/3, newpos.Y/3, newpos.Z/3))
    end
end

local function getBestTool(block)
    local tool = nil
	local toolnum = 0
	local blockmeta = bedwars["getItemMetadata"](block)
	local blockType = ""
	if blockmeta["block"] and blockmeta["block"]["breakType"] then
		blockType = blockmeta["block"]["breakType"]
	end
	for i,v in pairs(bedwars["getInventory"](lplr)["items"]) do
		local meta = bedwars["getItemMetadata"](v["itemType"])
		if meta["breakBlock"] and meta["breakBlock"][blockType] then
			tool = v
			break
		end
	end
    return tool
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (entity.isAlive and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool["tool"]) then
		if legit then
			if getHotbarSlot(tool["itemType"]) then
				bedwars["ClientStoreHandler"]:dispatch({
					type = "InventorySelectHotbarSlot", 
					slot = getHotbarSlot(tool["itemType"])
				})
				task.wait(0.1)
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool["tool"])
		task.wait(0.1)
	end
end


local function isBlockCovered(pos)
	local coveredsides = 0
	for i, v in pairs(normalsides) do
		local blockpos = (pos + (Vector3.FromNormalId(Enum.NormalId[v]) * 3))
		local block = getblock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #normalsides
end

local function getallblocks(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getblock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock and extrablock.Parent ~= nil and (covered or covered == false and lastblock == nil) then
			if bedwars["BlockController"]:isBlockBreakable({["blockPosition"] = blockpos}, lplr) then
				table.insert(blocks, extrablock.Name)
			else
				table.insert(blocks, "unbreakable")
				break
			end
			lastfound = extrablock
			if covered == false then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getlastblock(pos, normal)
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getblock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock and extrablock.Parent ~= nil and (covered or covered == false and lastblock == nil) then
			lastfound = extrablock
			if covered == false then
				break
			end
		else
			break
		end
	end
	return lastfound
end

local healthbarblocktable = {
	["blockHealth"] = -1,
	["breakingBlockPosition"] = Vector3.new(0, 0, 0)
}
bedwars["breakBlock"] = function(pos, effects, normal, bypass)
    if lplr:GetAttribute("DenyBlockBreak") == true then
		return nil
	end
	local block = ((bypass == nil and getlastblock(pos, Enum.NormalId[normal])) or getblock(pos))
	local notmainblock = not ((bypass == nil and getlastblock(pos, Enum.NormalId[normal])))
    if block and bedwars["BlockController"]:isBlockBreakable({blockPosition = bedwars["BlockController"]:getBlockPosition((notmainblock and pos or block.Position))}, lplr) then
        if bedwars["BlockEngineClientEvents"].DamageBlock:fire(block.Name, bedwars["BlockController"]:getBlockPosition((notmainblock and pos or block.Position)), block):isCancelled() then
            return nil
        end
        local olditem = nil
		pcall(function()
			olditem = lplr.Character.HandInvItem.Value
		end)
        local blockhealthbarpos = {blockPosition = Vector3.new(0, 0, 0)}
        local blockdmg = 0
        if block and block.Parent ~= nil then
            switchToAndUseTool(block)
            blockhealthbarpos = {
                blockPosition = bedwars["BlockController"]:getBlockPosition((notmainblock and pos or block.Position))
            }
            if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
				local blockdata = bedwars["BlockController"]:getStore():getBlockData(blockhealthbarpos.blockPosition)
				if not blockdata then
					return nil
				end
				local blockhealth = blockdata:GetAttribute(lplr.Name .. "_Health")
				if blockhealth == nil then
					blockhealth = block:GetAttribute("Health");
				end
				healthbarblocktable.blockHealth = blockhealth
				healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
			end
            blockdmg = bedwars["BlockController"]:calculateBlockDamage(lplr, blockhealthbarpos)
            healthbarblocktable.blockHealth = healthbarblocktable.blockHealth - blockdmg
            if healthbarblocktable.blockHealth < 0 then
                healthbarblocktable.blockHealth = 0
            end
            bedwars["ClientHandlerDamageBlock"]:Get("DamageBlock"):CallServerAsync({
                blockRef = blockhealthbarpos, 
                hitPosition = (notmainblock and pos or block.Position), 
                hitNormal = Vector3.FromNormalId(Enum.NormalId[normal])
            }):andThen(function(p9)
				if p9 == "failed" then
					healthbarblocktable.blockHealth = healthbarblocktable.blockHealth + blockdmg
				end
			end)
            if effects then
				bedwars["BlockBreaker"]:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg)
                if healthbarblocktable.blockHealth <= 0 then
                    bedwars["BlockBreaker"].breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
                    bedwars["BlockBreaker"].healthbarMaid:DoCleaning()
                else
                    bedwars["BlockBreaker"].breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
                end
            end
        end
    end
end	

local function hashvector(vec)
	return {
		["hash"] = bedwars["AttackHashFunction"](bedwars["AttackHashText"], bedwars["prepareHashing"](vec)), 
		["value"] = vec
	}
end

local function isPointInMapOccupied(p)
    local region = Region3.new(p - Vector3.new(1, 1, 1), p + Vector3.new(1, 1, 1))
    local x = workspace:FindPartsInRegion3WithWhiteList(region, game:GetService("CollectionService"):GetTagged("block"))
    return (#x == 0)
end

local function get3Vector(p) 
    local x,y,z = p.X, p.Y,p.Z 
    x = math.floor((x) + 0.5)
    y = math.floor((y) + 0.5)
    z = math.floor((z) + 0.5)
    return Vector3.new(x,y,z)
end

local function getBestSword()
	local data, slot, bestdmg
    local items = bedwars.getInventory().items
	for i, v in next, items do
		if v.itemType:lower():find("sword") or v.itemType:lower():find("blade") then
			if bestdmg == nil or bedwars.ItemTable[v.itemType].sword.damage > bestdmg then
                data = v
				bestdmg = bedwars.ItemTable[v.itemType].sword.damage
				slot = i
			end
		end
	end
	return data, slot
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

local function getBedNear(max)
    local returning, nearestnum = nil, max
    for i,v in next, WORKSPACE:WaitForChild("Map").Blocks:GetChildren() do 
        if v.Name == "bed" then
            local mag = (v.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
            if mag < nearestnum then 
                nearestnum = mag
                returning = v
            end
        end
    end
    return returning
end

-- // combat window
do 
    local aura = {["Enabled"] = false}
    local auraswing = {["Enabled"] = false}
    local auraswingsound = {["Enabled"] = false}    
    local soundtick = tick()
    local auradist = {["Value"] = 14 }
    local hitremote = bedwars["ClientHandler"]:Get(bedwars["AttackRemote"])["instance"]
    aura = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Aura",
        ["Function"] = function(callback) 
            spawn(function()
                repeat wait() 
                    for i,v in next, getAllPlrsNear() do 
                        if isAlive() and canBeTargeted(v) and (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude < auradist["Value"] then 
                            local weapon, slot = getBestSword()
                            local attackArgs = {
                                ["weapon"] = weapon~=nil and weapon.tool,
                                ["entityInstance"] = v.Character,
                                ["validate"] = {
                                    ["raycast"] = {
                                        ["cameraPosition"] = hashvector(cam.CFrame.p), 
                                        ["cursorDirection"] = hashvector(Ray.new(cam.CFrame.p, v.Character.HumanoidRootPart.Position).Unit.Direction)
                                    },
                                    ["targetPosition"] = hashvector(v.Character.HumanoidRootPart.Position),
                                    ["selfPosition"] = hashvector(lplr.Character.HumanoidRootPart.Position)
                                }
                            }
                            hitremote:InvokeServer(attackArgs)
                            if auraswingsound["Enabled"] then 
                                if soundtick < tick()+0.1 then
                                    playsound("rbxassetid://6760544639")
                                    soundtick = tick()
                                end
                            end
                            if auraswing["Enabled"] then
                                playanimation("rbxassetid://7234367412")
                            end
                        end
                    end
                until aura["Enabled"] == false
            end)
        end,
    })
    auraswing = aura.CreateToggle({
        ["Name"] = "Swing",
        ["Function"] = function() end,
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
    local veloh, velov = {["Value"] = 0},{["Value"] = 0}
    local velocity = {["Enabled"] = false}
    local oldveloh, oldvelov = bedwars["KnockbackTable"]["kbDirectionStrength"], bedwars["KnockbackTable"]["kbUpwardStrength"]
    velocity = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Velocity",
        ["Function"] = function(callback) 
            if callback then 
                bedwars["KnockbackTable"]["kbDirectionStrength"] = oldveloh * (veloh["Value"] / 100)
                bedwars["KnockbackTable"]["kbUpwardStrength"] = oldvelov * (velov["Value"] / 100)
            else
                bedwars["KnockbackTable"]["kbDirectionStrength"] = oldveloh
                bedwars["KnockbackTable"]["kbUpwardStrength"] = oldvelov
            end
        end,
    })
    veloh = velocity.CreateSlider({
        ["Name"] = "Horizontal",
        ["Function"] = function(value)
            bedwars["KnockbackTable"]["kbDirectionStrength"] = oldveloh * (value / 100)
        end,
        ["Min"] = 0,
        ["Max"] = 100,
        ["Default"] = 0,
        ["Round"] = 1
    })
    velov = velocity.CreateSlider({
        ["Name"] = "Vertical",
        ["Function"] = function(value)
            if velocity["Enabled"] then 
                bedwars["KnockbackTable"]["kbUpwardStrength"] = oldvelov * (value / 100)
            end
        end,
        ["Min"] = 0,
        ["Max"] = 100,
        ["Default"] = 0,
        ["Round"] = 1
    })
end



-- // exploits window 



--// misc window



-- // movement window 

do 
    local nofall = {["Enabled"] = false}
    nofall = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "NoFall",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    repeat wait() 
                        if WORKSPACE:FindFirstChild("Map") and isAlive() then
                            game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.GroundHit:FireServer(WORKSPACE.Map.Blocks,999999999999999.00069)
                        end
                    until nofall.Enabled == false
                end)
            end
        end
    })
end

-- // render window 



-- world window


do 
    local bedaura = {["Enabled"] = false}; bedaura = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
        ["Name"] = "BedAura",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function() 
                    repeat wait() 
                        local bed = getBedNear(20)
                        if bed then 
                            bedwars["breakBlock"](bed.Position)
                        end
                    until bedaura["Enabled"] == false
                end)
            end
        end
    })
end

local scaffold = {["Enabled"] = false}
scaffold = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
    ["Name"] = "Scaffold",
    ["Function"] = function(callback) 
        if callback then 
            BindToStepped("Scaffold", function()
                if isAlive() and lplr.Character:FindFirstChild("Humanoid") ~= nil then
                    local newpos = lplr.Character.HumanoidRootPart.Position
                    newpos = get3Vector( Vector3.new(newpos.X, lplr.Character.HumanoidRootPart.Position.Y-3, newpos.Z) )
                    local movedir = lplr.Character:FindFirstChild("Humanoid").MoveDirection
                    if movedir.X==0 and movedir.Z==0 and lplr.Character:FindFirstChild("Humanoid").Jump==true then 
                        local velo = lplr.Character.HumanoidRootPart.Velocity
                        lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 30, 0)
                    end
                    if not isPointInMapOccupied(newpos) then
                        bedwars["placeBlock"](newpos)
                    end

                    local expandpos = lplr.Character.HumanoidRootPart.Position + ((lplr.Character.Humanoid.MoveDirection.Unit))
                    expandpos = get3Vector( Vector3.new(expandpos.X, lplr.Character.HumanoidRootPart.Position.Y-3, expandpos.Z) )
                    if not isPointInMapOccupied(expandpos) then
                        bedwars["placeBlock"](expandpos)
                    end
                end
            end)
        else
            UnbindFromStepped("Scaffold")
        end
    end
})


-- other window 

