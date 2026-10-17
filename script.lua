--[[
    ============================================================================
    ⚔️ Multi-Game Delta Hub [PROTECTED v3.0 - Auto-Detect & Auto-Save]
    Supported Games:
      1. Attack on Titan: Revolution (AOT:R) - All Maps & Raids
      2. Pixel Blade (Dungeons, Raids, Kill Aura, Auto Upgrade, Chests & Portals)
    Compatible with: Delta Executor (Android / iOS / PC) & All Luau Executors
    Repository: https://github.com/slam27893-del/Ata
    ============================================================================
]]

repeat task.wait(0.2) until game:IsLoaded()

local SCRIPT_URL = "https://raw.githubusercontent.com/slam27893-del/Ata/main/script.lua"
local CONFIG_FILE = "AOTR_Delta_Config_v2.json"

-- Cleanup previous instance if re-executed in the same server
if getgenv and getgenv().AOTR_Delta_Cleanup then
    pcall(getgenv().AOTR_Delta_Cleanup)
end

--//===========================================================================
--// 🛡️ LAYER 1: CLONEREF & CRYPTO-STYLE RANDOM NAMING (STEALTH PROTECTION)
--//===========================================================================

local function safeCloneref(instance)
    if cloneref then
        local ok, res = pcall(cloneref, instance)
        if ok and res then return res end
    end
    return instance
end

local function randomIdentifier(length)
    length = length or 14
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local out = {}
    for i = 1, length do
        local idx = math.random(1, #chars)
        out[i] = string.sub(chars, idx, idx)
    end
    return table.concat(out)
end

--// Services (Protected via cloneref)
local Players = safeCloneref(game:GetService("Players"))
local RunService = safeCloneref(game:GetService("RunService"))
local TweenService = safeCloneref(game:GetService("TweenService"))
local UserInputService = safeCloneref(game:GetService("UserInputService"))
local ReplicatedStorage = safeCloneref(game:GetService("ReplicatedStorage"))
local TeleportService = safeCloneref(game:GetService("TeleportService"))
local GuiService = safeCloneref(game:GetService("GuiService"))
local HttpService = safeCloneref(game:GetService("HttpService"))
local Lighting = safeCloneref(game:GetService("Lighting"))

local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = safeCloneref(game:GetService("VirtualInputManager"))
end)

local VirtualUser = nil
pcall(function()
    VirtualUser = safeCloneref(game:GetService("VirtualUser"))
end)

--// LocalPlayer & Dynamic Character References
repeat task.wait() until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Character = LocalPlayer.Character
local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")

local function updateCharacterRefs(char)
    Character = char
    if char then
        HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
        Humanoid = char:WaitForChild("Humanoid", 10)
    else
        HumanoidRootPart = nil
        Humanoid = nil
    end
end

if Character then
    task.spawn(updateCharacterRefs, Character)
end

local charAddedConn = LocalPlayer.CharacterAdded:Connect(updateCharacterRefs)

--//===========================================================================
--// 🎮 AUTOMATIC GAME DETECTOR (AOT:R vs PIXEL BLADE)
--//===========================================================================

local PIXEL_BLADE_PLACE_IDS = {
    [18172550962] = true
}

local AOTR_PLACE_IDS = {
    MainMenu = 13379208636,
    Lobby = 14916516914
}

local function detectCurrentGame()
    if PIXEL_BLADE_PLACE_IDS[game.PlaceId] then
        return "PixelBlade"
    end
    if ReplicatedStorage:FindFirstChild("remotes") and (
        ReplicatedStorage.remotes:FindFirstChild("onHit")
        or ReplicatedStorage.remotes:FindFirstChild("abilityHit")
        or ReplicatedStorage.remotes:FindFirstChild("plrUpgrade")
        or ReplicatedStorage.remotes:FindFirstChild("playerTP")
    ) then
        return "PixelBlade"
    end
    if LocalPlayer:FindFirstChild("plrStats") or PlayerGui:FindFirstChild("gameUI") then
        return "PixelBlade"
    end
    return "AOTR"
end

local CurrentGame = detectCurrentGame()
task.spawn(function()
    task.wait(2)
    CurrentGame = detectCurrentGame()
end)

--// Remotes Discovery (AOT:R)
local Remotes = {
    GET = nil,
    POST = nil
}

local function refreshRemotes()
    if Remotes.GET and Remotes.POST then return true end
    local ok, assets = pcall(function()
        return ReplicatedStorage:FindFirstChild("Assets")
    end)
    if ok and assets then
        local remFolder = assets:FindFirstChild("Remotes")
        if remFolder then
            Remotes.GET = remFolder:FindFirstChild("GET")
            Remotes.POST = remFolder:FindFirstChild("POST")
        end
    end
    return (Remotes.GET ~= nil and Remotes.POST ~= nil)
end

task.spawn(refreshRemotes)

--// Remotes Discovery (Pixel Blade)
local function getPBRemotes()
    return ReplicatedStorage:FindFirstChild("remotes")
end

--//===========================================================================
--// 💾 AUTO-SAVE CONFIG & AUTO-EXECUTE ON NEXT RAID/DUNGEON
--//===========================================================================

local Config = {
    -- Global & Security Settings
    AutoExecuteOnTeleport = true,
    AntiKick = true,
    AntiAFK = true,
    SafeMissionTimerGuard = true,
    MinSafeMissionSeconds = 20,
    HumanizeAttacks = true,
    SpoofNapeProperties = true,
    AntiStaffProtection = true,
    AntiStrangerInSolo = false,
    VelocityAntiFling = true,

    -- [Game 1] Attack on Titan: Revolution Settings
    AutoKillBlades = false,
    MoveMode = "Teleportation",
    StartDelay = 3,
    FloatHeight = 200,
    GlideSpeed = 280,
    SlashCooldown = 0.25,
    KillNotifications = true,
    AutoFarmTS = false,
    TSKillMode = "Safe",
    TSHoverHeight = 60,
    TSStartDelay = 3,
    ExpandNapes = false,
    NapeSize = 200,
    NapeTransparency = 0.75,
    TitanRipper = false,
    AutoReloadBlades = false,
    AutoRefill = false,
    AutoEscapeGrab = false,
    AutoRetry = false,
    AutoSkipCutscene = false,
    AutoFreeChest = false,
    AutoPremiumChest = false,
    TitanESP = false,
    RefillESP = false,
    RemoveDamageText = false,
    AutoRollFamily = false,
    StopOnRareFamily = true,
    RollInterval = 0.5,

    -- [Game 2] Pixel Blade Settings
    PB_AutoFarmDungeon = false,
    PB_AutoFarmRaid = false,
    PB_KillAura = false,
    PB_KillAuraRange = 35,
    PB_GodBuffAndHeal = false,
    PB_AutoBreakables = false,
    PB_ExpandHitbox = false,
    PB_HitboxSize = 25,
    PB_AutoUpgrade = false,
    PB_HideUpgradePopup = true,
    PB_AutoOpenChests = false,
    PB_AutoOpenWishes = false,
    PB_AutoClaimQuests = false,
    PB_AutoClaimAchievements = false,
    PB_SelectedDungeon = "Grasslands",
    PB_SelectedDifficulty = "Normal",
    PB_AutoJoinPortal = false,
    PB_EnemyESP = false
}

local function saveConfig()
    if getgenv then
        getgenv().AOTR_SavedConfig = Config
    end
    if writefile then
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
        end)
    end
end

local function loadSavedConfig()
    local loadedTable = nil
    if isfile and readfile then
        local ok, exists = pcall(isfile, CONFIG_FILE)
        if ok and exists then
            local okRead, content = pcall(readfile, CONFIG_FILE)
            if okRead and content and #content > 2 then
                local okDec, decoded = pcall(function()
                    return HttpService:JSONDecode(content)
                end)
                if okDec and type(decoded) == "table" then
                    loadedTable = decoded
                end
            end
        end
    end

    if not loadedTable and getgenv and type(getgenv().AOTR_SavedConfig) == "table" then
        loadedTable = getgenv().AOTR_SavedConfig
    end

    if loadedTable then
        for k, v in pairs(loadedTable) do
            if Config[k] ~= nil and type(Config[k]) == type(v) then
                Config[k] = v
            end
        end
    end
end

loadSavedConfig()

local TeleportQueued = false
local function setupAutoExecuteOnTeleport()
    if TeleportQueued or not Config.AutoExecuteOnTeleport then return end
    local qFunc = queue_on_teleport
        or queueonteleport
        or (syn and syn.queue_on_teleport)
        or (fluxus and fluxus.queue_on_teleport)
        or (delta and delta.queue_on_teleport)

    if qFunc then
        TeleportQueued = true
        local payload = string.format([[
            repeat task.wait(0.2) until game:IsLoaded()
            task.wait(1)
            loadstring(game:HttpGet("%s"))()
        ]], SCRIPT_URL)
        pcall(qFunc, payload)
    end
end

setupAutoExecuteOnTeleport()

LocalPlayer.OnTeleport:Connect(function()
    saveConfig()
    setupAutoExecuteOnTeleport()
end)

--// Runtime State
local State = {
    Running = true,
    CanSlash = true,
    IsRefilling = false,
    FailedBladeReloadCount = 0,
    CachedRefillParts = nil,
    LastRefillScan = 0,
    FarmStartTimestamp = tick(),
    MissionStartTimestamp = tick(),
    MissionHasTitans = false,
    TitanKillsSession = 0,
    BlockedKicksCount = 0,
    LastRefillFire = 0,
    LastReloadFire = 0,
    NotifiedNapes = {},
    ActiveNotifs = {},
    TSHoverPos = nil,
    IsTSHovering = false,
    OriginalNapeSizes = {},
    Connections = {},
    ESPObjects = {},
    PB_EnteredBossRoom = false
}

local function getSafeGuiParent()
    local ok, hui = pcall(function()
        if gethui then
            return gethui()
        end
    end)
    if ok and hui then return hui end

    local okCore, core = pcall(function()
        return safeCloneref(game:GetService("CoreGui"))
    end)
    if okCore and core then return core end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local StealthESPFolder = Instance.new("Folder")
StealthESPFolder.Name = randomIdentifier(16)
StealthESPFolder.Parent = getSafeGuiParent()

--//===========================================================================
--// 🛡️ LAYER 2: METAMETHOD HOOKS (ANTI-KICK & HITBOX PROPERTY SPOOFER)
--//===========================================================================

