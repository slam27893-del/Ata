--[[
    ============================================================================
    ⚔️ Multi-Game Delta Hub [PROTECTED v3.5 - Auto-Detect & Auto-Save]
    Supported Games:
      1. Attack on Titan: Revolution (AOT:R) - All Maps & Raids
      2. Pixel Blade (Dungeon Farm, Auto Breakables, 1-Shot Kill, Auto Chests & Turbo Fish)
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
        HumanoidRootPart = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 10)
        Humanoid = char:FindFirstChildWhichIsA("Humanoid") or char:WaitForChild("Humanoid", 10)
    else
        HumanoidRootPart = nil
        Humanoid = nil
    end
end

local function refreshCharacterRefs()
    local rawPlr = game:GetService("Players").LocalPlayer or LocalPlayer
    local curChar = (rawPlr and rawPlr.Character) or LocalPlayer.Character
    if not curChar or not curChar.Parent then
        if rawPlr and rawPlr.DisplayName and rawPlr.DisplayName ~= "" then
            curChar = workspace:FindFirstChild(rawPlr.DisplayName)
        end
        if (not curChar or not curChar.Parent) and rawPlr and rawPlr.Name then
            curChar = workspace:FindFirstChild(rawPlr.Name)
        end
    end
    if curChar ~= Character then
        Character = curChar
        HumanoidRootPart = curChar and (curChar:FindFirstChild("HumanoidRootPart") or curChar.PrimaryPart or curChar:FindFirstChildWhichIsA("BasePart"))
        Humanoid = curChar and curChar:FindFirstChildWhichIsA("Humanoid")
    elseif curChar then
        if not HumanoidRootPart or not HumanoidRootPart.Parent then
            HumanoidRootPart = curChar:FindFirstChild("HumanoidRootPart") or curChar.PrimaryPart or curChar:FindFirstChildWhichIsA("BasePart")
        end
        if not Humanoid or not Humanoid.Parent then
            Humanoid = curChar:FindFirstChildWhichIsA("Humanoid")
        end
    end
    return Character, HumanoidRootPart, Humanoid
end

if Character then
    task.spawn(updateCharacterRefs, Character)
end

local charAddedConn = LocalPlayer.CharacterAdded:Connect(updateCharacterRefs)

--//===========================================================================
--// 🎮 AUTOMATIC GAME DETECTOR (AOT:R vs PIXEL BLADE)
--//===========================================================================

local PIXEL_BLADE_PLACE_IDS = {
    [18172550962] = true,
    [18172553902] = true
}

local AOTR_ALL_PLACE_IDS = {
    [13379208636] = true, [15393224326] = true, -- Main Menu
    [14916516914] = true, [15393230099] = true, -- Lobby
    [13379349730] = true, [17373821193] = true, -- Shiganshina
    [14012874501] = true, [15393230324] = true, -- Trost
    [14638336319] = true, [17373828240] = true, -- Giant Forest
    [13904207646] = true, [17373824844] = true, -- Outskirts
    [15220308770] = true, [18182863694] = true, -- Utgard
    [17688739434] = true, [110415968652032] = true, -- Docks
    [15824912319] = true, [139092911630535] = true, -- Stohess
    [126678335159530] = true, [133979984250876] = true -- Chapel
}

local AOTR_PLACE_IDS = {
    MainMenu = 13379208636,
    Lobby = 14916516914
}

local function checkGameSignatures()
    if PIXEL_BLADE_PLACE_IDS[game.PlaceId] then
        return "PixelBlade"
    end
    if AOTR_ALL_PLACE_IDS[game.PlaceId] then
        return "AOTR"
    end

    local pbRem = ReplicatedStorage:FindFirstChild("remotes")
    if pbRem and (
        pbRem:FindFirstChild("onHit")
        or pbRem:FindFirstChild("abilityHit")
        or pbRem:FindFirstChild("plrUpgrade")
        or pbRem:FindFirstChild("playerTP")
        or pbRem:FindFirstChild("swing")
    ) then
        return "PixelBlade"
    end
    if LocalPlayer:FindFirstChild("plrStats")
        or PlayerGui:FindFirstChild("gameUI")
        or workspace:FindFirstChild("worldType")
        or workspace:FindFirstChild("inCutscene")
        or ReplicatedStorage:FindFirstChild("constants") then
        return "PixelBlade"
    end

    local aotAssets = ReplicatedStorage:FindFirstChild("Assets")
    if aotAssets and aotAssets:FindFirstChild("Remotes") then
        return "AOTR"
    end
    if PlayerGui:FindFirstChild("Interface") or workspace:FindFirstChild("Titans") or workspace:FindFirstChild("Unclimbable") then
        return "AOTR"
    end

    return nil
end

local function detectCurrentGame()
    local detected = checkGameSignatures()
    if detected then return detected end
    local waitUntil = tick() + 3.0
    while tick() < waitUntil do
        task.wait(0.1)
        detected = checkGameSignatures()
        if detected then return detected end
    end
    return "PixelBlade"
end

local CurrentGame = detectCurrentGame()

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
    PB_KillAuraRange = 60,
    PB_GodBuffAndHeal = false,
    PB_AutoBreakables = true,
    PB_BringMobs = true,
    PB_ExpandHitbox = true,
    PB_HitboxSize = 35,
    PB_AutoUpgrade = false,
    PB_HideUpgradePopup = true,
    PB_AutoOpenChests = false,
    PB_AutoOpenWishes = false,
    PB_AutoClaimQuests = false,
    PB_AutoClaimAchievements = false,
    PB_SelectedDungeon = "Grasslands",
    PB_SelectedDifficulty = "Normal",
    PB_AutoJoinPortal = false,
    PB_EnemyESP = false,
    PB_InfDashAndNoCD = false,

    -- [Game 2] Pixel Blade Auto Fishing (الصيد التلقائي السريع بالصنارة)
    PB_AutoFish = false,
    PB_AutoEquipRod = true,
    PB_AutoFishMinigame = true,
    PB_FishSmartCycle = true,
    PB_FishCastHold = 0.6,
    PB_FishGreenHold = 1.0,
    PB_FishFollowGreenHold = 0.8,
    PB_FishTapCount = 16,
    PB_FishTapInterval = 0.015,
    PB_FishPostWait = 0.35,
    PB_FishTimeout = 5
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
        -- Upgrade legacy v3.1/v3.2 settings automatically to v3.3
        if Config.PB_FishTapInterval and Config.PB_FishTapInterval >= 0.05 then
            Config.PB_FishTapInterval = 0.015
        end
        if Config.PB_FishPostWait and Config.PB_FishPostWait >= 1.2 then
            Config.PB_FishPostWait = 0.35
        end
        if Config.PB_FishTimeout and Config.PB_FishTimeout >= 12 then
            Config.PB_FishTimeout = 5
        end
        if Config.PB_FishCastHold and Config.PB_FishCastHold >= 1.0 then
            Config.PB_FishCastHold = 0.6
        end
        if Config.PB_FishGreenHold and Config.PB_FishGreenHold >= 1.4 then
            Config.PB_FishGreenHold = 1.0
        end
        if Config.PB_KillAuraRange and Config.PB_KillAuraRange < 50 then
            Config.PB_KillAuraRange = 60
        end
        if Config.PB_HitboxSize and Config.PB_HitboxSize < 30 then
            Config.PB_HitboxSize = 35
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
            loadstring(game:HttpGet("%s?v=" .. tostring(os.time())))()
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
    PB_EnteredBossRoom = false,
    PB_ActiveTargetCFrame = nil,
    PB_LastSafeY = nil,
    PB_LastM1Time = 0,
    PB_LastAdvanceTime = 0,
    PB_LastRoomTPTime = 0,
    PB_CurrentTargetModel = nil,
    PB_CurrentTargetStartTime = 0,
    PB_CurrentTargetStartHP = 0,
    PB_TempSkipMobs = {},
    PB_CachedModels = {},
    PB_LastModelScanTime = 0,
    PB_OpenedWorkspaceChests = {},
    PB_LastVisitedRoomName = nil,
    PB_RoomWaypointIndex = 1,
    PB_DungeonStatusText = "متوقف (جاهز للتشغيل)",
    PB_OpeningChestsBusy = false,
    PB_FishCaughtCount = 0,
    PB_LastCastTime = 0,
    PB_CachedFishPrompt = nil,
    PB_LastFishPromptScan = 0,
    PB_BaselineGuiSet = {},
    PB_FishStatusText = "في انتظار التفعيل..."
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
--// 🗡️ GAME 2 MODULE: PIXEL BLADE FUNCTIONS (DUNGEONS, RAIDS, BREAKABLES, LOOT)
--//===========================================================================

local PB_IGNORE_MOBS = {
    "ShroomKnight",
    "blender",
    "CamnpfireRocky",
    "CampfireRocky"
}

-- Strict non-combat prop/NPC keywords (NEVER include "shroom", "knight", or "breakable"/"box"/"pot" here!)
local PB_NON_ENEMY_KEYWORDS = {
    "chest", "loot", "shroomknight", "blender", "campfire", "camnpfire",
    "rig", "npc", "merchant", "shop", "statue", "portal", "door", "gate",
    "dummy", "stand", "anvil", "forge", "fountain", "torch", "lantern",
    "pillar", "wall", "floor", "ceiling", "spawn", "exitzone", "cutscene"
}

local PB_BREAKABLE_KEYWORDS = {
    "breakable", "crate", "barrel", "box", "pot", "vase", "jar", "urn",
    "destruct", "crystal"
}

local function getPBRawCharacter()
    local rawPlr = game:GetService("Players").LocalPlayer or LocalPlayer
    if not rawPlr then return Character end
    local byDisplay = (rawPlr.DisplayName ~= rawPlr.Name) and workspace:FindFirstChild(rawPlr.DisplayName) or nil
    local byName = workspace:FindFirstChild(rawPlr.Name)
    return byDisplay or byName or rawPlr.Character or Character
end

-- Exact Weapon Base Damage reader from require(LocalPlayer.plrStats).wpnStats.Dmg
-- Passes the server's anti-cheat damage cap check (damage <= wpnStats.Dmg) while tempbuff 550,000,000% multiplies it!
local function currentPBWeaponDamage()
    local dmg = 9
    pcall(function()
        local rawPlr = game:GetService("Players").LocalPlayer or LocalPlayer
        local statsMod = rawPlr and rawPlr:FindFirstChild("plrStats")
        if statsMod then
            local ok, stats = pcall(require, statsMod)
            if ok and type(stats) == "table" and type(stats.wpnStats) == "table" then
                for k, v in next, stats.wpnStats do
                    if k == "Dmg" and type(v) == "number" and v > 0 then
                        dmg = v
                    end
                end
            end
        end
    end)
    return dmg
end

local function isPBChestModel(mob)
    if not mob or not mob:IsA("Model") then return false end
    if mob:FindFirstChild("Root") and mob:FindFirstChild("Top") then
        return true
    end
    local low = string.lower(mob.Name)
    return string.find(low, "chest", 1, true) ~= nil
end

local function isPBBreakableModel(mob)
    if not mob or not mob:IsA("Model") then return false end
    if isPBChestModel(mob) then return false end
    local low = string.lower(mob.Name)
    for _, kw in ipairs(PB_BREAKABLE_KEYWORDS) do
        if string.find(low, kw, 1, true) then
            return true
        end
    end
    -- Highlighted small breakables/pots in Chapter 1/3 that lack HumanoidRootPart
    local hl = mob:FindFirstChildOfClass("Highlight")
    if hl and hl.Enabled and not mob:FindFirstChild("HumanoidRootPart") and mob.Name ~= "Maneater" and mob.Name ~= "BookHand" then
        return true
    end
    return false
end

local function isPBChestOrPropModel(mob)
    if not mob or not mob:IsA("Model") then return true end
    if table.find(PB_IGNORE_MOBS, mob.Name) then return true end
    if isPBChestModel(mob) then return true end
    if mob:FindFirstChildOfClass("ClickDetector") or mob:FindFirstChildOfClass("Dialog") then
        return true
    end
    local low = string.lower(mob.Name)
    for _, kw in ipairs(PB_NON_ENEMY_KEYWORDS) do
        if string.find(low, kw, 1, true) then
            return true
        end
    end
    return false
end

-- Deep Workspace Scanner (pixelNerdV1 2026 + Descendant Humanoid/Highlight discovery)
-- Finds all enemies & breakables whether top-level in workspace OR nested inside Room Folders/Models!
local function collectAllPBModels()
    local now = tick()
    if State.PB_CachedModels and #State.PB_CachedModels > 0 and (now - (State.PB_LastModelScanTime or 0)) < 0.12 then
        return State.PB_CachedModels
    end
    State.PB_LastModelScanTime = now

    local list = {}
    local seen = {}
    local rawChar = getPBRawCharacter()

    local function addCandidate(m)
        if m and m:IsA("Model") and not seen[m] and m ~= Character and m ~= rawChar then
            seen[m] = true
            table.insert(list, m)
        end
    end

    -- 1. Top-level workspace children + 2 levels of Folder/Model containers (pixelNerdV1 2026 pattern)
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") then
            addCandidate(child)
            for _, sub in ipairs(child:GetChildren()) do
                if sub:IsA("Model") then
                    addCandidate(sub)
                elseif sub:IsA("Folder") then
                    for _, sub2 in ipairs(sub:GetChildren()) do
                        if sub2:IsA("Model") then
                            addCandidate(sub2)
                        end
                    end
                end
            end
        elseif child:IsA("Folder") then
            for _, sub in ipairs(child:GetChildren()) do
                if sub:IsA("Model") then
                    addCandidate(sub)
                    for _, sub2 in ipairs(sub:GetChildren()) do
                        if sub2:IsA("Model") then
                            addCandidate(sub2)
                        end
                    end
                elseif sub:IsA("Folder") then
                    for _, sub2 in ipairs(sub:GetChildren()) do
                        if sub2:IsA("Model") then
                            addCandidate(sub2)
                        end
                    end
                end
            end
        end
    end

    -- 2. Descendant Humanoids, Highlights, BookHands, and Worms (catches 100% of deeply nested room enemies & breakables)
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("Humanoid") or (desc:IsA("Highlight") and desc.Enabled) or desc.Name == "worm" or desc.Name == "basehitbox" then
            local p = desc.Parent
            if p and p:IsA("Model") then
                addCandidate(p)
            elseif p and p.Parent and p.Parent:IsA("Model") then
                addCandidate(p.Parent)
            end
        elseif desc:IsA("Model") and desc.Name == "BookHand" then
            addCandidate(desc)
        end
    end

    State.PB_CachedModels = list
    return list
end

local function getPBMobTargetPart(mob)
    if not mob or not mob:IsA("Model") then return nil end
    if isPBChestOrPropModel(mob) then return nil end
    if mob.Name == "Maneater" then
        local r = mob:FindFirstChild("Root") or mob:FindFirstChild("HumanoidRootPart")
        if r and r:IsA("BasePart") then return r end
    end
    if mob.Name == "BookHand" then
        local bh = mob:FindFirstChild("basehitbox", true) or mob.PrimaryPart
        if bh and bh:IsA("BasePart") then return bh end
    end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then
        return hrp
    end
    -- pixelNerdV1 2026 & Mana-scripts fallback for custom enemies and breakable boxes/pots
    if mob.PrimaryPart and mob.PrimaryPart:IsA("BasePart") then
        return mob.PrimaryPart
    end
    local bh = mob:FindFirstChild("basehitbox") or mob:FindFirstChild("basehitbox", true)
    if bh and bh:IsA("BasePart") then
        return bh
    end
    local part = mob:FindFirstChildOfClass("Part") or mob:FindFirstChildOfClass("MeshPart") or mob:FindFirstChildWhichIsA("BasePart", true)
    if part and part:IsA("BasePart") then
        return part
    end
    return nil
end

local function getPBMobCurrentHP(mob)
    if not mob or not mob:IsA("Model") then return 0 end
    local worldType = workspace:FindFirstChild("worldType")
    local isAncientSands = worldType and worldType.Value == "AncientSands"
    if isAncientSands and mob:FindFirstChild("worm") and mob.worm:FindFirstChild("Health") then
        return tonumber(mob.worm.Health.Value) or 0
    end
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if hum then
        return tonumber(hum.Health) or 0
    end
    local hpVal = mob:FindFirstChild("Health") or (mob.Name == "BookHand" and mob:FindFirstChild("Health", true))
    if hpVal and (hpVal:IsA("NumberValue") or hpVal:IsA("IntValue") or hpVal:IsA("DoubleConstrainedValue")) then
        return tonumber(hpVal.Value) or 0
    end
    local attrHP = mob:GetAttribute("Health") or mob:GetAttribute("HP")
    if type(attrHP) == "number" then
        return attrHP
    end
    local hl = mob:FindFirstChildOfClass("Highlight")
    if hl and hl.Enabled then
        return 100
    end
    return 0
end

local function isPBMobAlive(mob)
    if not mob or not mob:IsA("Model") or not mob.Parent then return false end
    local rawChar = getPBRawCharacter()
    if mob == Character or mob == rawChar or Players:GetPlayerFromCharacter(mob) then return false end
    if mob.Name == LocalPlayer.Name or mob.Name == LocalPlayer.DisplayName then return false end
    if isPBChestOrPropModel(mob) then return false end

    local worldType = workspace:FindFirstChild("worldType")
    local isAncientSands = worldType and worldType.Value == "AncientSands"
    if isAncientSands and mob:FindFirstChild("worm") and mob.worm:FindFirstChild("Health") then
        return mob.worm.Health.Value > 0
    end

    if mob.Name == "BookHand" then
        local hpVal = mob:FindFirstChild("Health", true)
        if hpVal and hpVal:IsA("NumberValue") then
            return hpVal.Value > 0
        end
    end

    local hum = mob:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.Health <= 0 then
            return false
        end
        local hpVal = mob:FindFirstChild("Health")
        if hpVal and (hpVal:IsA("NumberValue") or hpVal:IsA("IntValue")) and hpVal.Value <= 0 then
            return false
        end
        return true
    end

    local hpVal = mob:FindFirstChild("Health")
    if hpVal and (hpVal:IsA("NumberValue") or hpVal:IsA("IntValue")) then
        return hpVal.Value > 0
    end

    local attrHP = mob:GetAttribute("Health") or mob:GetAttribute("HP")
    if type(attrHP) == "number" then
        return attrHP > 0
    end

    -- Highlighted breakable/pot in Chapter 1/3 without Humanoid
    local hl = mob:FindFirstChildOfClass("Highlight")
    if hl and hl.Enabled and isPBBreakableModel(mob) then
        local p = getPBMobTargetPart(mob)
        if p and p.Transparency < 0.95 then
            return true
        end
    end

    return false
end

-- 5-Tier Smart Target Finder (Finds Enemies & Breakables at ANY nesting depth + Fast Anti-Stuck Skipper)
local function findBestPBTarget(isRaid)
    refreshCharacterRefs()
    if not Character or not HumanoidRootPart then return nil, nil end
    local myPos = HumanoidRootPart.Position
    local rawChar = getPBRawCharacter()
    local now = tick()

    for m, expTime in pairs(State.PB_TempSkipMobs) do
        if not m or not m.Parent or now >= expTime then
            State.PB_TempSkipMobs[m] = nil
        end
    end

    local tier1Mob, tier1Part, tier1Dist = nil, nil, math.huge -- Bosses / BookHand
    local tier2Mob, tier2Part, tier2Dist = nil, nil, math.huge -- Active Enemies (hadEntrance == true or Highlighted Enemy)
    local tier3Mob, tier3Part, tier3Dist = nil, nil, math.huge -- Standard Living Enemies (Humanoid + HRP/PrimaryPart)
    local tier4Mob, tier4Part, tier4Dist = nil, nil, math.huge -- Waiting Enemies (hadEntrance == false)
    local tier5Mob, tier5Part, tier5Dist = nil, nil, math.huge -- Breakable Boxes / Crates / Pots

    local allModels = collectAllPBModels()

    for _, m in ipairs(allModels) do
        if m and m.Parent and m ~= Character and m ~= rawChar and not State.PB_TempSkipMobs[m] then
            if not Players:GetPlayerFromCharacter(m) and not isPBChestOrPropModel(m) and isPBMobAlive(m) then
                local part = getPBMobTargetPart(m)
                if part then
                    local d = (part.Position - myPos).Magnitude
                    local isBreakable = isPBBreakableModel(m)
                    local entranceAttr = m:GetAttribute("hadEntrance")
                    local hasHighlight = m:FindFirstChildOfClass("Highlight") ~= nil

                    if m.Name == "BookHand" or m.Name == "Maneater" or m.Name == "Atticus" or m.Name == "LumberJack" then
                        if d < tier1Dist then
                            tier1Dist = d
                            tier1Mob = m
                            tier1Part = part
                        end
                    elseif isBreakable then
                        if Config.PB_AutoBreakables or Config.PB_AutoFarmDungeon then
                            -- If a breakable box is right next to us (< 22 studs), smash it along the way; otherwise Tier 5
                            if d < tier5Dist then
                                tier5Dist = d
                                tier5Mob = m
                                tier5Part = part
                            end
                        end
                    elseif entranceAttr == true or (hasHighlight and m:FindFirstChild("HumanoidRootPart")) then
                        if d < tier2Dist then
                            tier2Dist = d
                            tier2Mob = m
                            tier2Part = part
                        end
                    elseif entranceAttr == false then
                        if d < tier4Dist then
                            tier4Dist = d
                            tier4Mob = m
                            tier4Part = part
                        end
                    else
                        -- Standard living enemy (pixelNerdV1 2026 & WPBUNBLCOKER 2026)
                        if d < tier3Dist then
                            tier3Dist = d
                            tier3Mob = m
                            tier3Part = part
                        end
                    end
                end
            end
        end
    end

    local chosenMob = tier1Mob or tier2Mob or tier3Mob or tier4Mob or tier5Mob
    local chosenPart = tier1Part or tier2Part or tier3Part or tier4Part or tier5Part

    -- Fast Anti-Stuck Target Monitor:
    -- Breakables skip after 1.2s if HP doesn't drop; non-entrance models skip after 3.0s if HP doesn't drop!
    if chosenMob then
        local curHP = getPBMobCurrentHP(chosenMob)
        local isBrk = isPBBreakableModel(chosenMob)
        local maxStuckTime = isBrk and 1.2 or 3.0
        local skipDuration = isBrk and 20 or 8

        if State.PB_CurrentTargetModel ~= chosenMob then
            State.PB_CurrentTargetModel = chosenMob
            State.PB_CurrentTargetStartTime = now
            State.PB_CurrentTargetStartHP = curHP
        else
            if curHP < State.PB_CurrentTargetStartHP then
                State.PB_CurrentTargetStartTime = now
                State.PB_CurrentTargetStartHP = curHP
            elseif (now - State.PB_CurrentTargetStartTime) > maxStuckTime and (isBrk or chosenMob:GetAttribute("hadEntrance") ~= true) then
                State.PB_TempSkipMobs[chosenMob] = now + skipDuration
                State.PB_CurrentTargetModel = nil
                return nil, nil
            end
        end
    else
        State.PB_CurrentTargetModel = nil
    end

    return chosenMob, chosenPart
end

-- Multi-Method Positive Damage Sender (NEVER sends -math.huge which heals Humanoids!)
-- Combines:
-- 1. thha3203 v1/v2: onHit(target, wpnDmg, {}, 0)
-- 2. pixelNerdV1 (June 2026): multi-hit loop onHit(target, 9, {}, 0) (passes Lv.1/2 starter sword cap + 550,000,000% tempbuff!)
-- 3. WPBUNBLCOKER (April 2026): onHit(target, 9999999999, {}, 0)
-- 4. thha3203 v5 & TexRBLX final.lua: useAbility("tornado") + abilityHit(hum, math.huge, {stun={dur=1}})
-- 5. Physical TouchHitbox (firetouchinterest) for breakables/pots & close-range sword hits
local function pbDamageModel(v, wpnDmg)
    if not v or not v:IsA("Model") then return end
    local pbRemotes = getPBRemotes()
    if not pbRemotes then return end

    local swing = pbRemotes:FindFirstChild("swing")
    local onHit = pbRemotes:FindFirstChild("onHit")
    local useAbility = pbRemotes:FindFirstChild("useAbility")
    local abilityHit = pbRemotes:FindFirstChild("abilityHit")

    local hum = v:FindFirstChildOfClass("Humanoid") or v:FindFirstChild("Humanoid")
    local targetObj = hum
    local worldType = workspace:FindFirstChild("worldType")
    if worldType and worldType.Value == "AncientSands" and v:FindFirstChild("worm") and v.worm:FindFirstChild("Health") then
        targetObj = v.worm
    end
    if not targetObj then
        targetObj = v:FindFirstChild("Health") or v
    end

    pcall(function()
        if swing then
            swing:FireServer()
        end
        if onHit and targetObj then
            if wpnDmg and wpnDmg > 0 then
                onHit:FireServer(targetObj, wpnDmg, {}, 0)
            end
            -- pixelNerdV1 (2026) multi-hit with base 9 damage (guaranteed <= starter sword Dmg!)
            for _ = 1, 5 do
                if hum and hum.Health <= 0 then break end
                onHit:FireServer(targetObj, 9, {}, 0)
            end
            -- WPBUNBLCOKER (2026) uncapped hit
            onHit:FireServer(targetObj, 9999999999, {}, 0)
        end
        if abilityHit and (hum or targetObj) then
            local aTarget = hum or targetObj
            if useAbility then
                useAbility:FireServer("tornado")
            end
            abilityHit:FireServer(aTarget, math.huge, { ["stun"] = { ["dur"] = 1 } })
            abilityHit:FireServer(aTarget, 9999999999, { ["stun"] = { ["dur"] = 0.001 } })
        end
        if v.Name == "Maneater" and useAbility then
            useAbility:FireServer("lunarSpell")
        end
    end)

    -- Touch interest on target part if close (triggers physical sword/character touch hitboxes on boxes & mobs)
    if firetouchinterest and HumanoidRootPart then
        local tPart = getPBMobTargetPart(v)
        if tPart and (tPart.Position - HumanoidRootPart.Position).Magnitude <= 30 then
            pcall(function()
                firetouchinterest(HumanoidRootPart, tPart, 0)
                firetouchinterest(HumanoidRootPart, tPart, 1)
                if Character then
                    local tool = Character:FindFirstChildOfClass("Tool")
                    if tool then
                        for _, bp in ipairs(tool:GetDescendants()) do
                            if bp:IsA("BasePart") then
                                firetouchinterest(bp, tPart, 0)
                                firetouchinterest(bp, tPart, 1)
                            end
                        end
                    end
                end
            end)
        end
    end
end

-- Break All Breakable Boxes/Crates/Pots Across Entire Workspace (Including Inside Room Folders/Models)
local function pbBreakAllBreakables()
    if not (Config.PB_AutoBreakables or Config.PB_AutoFarmDungeon or Config.PB_KillAura) then return end
    local wpnDmg = currentPBWeaponDamage()
    local allModels = collectAllPBModels()

    for _, v in ipairs(allModels) do
        if v and v.Parent and isPBBreakableModel(v) and isPBMobAlive(v) then
            pbDamageModel(v, wpnDmg)
        end
    end
end

-- Multi-Stage Room Progression & Archway Advance (Rooms "1" -> "2" -> ... -> "25", BossRoom, Vault, ExitZone)
local function advancePBDungeonRoom()
    refreshCharacterRefs()
    if not HumanoidRootPart then return end
    local myPos = HumanoidRootPart.Position
    local now = tick()

    -- 1. Trigger any nearby enabled ProximityPrompt (doors, levers, chests, room transitions)
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled then
            local p = desc.Parent
            if p and p:IsA("Model") then
                p = p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart", true)
            end
            if p and p:IsA("BasePart") and (p.Position - myPos).Magnitude <= 50 then
                pcall(function()
                    if fireproximityprompt then fireproximityprompt(desc) end
                    desc:InputHoldBegin()
                    task.wait(0.03)
                    desc:InputHoldEnd()
                end)
            end
        end
    end

    -- 2. Check for ExitZone anywhere in workspace
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc.Name == "ExitZone" and desc:IsA("BasePart") then
            HumanoidRootPart.CFrame = desc.CFrame + Vector3.new(0, 3, 0)
            return
        end
    end

    -- 3. Sequential Numbered Dungeon Room Progression ("2" .. "25" + "BossRoom" + "Vault")
    if (now - (State.PB_LastRoomTPTime or 0)) > 1.0 then
        local highestRoomModel = nil
        local highestRoomNum = -1

        local function scanContainerForRooms(container)
            if not container then return end
            for _, child in ipairs(container:GetChildren()) do
                local num = tonumber(child.Name)
                if num and num >= 2 and num <= 30 and (child:IsA("Model") or child:IsA("Folder") or child:IsA("BasePart")) then
                    if num > highestRoomNum then
                        highestRoomNum = num
                        highestRoomModel = child
                    end
                end
            end
        end

        scanContainerForRooms(workspace)
        scanContainerForRooms(workspace:FindFirstChild("Rooms"))
        scanContainerForRooms(workspace:FindFirstChild("Map"))
        scanContainerForRooms(workspace:FindFirstChild("Dungeon"))

        local bossRoom = workspace:FindFirstChild("BossRoom") or workspace:FindFirstChild("20")
        if not highestRoomModel and bossRoom then
            highestRoomModel = bossRoom
        end

        if highestRoomModel then
            local targetPos = nil
            pcall(function()
                if highestRoomModel:IsA("Model") then
                    targetPos = highestRoomModel:GetPivot().Position + Vector3.new(0, 5, 0)
                elseif highestRoomModel:IsA("BasePart") then
                    targetPos = highestRoomModel.Position + Vector3.new(0, 5, 0)
                else
                    local bp = highestRoomModel:FindFirstChildWhichIsA("BasePart", true)
                    if bp then
                        targetPos = bp.Position + Vector3.new(0, 5, 0)
                    end
                end
            end)

            if targetPos and (targetPos - myPos).Magnitude > 10 then
                State.PB_LastRoomTPTime = now
                State.PB_LastVisitedRoomName = highestRoomModel.Name
                HumanoidRootPart.CFrame = CFrame.new(targetPos)
                return
            end
        end
    end

    -- 4. Raycast-Verified Safe Ground Step Forward (walks smoothly through archways when waiting for next room trigger)
    if (now - (State.PB_LastAdvanceTime or 0)) > 0.7 then
        State.PB_LastAdvanceTime = now
        local lookDir = HumanoidRootPart.CFrame.LookVector
        local flatDir = Vector3.new(lookDir.X, 0, lookDir.Z)
        if flatDir.Magnitude > 0.05 then
            flatDir = flatDir.Unit
        else
            flatDir = Vector3.new(0, 0, -1)
        end

        local candidatePos = myPos + (flatDir * 16) + Vector3.new(0, 6, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = { Character, getPBRawCharacter() }

        local hit = workspace:Raycast(candidatePos, Vector3.new(0, -35, 0), rayParams)
        if hit and hit.Position then
            HumanoidRootPart.CFrame = CFrame.lookAt(hit.Position + Vector3.new(0, 3.5, 0), hit.Position + Vector3.new(0, 3.5, 0) + flatDir)
        end
    end
end

local function computePBTargetCFrame(mob, part)
    if not mob or not part then return nil end
    if mob.Name == "Maneater" then
        local root = mob:FindFirstChild("Root") or part
        local mobPos = Vector3.new(root.Position.X, 35, root.Position.Z)
        local targetPos = mobPos + (root.CFrame.LookVector * -8)
        return CFrame.lookAt(targetPos, mobPos)
    elseif mob.Name == "Nekros" or mob.Name == "DarkNekros" then
        local mobPos = part.Position
        local targetPos = mobPos + (part.CFrame.LookVector * 2)
        return CFrame.lookAt(targetPos, mobPos)
    elseif mob.Name == "BookHand" then
        return part.CFrame * CFrame.new(0, 0, 5)
    elseif isPBBreakableModel(mob) then
        local mobPos = part.Position
        local targetPos = mobPos + Vector3.new(0, 2.5, 3.5)
        return CFrame.lookAt(targetPos, mobPos)
    else
        local mobPos = part.Position
        local targetPos = mobPos + (part.CFrame.LookVector * -4.5) + Vector3.new(0, 1.5, 0)
        return CFrame.lookAt(targetPos, mobPos)
    end
end

-- God Damage Buff (550,000,000%) + Speed + Auto Heal (thha3203 v5 + TexRBLX final.lua)
local function applyPBTempBuffAndHeal()
    refreshCharacterRefs()
    local pbRemotes = getPBRemotes()
    local abilityEvent = pbRemotes and pbRemotes:FindFirstChild("abilityEvent")
    local rawChar = getPBRawCharacter()
    if not abilityEvent then return end

    pcall(function()
        if rawChar then
            abilityEvent:FireServer({
                char = rawChar,
                name = "tempbuff",
                statBoosts = {
                    Dmg = "550000000%",
                    BaseSpeed = "45%",
                    stunDur = 20
                },
                dur = 50000000
            })
            abilityEvent:FireServer({
                char = rawChar,
                name = "heal",
                amount = 1
            })
        end
        if Character and Character ~= rawChar then
            abilityEvent:FireServer({
                char = Character,
                name = "tempbuff",
                statBoosts = {
                    Dmg = "550000000%",
                    BaseSpeed = "45%",
                    stunDur = 20
                },
                dur = 50000000
            })
            abilityEvent:FireServer({
                char = Character,
                name = "heal",
                amount = 1
            })
        end
    end)
end

-- Real M1 Sword Click + swing:FireServer
local function pbPerformRealM1Attack()
    if (tick() - (State.PB_LastM1Time or 0)) < 0.14 then return end
    State.PB_LastM1Time = tick()

    task.spawn(function()
        pcall(function()
            local pbRemotes = getPBRemotes()
            local swing = pbRemotes and pbRemotes:FindFirstChild("swing")
            if swing then
                swing:FireServer()
            end
            local rawChar = getPBRawCharacter()
            for _, ch in ipairs({ Character, rawChar }) do
                if ch then
                    local tool = ch:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                end
            end
            if VirtualInputManager then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end)
    end)
end

-- Expand Enemy Hitboxes & Anchor Active Mobs Across Entire Workspace (thha3203 v5 + TexRBLX final.lua)
local function pbBringAndExpandTargets()
    refreshCharacterRefs()
    if not HumanoidRootPart then return end
    local rawChar = getPBRawCharacter()
    local sz = Vector3.new(Config.PB_HitboxSize or 35, Config.PB_HitboxSize or 35, Config.PB_HitboxSize or 35)
    local frontCF = HumanoidRootPart.CFrame * CFrame.new(0, 0, -4.5)
    local allModels = collectAllPBModels()

    for _, v in ipairs(allModels) do
        if v and v.Parent and v ~= Character and v ~= rawChar and not isPBChestOrPropModel(v) and isPBMobAlive(v) then
            pcall(function()
                local bh = v:FindFirstChild("basehitbox") or v:FindFirstChild("basehitbox", true)
                if bh and bh:IsA("BasePart") and (Config.PB_ExpandHitbox or Config.PB_AutoFarmDungeon or Config.PB_KillAura) then
                    bh.Size = sz
                    bh.CanCollide = false
                    bh.Massless = true
                end
                local eHrp = v:FindFirstChild("HumanoidRootPart")
                if eHrp and eHrp:IsA("BasePart") then
                    if Config.PB_ExpandHitbox then
                        eHrp.Size = sz
                        eHrp.CanCollide = false
                    end
                    -- Anchor mob once its entrance is done or when in close combat
                    if (v:GetAttribute("hadEntrance") == true or v:GetAttribute("hadEntrance") == nil)
                        and (eHrp.Position - HumanoidRootPart.Position).Magnitude <= 55 then
                        eHrp.Anchored = true
                        if Config.PB_BringMobs and (eHrp.Position - HumanoidRootPart.Position).Magnitude <= 35 then
                            eHrp.CFrame = frontCF
                        end
                    end
                end
            end)
        end
    end
end

-- Universal Enemy & Breakable Killer (Scans all nested Room Folders/Models + Positive Multi-Hit Damage)
local function pbKillAllNearby(maxRange, isRaid)
    refreshCharacterRefs()
    local pbRemotes = getPBRemotes()
    if not pbRemotes or not HumanoidRootPart then return end

    local rawChar = getPBRawCharacter()
    local myPos = HumanoidRootPart.Position
    local rangeLimit = maxRange or 150
    local wpnDmg = currentPBWeaponDamage()
    local hasActiveTarget = false

    -- 1. Apply 550,000,000% Damage Buff & Heal
    applyPBTempBuffAndHeal()

    -- 2. Break all Breakable crates/boxes/pots
    pbBreakAllBreakables()

    -- 3. Expand hitboxes & anchor active enemies
    pbBringAndExpandTargets()

    -- 4. Damage all living enemies & breakables across all workspace models/folders
    local allModels = collectAllPBModels()
    for _, v in ipairs(allModels) do
        if v and v.Parent and v ~= Character and v ~= rawChar and not isPBChestOrPropModel(v) and isPBMobAlive(v) then
            local part = getPBMobTargetPart(v)
            local dist = part and (part.Position - myPos).Magnitude or math.huge
            if dist <= rangeLimit or isRaid or Config.PB_AutoFarmDungeon then
                hasActiveTarget = true
                pbDamageModel(v, wpnDmg)
            end
        end
    end

    if hasActiveTarget then
        pbPerformRealM1Attack()
    end
end

-- Open All Chests Automatically (Sequential Anti-Throttle Inventory Loot + ReplicatedStorage.Drops + Deep Workspace Dungeon Chests)
local function pbOpenAllChestsNow()
    if State.PB_OpeningChestsBusy then return end
    State.PB_OpeningChestsBusy = true

    task.spawn(function()
        pcall(function()
            local pbRemotes = getPBRemotes()
            local openLoot = pbRemotes and pbRemotes:FindFirstChild("openLoot")

            -- 1. Open all chests in PlayerGui.gameUI.armory.inventory.clip.Loot (thha3203 v5 exact path, sequential with 0.08s wait)
            if openLoot then
                local gameUI = PlayerGui:FindFirstChild("gameUI")
                local lootFolder = gameUI
                    and gameUI:FindFirstChild("armory")
                    and gameUI.armory:FindFirstChild("inventory")
                    and gameUI.armory.inventory:FindFirstChild("clip")
                    and gameUI.armory.inventory.clip:FindFirstChild("Loot")

                if lootFolder then
                    for _, loot in ipairs(lootFolder:GetChildren()) do
                        if string.find(loot.Name, "Chest", 1, true) or (not loot:IsA("UILayout") and not loot:IsA("UIComponent")) then
                            pcall(function()
                                openLoot:InvokeServer(loot.Name)
                            end)
                            task.wait(0.08)
                        end
                    end
                end

                -- Also scan any other Chest frames inside gameUI.armory
                local armory = gameUI and gameUI:FindFirstChild("armory")
                if armory then
                    for _, desc in ipairs(armory:GetDescendants()) do
                        if desc:IsA("GuiObject") and string.find(desc.Name, "Chest", 1, true) then
                            pcall(function()
                                openLoot:InvokeServer(desc.Name)
                            end)
                            task.wait(0.06)
                        end
                    end
                end
            end

            -- 2. TexRBLX final.lua root.29: Iterate ReplicatedStorage.Drops (models with Root & Top) for Tiers 1..3
            local dropsFolder = ReplicatedStorage:FindFirstChild("Drops")
            if openLoot and dropsFolder then
                for _, drop in ipairs(dropsFolder:GetChildren()) do
                    if typeof(drop) == "Instance" and drop:FindFirstChild("Root") and drop:FindFirstChild("Top") then
                        for tier = 1, 3 do
                            local tieredName = drop.Name .. tostring(tier)
                            pcall(function()
                                openLoot:InvokeServer(tieredName)
                            end)
                            task.wait(0.06)
                        end
                        pcall(function()
                            openLoot:InvokeServer(drop.Name)
                        end)
                        task.wait(0.06)
                    end
                end
            end

            -- 3. Deep Scan for Physical Chests & Loot Drops anywhere in workspace (including inside Room Models/Folders!)
            refreshCharacterRefs()
            if HumanoidRootPart then
                local myPos = HumanoidRootPart.Position
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and isPBChestModel(obj) then
                        local chestPart = obj:FindFirstChild("Root") or obj:FindFirstChild("Top") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                        local dist = chestPart and (chestPart.Position - myPos).Magnitude or math.huge

                        if dist <= 60 then
                            -- Briefly step to nearby unopened physical chest if no enemy target is active
                            if not State.PB_OpenedWorkspaceChests[obj] and not State.PB_ActiveTargetCFrame and chestPart then
                                State.PB_OpenedWorkspaceChests[obj] = true
                                pcall(function()
                                    HumanoidRootPart.CFrame = chestPart.CFrame * CFrame.new(0, 2.5, 3)
                                    if VirtualInputManager then
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.05)
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    end
                                end)
                            end

                            for _, desc in ipairs(obj:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    pcall(function()
                                        if fireproximityprompt then fireproximityprompt(desc) end
                                        desc:InputHoldBegin()
                                        task.wait(0.04)
                                        desc:InputHoldEnd()
                                    end)
                                elseif desc:IsA("ClickDetector") and fireclickdetector then
                                    pcall(function() fireclickdetector(desc) end)
                                elseif desc:IsA("BasePart") and firetouchinterest then
                                    pcall(function()
                                        firetouchinterest(HumanoidRootPart, desc, 0)
                                        firetouchinterest(HumanoidRootPart, desc, 1)
                                    end)
                                end
                            end
                        end
                    elseif obj:IsA("ProximityPrompt") and obj.Enabled then
                        local pName = string.lower(obj.Name .. " " .. obj.ActionText .. " " .. obj.ObjectText .. " " .. (obj.Parent and obj.Parent.Name or ""))
                        if string.find(pName, "chest", 1, true)
                            or string.find(pName, "loot", 1, true)
                            or string.find(pName, "open", 1, true)
                            or string.find(pName, "claim", 1, true)
                            or string.find(pName, "drop", 1, true) then
                            pcall(function()
                                if fireproximityprompt then fireproximityprompt(obj) end
                                obj:InputHoldBegin()
                                task.wait(0.04)
                                obj:InputHoldEnd()
                            end)
                        end
                    end
                end
            end
        end)
        State.PB_OpeningChestsBusy = false
    end)
end

-- Upgrade All Weapons & Armor Tiers 1..9 (TexRBLX final.lua root.30)
local function pbUpgradeAllItemsNow()
    local pbRemotes = getPBRemotes()
    local reqPurchase = pbRemotes and pbRemotes:FindFirstChild("requestPurchase")
    if not reqPurchase then return end

    local items = {}
    local armorFolder = ReplicatedStorage:FindFirstChild("armor")
    if armorFolder then
        for _, v in ipairs(armorFolder:GetChildren()) do
            table.insert(items, v.Name)
        end
    end
    local weaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
    if weaponsFolder then
        for _, v in ipairs(weaponsFolder:GetChildren()) do
            table.insert(items, v.Name)
        end
    end

    for _, itemName in ipairs(items) do
        for tier = 1, 9 do
            task.spawn(function()
                pcall(function()
                    reqPurchase:FireServer(itemName, "itemUpgrade", { upgradeTier = tier })
                end)
            end)
        end
    end
end

--// Pixel Blade Infinite Dash & No Ability Cooldown (via localChar environment)
local function applyPBInfDashAndNoCD()
    if not Config.PB_InfDashAndNoCD or not Character then return end
    pcall(function()
        if getsenv then
            local lc = Character:FindFirstChild("localChar")
            if lc and lc:IsA("LocalScript") then
                local env = getsenv(lc)
                if env then
                    if type(env.maxEnergy) == "number" then
                        env.energy = env.maxEnergy
                    end
                    if type(env.maxDashes) == "number" then
                        env.dashes = env.maxDashes
                    end
                    if env.dashCD ~= nil then
                        env.dashCD = 0
                    end
                    if type(env.abilityCooldowns) == "table" then
                        for k in pairs(env.abilityCooldowns) do
                            env.abilityCooldowns[k] = nil
                        end
                    end
                end
            end
        end
    end)
end

--//===========================================================================
--// 🎣 PIXEL BLADE ULTRA-FAST AUTO-FISHING ENGINE (v3.2 TURBO EDITION)
--//===========================================================================
-- Zero-lag 60Hz PlayerGui inspection (no workspace:GetDescendants() in loop!)
-- Supports:
-- 1. Baseline UI Diffing + Color/UIGradient/UIStroke/Name/Text Detection
-- 2. Reactive Green Circle Hold (releases the instant Blue appears or Green clears)
-- 3. Ultra-Fast Turbo Blue Reel Taps (0.012s press/release, >40 taps/sec)
-- 4. ProximityPrompt:InputHoldBegin/End + VirtualInputManager E + Mobile Touch Button
-- 5. Smart Hybrid Auto-Cycle so fishing NEVER stalls even if UI textures hide colors

local FISHING_KEYWORDS = {
    "fish", "rod", "pole", "cast", "reel", "catch", "bite", "hook", "bobber",
    "pond", "minigame", "circle", "ring", "qte", "popup", "bar", "sweetspot"
}

local function hasFishingKeyword(str)
    if not str or str == "" then return false end
    local low = string.lower(tostring(str))
    for _, kw in ipairs(FISHING_KEYWORDS) do
        if string.find(low, kw, 1, true) then
            return true
        end
    end
    return false
end

local function pbEquipFishingRod()
    refreshCharacterRefs()
    if not Character then return nil end
    for _, child in ipairs(Character:GetChildren()) do
        if child:IsA("Tool") and hasFishingKeyword(child.Name) then
            return child
        end
    end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and hasFishingKeyword(tool.Name) then
                pcall(function()
                    if Humanoid then
                        Humanoid:EquipTool(tool)
                    else
                        tool.Parent = Character
                    end
                end)
                return tool
            end
        end
    end
    return Character:FindFirstChildOfClass("Tool")
end

local function pbFindFishingPrompt(forceRefresh)
    refreshCharacterRefs()
    if not HumanoidRootPart then return nil end
    if not forceRefresh
        and State.PB_CachedFishPrompt
        and State.PB_CachedFishPrompt.Parent
        and State.PB_CachedFishPrompt.Enabled
        and (tick() - State.PB_LastFishPromptScan) < 2.5 then
        return State.PB_CachedFishPrompt
    end

    State.PB_LastFishPromptScan = tick()
    local myPos = HumanoidRootPart.Position
    local bestFishPrompt = nil
    local bestFishDist = math.huge
    local closestAnyPrompt = nil
    local closestAnyDist = 22

    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled then
            local part = desc.Parent
            if part and part:IsA("Model") then
                part = part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart", true)
            elseif part and not part:IsA("BasePart") then
                part = part:FindFirstChildWhichIsA("BasePart", true) or (part.Parent and part.Parent:IsA("BasePart") and part.Parent)
            end
            if part and part:IsA("BasePart") then
                local dist = (part.Position - myPos).Magnitude
                local isFishRelated = hasFishingKeyword(desc.Name)
                    or hasFishingKeyword(desc.ActionText)
                    or hasFishingKeyword(desc.ObjectText)
                    or (desc.Parent and hasFishingKeyword(desc.Parent.Name))

                if isFishRelated and dist <= 45 and dist < bestFishDist then
                    bestFishDist = dist
                    bestFishPrompt = desc
                elseif dist < closestAnyDist then
                    closestAnyDist = dist
                    closestAnyPrompt = desc
                end
            end
        end
    end

    State.PB_CachedFishPrompt = bestFishPrompt or closestAnyPrompt
    return State.PB_CachedFishPrompt
end

local function pbFireFishingRemotes(stage)
    local pbRemotes = getPBRemotes()
    if pbRemotes then
        for _, rem in ipairs(pbRemotes:GetChildren()) do
            if hasFishingKeyword(rem.Name) then
                pcall(function()
                    if rem:IsA("RemoteEvent") then
                        if stage == "cast" then
                            rem:FireServer("Cast")
                            rem:FireServer(true)
                        elseif stage == "green" then
                            rem:FireServer("Hold", true)
                            rem:FireServer(true)
                        elseif stage == "reel" then
                            rem:FireServer("Reel")
                            rem:FireServer("Catch", true)
                            rem:FireServer("Complete", 100)
                            rem:FireServer(true)
                        end
                    elseif rem:IsA("RemoteFunction") then
                        task.spawn(function()
                            pcall(function()
                                if stage == "cast" then
                                    rem:InvokeServer("Cast")
                                else
                                    rem:InvokeServer("Catch", true)
                                    rem:InvokeServer(true)
                                end
                            end)
                        end)
                    elseif rem:IsA("BindableEvent") then
                        rem:Fire(true)
                    end
                end)
            end
        end
    end
end

local function isColorCloseTo(col, tr, tg, tb, tol)
    if not col then return false end
    local r = math.floor(col.R * 255 + 0.5)
    local g = math.floor(col.G * 255 + 0.5)
    local b = math.floor(col.B * 255 + 0.5)
    return math.abs(r - tr) <= tol
        and math.abs(g - tg) <= tol
        and math.abs(b - tb) <= tol
end

-- Snapshot currently visible GUI objects before casting so any newly visible minigame popup is caught instantly
local function pbSnapshotBaselineGui(hubScreenGui)
    local baseline = {}
    local ignoreGui = hubScreenGui or State.HubScreenGui
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui ~= ignoreGui and gui ~= StealthESPFolder and gui:IsA("LayerCollector") and gui.Enabled then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and isGuiVisible(obj) then
                    baseline[obj] = true
                end
            end
        end
    end
    State.PB_BaselineGuiSet = baseline
end

-- Fast 0-lag PlayerGui Fishing Detector (checks Colors, UIGradient, UIStroke, Names, Text & Baseline Diff)
local function pbDetectFishingMinigameState(hubScreenGui)
    local greenDetected = false
    local blueDetected = false
    local newPopupDetected = false
    local mobileFishBtn = nil
    local fishingGuiActive = false
    local baseline = State.PB_BaselineGuiSet or {}

    local function checkSingleColor(col, inFishingContext)
        if not col then return end
        -- Exact Pixel Blade Green Circle RGB(39, 162, 71)
        if isColorCloseTo(col, 39, 162, 71, 32) then
            greenDetected = true
            fishingGuiActive = true
        end
        -- Exact Pixel Blade Blue Center Circle RGB(195, 223, 224)
        if isColorCloseTo(col, 195, 223, 224, 30) then
            blueDetected = true
            fishingGuiActive = true
        end
        if inFishingContext then
            local r = math.floor(col.R * 255 + 0.5)
            local g = math.floor(col.G * 255 + 0.5)
            local b = math.floor(col.B * 255 + 0.5)
            if g >= 130 and g > (r + 35) and g > (b + 25) then
                greenDetected = true
                fishingGuiActive = true
            elseif b >= 160 and g >= 135 and b > (r + 10) then
                blueDetected = true
                fishingGuiActive = true
            end
        end
    end

    local ignoreGui = hubScreenGui or State.HubScreenGui
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui ~= ignoreGui and gui ~= StealthESPFolder and gui:IsA("LayerCollector") and gui.Enabled then
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("GuiObject") and isGuiVisible(obj) then
                    local objNameLow = string.lower(obj.Name)
                    local parentNameLow = obj.Parent and string.lower(obj.Parent.Name) or ""
                    local inFishingContext = hasFishingKeyword(objNameLow)
                        or hasFishingKeyword(parentNameLow)
                        or not baseline[obj]

                    if hasFishingKeyword(objNameLow) or hasFishingKeyword(parentNameLow) then
                        fishingGuiActive = true
                    end

                    -- If a new centered GUI popup became visible after casting
                    if not baseline[obj] and obj.AbsoluteSize.X >= 25 and obj.AbsoluteSize.Y >= 25 then
                        newPopupDetected = true
                        fishingGuiActive = true
                    end

                    -- 1. Check Colors (BackgroundColor3, ImageColor3, UIStroke, UIGradient)
                    if obj.BackgroundTransparency < 0.95 then
                        checkSingleColor(obj.BackgroundColor3, inFishingContext)
                    end
                    if (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) and obj.ImageTransparency < 0.95 then
                        checkSingleColor(obj.ImageColor3, inFishingContext)
                    end
                    local stroke = obj:FindFirstChildOfClass("UIStroke")
                    if stroke and stroke.Enabled and stroke.Transparency < 0.95 then
                        checkSingleColor(stroke.Color, true)
                    end
                    local grad = obj:FindFirstChildOfClass("UIGradient")
                    if grad and grad.Enabled then
                        pcall(function()
                            for _, kp in ipairs(grad.Color.Keypoints) do
                                checkSingleColor(kp.Value, true)
                            end
                        end)
                    end

                    -- 2. Check Name / Asset / Text cues for Circle Popup / Reel_10..Reel_1
                    if string.find(objNameLow, "circle_popup", 1, true)
                        or string.find(objNameLow, "circle_maxe", 1, true)
                        or string.find(objNameLow, "hold", 1, true) then
                        greenDetected = true
                        fishingGuiActive = true
                    elseif string.find(objNameLow, "reel_", 1, true)
                        or objNameLow == "reel"
                        or string.find(objNameLow, "mash", 1, true)
                        or string.find(objNameLow, "tap", 1, true) then
                        blueDetected = true
                        fishingGuiActive = true
                    end

                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        local txtLow = string.lower(tostring(obj.Text or ""))
                        if string.find(txtLow, "hold", 1, true) then
                            greenDetected = true
                            fishingGuiActive = true
                        elseif string.find(txtLow, "tap", 1, true)
                            or string.find(txtLow, "reel", 1, true)
                            or string.find(txtLow, "spam", 1, true)
                            or string.find(txtLow, "pull", 1, true) then
                            blueDetected = true
                            fishingGuiActive = true
                        end
                    end

                    -- 3. Auto-Align Bar/Cursor if a Bar Minigame exists
                    if inFishingContext and (objNameLow == "bar" or objNameLow == "playerbar" or objNameLow == "cursor" or objNameLow == "catchbar") and obj.Parent then
                        local targetObj = obj.Parent:FindFirstChild("fish")
                            or obj.Parent:FindFirstChild("Fish")
                            or obj.Parent:FindFirstChild("target")
                            or obj.Parent:FindFirstChild("Target")
                            or obj.Parent:FindFirstChild("zone")
                            or obj.Parent:FindFirstChild("sweetspot")
                        if targetObj and targetObj:IsA("GuiObject") then
                            pcall(function()
                                obj.Position = targetObj.Position
                            end)
                        end
                    end

                    -- 4. Detect Mobile Touch Fishing Button
                    if obj:IsA("GuiButton") and inFishingContext then
                        mobileFishBtn = obj
                    end
                end
            end
        end
    end

    return {
        green = greenDetected,
        blue = blueDetected,
        newPopup = newPopupDetected,
        fishingGuiActive = fishingGuiActive,
        mobileBtn = mobileFishBtn
    }
end

local function pbPressEDown(mobileBtn, prompt, stage)
    pcall(function()
        if Config.PB_AutoEquipRod then
            local rod = pbEquipFishingRod()
            if rod then
                pcall(function() rod:Activate() end)
            end
        end
        if prompt and prompt.Parent and prompt.Enabled then
            if stage == "cast" and fireproximityprompt then
                pcall(function() fireproximityprompt(prompt) end)
            end
            pcall(function() prompt:InputHoldBegin() end)
        end
        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        end
        if mobileBtn then
            if firesignal then
                pcall(firesignal, mobileBtn.MouseButton1Down)
            end
            activateGuiButton(mobileBtn)
        end
    end)
end

local function pbReleaseEUp(mobileBtn, prompt)
    pcall(function()
        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end
        if prompt and prompt.Parent then
            pcall(function() prompt:InputHoldEnd() end)
        end
        if mobileBtn and firesignal then
            pcall(firesignal, mobileBtn.MouseButton1Up)
        end
    end)
end

-- Reactive Hold E: holds E for up to maxHoldSeconds, but releases IMMEDIATELY if Blue appears or Green clears!
local function pbReactiveHoldE(maxHoldSeconds, mobileBtn, stage, stopOnGreenClear)
    local dur = math.max(0.08, tonumber(maxHoldSeconds) or 0.9)
    local prompt = pbFindFishingPrompt(stage == "cast")
    pbFireFishingRemotes(stage or "green")
    pbPressEDown(mobileBtn, prompt, stage)

    local startT = tick()
    local endT = startT + dur
    while State.Running and Config.PB_AutoFish and tick() < endT do
        task.wait(0.015)
        local st = pbDetectFishingMinigameState(nil)
        if st.blue then
            -- Blue reel phase started! Release E immediately so we can start rapid-tapping!
            break
        end
        if stage == "cast" and st.green then
            -- Bite/Green circle appeared during cast hold!
            break
        end
        if stopOnGreenClear and (tick() - startT) >= 0.25 and not st.green and not st.newPopup then
            break
        end
    end

    pbReleaseEUp(mobileBtn, prompt)
end

-- Ultra-Fast Turbo Tap E (0.012s press / 0.012s release, >40 taps/sec!)
local function pbTurboTapE(tapCount, tapInterval, mobileBtn)
    local count = math.clamp(tonumber(tapCount) or 16, 4, 40)
    local interval = math.clamp(tonumber(tapInterval) or 0.015, 0.008, 0.08)
    local prompt = pbFindFishingPrompt(false)

    pbFireFishingRemotes("reel")

    for i = 1, count do
        if not State.Running or not Config.PB_AutoFish then
            break
        end
        pcall(function()
            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            end
            if prompt and prompt.Parent and prompt.Enabled then
                pcall(function()
                    prompt:InputHoldBegin()
                    if fireproximityprompt and i % 4 == 1 then
                        fireproximityprompt(prompt)
                    end
                end)
            end
            if mobileBtn then
                activateGuiButton(mobileBtn)
            end
        end)
        task.wait(0.012)
        pcall(function()
            if VirtualInputManager then
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
            if prompt and prompt.Parent then
                pcall(function() prompt:InputHoldEnd() end)
            end
        end)
        task.wait(interval)
    end
end

--//===========================================================================
--// MAIN LOOPS (AOT:R + PIXEL BLADE)
--//===========================================================================

-- 1. Heartbeat Loop (AOT:R Auto Kill + Pixel Blade 60FPS Target Lock)
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if not State.Running then return end
    refreshCharacterRefs()
    if not HumanoidRootPart then return end

    if Config.VelocityAntiFling then
        if HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 650 then
            HumanoidRootPart.AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity.Unit * 300
        end
        if HumanoidRootPart.AssemblyAngularVelocity.Magnitude > 50 then
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- Pixel Blade Active Farm 60FPS Position Lock & Noclip
    if Config.PB_AutoFarmDungeon or Config.PB_AutoFarmRaid then
        local rawChar = getPBRawCharacter()
        for _, ch in ipairs({ Character, rawChar }) do
            if ch then
                for _, part in ipairs(ch:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        if State.PB_ActiveTargetCFrame then
            HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
            HumanoidRootPart.CFrame = State.PB_ActiveTargetCFrame
            if rawChar and rawChar ~= Character then
                local rHrp = rawChar:FindFirstChild("HumanoidRootPart") or rawChar.PrimaryPart
                if rHrp and rHrp:IsA("BasePart") then
                    rHrp.AssemblyLinearVelocity = Vector3.zero
                    rHrp.AssemblyAngularVelocity = Vector3.zero
                    rHrp.CFrame = State.PB_ActiveTargetCFrame
                end
            end
        end
    else
        State.PB_ActiveTargetCFrame = nil
    end

    if Config.PB_InfDashAndNoCD then
        applyPBInfDashAndNoCD()
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

-- 2. Pixel Blade Auto Farm Loop (Dungeons, Raids, Kill Aura, Breakables, Upgrades)
task.spawn(function()
    while State.Running do
        task.wait(0.08)
        local pbRemotes = getPBRemotes()
        if pbRemotes then
            refreshCharacterRefs()

            -- God Buff & Auto Heal
            if Config.PB_GodBuffAndHeal then
                applyPBTempBuffAndHeal()
            end

            -- Kill Aura / Breakables (when Dungeon/Raid farm isn't already running pbKillAllNearby)
            if (Config.PB_KillAura or Config.PB_AutoBreakables) and not (Config.PB_AutoFarmDungeon or Config.PB_AutoFarmRaid) then
                pcall(pbKillAllNearby, Config.PB_KillAuraRange, false)
            end

            -- Expand Enemy Hitboxes
            if Config.PB_ExpandHitbox then
                pcall(pbBringAndExpandTargets)
            end

            -- Auto Farm Dungeon / Raid Movement, Box Breaking & Enemy Killing
            if (Config.PB_AutoFarmDungeon or Config.PB_AutoFarmRaid) and HumanoidRootPart then
                local isRaid = Config.PB_AutoFarmRaid
                local cutscene = workspace:FindFirstChild("inCutscene")
                local inCutscene = cutscene and cutscene.Value == true

                if not inCutscene then
                    local mob, mobPart = findBestPBTarget(isRaid)
                    if mob and mobPart then
                        pcall(function()
                            local dist = math.floor((mobPart.Position - HumanoidRootPart.Position).Magnitude)
                            local hp = math.floor(getPBMobCurrentHP(mob))
                            State.PB_DungeonStatusText = string.format(
                                "⚔️ يهاجم: %s | المسافة: %d | HP: %d | سلاحك: %d",
                                tostring(mob.Name), dist, hp, currentPBWeaponDamage()
                            )

                            if mob.Name == "Atticus" and not State.PB_EnteredBossRoom then
                                local vault = workspace:FindFirstChild("Vault")
                                if vault then
                                    local vaultCF = CFrame.new(vault:GetPivot().Position)
                                    State.PB_ActiveTargetCFrame = vaultCF
                                    HumanoidRootPart.CFrame = vaultCF
                                    State.PB_EnteredBossRoom = true
                                    task.wait(0.35)
                                end
                            end

                            local targetCF = computePBTargetCFrame(mob, mobPart)
                            if targetCF then
                                State.PB_ActiveTargetCFrame = targetCF
                                HumanoidRootPart.CFrame = targetCF
                            end

                            pbKillAllNearby(500, true)
                        end)
                    elseif Config.PB_AutoFarmDungeon then
                        -- Room clear or waiting for next wave -> Release lock & advance safely!
                        State.PB_ActiveTargetCFrame = nil
                        State.PB_DungeonStatusText = "🏃 الغرفة فارغة: جاري التقدم للغرفة التالية وتكسير الصناديق..."
                        pcall(advancePBDungeonRoom)
                        pcall(pbKillAllNearby, 250, true)
                    else
                        State.PB_ActiveTargetCFrame = nil
                        State.PB_DungeonStatusText = "⏳ في انتظار ظهور وحوش الغارة..."
                        pcall(pbKillAllNearby, 500, true)
                    end
                else
                    State.PB_ActiveTargetCFrame = nil
                    State.PB_DungeonStatusText = "🎬 مشهد سينمائي (Cutscene)..."
                end
            else
                State.PB_ActiveTargetCFrame = nil
                State.PB_DungeonStatusText = "متوقف (جاهز للتشغيل)"
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
                        task.wait(0.02)
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
        task.wait(1.0)
        local pbRemotes = getPBRemotes()
        if pbRemotes then
            -- Auto Open All Chests (ReplicatedStorage.Drops Tiers 1..3 + Inventory Loot + Workspace Chests)
            if Config.PB_AutoOpenChests or Config.PB_AutoFarmDungeon then
                pcall(pbOpenAllChestsNow)
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

-- 3.5. Pixel Blade Ultra-Fast Auto-Fishing Loop (v3.2 Turbo: 60FPS UI + Smart Hybrid Cycle)
task.spawn(function()
    while State.Running do
        if Config.PB_AutoFish then
            pcall(function()
                -- Snapshot baseline visible GUI before casting so any new minigame popup is caught at 60FPS
                pbSnapshotBaselineGui(nil)

                -- Step 1: Fast Cast Rod (Equip Rod + Fire Prompt + Reactive Hold E)
                State.PB_FishStatusText = "🎣 رمي سريع للصنارة..."
                local initState = pbDetectFishingMinigameState(nil)
                if not initState.green and not initState.blue then
                    pbReactiveHoldE(Config.PB_FishCastHold, initState.mobileBtn, "cast", false)
                end
                State.PB_LastCastTime = tick()

                if not Config.PB_AutoFish then return end

                local firstGreenSeen = false
                local smartCycleTriggered = false

                -- Step 2 & 3: 60Hz (0.015s) Zero-Lag Monitor for Green Circle, Blue Reel, or Smart Cycle
                while State.Running and Config.PB_AutoFish do
                    local mgState = pbDetectFishingMinigameState(nil)

                    if Config.PB_AutoFishMinigame then
                        -- Priority A: Blue Center Reel Detected -> Immediate Turbo Tap E!
                        if mgState.blue then
                            State.PB_FishStatusText = "🔵 سحب سريع تيربو (Turbo Reel Tap)!"
                            pbTurboTapE(Config.PB_FishTapCount, Config.PB_FishTapInterval, mgState.mobileBtn)
                            -- Continue tapping if blue stays visible
                            local extraLimit = tick() + 1.2
                            while State.Running and Config.PB_AutoFish and tick() < extraLimit do
                                local checkSt = pbDetectFishingMinigameState(nil)
                                if not checkSt.blue then break end
                                pbTurboTapE(6, Config.PB_FishTapInterval, checkSt.mobileBtn)
                            end
                            State.PB_FishCaughtCount = State.PB_FishCaughtCount + 1
                            State.PB_FishStatusText = "✅ تم الصيد! (#" .. tostring(State.PB_FishCaughtCount) .. ")"
                            task.wait(math.clamp(tonumber(Config.PB_FishPostWait) or 0.35, 0.1, 2.0))
                            break

                        -- Priority B: Green Circle or New Minigame Popup Detected -> Reactive Hold E -> Immediate Turbo Reel!
                        elseif mgState.green or mgState.newPopup then
                            local holdDur = firstGreenSeen and Config.PB_FishFollowGreenHold or Config.PB_FishGreenHold
                            firstGreenSeen = true
                            State.PB_FishStatusText = "🟢 الدائرة الخضراء -> ضغط ذكي (Reactive Hold E)!"
                            pbReactiveHoldE(holdDur, mgState.mobileBtn, "green", true)

                            -- Check immediately if a second green circle appeared or if we transition straight to Blue Turbo Reel
                            task.wait(0.05)
                            local afterGreen = pbDetectFishingMinigameState(nil)
                            if afterGreen.green and not afterGreen.blue then
                                State.PB_FishStatusText = "🟢 دائرة خضراء ثانية -> ضغط ذكي..."
                                pbReactiveHoldE(Config.PB_FishFollowGreenHold, afterGreen.mobileBtn, "green", true)
                                task.wait(0.04)
                                afterGreen = pbDetectFishingMinigameState(nil)
                            end

                            -- Execute immediate Turbo Reel Tap burst!
                            if afterGreen.blue or afterGreen.fishingGuiActive or Config.PB_FishSmartCycle then
                                State.PB_FishStatusText = "🔵 سحب تيربو فوري (Instant Reel Burst)!"
                                pbTurboTapE(Config.PB_FishTapCount, Config.PB_FishTapInterval, afterGreen.mobileBtn)
                                State.PB_FishCaughtCount = State.PB_FishCaughtCount + 1
                                State.PB_FishStatusText = "✅ تم الصيد! (#" .. tostring(State.PB_FishCaughtCount) .. ")"
                                task.wait(math.clamp(tonumber(Config.PB_FishPostWait) or 0.35, 0.1, 2.0))
                                break
                            end
                        end
                    end

                    -- Priority C: Smart Hybrid Auto-Cycle (never waits 15s if texture hides UI colors!)
                    local elapsed = tick() - State.PB_LastCastTime
                    if Config.PB_FishSmartCycle and not firstGreenSeen and not smartCycleTriggered and elapsed >= 2.6 then
                        smartCycleTriggered = true
                        State.PB_FishStatusText = "⚡ دورة صيد سريعة (Hold E -> Turbo Tap E)..."
                        pbReactiveHoldE(Config.PB_FishGreenHold, mgState.mobileBtn, "green", false)
                        task.wait(0.04)
                        pbTurboTapE(Config.PB_FishTapCount, Config.PB_FishTapInterval, mgState.mobileBtn)
                        State.PB_FishCaughtCount = State.PB_FishCaughtCount + 1
                        State.PB_FishStatusText = "✅ اكتملت الدورة (#" .. tostring(State.PB_FishCaughtCount) .. ") -> رمي جديد..."
                        task.wait(math.clamp(tonumber(Config.PB_FishPostWait) or 0.35, 0.1, 2.0))
                        break
                    end

                    -- Fast Timeout Guard
                    local timeoutSec = math.clamp(tonumber(Config.PB_FishTimeout) or 5, 3, 20)
                    if elapsed >= timeoutSec then
                        State.PB_FishStatusText = "🔄 إعادة رمي سريعة..."
                        pbTurboTapE(8, 0.012, mgState.mobileBtn)
                        task.wait(0.15)
                        break
                    end

                    task.wait(0.015)
                end
            end)
        else
            State.PB_FishStatusText = "متوقف (Idle)"
            task.wait(0.25)
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
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v ~= Character and isPBMobAlive(v) and not State.ESPObjects[v] then
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

if Config.RemoveDamageText and CurrentGame == "AOTR" then
    task.spawn(function()
        PlayerGui:WaitForChild("Interface", 15)
        applyRemoveDamageText(true)
    end)
end

--//===========================================================================
--// DELTA MOBILE & PC CUSTOM GUI (STRICT GAME-ISOLATED TABS v3.2)
--//===========================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomIdentifier(16)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getSafeGuiParent()
State.HubScreenGui = ScreenGui

local FloatButton = Instance.new("TextButton")
FloatButton.Name = randomIdentifier(10)
FloatButton.Size = UDim2.new(0, 56, 0, 56)
FloatButton.Position = UDim2.new(0, 18, 0.5, -28)
FloatButton.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
FloatButton.Text = CurrentGame == "PixelBlade" and "🗡️\nPB" or "🛡️\nAOT"
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
TitleLabel.Text = CurrentGame == "PixelBlade"
    and "🗡️ Delta Hub v3.4 | Pixel Blade Edition"
    or "⚔️ Delta Hub v3.4 | Attack on Titan: Revolution"
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
--// BUILD TABS & CONTROLS (STRICT PER-GAME ISOLATION: PIXEL BLADE vs AOT:R)
--//===========================================================================

local TabPBFarm, TabPBFish, TabPBLoot = nil, nil, nil
local TabFarm, TabCombat, TabMisc = nil, nil, nil

if CurrentGame == "PixelBlade" then
    TabPBFarm = createTab("🗡️ الدنجن والقتال", 1)
    TabPBFish = createTab("🎣 الصيد بالصنارة", 2)
    TabPBLoot = createTab("🎁 الصناديق والبوابات", 3)
else
    TabFarm = createTab("⚔️ الفارم والعمالقة", 1)
    TabCombat = createTab("⚡ المهمات والتعبئة", 2)
    TabMisc = createTab("🎲 العائلات والتنقل", 3)
end

local TabSecurity = createTab("🛡️ الحماية (Anti-Ban)", 4)
local TabESP = createTab("👁️ الرادار والفريمات", 5)

-- Automatically open the active game's first tab!
if CurrentGame == "PixelBlade" then
    selectTab("🗡️ الدنجن والقتال")
else
    selectTab("⚔️ الفارم والعمالقة")
end

-- ============================================================================
-- [GAME 2 ONLY: PIXEL BLADE TABS & CONTROLS]
-- ============================================================================
if CurrentGame == "PixelBlade" then
    -- [PIXEL BLADE TAB 1: FARM & COMBAT]
    addSectionHeader(TabPBFarm, "🗡️ Pixel Blade v3.5 - تفريم الدنجن والغارات والقتال")

    local DungeonStatusBox = Instance.new("TextLabel")
    DungeonStatusBox.Size = UDim2.new(1, 0, 0, 34)
    DungeonStatusBox.BackgroundColor3 = Color3.fromRGB(28, 38, 34)
    DungeonStatusBox.Text = "🗡️ الحالة: متوقف (جاهز للتشغيل)"
    DungeonStatusBox.TextColor3 = Color3.fromRGB(115, 245, 165)
    DungeonStatusBox.Font = Enum.Font.GothamBold
    DungeonStatusBox.TextSize = 11
    DungeonStatusBox.TextWrapped = true
    DungeonStatusBox.Parent = TabPBFarm

    local dStatusCorner = Instance.new("UICorner")
    dStatusCorner.CornerRadius = UDim.new(0, 6)
    dStatusCorner.Parent = DungeonStatusBox

    task.spawn(function()
        while State.Running do
            task.wait(0.2)
            if DungeonStatusBox and DungeonStatusBox.Parent then
                DungeonStatusBox.Text = "🗡️ " .. tostring(State.PB_DungeonStatusText or "جاهز")
            end
        end
    end)

    addToggle(TabPBFarm, "فارم الدنجن التلقائي الذكي (Auto Farm Dungeon)", Config.PB_AutoFarmDungeon, function(val)
        Config.PB_AutoFarmDungeon = val
        State.PB_EnteredBossRoom = false
        if not val then
            State.PB_ActiveTargetCFrame = nil
        else
            applyPBTempBuffAndHeal()
        end
    end)

    addToggle(TabPBFarm, "فارم الغارات التلقائي (Auto Farm Raids)", Config.PB_AutoFarmRaid, function(val)
        Config.PB_AutoFarmRaid = val
        if not val then
            State.PB_ActiveTargetCFrame = nil
        else
            applyPBTempBuffAndHeal()
        end
    end)

    addToggle(TabPBFarm, "قتل جماعي تلقائي حولك (Kill Aura + Tornado)", Config.PB_KillAura, function(val)
        Config.PB_KillAura = val
    end)

    addStepper(TabPBFarm, "مدى الـ Kill Aura", 15, 250, 5, Config.PB_KillAuraRange, function(val)
        Config.PB_KillAuraRange = val
    end)

    addToggle(TabPBFarm, "تقوية الضرر الخارق + شفاء تلقائي (God Buff & Heal)", Config.PB_GodBuffAndHeal, function(val)
        Config.PB_GodBuffAndHeal = val
        if val then
            applyPBTempBuffAndHeal()
        end
    end)

    addToggle(TabPBFarm, "داش لا نهائي وإلغاء انتظار المهارات (Inf Dash & No CD)", Config.PB_InfDashAndNoCD, function(val)
        Config.PB_InfDashAndNoCD = val
    end)

    addToggle(TabPBFarm, "تكسير الصناديق/البراميل تلقائياً (Auto Breakables)", Config.PB_AutoBreakables, function(val)
        Config.PB_AutoBreakables = val
    end)

    addToggle(TabPBFarm, "سحب الأعداء أمامك تلقائياً للقتل السريع (Bring Enemies)", Config.PB_BringMobs, function(val)
        Config.PB_BringMobs = val
    end)

    addActionButton(TabPBFarm, "💥 قتل كل الأعداء وتكسير الصناديق بالغرفة فوراً (Kill & Break All)", function()
        task.spawn(function()
            applyPBTempBuffAndHeal()
            pbKillAllNearby(1000, true)
        end)
    end)

    addSectionHeader(TabPBFarm, "🎯 تكبير هيت بوكس الأعداء (Hitbox Expander)")

    addToggle(TabPBFarm, "تكبير هيت بوكس الأعداء (Expand Enemy Hitbox)", Config.PB_ExpandHitbox, function(val)
        Config.PB_ExpandHitbox = val
    end)

    addStepper(TabPBFarm, "حجم هيت بوكس الأعداء", 5, 80, 5, Config.PB_HitboxSize, function(val)
        Config.PB_HitboxSize = val
    end)

    -- [PIXEL BLADE TAB 2: 🎣 ULTRA-FAST AUTO FISHING (الصيد التلقائي السريع بالصنارة)]
    addSectionHeader(TabPBFish, "🎣 الصيد التلقائي السريع بالصنارة (Turbo v3.2)")

    local FishStatusBox = Instance.new("TextLabel")
    FishStatusBox.Size = UDim2.new(1, 0, 0, 36)
    FishStatusBox.BackgroundColor3 = Color3.fromRGB(26, 36, 48)
    FishStatusBox.Text = "🎣 الحالة: متوقف | الأسماك المصطادة: 0"
    FishStatusBox.TextColor3 = Color3.fromRGB(110, 235, 255)
    FishStatusBox.Font = Enum.Font.GothamBold
    FishStatusBox.TextSize = 11
    FishStatusBox.TextWrapped = true
    FishStatusBox.Parent = TabPBFish

    local fishStatusCorner = Instance.new("UICorner")
    fishStatusCorner.CornerRadius = UDim.new(0, 6)
    fishStatusCorner.Parent = FishStatusBox

    task.spawn(function()
        while State.Running do
            task.wait(0.2)
            if FishStatusBox and FishStatusBox.Parent then
                FishStatusBox.Text = string.format(
                    "🎣 الحالة: %s | 🐟 تم صيد: %d",
                    tostring(State.PB_FishStatusText or "متوقف"),
                    tonumber(State.PB_FishCaughtCount) or 0
                )
            end
        end
    end)

    addToggle(TabPBFish, "تفعيل الصيد التلقائي التيربو (Turbo Auto Fish)", Config.PB_AutoFish, function(val)
        Config.PB_AutoFish = val
        if not val then
            pbReleaseEUp(nil, State.PB_CachedFishPrompt)
        end
    end)

    addToggle(TabPBFish, "تجهيز الصنارة والتفاعل مع نقطة الصيد تلقائياً", Config.PB_AutoEquipRod, function(val)
        Config.PB_AutoEquipRod = val
    end)

    addToggle(TabPBFish, "حل ميني جيم الصيد الفوري (60FPS دائرة خضراء + سحب أزرق)", Config.PB_AutoFishMinigame, function(val)
        Config.PB_AutoFishMinigame = val
    end)

    addToggle(TabPBFish, "الدورة الذكية السريعة (Smart Turbo Cycle بدون انتظار)", Config.PB_FishSmartCycle, function(val)
        Config.PB_FishSmartCycle = val
    end)

    addSectionHeader(TabPBFish, "⏱️ إعدادات سرعة الصيد التيربو (Turbo Timings)")

    addStepper(TabPBFish, "مدة ضغط رمي الصنارة (Cast Hold E)", 0.2, 2.0, 0.1, Config.PB_FishCastHold, function(val)
        Config.PB_FishCastHold = val
    end)

    addStepper(TabPBFish, "مدة ضغط الدائرة الخضراء (Green Hold E)", 0.3, 2.5, 0.1, Config.PB_FishGreenHold, function(val)
        Config.PB_FishGreenHold = val
    end)

    addStepper(TabPBFish, "عدد نقرات السحب السريعة (Turbo Reel Taps)", 6, 30, 2, Config.PB_FishTapCount, function(val)
        Config.PB_FishTapCount = val
    end)

    addStepper(TabPBFish, "مهلة إعادة الرمي السريع بالثواني (Fast Timeout)", 3, 15, 1, Config.PB_FishTimeout, function(val)
        Config.PB_FishTimeout = val
    end)

    addActionButton(TabPBFish, "🎣 رمي الصنارة الآن يدوياً (Cast Rod Once)", function()
        task.spawn(function()
            local st = pbDetectFishingMinigameState(State.HubScreenGui)
            pbReactiveHoldE(Config.PB_FishCastHold, st.mobileBtn, "cast", false)
        end)
    end)

    addActionButton(TabPBFish, "⚡ تنفيذ نقرات سحب تيربو فوراً (Test Turbo Reel)", function()
        task.spawn(function()
            local st = pbDetectFishingMinigameState(State.HubScreenGui)
            pbTurboTapE(Config.PB_FishTapCount, Config.PB_FishTapInterval, st.mobileBtn)
        end)
    end)

    -- [PIXEL BLADE TAB 3: UPGRADES, CHESTS, WISHES & PORTALS]
    addSectionHeader(TabPBLoot, "⚡ الترقيات والصناديق والأمنيات (Pixel Blade)")

    addToggle(TabPBLoot, "اختيار الترقية تلقائياً بالدنجن (Auto Pick Upgrade)", Config.PB_AutoUpgrade, function(val)
        Config.PB_AutoUpgrade = val
    end)

    addToggle(TabPBLoot, "إخفاء نافذة الترقية المزعجة (Hide Upgrade Popup)", Config.PB_HideUpgradePopup, function(val)
        Config.PB_HideUpgradePopup = val
    end)

    addToggle(TabPBLoot, "فتح جميع الصناديق تلقائياً (Auto Open All Chests)", Config.PB_AutoOpenChests, function(val)
        Config.PB_AutoOpenChests = val
        if val then
            task.spawn(pbOpenAllChestsNow)
        end
    end)

    addActionButton(TabPBLoot, "🎁 فتح وجمع كل الصناديق فوراً (Open All Chests Now)", function()
        task.spawn(pbOpenAllChestsNow)
    end)

    addActionButton(TabPBLoot, "⬆️ ترقية جميع الأسلحة والدروع (Upgrade All Items 1-9)", function()
        task.spawn(pbUpgradeAllItemsNow)
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
end

-- ============================================================================
-- [GAME 1 ONLY: ATTACK ON TITAN: REVOLUTION TABS & CONTROLS]
-- ============================================================================
if CurrentGame == "AOTR" then
    -- [AOT:R TAB 1: AUTO FARM]
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

    -- [AOT:R TAB 2: COMBAT & MISSIONS]
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

    -- [AOT:R TAB 3: FAMILY ROLL & TELEPORT]
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
end

-- ============================================================================
-- [TAB 4: 🛡️ SECURITY & ANTI-BAN (GAME-AWARE)]
-- ============================================================================
addSectionHeader(TabSecurity, "🛡️ أنظمة الحماية وحفظ الإعدادات")

addToggle(TabSecurity, "تشغيل السكربت والإعدادات تلقائياً بالغارة/الدنجن القادم", Config.AutoExecuteOnTeleport, function(val)
    Config.AutoExecuteOnTeleport = val
    if val then setupAutoExecuteOnTeleport() end
end)

if CurrentGame == "AOTR" then
    addToggle(TabSecurity, "حارس وقت مهمة AOT:R (ينتظر 20ث قبل قتل آخر عملاق)", Config.SafeMissionTimerGuard, function(val)
        Config.SafeMissionTimerGuard = val
    end)

    addStepper(TabSecurity, "الحد الآمن لإنهاء المهمة (ثانية)", 17, 45, 1, Config.MinSafeMissionSeconds, function(val)
        Config.MinSafeMissionSeconds = val
    end)
end

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
    Config.PB_AutoFish = false
    State.IsTSHovering = false
    State.TSHoverPos = nil
    State.PB_ActiveTargetCFrame = nil
    saveConfig()
    pbReleaseEUp(nil, State.PB_CachedFishPrompt)
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
-- [TAB 5: ESP & PERFORMANCE (GAME-AWARE)]
-- ============================================================================
addSectionHeader(TabESP, "الرادار المخفي (Stealth ESP)")

if CurrentGame == "PixelBlade" then
    addToggle(TabESP, "كشف أعداء Pixel Blade (Enemy Highlight ESP)", Config.PB_EnemyESP, function(val)
        Config.PB_EnemyESP = val
        if not val then clearESP() else pcall(updateESP) end
    end)
else
    addToggle(TabESP, "كشف عمالقة AOT:R (Titan Highlight ESP)", Config.TitanESP, function(val)
        Config.TitanESP = val
        if not val then clearESP() else pcall(updateESP) end
    end)

    addToggle(TabESP, "كشف نقاط التعبئة AOT:R (Refill Station ESP)", Config.RefillESP, function(val)
        Config.RefillESP = val
        if not val then clearESP() else pcall(updateESP) end
    end)
end

addSectionHeader(TabESP, "تحسين الأداء والفريمات (FPS & Visuals)")

if CurrentGame == "AOTR" then
    addToggle(TabESP, "إخفاء أرقام الضرر (Remove Damage Text)", Config.RemoveDamageText, function(val)
        Config.RemoveDamageText = val
        applyRemoveDamageText(val)
    end)
end

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
    Config.PB_AutoFish = false
    State.PB_ActiveTargetCFrame = nil
    pbReleaseEUp(nil, State.PB_CachedFishPrompt)
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

print("[🛡️ Delta Hub v3.4] Loaded! Active Game Detected: " .. tostring(CurrentGame))