pcall(function()
    if hookmetamethod and getnamecallmethod and checkcaller then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and Config.AntiKick then
                if self == LocalPlayer and (method == "Kick" or method == "kick") then
                    State.BlockedKicksCount = State.BlockedKicksCount + 1
                    warn("[🛡️ Security] Blocked a client Kick attempt!")
                    return nil
                end
            end
            return oldNamecall(self, ...)
        end)

        local oldIndex
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if not checkcaller() and Config.SpoofNapeProperties then
                local origData = State.OriginalNapeSizes[self]
                if origData then
                    if key == "Size" then
                        return origData.Size
                    elseif key == "Transparency" then
                        return origData.Transparency
                    elseif key == "CanCollide" then
                        return origData.CanCollide
                    end
                end
            end
            return oldIndex(self, key)
        end)
    end

    if hookfunction and LocalPlayer.Kick then
        local oldKick
        oldKick = hookfunction(LocalPlayer.Kick, function(self, ...)
            if self == LocalPlayer and Config.AntiKick then
                State.BlockedKicksCount = State.BlockedKicksCount + 1
                return nil
            end
            return oldKick(self, ...)
        end)
    end
end)

--//===========================================================================
--// 🛡️ LAYER 3: ANTI-AFK & STAFF / MODERATOR DETECTOR
--//===========================================================================

pcall(function()
    if getconnections then
        for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
            if conn.Disable then
                conn:Disable()
            elseif conn.Disconnect then
                conn:Disconnect()
            end
        end
    end
end)

table.insert(State.Connections, LocalPlayer.Idled:Connect(function()
    if not Config.AntiAFK then return end
    pcall(function()
        if VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        elseif VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightShift, false, game)
        end
    end)
end))

local function checkPlayerSecurity(plr)
    if not State.Running or plr == LocalPlayer then return end

    if Config.AntiStaffProtection then
        local isSuspiciousStaff = false
        pcall(function()
            if game.CreatorType == Enum.CreatorType.User and plr.UserId == game.CreatorId then
                isSuspiciousStaff = true
            elseif game.CreatorType == Enum.CreatorType.Group and game.CreatorId > 0 then
                local rank = plr:GetRankInGroup(game.CreatorId)
                if rank >= 100 then
                    isSuspiciousStaff = true
                end
            end
        end)

        if isSuspiciousStaff then
            Config.AutoKillBlades = false
            Config.AutoFarmTS = false
            Config.PB_AutoFarmDungeon = false
            Config.PB_AutoFarmRaid = false
            Config.PB_KillAura = false
            warn("[🛡️ Security] Staff/Moderator detected (" .. plr.Name .. ")! Pausing all farm features.")
            return
        end
    end

    if Config.AntiStrangerInSolo then
        Config.AutoKillBlades = false
        Config.AutoFarmTS = false
        Config.PB_AutoFarmDungeon = false
        Config.PB_AutoFarmRaid = false
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    task.spawn(checkPlayerSecurity, plr)
end
table.insert(State.Connections, Players.PlayerAdded:Connect(checkPlayerSecurity))

--//===========================================================================
--// UI & MULTI-METHOD BUTTON CLICKER
--//===========================================================================

local function makeDraggable(dragTrigger, targetFrame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    dragTrigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragTrigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    table.insert(State.Connections, UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and dragStart and startPos then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end))
end

local function isGuiVisible(obj)
    if not obj or not obj:IsDescendantOf(PlayerGui) then return false end
    if obj:IsA("GuiObject") and obj.AbsoluteSize.Magnitude <= 5 then return false end
    local current = obj
    while current and current ~= PlayerGui do
        if current:IsA("GuiObject") and not current.Visible then
            return false
        end
        if current:IsA("ScreenGui") and not current.Enabled then
            return false
        end
        current = current.Parent
    end
    return true
end

local function smartClickButton(btn, offsetX, offsetY)
    if not btn then return false end
    local clicked = false

    pcall(function()
        if firesignal and btn:IsA("GuiButton") then
            pcall(firesignal, btn.Activated)
            pcall(firesignal, btn.MouseButton1Click)
            pcall(firesignal, btn.MouseButton1Down)
            task.wait(0.02)
            pcall(firesignal, btn.MouseButton1Up)
            clicked = true
        end
    end)

    pcall(function()
        if VirtualInputManager and btn:IsA("GuiObject") then
            btn.Selectable = true
            GuiService.SelectedObject = btn
            task.wait(0.03)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            task.wait(0.03)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            task.wait(0.02)
            GuiService.SelectedObject = nil
            clicked = true
        end
    end)

    pcall(function()
        if VirtualInputManager and btn:IsA("GuiObject") then
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local inset = GuiService:GetGuiInset()

            local centerX = pos.X + (size.X / 2) + (offsetX or 0)
            local baseCenterY = pos.Y + (size.Y / 2)

            local yOffsets = { inset.Y + (offsetY or 0), 50, 35, 0 }
            for _, yOff in ipairs(yOffsets) do
                local clickY = baseCenterY + yOff
                VirtualInputManager:SendMouseMoveEvent(centerX, clickY, game)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(centerX, clickY, 0, true, game, 1)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(centerX, clickY, 0, false, game, 1)
            end
            clicked = true
        end
    end)

    return clicked
end

--//===========================================================================
--// ⚔️ GAME 1 MODULE: ATTACK ON TITAN: REVOLUTION (AOT:R)
--//===========================================================================

local PRIORITY_TITANS = { "Attack_Titan", "Female_Titan", "Armored_Titan" }

local function countAliveTitans()
    local titansFolder = workspace:FindFirstChild("Titans")
    if not titansFolder then return 0 end
    local alive = 0
    for _, t in ipairs(titansFolder:GetChildren()) do
        local hum = t:FindFirstChildWhichIsA("Humanoid")
        if hum and hum.Health > 0 then
            alive = alive + 1
        end
    end
    return alive
end

local function isSafeToKillTitan()
    if not Config.SafeMissionTimerGuard then
        return true
    end
    local aliveCount = countAliveTitans()
    local elapsed = tick() - State.MissionStartTimestamp
    if aliveCount <= 1 and elapsed < Config.MinSafeMissionSeconds then
        return false
    end
    return true
end

task.spawn(function()
    while State.Running do
        task.wait(0.5)
        local alive = countAliveTitans()
        if alive > 0 and not State.MissionHasTitans then
            State.MissionHasTitans = true
            State.MissionStartTimestamp = tick()
            State.NotifiedNapes = {}
        elseif alive == 0 and State.MissionHasTitans then
            local interface = PlayerGui:FindFirstChild("Interface")
            local rewards = interface and interface:FindFirstChild("Rewards")
            if rewards and rewards.Visible then
                State.MissionHasTitans = false
            end
        end
    end
end)

local function showKillNotification(killCount)
    if not Config.KillNotifications then return end

    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = randomIdentifier(12)
    notifGui.ResetOnSpawn = false
    notifGui.IgnoreGuiInset = true
    notifGui.Parent = getSafeGuiParent()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 185, 0, 62)
    frame.Position = UDim2.new(1, 20, 0, 15 + (#State.ActiveNotifs * 68))
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    frame.BorderSizePixel = 0
    frame.Parent = notifGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(212, 175, 55)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.65, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚔️ تم إصابة العملاق\nالإجمالي:"
    titleLabel.TextColor3 = Color3.fromRGB(220, 195, 110)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(0.3, 0, 1, 0)
    countLabel.Position = UDim2.new(0.68, 0, 0, 0)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = tostring(killCount)
    countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    countLabel.Font = Enum.Font.GothamBlack
    countLabel.TextSize = 22
    countLabel.Parent = frame

    table.insert(State.ActiveNotifs, notifGui)

    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -200, 0, 15 + ((#State.ActiveNotifs - 1) * 68))
    }):Play()

    task.delay(4, function()
        if notifGui and notifGui.Parent then
            notifGui:Destroy()
        end
        for i, v in ipairs(State.ActiveNotifs) do
            if v == notifGui then
                table.remove(State.ActiveNotifs, i)
                break
            end
        end
    end)
end

local function getTitanNape(titan)
    if not titan then return nil end
    local hitboxes = titan:FindFirstChild("Hitboxes")
    local hit = hitboxes and hitboxes:FindFirstChild("Hit")
    return hit and hit:FindFirstChild("Nape")
end

local function isTitanAlive(titan)
    local hum = titan and titan:FindFirstChildWhichIsA("Humanoid")
    return hum and hum.Health > 0
end

local function getClosestValidNape()
    if not HumanoidRootPart then return nil end
    local titansFolder = workspace:FindFirstChild("Titans")
    if not titansFolder then return nil end

    for _, bossName in ipairs(PRIORITY_TITANS) do
        local boss = titansFolder:FindFirstChild(bossName)
        if boss and isTitanAlive(boss) then
            local nape = getTitanNape(boss)
            if nape then return nape end
        end
    end

    local closestNape = nil
    local minDist = math.huge

    for _, titan in ipairs(titansFolder:GetChildren()) do
        if isTitanAlive(titan) then
            local nape = getTitanNape(titan)
            if nape then
                local dist = (HumanoidRootPart.Position - nape.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closestNape = nape
                end
            end
        end
    end

    return closestNape
end

local function getMultipleNapes(limit)
    local out = {}
    if not HumanoidRootPart then return out end
    local titansFolder = workspace:FindFirstChild("Titans")
    if not titansFolder then return out end

    local candidates = {}

    for _, titan in ipairs(titansFolder:GetChildren()) do
        if table.find(PRIORITY_TITANS, titan.Name) and isTitanAlive(titan) then
            local nape = getTitanNape(titan)
            if nape then
                local d = (HumanoidRootPart.Position - nape.Position).Magnitude
                for _ = 1, limit do
                    table.insert(candidates, { part = nape, dist = d })
                end
            end
        end
    end

    if #candidates == 0 then
        for _, titan in ipairs(titansFolder:GetChildren()) do
            if isTitanAlive(titan) then
                local nape = getTitanNape(titan)
                if nape then
                    table.insert(candidates, {
                        part = nape,
                        dist = (HumanoidRootPart.Position - nape.Position).Magnitude
                    })
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        return a.dist < b.dist
    end)

    for i = 1, math.min(limit, #candidates) do
        table.insert(out, candidates[i].part)
    end

    return out
end

local function applyNapeResize(part)
    if not part or not part:IsA("BasePart") or part.Name ~= "Nape" then return end
    if not State.OriginalNapeSizes[part] then
        State.OriginalNapeSizes[part] = {
            Size = part.Size,
            Transparency = part.Transparency,
            CanCollide = part.CanCollide
        }
    end
    if Config.ExpandNapes then
        part.Massless = true
        part.CanCollide = false
        part.Size = Vector3.new(Config.NapeSize, Config.NapeSize, Config.NapeSize)
        part.Transparency = Config.NapeTransparency
    else
        local orig = State.OriginalNapeSizes[part]
        if orig then
            part.Size = orig.Size
            part.Transparency = orig.Transparency
            part.CanCollide = orig.CanCollide
        end
    end
end

local function updateAllNapes()
    local titansFolder = workspace:FindFirstChild("Titans")
    if not titansFolder then return end
    for _, desc in ipairs(titansFolder:GetDescendants()) do
        if desc:IsA("BasePart") and desc.Name == "Nape" then
            applyNapeResize(desc)
        end
    end
end

-- Utgard + All-Maps Refill Finder
local function getAllWorkspaceRefills()
    if not State.CachedRefillParts or (#State.CachedRefillParts == 0 and (os.clock() - State.LastRefillScan) > 8) then
        State.LastRefillScan = os.clock()
        State.CachedRefillParts = {}

        local unclimbable = workspace:FindFirstChild("Unclimbable")
        local reloads = unclimbable and unclimbable:FindFirstChild("Reloads")
        if reloads then
            for _, desc in ipairs(reloads:GetDescendants()) do
                if desc.Name == "Refill" and desc:IsA("BasePart") then
                    table.insert(State.CachedRefillParts, desc)
                end
            end
        end

        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc.Name == "Refill" and desc:IsA("BasePart") then
                if not table.find(State.CachedRefillParts, desc) then
                    table.insert(State.CachedRefillParts, desc)
                end
            end
        end
    end
    return State.CachedRefillParts
end

workspace:GetAttributeChangedSignal("Type"):Connect(function()
    State.CachedRefillParts = nil
end)

local function findClosestRefillPart()
    local rootPos = HumanoidRootPart and HumanoidRootPart.Position
    local closest = nil
    local minDist = math.huge

    for _, part in ipairs(getAllWorkspaceRefills()) do
        if part and part:IsDescendantOf(workspace) then
            if not rootPos then
                return part
            end
            local d = (part.Position - rootPos).Magnitude
            if d < minDist then
                minDist = d
                closest = part
            end
        end
    end

    return closest
end

local function getActiveHandBlade()
    local char = LocalPlayer.Character
    if not char then return nil end
    local rig = char:FindFirstChild("Rig_" .. LocalPlayer.Name)
    if not rig then
        local charsFolder = workspace:FindFirstChild("Characters")
        local charInFolder = charsFolder and charsFolder:FindFirstChild(LocalPlayer.Name)
        rig = charInFolder and charInFolder:FindFirstChild("Rig_" .. LocalPlayer.Name)
    end
    local leftHand = rig and rig:FindFirstChild("LeftHand")
    return leftHand and leftHand:FindFirstChild("Blade_1")
end

local function areHandBladesBroken()
    local blade = getActiveHandBlade()
    if blade and blade.Transparency >= 0.95 then
        return true
    end
    return false
end

local function parseRichTextNumber(label)
    if not label then return nil end
    local ok, text = pcall(function() return label.ContentText end)
    if not ok or not text or text == "" then
        ok, text = pcall(function() return label.Text end)
    end
    if not ok or not text then return nil end
    text = string.gsub(tostring(text), "<[^>]+>", "")
    local firstNum = string.match(text, "%d+")
    return tonumber(firstNum)
end

local function getWeaponStatus()
    local bladesEmpty = false
    local spearsEmpty = false
    local setsCount = 3
    local spearSlotCount = "0"
    local hasSpearAmmo = false
    local bladeBarDepleted = areHandBladesBroken()
    local gasLow = false

    local interface = PlayerGui:FindFirstChild("Interface")
    local hud = interface and interface:FindFirstChild("HUD")
    local main = hud and hud:FindFirstChild("Main")
    local top = main and main:FindFirstChild("Top")

    if top then
        local bladeFrame = top:FindFirstChild("Blades") or top:FindFirstChild("Blade")
        if not bladeFrame then
            for _, child in ipairs(top:GetChildren()) do
                local bf = child:FindFirstChild("Blades") or child:FindFirstChild("Blade")
                if bf then
                    bladeFrame = bf
                    break
                end
            end
        end

        local setsLabel = (bladeFrame and bladeFrame:FindFirstChild("Sets", true)) or top:FindFirstChild("Sets", true)
        local parsedSets = parseRichTextNumber(setsLabel)
        if parsedSets ~= nil then
            setsCount = parsedSets
            bladesEmpty = (parsedSets == 0)
        end

        if bladeFrame then
            local grad = bladeFrame:FindFirstChild("Gradient", true)
            if grad and grad:IsA("UIGradient") and grad.Offset.X <= -0.14 then
                bladeBarDepleted = true
            end
        end

        local gasFrame = top:FindFirstChild("Gas", true)
        if gasFrame then
            local gasGrad = gasFrame:FindFirstChild("Gradient", true)
            if gasGrad and gasGrad:IsA("UIGradient") and gasGrad.Offset.X <= -0.25 then
                gasLow = true
            end
        end

        local spearsFrame = top:FindFirstChild("Spears", true)
        local spearLabel = (spearsFrame and spearsFrame:FindFirstChild("Spears", true)) or (interface and interface:FindFirstChild("Spears", true))
        local parsedSpears = parseRichTextNumber(spearLabel)
        if parsedSpears ~= nil then
            spearSlotCount = tostring(parsedSpears)
            hasSpearAmmo = (parsedSpears > 0)
            spearsEmpty = (parsedSpears == 0)
        end
    end

    return {
        bladesEmpty = bladesEmpty,
        spearsEmpty = spearsEmpty,
        setsCount = setsCount,
        spearSlot = spearSlotCount,
        hasSpears = hasSpearAmmo,
        bladeBarDepleted = bladeBarDepleted,
        gasLow = gasLow
    }
end

local function executeFullStationRefill()
    if State.IsRefilling then return end
    refreshRemotes()

    local refillPart = findClosestRefillPart()
    if not refillPart then
        State.CachedRefillParts = nil
        refillPart = findClosestRefillPart()
    end
    if not refillPart or not HumanoidRootPart then return end

    State.IsRefilling = true

    pcall(function()
        local targetCFrame = CFrame.new(refillPart.Position + Vector3.new(0, 3, 0))
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.CFrame = targetCFrame
        HumanoidRootPart.Anchored = true
    end)

    task.wait(0.25)

    pcall(function()
        if fireproximityprompt then
            local prompt = refillPart:FindFirstChildOfClass("ProximityPrompt")
                or (refillPart.Parent and refillPart.Parent:FindFirstChildOfClass("ProximityPrompt"))
                or (refillPart.Parent and refillPart.Parent.Parent and refillPart.Parent.Parent:FindFirstChildOfClass("ProximityPrompt"))
            if prompt then
                fireproximityprompt(prompt)
            end
        end
    end)

    for _ = 1, 3 do
        pcall(function()
            if HumanoidRootPart and refillPart then
                HumanoidRootPart.CFrame = CFrame.new(refillPart.Position + Vector3.new(0, 3, 0))
            end
            if Remotes.POST then
                Remotes.POST:FireServer("Attacks", "Reload", refillPart)
                Remotes.POST:FireServer("Stats", "Gas_Supply", 1)
            end
            if Remotes.GET then
                task.spawn(function()
                    pcall(function()
                        Remotes.GET:InvokeServer("Attacks", "Reload", refillPart)
                    end)
                end)
            end
            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
            end
        end)
        task.wait(0.35)
    end

    task.wait(1.2)

    if Remotes.GET then
        pcall(function()
            Remotes.GET:InvokeServer("Blades", "Reload")
        end)
    end

    pcall(function()
        if HumanoidRootPart then
            HumanoidRootPart.Anchored = false
        end
    end)

    State.FailedBladeReloadCount = 0
    State.IsRefilling = false
end

local function findFamilyRollButton()
    local interface = PlayerGui:FindFirstChild("Interface")
    if not interface then return nil end

    local custom = interface:FindFirstChild("Customisation")
    local family = custom and custom:FindFirstChild("Family")
    if family then
        local btns2 = family:FindFirstChild("Buttons_2")
        if btns2 and btns2:FindFirstChild("Roll") then
            return btns2.Roll
        end
        local deepRoll = family:FindFirstChild("Roll", true)
        if deepRoll and deepRoll:IsA("GuiButton") then
            return deepRoll
        end
    end

    for _, desc in ipairs(interface:GetDescendants()) do
        if desc:IsA("GuiButton") then
            if desc.Name == "Roll" or desc.Name == "RollButton" then
                return desc
            end
            local txtChild = desc:FindFirstChild("Text") or desc:FindFirstChild("Title")
            local txt = (txtChild and txtChild:IsA("TextLabel") and txtChild.Text) or (desc:IsA("TextButton") and desc.Text) or ""
            if string.find(string.lower(tostring(txt)), "roll") then
                return desc
            end
        end
    end

    return nil
end

local function getCurrentFamilyName()
    local interface = PlayerGui:FindFirstChild("Interface")
    local custom = interface and interface:FindFirstChild("Customisation")
    local famFrame = custom and custom:FindFirstChild("Family")
    local innerFam = famFrame and famFrame:FindFirstChild("Family")
    local title = innerFam and innerFam:FindFirstChild("Title")
    if title and title:IsA("TextLabel") then
        return string.upper(tostring(title.Text))
    end
    return ""
end

local function isRareFamily(familyText)
    if not familyText or familyText == "" then return false end
    local up = string.upper(tostring(familyText))
    return string.find(up, "YEAGER") ~= nil
        or string.find(up, "ACKERMAN") ~= nil
        or string.find(up, "REISS") ~= nil
        or string.find(up, "FRITZ") ~= nil
        or string.find(up, "HELOS") ~= nil
end

--//===========================================================================
--// 🗡️ GAME 2 MODULE: PIXEL BLADE FUNCTIONS (DUNGEONS, RAIDS, AURA, LOOT)
--//===========================================================================

local PB_IGNORE_MOBS = { "ShroomKnight", "blender" }

local function isPBMobAlive(mob)
    if not mob or table.find(PB_IGNORE_MOBS, mob.Name) then return false end
    local worldType = workspace:FindFirstChild("worldType")
    local isAncientSands = worldType and worldType.Value == "AncientSands"
    if isAncientSands and mob:FindFirstChild("worm") and mob.worm:FindFirstChild("Health") then
        return mob.worm.Health.Value > 0
    end
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        return true
    end
    local hpVal = mob:FindFirstChild("Health")
    if hpVal and hpVal:IsA("NumberValue") and hpVal.Value > 0 then
        return true
    end
    return false
end

local function findClosestPBMob(isRaid)
    if not Character or not HumanoidRootPart then return nil end
    local myPos = HumanoidRootPart.Position
    local closestMob = nil
    local minDist = math.huge

    for _, v in ipairs(workspace:GetChildren()) do
        if v ~= Character and v:IsA("Model") and not table.find(PB_IGNORE_MOBS, v.Name) then
            local hasEntrance = (v:GetAttribute("hadEntrance") ~= nil) or isRaid
            if hasEntrance and isPBMobAlive(v) then
                local ok, pivot = pcall(function() return v:GetPivot() end)
                if ok and pivot then
                    local d = (pivot.Position - myPos).Magnitude
                    if d < minDist then
                        minDist = d
                        closestMob = v
                    end
                end
            end
        end
    end

    return closestMob
end

local function applyPBTempBuffAndHeal()
    local pbRemotes = getPBRemotes()
    local abilityEvent = pbRemotes and pbRemotes:FindFirstChild("abilityEvent")
    if not abilityEvent or not Character then return end

    pcall(function()
        abilityEvent:FireServer({
            char = Character,
            name = "tempbuff",
            statBoosts = {
                Dmg = "550000000%",
                BaseSpeed = "45%"
            },
            dur = 50000000
        })
        abilityEvent:FireServer({
            char = Character,
            name = "heal",
            amount = 1
        })
    end)
end

local function pbKillAllNearby(maxRange, isRaid)
    local pbRemotes = getPBRemotes()
    if not pbRemotes or not HumanoidRootPart then return end

    local onHit = pbRemotes:FindFirstChild("onHit")
    local useAbility = pbRemotes:FindFirstChild("useAbility")
    local abilityHit = pbRemotes:FindFirstChild("abilityHit")
    local abilityEvent = pbRemotes:FindFirstChild("abilityEvent")
    local myPos = HumanoidRootPart.Position

    for _, v in ipairs(workspace:GetChildren()) do
        if v ~= Character and v:IsA("Model") and not table.find(PB_IGNORE_MOBS, v.Name) then
            -- Breakables check
            if Config.PB_AutoBreakables and string.find(string.lower(v.Name), "breakable") then
                local bHum = v:FindFirstChildOfClass("Humanoid")
                if bHum and onHit then
                    pcall(function()
                        onHit:FireServer(bHum, -math.huge, {}, 0)
                    end)
                end
            elseif isPBMobAlive(v) then
                local ok, pivot = pcall(function() return v:GetPivot() end)
                local dist = (ok and pivot) and (pivot.Position - myPos).Magnitude or math.huge
                if dist <= (maxRange or 100) or isRaid then
                    local hum = v:FindFirstChildOfClass("Humanoid")
                    if hum then
                        if onHit then
                            pcall(function()
                                onHit:FireServer(hum, -math.huge, {}, 0)
                            end)
                        end
                        if useAbility and abilityHit then
                            pcall(function()
                                useAbility:FireServer("tornado")
                                abilityHit:FireServer(hum, math.huge, { stun = { dur = 1 } })
                            end)
                        end
                    end
                    if v.Name == "Maneater" and useAbility then
                        pcall(function()
                            useAbility:FireServer("lunarSpell")
                        end)
                    elseif v.Name == "Atticus" and VirtualInputManager then
                        pcall(function()
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end)
                    end
                end
            end
        end
    end

    if Config.PB_GodBuffAndHeal and abilityEvent and Character then
        pcall(function()
            abilityEvent:FireServer({
                char = Character,
                name = "heal",
                amount = 1
            })
        end)
    end
end

--//===========================================================================
--// MAIN LOOPS (AOT:R + PIXEL BLADE)
--//===========================================================================

-- 1. Heartbeat Loop (AOT:R Auto Kill + Pixel Blade Velocity Lock & Hitbox)
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if not State.Running or not HumanoidRootPart then return end

    if Config.VelocityAntiFling then
        if HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 650 then
            HumanoidRootPart.AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity.Unit * 300
        end
        if HumanoidRootPart.AssemblyAngularVelocity.Magnitude > 50 then
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- Pixel Blade Active Farm Velocity Lock & Noclip
    if Config.PB_AutoFarmDungeon or Config.PB_AutoFarmRaid then
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end

    -- AOT:R Refill Pause
    if State.IsRefilling then
        return
    end

    -- AOT:R Thunder Spears Hover Lock
    if Config.AutoFarmTS and State.IsTSHovering and State.TSHoverPos then
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.CFrame = CFrame.new(State.TSHoverPos)
        return
    end

    -- AOT:R Auto Kill Titans (Blades)
    if Config.AutoKillBlades then
        if (tick() - State.FarmStartTimestamp) < Config.StartDelay then
            return
        end

        local nape = getClosestValidNape()
        if not nape then return end

        local targetPos = nape.Position + Vector3.new(0, Config.FloatHeight, 0)

        if Config.MoveMode == "Gliding" then
            local delta = targetPos - HumanoidRootPart.Position
            if delta.Magnitude > 4 then
                HumanoidRootPart.AssemblyLinearVelocity = delta.Unit * Config.GlideSpeed
            else
                HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            end
        else
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.CFrame = CFrame.new(targetPos)
        end

        if not isSafeToKillTitan() then
            return
        end

        if (HumanoidRootPart.Position - nape.Position).Magnitude <= 1500 and State.CanSlash then
            State.CanSlash = false
            task.spawn(function()
                refreshRemotes()
                local debugId = tostring(nape:GetDebugId())
                if Remotes.POST then
                    pcall(function()
                        local dmg = Config.HumanizeAttacks and math.random(215, 295) or 250
                        local acc = Config.HumanizeAttacks and (math.random(20, 30) / 100) or 0.25
                        Remotes.POST:FireServer("Hitboxes", "Register", nape, dmg, acc)
                        Remotes.POST:FireServer("Attacks", "Slash", true)
                    end)
                end

                if not State.NotifiedNapes[debugId] then
                    State.NotifiedNapes[debugId] = true
                    State.TitanKillsSession = State.TitanKillsSession + 1
                    showKillNotification(State.TitanKillsSession)
                end

                local jitter = Config.HumanizeAttacks and (math.random(0, 8) / 100) or 0
                task.wait(Config.SlashCooldown + jitter)
                State.CanSlash = true
            end)
        end
    end
end))

-- 2. Pixel Blade Auto Farm Loop (Dungeons, Raids, Kill Aura, Upgrades, Chests, Portals)
task.spawn(function()
    while State.Running do
        task.wait(0.15)
        local pbRemotes = getPBRemotes()
        if pbRemotes then
            -- God Buff & Auto Heal
            if Config.PB_GodBuffAndHeal then
                applyPBTempBuffAndHeal()
            end

            -- Kill Aura / Breakables
            if Config.PB_KillAura or Config.PB_AutoBreakables then
                pcall(pbKillAllNearby, Config.PB_KillAuraRange, false)
            end

            -- Expand Enemy Hitboxes
            if Config.PB_ExpandHitbox then
                pcall(function()
                    local sz = Vector3.new(Config.PB_HitboxSize, Config.PB_HitboxSize, Config.PB_HitboxSize)
                    for _, v in ipairs(workspace:GetChildren()) do
                        if v ~= Character and v:IsA("Model") and isPBMobAlive(v) then
                            local bh = v:FindFirstChild("basehitbox")
                            if bh and bh:IsA("BasePart") then
                                bh.Size = sz
                                bh.CanCollide = false
                            end
                            local mHrp = v:FindFirstChild("HumanoidRootPart")
                            if mHrp and mHrp:IsA("BasePart") then
                                mHrp.Size = sz
                                mHrp.CanCollide = false
                            end
                        end
                    end
                end)
            end

            -- Auto Farm Dungeon / Raid Movement & Combat
            if (Config.PB_AutoFarmDungeon or Config.PB_AutoFarmRaid) and HumanoidRootPart then
                local isRaid = Config.PB_AutoFarmRaid
                local cutscene = workspace:FindFirstChild("inCutscene")
                local inCutscene = cutscene and cutscene.Value == true

                -- Auto Room Progression in Dungeon
                if Config.PB_AutoFarmDungeon then
                    pcall(function()
                        local diffObj = workspace:FindFirstChild("difficulty")
                        local diffVal = diffObj and diffObj.Value
                        local r6 = workspace:FindFirstChild("6")
                        local r7 = workspace:FindFirstChild("7")
                        local r8 = workspace:FindFirstChild("8")
                        local r9 = workspace:FindFirstChild("9")
                        if diffVal == "Normal" and r6 and r7 then
                            HumanoidRootPart.CFrame = CFrame.new(r7:GetPivot().Position + Vector3.new(0, 5, 0))
                        elseif diffVal == "Heroic" and r7 and r8 then
                            HumanoidRootPart.CFrame = CFrame.new(r8:GetPivot().Position + Vector3.new(0, 5, 0))
                        elseif diffVal == "Nightmare" and r8 and r9 then
                            HumanoidRootPart.CFrame = CFrame.new(r9:GetPivot().Position + Vector3.new(0, 5, 0))
                        end
                    end)
                end

                if not inCutscene then
                    local mob = findClosestPBMob(isRaid)
                    if mob then
                        pcall(function()
                            if mob.Name == "Atticus" and not State.PB_EnteredBossRoom then
                                local vault = workspace:FindFirstChild("Vault")
                                if vault then
                                    HumanoidRootPart.CFrame = CFrame.new(vault:GetPivot().Position)
                                    State.PB_EnteredBossRoom = true
                                    task.wait(0.5)
                                end
                            end

                            local mobPos, mobLook
                            if mob.Name == "Maneater" and mob:FindFirstChild("Root") then
                                mobPos = Vector3.new(mob.Root.Position.X, 35, mob.Root.Position.Z)
                                mobLook = mob.Root.CFrame.LookVector
                            elseif mob:FindFirstChild("HumanoidRootPart") then
                                mobPos = mob.HumanoidRootPart.Position
                                mobLook = mob.HumanoidRootPart.CFrame.LookVector
                                if not isRaid then
                                    mob.HumanoidRootPart.Anchored = true
                                end
                            else
                                local pv = mob:GetPivot()
                                mobPos = pv.Position
                                mobLook = pv.LookVector
                            end

                            local offsetMult = (mob.Name == "Nekros" or mob.Name == "DarkNekros") and 2 or -7
                            local targetPos = mobPos + (mobLook * offsetMult)
                            HumanoidRootPart.CFrame = CFrame.lookAt(targetPos, mobPos)

                            applyPBTempBuffAndHeal()
                            pbKillAllNearby(120, isRaid)
                        end)
                    end
                end
            end

            -- Auto Pick Dungeon Upgrades
            if Config.PB_AutoUpgrade then
                pcall(function()
                    local upgRemote = pbRemotes:FindFirstChild("plrUpgrade")
                    if upgRemote then
                        upgRemote:FireServer(math.random(1, 3))
                    end
                    if VirtualInputManager then
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                        task.wait(0.03)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                    end
                    if Config.PB_HideUpgradePopup then
                        local dBlur = Lighting:FindFirstChild("deathBlur")
                        if dBlur then dBlur.Size = 0 end
                        local gameUI = PlayerGui:FindFirstChild("gameUI")
                        local upgFrame = gameUI and gameUI:FindFirstChild("upgradeFrame")
                        if upgFrame then
                            upgFrame.Position = UDim2.new(0, 0, -1.2, 0)
                        end
                    end
                end)
            end
        end
    end
end)

-- 3. Pixel Blade Slow Automation Loop (Chests, Wishes, Quests, Portal Auto-Join)
task.spawn(function()
    while State.Running do
        task.wait(1)
        local pbRemotes = getPBRemotes()
        if pbRemotes then
            -- Auto Open All Chests in Inventory
            if Config.PB_AutoOpenChests then
                pcall(function()
                    local openLoot = pbRemotes:FindFirstChild("openLoot")
                    local gameUI = PlayerGui:FindFirstChild("gameUI")
                    local lootFolder = gameUI
                        and gameUI:FindFirstChild("armory")
                        and gameUI.armory:FindFirstChild("inventory")
                        and gameUI.armory.inventory:FindFirstChild("clip")
                        and gameUI.armory.inventory.clip:FindFirstChild("Loot")
                    if openLoot and lootFolder then
                        for _, item in ipairs(lootFolder:GetChildren()) do
                            if string.find(item.Name, "Chest") then
                                openLoot:InvokeServer(item.Name)
                                task.wait(0.1)
                            end
                        end
                    end
                end)
            end

            -- Auto Open Wishes
            if Config.PB_AutoOpenWishes then
                pcall(function()
                    local openWish = pbRemotes:FindFirstChild("openWish")
                    if openWish then
                        openWish:InvokeServer()
                    end
                end)
            end

            -- Auto Claim Daily Quests & Achievements
            if Config.PB_AutoClaimQuests then
                pcall(function()
                    local dq = pbRemotes:FindFirstChild("dailyQuestEvent")
                    if dq then
                        for i = 1, 3 do
                            for j = 1, 3 do
                                dq:FireServer("Claim", "Quest_" .. tostring(i), j)
                            end
                        end
                    end
                end)
            end

            if Config.PB_AutoClaimAchievements then
                pcall(function()
                    local dq = pbRemotes:FindFirstChild("dailyQuestEvent")
                    local constants = ReplicatedStorage:FindFirstChild("constants")
                    local qDataMod = constants and constants:FindFirstChild("questData")
                    if dq and qDataMod then
                        local qData = require(qDataMod)
                        if qData and qData.Achievements then
                            for _, ach in pairs(qData.Achievements) do
                                if ach and ach.id then
                                    dq:FireServer("Claim", ach.id, true)
                                end
                            end
                        end
                    end
                end)
            end

            -- Auto Join Dungeon Portal
            if Config.PB_AutoJoinPortal then
                pcall(function()
                    local playerTP = pbRemotes:FindFirstChild("playerTP")
                    if playerTP then
                        saveConfig()
                        setupAutoExecuteOnTeleport()
                        playerTP:FireServer(Config.PB_SelectedDungeon, Config.PB_SelectedDifficulty, true)
                    end
                end)
            end
        end
    end
end)

-- 4. AOT:R Thunder Spears Background Loop
task.spawn(function()
    local firstLaunch = true
    while State.Running do
        if Config.AutoFarmTS and HumanoidRootPart and not State.IsRefilling then
            refreshRemotes()
            local debrisFolder = workspace:FindFirstChild("Debris")
            if debrisFolder and debrisFolder:FindFirstChild("Roar") then
                repeat task.wait(0.15) until not (debrisFolder and debrisFolder:FindFirstChild("Roar")) or not Config.AutoFarmTS
            end

            if not isSafeToKillTitan() then
                if HumanoidRootPart then
                    State.TSHoverPos = HumanoidRootPart.Position
                    State.IsTSHovering = true
                end
                task.wait(0.4)
            else
                local weaponInfo = getWeaponStatus()
                if weaponInfo.hasSpears and Remotes.GET and Remotes.POST then
                    local batchCount = (Config.TSKillMode == "Risk") and math.random(10, 20) or math.random(3, 8)
                    local napes = getMultipleNapes(batchCount)

                    if #napes > 0 then
                        local hoverTarget = napes[1].Position + Vector3.new(0, Config.TSHoverHeight, 0)
                        if (HumanoidRootPart.Position - hoverTarget).Magnitude > 150 and Character then
                            Character:PivotTo(CFrame.new(hoverTarget))
                        else
                            HumanoidRootPart.CFrame = CFrame.new(hoverTarget)
                        end
                        State.TSHoverPos = hoverTarget
                        State.IsTSHovering = true

                        if firstLaunch then
                            task.wait(Config.TSStartDelay)
                            firstLaunch = false
                        end

                        pcall(function()
                            Remotes.GET:InvokeServer("Spears", "S_Fire", weaponInfo.spearSlot)
                        end)

                        for _, n in ipairs(napes) do
                            if n and n.Parent and isSafeToKillTitan() then
                                pcall(function()
                                    Remotes.POST:FireServer("Spears", "S_Explode", n.Position, 0.501303055920385, 450.20495501920485)
                                end)
                            end
                        end
                    end
                end

                if not State.TSHoverPos and HumanoidRootPart then
                    State.TSHoverPos = HumanoidRootPart.Position + Vector3.new(0, Config.TSHoverHeight, 0)
                end
                State.IsTSHovering = true
                task.wait(1)
            end
        else
            firstLaunch = true
            State.IsTSHovering = false
            State.TSHoverPos = nil
            task.wait(0.4)
        end
    end
end)

-- 5. AOT:R Combat Automation Loop (Utgard + All-Maps Auto Refill, Auto Reload Blades, Auto Escape, Titan Ripper)
task.spawn(function()
    local skillCooldowns = {
        ["14"] = { last = 0, cd = 5 },
        ["23"] = { last = 0, cd = 8 }
    }

    pcall(function()
        local skillMod = ReplicatedStorage:WaitForChild("Modules", 5)
            and ReplicatedStorage.Modules:WaitForChild("Storage", 5)
            and ReplicatedStorage.Modules.Storage:WaitForChild("Skill", 5)
        if skillMod then
            local data = require(skillMod)
            if type(data) == "table" then
                if data["14"] and data["14"].Cooldown then skillCooldowns["14"].cd = data["14"].Cooldown end
                if data["23"] and data["23"].Cooldown then skillCooldowns["23"].cd = data["23"].Cooldown end
            end
        end
    end)

    while State.Running do
        task.wait(0.25)
        refreshRemotes()

        local status = getWeaponStatus()
        local now = tick()

        if (Config.AutoReloadBlades or Config.AutoRefill) and status.bladeBarDepleted and not status.bladesEmpty and not State.IsRefilling then
            if (now - State.LastReloadFire) >= 0.45 then
                State.LastReloadFire = now
                if Remotes.GET then
                    pcall(function()
                        Remotes.GET:InvokeServer("Blades", "Reload")
                    end)
                end
                task.wait(0.25)
                if areHandBladesBroken() then
                    State.FailedBladeReloadCount = State.FailedBladeReloadCount + 1
                else
                    State.FailedBladeReloadCount = 0
                end
            end
        elseif not status.bladeBarDepleted then
            State.FailedBladeReloadCount = 0
        end

        if Config.AutoRefill and not State.IsRefilling then
            local emptySheaths = status.bladesEmpty or (status.setsCount == 0) or (State.FailedBladeReloadCount >= 2)
            local needsStationRefill = emptySheaths or status.spearsEmpty or status.gasLow

            if needsStationRefill and (now - State.LastRefillFire) >= 0.6 then
                State.LastRefillFire = now
                local refillPart = findClosestRefillPart()
                if refillPart then
                    if Remotes.POST then
                        pcall(function()
                            Remotes.POST:FireServer("Attacks", "Reload", refillPart)
                            Remotes.POST:FireServer("Stats", "Gas_Supply", 1)
                        end)
                    end
                    if Remotes.GET then
                        task.spawn(function()
                            pcall(function()
                                Remotes.GET:InvokeServer("Attacks", "Reload", refillPart)
                            end)
                        end)
                    end

                    if (emptySheaths and status.bladeBarDepleted) or State.FailedBladeReloadCount >= 2 then
                        executeFullStationRefill()
                    elseif status.bladeBarDepleted and Remotes.GET then
                        task.delay(0.2, function()
                            pcall(function()
                                Remotes.GET:InvokeServer("Blades", "Reload")
                            end)
                        end)
                    end
                end
            end
        end

        if Config.AutoEscapeGrab and Remotes.POST then
            local interface = PlayerGui:FindFirstChild("Interface")
            local buttons = interface and interface:FindFirstChild("Buttons")
            if buttons then
                local children = buttons:GetChildren()
                if #children > 0 then
                    pcall(function()
                        Remotes.POST:FireServer("Attacks", "Slash_Escape")
                    end)
                    for _, b in ipairs(children) do
                        pcall(function() b:Destroy() end)
                    end
                end
            end
        end

        if Config.TitanRipper and Remotes.GET and isSafeToKillTitan() and not State.IsRefilling then
            for skillId, info in pairs(skillCooldowns) do
                if (now - info.last) >= info.cd then
                    info.last = now
                    task.spawn(function()
                        pcall(function()
                            Remotes.GET:InvokeServer("S_Skills", "Usage", skillId, false)
                        end)
                    end)
                end
            end
        end
    end
end)

-- 6. AOT:R Mission & Menu UI Automation Loop
task.spawn(function()
    while State.Running do
        task.wait(0.4)
        local interface = PlayerGui:FindFirstChild("Interface")
        if interface then
            if Config.AutoSkipCutscene then
                local skipBtn = interface:FindFirstChild("Skip")
                if isGuiVisible(skipBtn) then
                    smartClickButton(skipBtn, 0, 0)
                end
            end

            local chests = interface:FindFirstChild("Chests")
            if chests then
                local finishBtn = chests:FindFirstChild("Finish")
                if isGuiVisible(finishBtn) then
                    if Config.AutoFreeChest then
                        local freeBtn = chests:FindFirstChild("Free")
                        if isGuiVisible(freeBtn) then
                            smartClickButton(freeBtn, 0, 0)
                            task.wait(6.5)
                        end
                        if isGuiVisible(finishBtn) then
                            smartClickButton(finishBtn, 0, 0)
                            task.wait(1.5)
                        end
                    end
                    if Config.AutoPremiumChest then
                        local premBtn = chests:FindFirstChild("Premium")
                        if isGuiVisible(premBtn) then
                            smartClickButton(premBtn, 0, 0)
                            task.wait(6.5)
                        end
                        if isGuiVisible(finishBtn) then
                            smartClickButton(finishBtn, 0, 0)
                            task.wait(1.5)
                        end
                    end
                end
            end

            if Config.AutoRetry then
                local rewards = interface:FindFirstChild("Rewards")
                local rMain = rewards and rewards:FindFirstChild("Main")
                local rInfo = rMain and rMain:FindFirstChild("Info")
                local rInfoMain = rInfo and rInfo:FindFirstChild("Main")
                local rButtons = rInfoMain and rInfoMain:FindFirstChild("Buttons")
                local retryBtn = rButtons and rButtons:FindFirstChild("Retry")

                if isGuiVisible(retryBtn) then
                    saveConfig()
                    setupAutoExecuteOnTeleport()
                    task.wait(0.8)
                    if isGuiVisible(retryBtn) then
                        State.MissionStartTimestamp = tick()
                        State.MissionHasTitans = false
                        smartClickButton(retryBtn, 20, 0)
                        task.wait(2.5)
                    end
                end
            end

            if Config.AutoRollFamily then
                local currentFamily = getCurrentFamilyName()
                if Config.StopOnRareFamily and isRareFamily(currentFamily) then
                    Config.AutoRollFamily = false
                    saveConfig()
                    warn("[🎉 AOT:R Hub] Stopped rolling! Obtained rare family: " .. tostring(currentFamily))
                else
                    refreshRemotes()
                    local rolledFamily = nil
                    if Remotes.GET then
                        pcall(function()
                            local _, _, _, newFam = Remotes.GET:InvokeServer("Family", "Roll")
                            if type(newFam) == "string" then
                                rolledFamily = newFam
                            end
                        end)
                    end

                    local rollBtn = findFamilyRollButton()
                    if rollBtn and isGuiVisible(rollBtn) then
                        smartClickButton(rollBtn, 0, 0)
                    end

                    if Config.StopOnRareFamily and isRareFamily(rolledFamily or getCurrentFamilyName()) then
                        Config.AutoRollFamily = false
                        saveConfig()
                        warn("[🎉 AOT:R Hub] Stopped rolling! Obtained rare family: " .. tostring(rolledFamily or getCurrentFamilyName()))
                    end

                    task.wait(Config.RollInterval)
                end
            end
        end
    end
end)

--// Stealth ESP System (AOT:R Titans/Refills + Pixel Blade Enemies)
local function clearESP()
    for _, item in pairs(State.ESPObjects) do
        pcall(function()
            if item and item.Parent then item:Destroy() end
        end)
    end
    State.ESPObjects = {}
end

local function updateESP()
    for target, espInstance in pairs(State.ESPObjects) do
        if not target or not target.Parent then
            pcall(function() espInstance:Destroy() end)
            State.ESPObjects[target] = nil
        end
    end

    if Config.TitanESP then
        local titansFolder = workspace:FindFirstChild("Titans")
        if titansFolder then
            for _, titan in ipairs(titansFolder:GetChildren()) do
                if isTitanAlive(titan) and not State.ESPObjects[titan] then
                    local isBoss = table.find(PRIORITY_TITANS, titan.Name) ~= nil
                    local highlight = Instance.new("Highlight")
                    highlight.Name = randomIdentifier(10)
                    highlight.FillColor = isBoss and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 190, 40)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.65
                    highlight.OutlineTransparency = 0.1
                    highlight.Adornee = titan
                    highlight.Parent = StealthESPFolder
                    State.ESPObjects[titan] = highlight
                end
            end
        end
    end

    if Config.RefillESP then
        for _, refillPart in ipairs(getAllWorkspaceRefills()) do
            local adorneeTarget = (refillPart.Parent and refillPart.Parent:IsA("Model") and refillPart.Parent) or refillPart
            if adorneeTarget and not State.ESPObjects[adorneeTarget] then
                local hl = Instance.new("Highlight")
                hl.Name = randomIdentifier(10)
                hl.FillColor = Color3.fromRGB(50, 220, 120)
                hl.OutlineColor = Color3.fromRGB(200, 255, 220)
                hl.FillTransparency = 0.45
                hl.Adornee = adorneeTarget
                hl.Parent = StealthESPFolder
                State.ESPObjects[adorneeTarget] = hl
            end
        end
    end

    if Config.PB_EnemyESP then
        for _, v in ipairs(workspace:GetChildren()) do
            if v ~= Character and v:IsA("Model") and isPBMobAlive(v) and not State.ESPObjects[v] then
                local hl = Instance.new("Highlight")
                hl.Name = randomIdentifier(10)
                hl.FillColor = Color3.fromRGB(180, 80, 255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.55
                hl.Adornee = v
                hl.Parent = StealthESPFolder
                State.ESPObjects[v] = hl
            end
        end
    end
end

task.spawn(function()
    while State.Running do
        task.wait(1)
        if Config.TitanESP or Config.RefillESP or Config.PB_EnemyESP then
            pcall(updateESP)
        end
        if Config.ExpandNapes then
            pcall(updateAllNapes)
        end
    end
end)

local dmgTextConn = nil
local function applyRemoveDamageText(state)
    local interface = PlayerGui:FindFirstChild("Interface")
    if state and interface then
        for _, obj in ipairs(interface:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Name == "Number" then
                obj.Visible = false
            end
        end
        if not dmgTextConn then
            dmgTextConn = interface.DescendantAdded:Connect(function(obj)
                if obj:IsA("TextLabel") and obj.Name == "Number" then
                    obj.Visible = false
                end
            end)
        end
    else
        if dmgTextConn then
            dmgTextConn:Disconnect()
            dmgTextConn = nil
        end
    end
end

if Config.RemoveDamageText then
    task.spawn(function()
        PlayerGui:WaitForChild("Interface", 15)
        applyRemoveDamageText(true)
    end)
end

--//===========================================================================
--// DELTA MOBILE & PC CUSTOM GUI (MULTI-GAME HUB: AOT:R + PIXEL BLADE)
--//===========================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomIdentifier(16)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getSafeGuiParent()

local FloatButton = Instance.new("TextButton")
FloatButton.Name = randomIdentifier(10)
FloatButton.Size = UDim2.new(0, 56, 0, 56)
FloatButton.Position = UDim2.new(0, 18, 0.5, -28)
FloatButton.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
FloatButton.Text = CurrentGame == "PixelBlade" and "🗡️\nPB" or "🛡️\nHUB"
FloatButton.TextColor3 = Color3.fromRGB(90, 230, 145)
FloatButton.Font = Enum.Font.GothamBlack
FloatButton.TextSize = 13
FloatButton.AutoButtonColor = true
FloatButton.Parent = ScreenGui

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(0, 14)
floatCorner.Parent = FloatButton

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Color3.fromRGB(80, 215, 130)
floatStroke.Thickness = 2
floatStroke.Parent = FloatButton

makeDraggable(FloatButton, FloatButton)

local MainFrame = Instance.new("Frame")
MainFrame.Name = randomIdentifier(12)
MainFrame.Size = UDim2.new(0, 560, 0, 380)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 17, 23)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(212, 175, 55)
mainStroke.Thickness = 1.5
mainStroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Name = randomIdentifier(8)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(24, 25, 34)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = Header

makeDraggable(Header, MainFrame)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -140, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🛡️ Delta Multi-Hub v3.0 | AOT:R + Pixel Blade"
TitleLabel.TextColor3 = Color3.fromRGB(235, 200, 90)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SecurityBadge = Instance.new("TextLabel")
SecurityBadge.Size = UDim2.new(0, 82, 0, 22)
SecurityBadge.Position = UDim2.new(1, -128, 0.5, -11)
SecurityBadge.BackgroundColor3 = Color3.fromRGB(25, 65, 42)
SecurityBadge.Text = CurrentGame == "PixelBlade" and "🗡️ Pixel" or "⚔️ AOT:R"
SecurityBadge.TextColor3 = Color3.fromRGB(95, 240, 150)
SecurityBadge.Font = Enum.Font.GothamBold
SecurityBadge.TextSize = 11
SecurityBadge.Parent = Header

local badgeCorner = Instance.new("UICorner")
badgeCorner.CornerRadius = UDim.new(0, 6)
badgeCorner.Parent = SecurityBadge

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -40, 0, 7)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 42, 56)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.Parent = Header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = MinimizeBtn

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 152, 1, -52)
Sidebar.Position = UDim2.new(0, 8, 0, 46)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 23, 31)
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.Parent = MainFrame

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 8)
sideCorner.Parent = Sidebar

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 5)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = Sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 8)
sidePad.PaddingBottom = UDim.new(0, 8)
sidePad.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -174, 1, -52)
ContentArea.Position = UDim2.new(0, 166, 0, 46)
ContentArea.BackgroundColor3 = Color3.fromRGB(22, 23, 31)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = ContentArea

local Tabs = {}
local TabButtons = {}

local function selectTab(tabName)
    for _, p in pairs(Tabs) do p.Visible = false end
    for _, b in pairs(TabButtons) do
        b.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
        b.TextColor3 = Color3.fromRGB(200, 200, 210)
    end
    if Tabs[tabName] and TabButtons[tabName] then
        Tabs[tabName].Visible = true
        TabButtons[tabName].BackgroundColor3 = Color3.fromRGB(212, 175, 55)
        TabButtons[tabName].TextColor3 = Color3.fromRGB(16, 17, 23)
    end
end

local function createTab(tabName, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -12, 1, -12)
    page.Position = UDim2.new(0, 6, 0, 6)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(212, 175, 55)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 7)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page

    local pagePad = Instance.new("UIPadding")
    pagePad.PaddingTop = UDim.new(0, 4)
    pagePad.PaddingBottom = UDim.new(0, 8)
    pagePad.PaddingLeft = UDim.new(0, 4)
    pagePad.PaddingRight = UDim.new(0, 8)
    pagePad.Parent = page

    btn.MouseButton1Click:Connect(function()
        selectTab(tabName)
    end)

    Tabs[tabName] = page
    TabButtons[tabName] = btn
    return page
end

-- UI Component Helpers
local function addSectionHeader(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = Color3.fromRGB(230, 190, 75)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function addToggle(parent, labelText, initialVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
    row.BorderSizePixel = 0
    row.Parent = parent

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 6)
    rCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -66, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(235, 235, 240)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local state = initialVal and true or false
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 46, 0, 24)
    toggleBtn.Position = UDim2.new(1, -54, 0.5, -12)
    toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60, 195, 105) or Color3.fromRGB(60, 62, 78)
    toggleBtn.Text = state and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 11
    toggleBtn.Parent = row

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 6)
    tCorner.Parent = toggleBtn

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(60, 195, 105) or Color3.fromRGB(60, 62, 78)
        toggleBtn.Text = state and "ON" or "OFF"
        pcall(callback, state)
        saveConfig()
    end)
end

local function addCycleButton(parent, labelText, options, currentVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
    row.BorderSizePixel = 0
    row.Parent = parent

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 6)
    rCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.58, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(235, 235, 240)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local idx = table.find(options, currentVal) or 1
    local cycleBtn = Instance.new("TextButton")
    cycleBtn.Size = UDim2.new(0.38, -10, 0, 26)
    cycleBtn.Position = UDim2.new(0.62, 0, 0.5, -13)
    cycleBtn.BackgroundColor3 = Color3.fromRGB(48, 52, 70)
    cycleBtn.Text = tostring(options[idx])
    cycleBtn.TextColor3 = Color3.fromRGB(230, 195, 85)
    cycleBtn.Font = Enum.Font.GothamBold
    cycleBtn.TextSize = 11
    cycleBtn.Parent = row

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 6)
    cCorner.Parent = cycleBtn

    cycleBtn.MouseButton1Click:Connect(function()
        idx = (idx % #options) + 1
        cycleBtn.Text = tostring(options[idx])
        pcall(callback, options[idx])
        saveConfig()
    end)
end

local function addStepper(parent, labelText, minVal, maxVal, stepVal, initialVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
    row.BorderSizePixel = 0
    row.Parent = parent

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 6)
    rCorner.Parent = row

    local currentVal = initialVal

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. ": " .. tostring(currentVal)
    lbl.TextColor3 = Color3.fromRGB(235, 235, 240)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 32, 0, 24)
    minusBtn.Position = UDim2.new(1, -76, 0.5, -12)
    minusBtn.BackgroundColor3 = Color3.fromRGB(52, 54, 72)
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 14
    minusBtn.Parent = row

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 6)
    mCorner.Parent = minusBtn

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 32, 0, 24)
    plusBtn.Position = UDim2.new(1, -38, 0.5, -12)
    plusBtn.BackgroundColor3 = Color3.fromRGB(52, 54, 72)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 14
    plusBtn.Parent = row

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 6)
    pCorner.Parent = plusBtn

    local function updateValue(newVal)
        currentVal = math.clamp(tonumber(string.format("%.2f", newVal)) or minVal, minVal, maxVal)
        lbl.Text = labelText .. ": " .. tostring(currentVal)
        pcall(callback, currentVal)
        saveConfig()
    end

    minusBtn.MouseButton1Click:Connect(function()
        updateValue(currentVal - stepVal)
    end)

    plusBtn.MouseButton1Click:Connect(function()
        updateValue(currentVal + stepVal)
    end)
end

local function addActionButton(parent, labelText, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(235, 200, 90)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = parent

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

--//===========================================================================
--// BUILD TABS & CONTROLS (AOT:R + PIXEL BLADE + SHARED SECURITY)
--//===========================================================================

local TabPBFarm = createTab("🗡️ Pixel Blade قتال", 1)
local TabPBLoot = createTab("🎁 Pixel صناديق وبوابات", 2)
local TabFarm = createTab("⚔️ AOT:R الفارم", 3)
local TabCombat = createTab("⚡ AOT:R المساعدات", 4)
local TabMisc = createTab("🎲 AOT:R العائلات", 5)
local TabSecurity = createTab("🛡️ الحماية (Anti-Ban)", 6)
local TabESP = createTab("👁️ الرادار والفريمات", 7)

-- Automatically open the detected game's main tab first!
if CurrentGame == "PixelBlade" then
    selectTab("🗡️ Pixel Blade قتال")
else
    selectTab("⚔️ AOT:R الفارم")
end

-- ============================================================================
-- [PIXEL BLADE TAB 1: FARM & COMBAT]
-- ============================================================================
addSectionHeader(TabPBFarm, "🗡️ Pixel Blade - الفارم والقتال التلقائي")

addToggle(TabPBFarm, "فارم الدنجن التلقائي (Auto Farm Dungeon)", Config.PB_AutoFarmDungeon, function(val)
    Config.PB_AutoFarmDungeon = val
    State.PB_EnteredBossRoom = false
    if val then
        applyPBTempBuffAndHeal()
    end
end)

addToggle(TabPBFarm, "فارم الغارات التلقائي (Auto Farm Raids)", Config.PB_AutoFarmRaid, function(val)
    Config.PB_AutoFarmRaid = val
    if val then
        applyPBTempBuffAndHeal()
    end
end)

addToggle(TabPBFarm, "قتل جماعي تلقائي حولك (Kill Aura + Tornado)", Config.PB_KillAura, function(val)
    Config.PB_KillAura = val
end)

addStepper(TabPBFarm, "مدى الـ Kill Aura", 15, 150, 5, Config.PB_KillAuraRange, function(val)
    Config.PB_KillAuraRange = val
end)

addToggle(TabPBFarm, "تقوية الضرر الخارق + شفاء تلقائي (God Buff & Heal)", Config.PB_GodBuffAndHeal, function(val)
    Config.PB_GodBuffAndHeal = val
    if val then
        applyPBTempBuffAndHeal()
    end
end)

addToggle(TabPBFarm, "تكسير الصناديق/الأغراض تلقائياً (Auto Breakables)", Config.PB_AutoBreakables, function(val)
    Config.PB_AutoBreakables = val
end)

addSectionHeader(TabPBFarm, "🎯 تكبير هيت بوكس الأعداء (Hitbox Expander)")

addToggle(TabPBFarm, "تكبير هيت بوكس الأعداء (Expand Enemy Hitbox)", Config.PB_ExpandHitbox, function(val)
    Config.PB_ExpandHitbox = val
end)

addStepper(TabPBFarm, "حجم هيت بوكس الأعداء", 5, 80, 5, Config.PB_HitboxSize, function(val)
    Config.PB_HitboxSize = val
end)

-- ============================================================================
-- [PIXEL BLADE TAB 2: UPGRADES, CHESTS, WISHES & PORTALS]
-- ============================================================================
addSectionHeader(TabPBLoot, "⚡ الترقيات والصناديق والأمنيات (Pixel Blade)")

addToggle(TabPBLoot, "اختيار الترقية تلقائياً بالدنجن (Auto Pick Upgrade)", Config.PB_AutoUpgrade, function(val)
    Config.PB_AutoUpgrade = val
end)

addToggle(TabPBLoot, "إخفاء نافذة الترقية المزعجة (Hide Upgrade Popup)", Config.PB_HideUpgradePopup, function(val)
    Config.PB_HideUpgradePopup = val
end)

addToggle(TabPBLoot, "فتح جميع الصناديق بالحقيبة تلقائياً (Auto Open Chests)", Config.PB_AutoOpenChests, function(val)
    Config.PB_AutoOpenChests = val
end)

addToggle(TabPBLoot, "فتح الأمنيات تلقائياً (Auto Open Wishes)", Config.PB_AutoOpenWishes, function(val)
    Config.PB_AutoOpenWishes = val
end)

addToggle(TabPBLoot, "استلام المهام اليومية تلقائياً (Auto Claim Quests)", Config.PB_AutoClaimQuests, function(val)
    Config.PB_AutoClaimQuests = val
end)

addToggle(TabPBLoot, "استلام الإنجازات تلقائياً (Auto Claim Achievements)", Config.PB_AutoClaimAchievements, function(val)
    Config.PB_AutoClaimAchievements = val
end)

addSectionHeader(TabPBLoot, "🌀 دخول البوابات التلقائي (Auto Dungeon Portal)")

addCycleButton(TabPBLoot, "اختيار البوابة (Select Portal)", { "Grasslands", "AncientSands" }, Config.PB_SelectedDungeon, function(opt)
    Config.PB_SelectedDungeon = opt
end)

addCycleButton(TabPBLoot, "اختيار الصعوبة (Difficulty)", { "Normal", "Heroic", "Nightmare" }, Config.PB_SelectedDifficulty, function(opt)
    Config.PB_SelectedDifficulty = opt
end)

addToggle(TabPBLoot, "دخول البوابة تلقائياً (Auto Join Portal)", Config.PB_AutoJoinPortal, function(val)
    Config.PB_AutoJoinPortal = val
end)

addActionButton(TabPBLoot, "🏠 العودة إلى اللوبي في Pixel Blade (Return to Lobby)", function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
    end
end)

-- ============================================================================
-- [AOT:R TAB 3: AUTO FARM]
-- ============================================================================
addSectionHeader(TabFarm, "⚔️ AOT:R - قتل العمالقة بالسيوف (Auto Kill Blades)")

addToggle(TabFarm, "تفعيل القتل التلقائي (Auto Kill Titans)", Config.AutoKillBlades, function(val)
    Config.AutoKillBlades = val
    if val then
        State.FarmStartTimestamp = tick()
    elseif HumanoidRootPart then
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end
end)

addCycleButton(TabFarm, "طريقة الحركة (Move Mode)", { "Teleportation", "Gliding" }, Config.MoveMode, function(opt)
    Config.MoveMode = opt
end)

addStepper(TabFarm, "تأخير البدء بالثواني (Start Delay)", 0, 30, 1, Config.StartDelay, function(val)
    Config.StartDelay = val
end)

addStepper(TabFarm, "ارتفاع الطيران (Float Height)", 50, 350, 25, Config.FloatHeight, function(val)
    Config.FloatHeight = val
end)

addStepper(TabFarm, "سرعة الانزلاق (Glide Speed)", 100, 500, 25, Config.GlideSpeed, function(val)
    Config.GlideSpeed = val
end)

addSectionHeader(TabFarm, "رماح الرعد (Thunder Spears Farm)")

addToggle(TabFarm, "فارم رماح الرعد (Auto Thunder Spears)", Config.AutoFarmTS, function(val)
    Config.AutoFarmTS = val
    if not val then
        State.IsTSHovering = false
        State.TSHoverPos = nil
    end
end)

addCycleButton(TabFarm, "وضع رماح الرعد (TS Mode)", { "Safe", "Risk" }, Config.TSKillMode, function(opt)
    Config.TSKillMode = opt
end)

addSectionHeader(TabFarm, "تكبير نقطة الضعف والمهارات (Hitbox & Skills)")

addToggle(TabFarm, "تكبير رقبة العملاق (Expand Nape Hitbox)", Config.ExpandNapes, function(val)
    Config.ExpandNapes = val
    pcall(updateAllNapes)
end)

addStepper(TabFarm, "حجم الهيت بوكس (Nape Size)", 50, 1500, 50, Config.NapeSize, function(val)
    Config.NapeSize = val
    if Config.ExpandNapes then
        pcall(updateAllNapes)
    end
end)

addToggle(TabFarm, "تفعيل المهارات تلقائياً (Titan Ripper)", Config.TitanRipper, function(val)
    Config.TitanRipper = val
end)

-- ============================================================================
-- [AOT:R TAB 4: COMBAT & MISSIONS]
-- ============================================================================
addSectionHeader(TabCombat, "الذخيرة والتعبئة (شامل أوتغارد وجميع الخرائط)")

addToggle(TabCombat, "تبديل السيوف تلقائياً (Auto Reload Blades)", Config.AutoReloadBlades, function(val)
    Config.AutoReloadBlades = val
end)

addToggle(TabCombat, "إعادة التعبئة التلقائية (Auto Refill All Maps)", Config.AutoRefill, function(val)
    Config.AutoRefill = val
end)

addActionButton(TabCombat, "🔄 الانتقال لنقطة التعبئة والتعبئة فوراً (TP & Refill Now)", function()
    task.spawn(executeFullStationRefill)
end)

addToggle(TabCombat, "الهروب من مسكة العملاق (Auto Escape Grab)", Config.AutoEscapeGrab, function(val)
    Config.AutoEscapeGrab = val
end)

addSectionHeader(TabCombat, "المهمات والغارات (Missions & Raids)")

addToggle(TabCombat, "إعادة المهمة/الغارة تلقائياً (Auto Retry)", Config.AutoRetry, function(val)
    Config.AutoRetry = val
end)

addToggle(TabCombat, "تخطي المشاهد السينمائية (Auto Skip Cutscene)", Config.AutoSkipCutscene, function(val)
    Config.AutoSkipCutscene = val
end)

addToggle(TabCombat, "فتح الصندوق المجاني (Auto Free Chest)", Config.AutoFreeChest, function(val)
    Config.AutoFreeChest = val
end)

addToggle(TabCombat, "فتح الصندوق المميز (Auto Premium Chest)", Config.AutoPremiumChest, function(val)
    Config.AutoPremiumChest = val
end)

addToggle(TabCombat, "إشعارات القتل على الشاشة (Kill Notifications)", Config.KillNotifications, function(val)
    Config.KillNotifications = val
end)

-- ============================================================================
-- [AOT:R TAB 5: FAMILY ROLL & TELEPORT]
-- ============================================================================
addSectionHeader(TabMisc, "لفات العائلات في القائمة الرئيسية (AOT:R Family Roll)")

addToggle(TabMisc, "لف العائلات تلقائياً (Auto Family Roll)", Config.AutoRollFamily, function(val)
    Config.AutoRollFamily = val
end)

addToggle(TabMisc, "التوقف تلقائياً عند (Yeager / Ackerman / Reiss / Fritz)", Config.StopOnRareFamily, function(val)
    Config.StopOnRareFamily = val
end)

addStepper(TabMisc, "سرعة اللف بالثواني (Roll Delay)", 0.2, 5, 0.2, Config.RollInterval, function(val)
    Config.RollInterval = val
end)

addActionButton(TabMisc, "🎲 لف العائلة مرة واحدة الآن (Roll Once)", function()
    refreshRemotes()
    if Remotes.GET then
        task.spawn(function()
            pcall(function()
                Remotes.GET:InvokeServer("Family", "Roll")
            end)
        end)
    end
    local btn = findFamilyRollButton()
    if btn then
        smartClickButton(btn, 0, 0)
    end
end)

addSectionHeader(TabMisc, "التنقل السريع (AOT:R Quick Teleport)")

addActionButton(TabMisc, "🏠 الانتقال إلى لوبي AOT:R (Return to Lobby)", function()
    saveConfig()
    setupAutoExecuteOnTeleport()
    TeleportService:Teleport(AOTR_PLACE_IDS.Lobby, LocalPlayer)
end)

addActionButton(TabMisc, "🎮 الانتقال للقائمة الرئيسية AOT:R (Main Menu)", function()
    saveConfig()
    setupAutoExecuteOnTeleport()
    TeleportService:Teleport(AOTR_PLACE_IDS.MainMenu, LocalPlayer)
end)

-- ============================================================================
-- [SHARED TAB 6: 🛡️ SECURITY & ANTI-BAN]
-- ============================================================================
addSectionHeader(TabSecurity, "🛡️ أنظمة الحماية المشتركة وحفظ الإعدادات")

addToggle(TabSecurity, "تشغيل السكربت والإعدادات تلقائياً بالغارة/الدنجن القادم", Config.AutoExecuteOnTeleport, function(val)
    Config.AutoExecuteOnTeleport = val
    if val then setupAutoExecuteOnTeleport() end
end)

addToggle(TabSecurity, "حارس وقت مهمة AOT:R (ينتظر 20ث قبل قتل آخر عملاق)", Config.SafeMissionTimerGuard, function(val)
    Config.SafeMissionTimerGuard = val
end)

addStepper(TabSecurity, "الحد الآمن لإنهاء المهمة (ثانية)", 17, 45, 1, Config.MinSafeMissionSeconds, function(val)
    Config.MinSafeMissionSeconds = val
end)

addToggle(TabSecurity, "منع الطرد من الكلاينت (Anti-Kick Hook)", Config.AntiKick, function(val)
    Config.AntiKick = val
end)

addToggle(TabSecurity, "تمويه حجم الهيت بوكس عن فحص اللعبة (Hitbox Spoof)", Config.SpoofNapeProperties, function(val)
    Config.SpoofNapeProperties = val
end)

addToggle(TabSecurity, "أنسنة سرعة الضربات والضرر (Humanize Hits)", Config.HumanizeAttacks, function(val)
    Config.HumanizeAttacks = val
end)

addToggle(TabSecurity, "مانع الطيران العشوائي خارج الخريطة (Anti-Fling)", Config.VelocityAntiFling, function(val)
    Config.VelocityAntiFling = val
end)

addSectionHeader(TabSecurity, "👮 حماية ضد المشرفين والخمول (Staff & AFK)")

addToggle(TabSecurity, "إيقاف الفارم عند دخول مشرف/أدمن (Anti-Staff)", Config.AntiStaffProtection, function(val)
    Config.AntiStaffProtection = val
end)

addToggle(TabSecurity, "إيقاف الفارم إذا دخل لاعب غريب معك (Solo Safe)", Config.AntiStrangerInSolo, function(val)
    Config.AntiStrangerInSolo = val
end)

addToggle(TabSecurity, "مانع الطرد بسبب الخمول (Anti-AFK 24/7)", Config.AntiAFK, function(val)
    Config.AntiAFK = val
end)

addActionButton(TabSecurity, "🚨 زر الطوارئ: إيقاف كل التفعيلات فوراً (Panic Stop)", function()
    Config.AutoKillBlades = false
    Config.AutoFarmTS = false
    Config.ExpandNapes = false
    Config.TitanRipper = false
    Config.PB_AutoFarmDungeon = false
    Config.PB_AutoFarmRaid = false
    Config.PB_KillAura = false
    State.IsTSHovering = false
    State.TSHoverPos = nil
    saveConfig()
    pcall(updateAllNapes)
    pcall(clearESP)
    if HumanoidRootPart then
        HumanoidRootPart.Anchored = false
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end
end)

addActionButton(TabSecurity, "🗑️ مسح الإعدادات المحفوظة (Reset Saved Config)", function()
    if delfile and isfile then
        pcall(function()
            if isfile(CONFIG_FILE) then delfile(CONFIG_FILE) end
        end)
    end
    if getgenv then
        getgenv().AOTR_SavedConfig = nil
    end
end)

addActionButton(TabSecurity, "❌ إغلاق وحذف السكربت بالكامل (Unload Script)", function()
    if getgenv and getgenv().AOTR_Delta_Cleanup then
        getgenv().AOTR_Delta_Cleanup()
    end
end)

-- ============================================================================
-- [SHARED TAB 7: ESP & PERFORMANCE]
-- ============================================================================
addSectionHeader(TabESP, "الرادار المخفي (Stealth ESP)")

addToggle(TabESP, "كشف أعداء Pixel Blade (Pixel Blade Enemy ESP)", Config.PB_EnemyESP, function(val)
    Config.PB_EnemyESP = val
    if not val then clearESP() else pcall(updateESP) end
end)

addToggle(TabESP, "كشف عمالقة AOT:R (Titan Highlight ESP)", Config.TitanESP, function(val)
    Config.TitanESP = val
    if not val then clearESP() else pcall(updateESP) end
end)

addToggle(TabESP, "كشف نقاط التعبئة AOT:R (Refill Station ESP)", Config.RefillESP, function(val)
    Config.RefillESP = val
    if not val then clearESP() else pcall(updateESP) end
end)

addSectionHeader(TabESP, "تحسين الأداء والفريمات (FPS & Visuals)")

addToggle(TabESP, "إخفاء أرقام الضرر (Remove Damage Text)", Config.RemoveDamageText, function(val)
    Config.RemoveDamageText = val
    applyRemoveDamageText(val)
end)

addActionButton(TabESP, "🚀 تحسين الفريمات للجوال (FPS Boost)", function()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
    end)
end)

--// Toggle Menu Visibility
local function toggleMainWindow()
    MainFrame.Visible = not MainFrame.Visible
    FloatButton.BackgroundColor3 = MainFrame.Visible and Color3.fromRGB(22, 22, 30) or Color3.fromRGB(45, 25, 25)
end

FloatButton.MouseButton1Click:Connect(toggleMainWindow)
MinimizeBtn.MouseButton1Click:Connect(toggleMainWindow)

table.insert(State.Connections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Delete then
        toggleMainWindow()
    end
end))

--// Global Cleanup Function
local function cleanupScript()
    State.Running = false
    Config.AutoKillBlades = false
    Config.AutoFarmTS = false
    Config.ExpandNapes = false
    Config.PB_AutoFarmDungeon = false
    Config.PB_AutoFarmRaid = false
    Config.PB_KillAura = false
    pcall(function()
        if HumanoidRootPart then HumanoidRootPart.Anchored = false end
    end)
    pcall(updateAllNapes)
    pcall(clearESP)

    if charAddedConn then
        pcall(function() charAddedConn:Disconnect() end)
    end
    if dmgTextConn then
        pcall(function() dmgTextConn:Disconnect() end)
    end
    for _, conn in ipairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, notif in ipairs(State.ActiveNotifs) do
        pcall(function() notif:Destroy() end)
    end
    if StealthESPFolder and StealthESPFolder.Parent then
        pcall(function() StealthESPFolder:Destroy() end)
    end
    if ScreenGui and ScreenGui.Parent then
        pcall(function() ScreenGui:Destroy() end)
    end
end

if getgenv then
    getgenv().AOTR_Delta_Cleanup = cleanupScript
end

print("[🛡️ Delta Multi-Hub v3.0] Loaded! Active Game Detected: " .. tostring(CurrentGame))
