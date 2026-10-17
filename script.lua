--[[
    ============================================================================
    ⚔️ Attack on Titan: Revolution (AOT:R) - Delta Hub [PROTECTED EDITION]
    Compatible with: Delta Executor (Android / iOS / PC) & All Luau Executors
    Repository: https://github.com/slam27893-del/Ata
    ============================================================================
]]

repeat task.wait(0.2) until game:IsLoaded()

-- Cleanup previous instance if re-executed
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
local StarterGui = safeCloneref(game:GetService("StarterGui"))

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

--// Remotes Discovery (Safe & Non-blocking)
local Remotes = {
    GET = nil,
    POST = nil
}

task.spawn(function()
    local ok, assets = pcall(function()
        return ReplicatedStorage:WaitForChild("Assets", 15)
    end)
    if ok and assets then
        local remFolder = assets:WaitForChild("Remotes", 15)
        if remFolder then
            Remotes.GET = remFolder:WaitForChild("GET", 10)
            Remotes.POST = remFolder:WaitForChild("POST", 10)
        end
    end
end)

--// Place IDs for AOT:R
local PLACE_IDS = {
    MainMenu = 13379208636,
    Lobby = 14916516914
}

--// Configuration & State
local Config = {
    -- 🛡️ Security & Anti-Ban Settings (Enabled by Default)
    AntiKick = true,
    AntiAFK = true,
    SafeMissionTimerGuard = true,
    MinSafeMissionSeconds = 20, -- Prevents finishing mission under 20s
    SafeHitDistanceCheck = true,
    MaxSafeSlashDistance = 320, -- Only sends hit packet when within safe distance
    HumanizeAttacks = true,     -- Adds human-like timing jitter & randomized damage
    SpoofNapeProperties = true, -- Spoofs Nape.Size & Nape.Transparency to game scripts
    AntiStaffProtection = true, -- Evades if a Group Admin/Mod joins
    AntiStrangerInSolo = false, -- Optional: Evades if any stranger joins your solo mission
    VelocityAntiFling = true,   -- Prevents abnormal physics velocity spikes

    -- Auto Kill (Blades)
    AutoKillBlades = false,
    MoveMode = "Teleportation", -- "Teleportation" | "Gliding"
    StartDelay = 5,
    FloatHeight = 200,
    GlideSpeed = 260,
    SlashCooldown = 0.28,
    KillNotifications = true,

    -- Auto Thunder Spears
    AutoFarmTS = false,
    TSKillMode = "Safe", -- "Safe" | "Risk"
    TSHoverHeight = 60,
    TSStartDelay = 4,

    -- Nape Hitbox & Skills
    ExpandNapes = false,
    NapeSize = 150,
    NapeTransparency = 0.75,
    TitanRipper = false,

    -- Combat & Mission Helpers
    AutoReloadBlades = false,
    AutoRefill = false,
    AutoEscapeGrab = false,
    AutoRetry = false,
    AutoSkipCutscene = false,
    AutoFreeChest = false,
    AutoPremiumChest = false,

    -- Visuals & Performance
    TitanESP = false,
    RefillESP = false,
    RemoveDamageText = false,

    -- Main Menu & Webhook
    AutoRollFamily = false,
    RollInterval = 2,
    WebhookURL = "",
    WebhookEnabled = false,
    WebhookShowUsername = false
}

local State = {
    Running = true,
    CanSlash = true,
    FarmStartTimestamp = tick(),
    MissionStartTimestamp = tick(),
    TitanKillsSession = 0,
    BlockedKicksCount = 0,
    NotifiedNapes = {},
    ActiveNotifs = {},
    LastBladesEmpty = false,
    LastSpearsEmpty = false,
    LastMissionTime = nil,
    TSHoverPos = nil,
    IsTSHovering = false,
    OriginalNapeSizes = {},
    Connections = {},
    ESPObjects = {}
}

--// Helper: Safe Parent for GUI on Delta / Mobile / PC
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

-- Stealth Container for ESP Highlights (Never placed inside workspace!)
local StealthESPFolder = Instance.new("Folder")
StealthESPFolder.Name = randomIdentifier(16)
StealthESPFolder.Parent = getSafeGuiParent()

--//===========================================================================
--// 🛡️ LAYER 2: METAMETHOD HOOKS (ANTI-KICK & NAPE PROPERTY SPOOFER)
--//===========================================================================

pcall(function()
    if hookmetamethod and getnamecallmethod and checkcaller then
        -- 1. Anti-Kick Hook (__namecall)
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and Config.AntiKick then
                if self == LocalPlayer and (method == "Kick" or method == "kick") then
                    State.BlockedKicksCount = State.BlockedKicksCount + 1
                    warn("[🛡️ AOT:R Security] Blocked a client Kick attempt!")
                    return nil
                end
            end
            return oldNamecall(self, ...)
        end)

        -- 2. Property Spoofer (__index) for Nape Size/Transparency & WalkSpeed
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

    -- Direct Kick function hook fallback
    if hookfunction and LocalPlayer.Kick then
        local oldKick
        oldKick = hookfunction(LocalPlayer.Kick, function(self, ...)
            if self == LocalPlayer and Config.AntiKick then
                State.BlockedKicksCount = State.BlockedKicksCount + 1
                warn("[🛡️ AOT:R Security] Blocked direct LocalPlayer.Kick!")
                return nil
            end
            return oldKick(self, ...)
        end)
    end
end)

--//===========================================================================
--// 🛡️ LAYER 3: ANTI-AFK & STAFF / MODERATOR DETECTOR
--//===========================================================================

-- Disable Roblox Idle connections if getconnections is supported by Delta
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

-- Moderator / Staff / Stranger Detection
local function checkPlayerSecurity(plr)
    if not State.Running or plr == LocalPlayer then return end

    -- Check if player is a game creator or high group rank (Staff/Admin)
    if Config.AntiStaffProtection then
        local isSuspiciousStaff = false
        pcall(function()
            if game.CreatorType == Enum.CreatorType.User and plr.UserId == game.CreatorId then
                isSuspiciousStaff = true
            elseif game.CreatorType == Enum.CreatorType.Group and game.CreatorId > 0 then
                local rank = plr:GetRankInGroup(game.CreatorId)
                if rank >= 100 then -- Moderator / Developer / Admin rank threshold
                    isSuspiciousStaff = true
                end
            end
        end)

        if isSuspiciousStaff then
            Config.AutoKillBlades = false
            Config.AutoFarmTS = false
            warn("[🛡️ AOT:R Security] Staff/Moderator detected (" .. plr.Name .. ")! Evading to Lobby...")
            pcall(function()
                TeleportService:Teleport(PLACE_IDS.Lobby, LocalPlayer)
            end)
            return
        end
    end

    -- Optional: If farming in a solo mission and a stranger joins
    if Config.AntiStrangerInSolo and game.PlaceId ~= PLACE_IDS.MainMenu and game.PlaceId ~= PLACE_IDS.Lobby then
        if Config.AutoKillBlades or Config.AutoFarmTS then
            Config.AutoKillBlades = false
            Config.AutoFarmTS = false
            warn("[🛡️ AOT:R Security] Another player (" .. plr.Name .. ") joined! Pausing Auto-Farm.")
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    task.spawn(checkPlayerSecurity, plr)
end
table.insert(State.Connections, Players.PlayerAdded:Connect(checkPlayerSecurity))

--//===========================================================================
--// 🛡️ LAYER 4: MISSION TIMER GUARD (ANTI-17s BAN)
--//===========================================================================

-- Reads the in-game mission timer or falls back to script mission tracker
local function getMissionElapsedSeconds()
    local interface = PlayerGui:FindFirstChild("Interface")
    local hud = interface and interface:FindFirstChild("HUD")
    if hud then
        for _, desc in ipairs(hud:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible then
                local mm, ss = desc.Text:match("^(%d+):(%d+)$")
                if mm and ss then
                    return (tonumber(mm) * 60) + tonumber(ss)
                end
            end
        end
    end
    return tick() - State.MissionStartTimestamp
end

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

-- Returns true if it is safe to kill a Titan right now
local function isSafeToKillTitan()
    if not Config.SafeMissionTimerGuard then
        return true
    end
    local aliveCount = countAliveTitans()
    local elapsed = getMissionElapsedSeconds()

    -- If this is the LAST Titan (or <= 2 Titans) and mission time is under MinSafeMissionSeconds (20s),
    -- hold fire until the safe time passes so the mission never finishes in < 17s!
    if aliveCount <= 2 and elapsed < Config.MinSafeMissionSeconds then
        return false
    end
    return true
end

-- Reset mission timer when workspace.Titans repopulates after retry
task.spawn(function()
    local lastAlive = 0
    while State.Running do
        task.wait(1)
        local currentAlive = countAliveTitans()
        if lastAlive == 0 and currentAlive > 0 then
            State.MissionStartTimestamp = tick()
            State.NotifiedNapes = {}
        end
        lastAlive = currentAlive
    end
end)

--//===========================================================================
--// UI & INPUT HELPERS
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

local function smartClickButton(btn, offsetX, offsetY)
    if not btn then return false end
    local clicked = false

    pcall(function()
        if firesignal then
            if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                firesignal(btn.MouseButton1Click)
                firesignal(btn.Activated)
                clicked = true
            end
        end
    end)

    pcall(function()
        if VirtualInputManager then
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local inset = GuiService:GetGuiInset()

            local x = pos.X + (size.X / 2) + (offsetX or 0)
            local y
            if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
                y = pos.Y + (size.Y / 2) + (offsetY or 55)
            else
                y = pos.Y + (size.Y / 2) + inset.Y + (offsetY or 0)
            end

            VirtualInputManager:SendMouseMoveEvent(x, y, game)
            task.wait(0.04)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            clicked = true
        end
    end)

    return clicked
end

local function isGuiVisible(obj)
    if not obj or not obj:IsDescendantOf(PlayerGui) then return false end
    if obj.AbsoluteSize.Magnitude <= 10 then return false end
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

--//===========================================================================
--// GAMEPLAY LOGIC FUNCTIONS (AOT:R)
--//===========================================================================

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

local PRIORITY_TITANS = { "Attack_Titan", "Female_Titan", "Armored_Titan" }

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

-- Safe Nape Hitbox Resizer (With Massless & Property Spoof Cache)
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

local function findRefillObject()
    local unclimbable = workspace:FindFirstChild("Unclimbable")
    local reloads = unclimbable and unclimbable:FindFirstChild("Reloads")
    if reloads then
        for _, obj in ipairs(reloads:GetChildren()) do
            local refill = obj:FindFirstChild("Refill")
            if refill then
                return refill
            end
        end
    end
    return nil
end

local function getWeaponStatus()
    local bladesEmpty = false
    local spearsEmpty = false
    local spearSlotCount = "0"
    local hasSpearAmmo = false
    local bladeBarDepleted = false

    local interface = PlayerGui:FindFirstChild("Interface")
    local hud = interface and interface:FindFirstChild("HUD")
    local main = hud and hud:FindFirstChild("Main")
    local top = main and main:FindFirstChild("Top")

    if top then
        local blades = top:FindFirstChild("Blades")
        if blades then
            local sets = blades:FindFirstChild("Sets", true)
            if sets and sets:IsA("TextLabel") then
                local currentSets = tonumber(sets.Text:match("^(%d+)") or "1")
                bladesEmpty = (currentSets == 0)
            end
            local inner = blades:FindFirstChild("Inner")
            local bar = inner and inner:FindFirstChild("Bar")
            local grad = bar and bar:FindFirstChild("Gradient")
            if grad and grad:IsA("UIGradient") then
                bladeBarDepleted = (grad.Offset == Vector2.new(-0.15, 0))
            end
        end

        local spears = top:FindFirstChild("Spears")
        if spears then
            local spearLabel = spears:FindFirstChild("Spears", true)
            if spearLabel and spearLabel:IsA("TextLabel") then
                local c = tonumber(spearLabel.Text:match("^(%d+)") or "0")
                spearSlotCount = tostring(c or 0)
                hasSpearAmmo = (c and c > 0) or false
                spearsEmpty = (c == 0)
            end
        end
    end

    return {
        bladesEmpty = bladesEmpty,
        spearsEmpty = spearsEmpty,
        spearSlot = spearSlotCount,
        hasSpears = hasSpearAmmo,
        bladeBarDepleted = bladeBarDepleted
    }
end

--// Main Heartbeat Loop (Protected Auto Kill Blades + Anti-Fling + Safe Distance Check)
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    if not State.Running or not HumanoidRootPart then return end

    -- Anti-Fling Velocity Clamp Protection
    if Config.VelocityAntiFling then
        if HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 650 then
            HumanoidRootPart.AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity.Unit * 300
        end
        if HumanoidRootPart.AssemblyAngularVelocity.Magnitude > 50 then
            HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- Thunder Spears Hover Lock
    if Config.AutoFarmTS and State.IsTSHovering and State.TSHoverPos then
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.CFrame = CFrame.new(State.TSHoverPos)
        return
    end

    -- Auto Kill Titans (Blades)
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

        -- 🛡️ Security Check 1: Mission Timer Guard (Never finish mission under 20s)
        if not isSafeToKillTitan() then
            return
        end

        -- 🛡️ Security Check 2: Safe Hit Distance Check
        local distToNape = (HumanoidRootPart.Position - nape.Position).Magnitude
        local maxAllowedDist = Config.SafeHitDistanceCheck and math.max(Config.MaxSafeSlashDistance, Config.FloatHeight + 45) or 1500

        if distToNape <= maxAllowedDist and State.CanSlash then
            State.CanSlash = false
            task.spawn(function()
                local debugId = tostring(nape:GetDebugId())
                if Remotes.POST then
                    pcall(function()
                        local dmg = Config.HumanizeAttacks and math.random(212, 294) or 250
                        local acc = Config.HumanizeAttacks and (math.random(19, 31) / 100) or 0.25
                        Remotes.POST:FireServer("Hitboxes", "Register", nape, dmg, acc)
                        Remotes.POST:FireServer("Attacks", "Slash", true)
                    end)
                end

                if not State.NotifiedNapes[debugId] then
                    State.NotifiedNapes[debugId] = true
                    State.TitanKillsSession = State.TitanKillsSession + 1
                    showKillNotification(State.TitanKillsSession)
                end

                local jitter = Config.HumanizeAttacks and (math.random(0, 10) / 100) or 0
                task.wait(Config.SlashCooldown + jitter)
                State.CanSlash = true
            end)
        end
    end
end))

--// Thunder Spears Background Loop (With Mission Timer Guard)
task.spawn(function()
    local firstLaunch = true
    while State.Running do
        if Config.AutoFarmTS and HumanoidRootPart and Remotes.GET and Remotes.POST then
            local debrisFolder = workspace:FindFirstChild("Debris")
            if debrisFolder and debrisFolder:FindFirstChild("Roar") then
                repeat task.wait(0.15) until not (debrisFolder and debrisFolder:FindFirstChild("Roar")) or not Config.AutoFarmTS
            end

            -- Wait if finishing now would violate the 20s Safe Mission Timer
            if not isSafeToKillTitan() then
                if HumanoidRootPart then
                    State.TSHoverPos = HumanoidRootPart.Position
                    State.IsTSHovering = true
                end
                task.wait(0.5)
            else
                local weaponInfo = getWeaponStatus()
                if weaponInfo.hasSpears then
                    local batchCount = (Config.TSKillMode == "Risk") and math.random(8, 16) or math.random(3, 6)
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
                task.wait(1 + (Config.HumanizeAttacks and math.random(1, 25) / 100 or 0))
            end
        else
            firstLaunch = true
            State.IsTSHovering = false
            State.TSHoverPos = nil
            task.wait(0.4)
        end
    end
end)

--// Combat Automation Loop (Auto Reload, Auto Refill, Auto Escape, Titan Ripper)
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

        local status = getWeaponStatus()

        if Config.AutoReloadBlades and status.bladeBarDepleted and Remotes.GET then
            pcall(function()
                Remotes.GET:InvokeServer("Blades", "Reload")
            end)
        end

        if Config.AutoRefill and Remotes.POST then
            local refillObj = findRefillObject()
            if refillObj then
                if status.bladesEmpty and not State.LastBladesEmpty then
                    pcall(function()
                        Remotes.POST:FireServer("Attacks", "Reload", refillObj)
                    end)
                end
                if status.spearsEmpty and not State.LastSpearsEmpty then
                    pcall(function()
                        Remotes.POST:FireServer("Attacks", "Reload", refillObj)
                    end)
                end
                State.LastBladesEmpty = status.bladesEmpty
                State.LastSpearsEmpty = status.spearsEmpty
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

        if Config.TitanRipper and Remotes.GET and isSafeToKillTitan() then
            local now = tick()
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

--// Mission UI Automation Loop (Auto Retry, Skip Cutscene, Open Chests, Auto Roll)
task.spawn(function()
    while State.Running do
        task.wait(0.6)
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
                    task.wait(0.9)
                    if isGuiVisible(retryBtn) then
                        State.MissionStartTimestamp = tick()
                        smartClickButton(retryBtn, 20, 0)
                        task.wait(3)
                    end
                end
            end

            if Config.AutoRollFamily then
                local custom = interface:FindFirstChild("Customisation")
                local family = custom and custom:FindFirstChild("Family")
                local rollBtn = family and family:FindFirstChild("Roll")
                if isGuiVisible(rollBtn) then
                    smartClickButton(rollBtn, 0, 0)
                    task.wait(Config.RollInterval)
                end
            end
        end
    end
end)

--// Stealth ESP System (Parented to StealthESPFolder inside gethui(), NEVER inside workspace!)
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
                    highlight.Parent = StealthESPFolder -- Hidden from workspace scans!
                    State.ESPObjects[titan] = highlight
                end
            end
        end
    end

    if Config.RefillESP then
        local unclimbable = workspace:FindFirstChild("Unclimbable")
        local reloads = unclimbable and unclimbable:FindFirstChild("Reloads")
        if reloads then
            for _, station in ipairs(reloads:GetChildren()) do
                if not State.ESPObjects[station] then
                    local hl = Instance.new("Highlight")
                    hl.Name = randomIdentifier(10)
                    hl.FillColor = Color3.fromRGB(50, 220, 120)
                    hl.OutlineColor = Color3.fromRGB(200, 255, 220)
                    hl.FillTransparency = 0.5
                    hl.Adornee = station
                    hl.Parent = StealthESPFolder -- Hidden from workspace scans!
                    State.ESPObjects[station] = hl
                end
            end
        end
    end
end

task.spawn(function()
    while State.Running do
        task.wait(1)
        if Config.TitanESP or Config.RefillESP then
            pcall(updateESP)
        end
        if Config.ExpandNapes then
            pcall(updateAllNapes)
        end
    end
end)

--// Discord Webhook Reporter
local function sendWebhookNotification()
    local httpReq = (syn and syn.request) or (http and http.request) or http_request or request
    if not httpReq or Config.WebhookURL == "" then return end

    local function getGuiText(path)
        local node = PlayerGui
        for _, part in ipairs(string.split(path, ".")) do
            if not node then return "0" end
            node = node:FindFirstChild(part)
        end
        return (node and node:IsA("TextLabel") and node.Text) or "0"
    end

    local timeTaken = getGuiText("Interface.Rewards.Main.Info.Main.Stats.Time_Taken.Amount")
    if timeTaken == "0" or timeTaken == State.LastMissionTime then return end
    State.LastMissionTime = timeTaken

    local damage = getGuiText("Interface.Rewards.Main.Info.Main.Stats.Damage_Dealt.Amount")
    local kills = getGuiText("Interface.Rewards.Main.Info.Main.Stats.Titans_Killed.Amount")
    local crits = getGuiText("Interface.Rewards.Main.Info.Main.Stats.Critical_Hits.Amount")

    local payload = {
        embeds = {{
            title = "⚔️ AOT:R Delta Hub - تقرير المهمة",
            color = 13938487,
            fields = {
                {
                    name = "👤 اللاعب",
                    value = Config.WebhookShowUsername and LocalPlayer.Name or "مخفي (Protected)",
                    inline = true
                },
                {
                    name = "⏱️ الوقت المستغرق",
                    value = tostring(timeTaken),
                    inline = true
                },
                {
                    name = "📊 الإحصائيات",
                    value = string.format("القتلى: **%s**\nالضرر: **%s**\nالضربات الحرجة: **%s**", kills, damage, crits),
                    inline = false
                }
            },
            footer = {
                text = "AOT:R Protected Delta Hub • " .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }}
    }

    pcall(function()
        httpReq({
            Url = Config.WebhookURL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

task.spawn(function()
    while State.Running do
        task.wait(1.5)
        if Config.WebhookEnabled and Config.WebhookURL ~= "" then
            local interface = PlayerGui:FindFirstChild("Interface")
            local retryBtn = interface
                and interface:FindFirstChild("Rewards")
                and interface.Rewards:FindFirstChild("Main")
                and interface.Rewards.Main:FindFirstChild("Info")
                and interface.Rewards.Main.Info:FindFirstChild("Main")
                and interface.Rewards.Main.Info.Main:FindFirstChild("Buttons")
                and interface.Rewards.Main.Info.Main.Buttons:FindFirstChild("Retry")
            if isGuiVisible(retryBtn) then
                sendWebhookNotification()
            end
        end
    end
end)

--//===========================================================================
--// DELTA MOBILE & PC CUSTOM GUI (RANDOMIZED STEALTH NAMES)
--//===========================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = randomIdentifier(16)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getSafeGuiParent()

-- Floating Toggle Button (For Delta Mobile Users)
local FloatButton = Instance.new("TextButton")
FloatButton.Name = randomIdentifier(10)
FloatButton.Size = UDim2.new(0, 54, 0, 54)
FloatButton.Position = UDim2.new(0, 18, 0.5, -27)
FloatButton.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
FloatButton.Text = "🛡️\nAOT"
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

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = randomIdentifier(12)
MainFrame.Size = UDim2.new(0, 540, 0, 365)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -182)
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

-- Top Header Bar
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
TitleLabel.Size = UDim2.new(1, -135, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🛡️ AOT: Revolution | Delta Hub [حماية مشددة]"
TitleLabel.TextColor3 = Color3.fromRGB(235, 200, 90)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SecurityBadge = Instance.new("TextLabel")
SecurityBadge.Size = UDim2.new(0, 76, 0, 22)
SecurityBadge.Position = UDim2.new(1, -122, 0.5, -11)
SecurityBadge.BackgroundColor3 = Color3.fromRGB(25, 65, 42)
SecurityBadge.Text = "🛡️ آمن"
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

-- Sidebar Navigation
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 145, 1, -52)
Sidebar.Position = UDim2.new(0, 8, 0, 46)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 23, 31)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 8)
sideCorner.Parent = Sidebar

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 6)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
sideLayout.Parent = Sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 8)
sidePad.Parent = Sidebar

-- Content Container
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -167, 1, -52)
ContentArea.Position = UDim2.new(0, 159, 0, 46)
ContentArea.BackgroundColor3 = Color3.fromRGB(22, 23, 31)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = ContentArea

-- Tab Builder
local Tabs = {}
local TabButtons = {}

local function createTab(tabName, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -14, 0, 34)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
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
        for _, p in pairs(Tabs) do p.Visible = false end
        for _, b in pairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
            b.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(212, 175, 55)
        btn.TextColor3 = Color3.fromRGB(16, 17, 23)
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

local function addToggle(parent, labelText, defaultVal, callback)
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

    local state = defaultVal
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
    end)
end

local function addCycleButton(parent, labelText, options, defaultIndex, callback)
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

    local idx = defaultIndex or 1
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
    end)
end

local function addStepper(parent, labelText, minVal, maxVal, stepVal, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
    row.BorderSizePixel = 0
    row.Parent = parent

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 6)
    rCorner.Parent = row

    local currentVal = defaultVal

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
        currentVal = math.clamp(newVal, minVal, maxVal)
        lbl.Text = labelText .. ": " .. tostring(currentVal)
        pcall(callback, currentVal)
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
--// BUILD TABS & CONTROLS
--//===========================================================================

local TabFarm = createTab("⚔️ الفارم (Farm)", 1)
local TabSecurity = createTab("🛡️ الحماية (Anti-Ban)", 2)
local TabCombat = createTab("⚡ المساعدات", 3)
local TabESP = createTab("👁️ الرادار (ESP)", 4)
local TabMisc = createTab("⚙️ القائمة واللوبي", 5)

-- Activate first tab by default
Tabs["⚔️ الفارم (Farm)"].Visible = true
TabButtons["⚔️ الفارم (Farm)"].BackgroundColor3 = Color3.fromRGB(212, 175, 55)
TabButtons["⚔️ الفارم (Farm)"].TextColor3 = Color3.fromRGB(16, 17, 23)

-- [TAB 1: AUTO FARM]
addSectionHeader(TabFarm, "قتل العمالقة بالسيوف (Auto Kill Blades)")

addToggle(TabFarm, "تفعيل القتل التلقائي (Auto Kill Titans)", false, function(val)
    Config.AutoKillBlades = val
    if val then
        State.FarmStartTimestamp = tick()
    elseif HumanoidRootPart then
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end
end)

addCycleButton(TabFarm, "طريقة الحركة (Move Mode)", { "Teleportation", "Gliding" }, 1, function(opt)
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

addToggle(TabFarm, "فارم رماح الرعد (Auto Thunder Spears)", false, function(val)
    Config.AutoFarmTS = val
    if not val then
        State.IsTSHovering = false
        State.TSHoverPos = nil
    end
end)

addCycleButton(TabFarm, "وضع رماح الرعد (TS Mode)", { "Safe", "Risk" }, 1, function(opt)
    Config.TSKillMode = opt
end)

addSectionHeader(TabFarm, "تكبير نقطة الضعف والمهارات (Hitbox & Skills)")

addToggle(TabFarm, "تكبير رقبة العملاق (Expand Nape Hitbox)", false, function(val)
    Config.ExpandNapes = val
    pcall(updateAllNapes)
end)

addStepper(TabFarm, "حجم الهيت بوكس (Nape Size)", 50, 1500, 50, Config.NapeSize, function(val)
    Config.NapeSize = val
    if Config.ExpandNapes then
        pcall(updateAllNapes)
    end
end)

addToggle(TabFarm, "تفعيل المهارات تلقائياً (Titan Ripper)", false, function(val)
    Config.TitanRipper = val
end)

-- [TAB 2: 🛡️ SECURITY & ANTI-BAN]
addSectionHeader(TabSecurity, "🛡️ أنظمة الحماية ضد الباند والطرد (مفعلة تلقائياً)")

addToggle(TabSecurity, "حارس وقت المهمة الآمن (منع الإنهاء قبل 20ث)", true, function(val)
    Config.SafeMissionTimerGuard = val
end)

addStepper(TabSecurity, "الحد الأدنى لوقت المهمة (ثانية)", 17, 45, 1, Config.MinSafeMissionSeconds, function(val)
    Config.MinSafeMissionSeconds = val
end)

addToggle(TabSecurity, "منع الطرد من الكلاينت (Anti-Kick Hook)", true, function(val)
    Config.AntiKick = val
end)

addToggle(TabSecurity, "تمويه حجم الهيت بوكس عن فحص اللعبة (Nape Spoof)", true, function(val)
    Config.SpoofNapeProperties = val
end)

addToggle(TabSecurity, "التحقق من المسافة الآمنة قبل الضرب (Safe Range)", true, function(val)
    Config.SafeHitDistanceCheck = val
end)

addToggle(TabSecurity, "أنسنة سرعة الضربات والضرر (Humanize Hits)", true, function(val)
    Config.HumanizeAttacks = val
end)

addToggle(TabSecurity, "مانع الطيران العشوائي خارج الخريطة (Anti-Fling)", true, function(val)
    Config.VelocityAntiFling = val
end)

addSectionHeader(TabSecurity, "👮 حماية ضد المشرفين والخمول (Staff & AFK)")

addToggle(TabSecurity, "الهروب للوبي عند دخول مشرف/أدمن (Anti-Staff)", true, function(val)
    Config.AntiStaffProtection = val
end)

addToggle(TabSecurity, "إيقاف الفارم إذا دخل لاعب غريب معك (Solo Safe)", false, function(val)
    Config.AntiStrangerInSolo = val
end)

addToggle(TabSecurity, "مانع الطرد بسبب الخمول (Anti-AFK 24/7)", true, function(val)
    Config.AntiAFK = val
end)

addActionButton(TabSecurity, "🚨 زر الطوارئ: إيقاف كل التفعيلات فوراً (Panic Stop)", function()
    Config.AutoKillBlades = false
    Config.AutoFarmTS = false
    Config.ExpandNapes = false
    Config.TitanRipper = false
    State.IsTSHovering = false
    State.TSHoverPos = nil
    pcall(updateAllNapes)
    pcall(clearESP)
    if HumanoidRootPart then
        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- [TAB 3: COMBAT & MISSIONS]
addSectionHeader(TabCombat, "الذخيرة والبقاء (Blades, Gas & Escape)")

addToggle(TabCombat, "تبديل السيوف تلقائياً (Auto Reload Blades)", false, function(val)
    Config.AutoReloadBlades = val
end)

addToggle(TabCombat, "إعادة التعبئة التلقائية (Auto Refill Station)", false, function(val)
    Config.AutoRefill = val
end)

addToggle(TabCombat, "الهروب من مسكة العملاق (Auto Escape Grab)", false, function(val)
    Config.AutoEscapeGrab = val
end)

addSectionHeader(TabCombat, "المهمات والغارات (Missions & Raids)")

addToggle(TabCombat, "إعادة المهمة تلقائياً (Auto Retry)", false, function(val)
    Config.AutoRetry = val
end)

addToggle(TabCombat, "تخطي المشاهد السينمائية (Auto Skip Cutscene)", false, function(val)
    Config.AutoSkipCutscene = val
end)

addToggle(TabCombat, "فتح الصندوق المجاني (Auto Free Chest)", false, function(val)
    Config.AutoFreeChest = val
end)

addToggle(TabCombat, "فتح الصندوق المميز (Auto Premium Chest)", false, function(val)
    Config.AutoPremiumChest = val
end)

addToggle(TabCombat, "إشعارات القتل على الشاشة (Kill Notifications)", true, function(val)
    Config.KillNotifications = val
end)

-- [TAB 4: ESP & PERFORMANCE]
addSectionHeader(TabESP, "الرادار المخفي (Stealth ESP)")

addToggle(TabESP, "كشف العمالقة (Titan Highlight ESP)", false, function(val)
    Config.TitanESP = val
    if not val then clearESP() else pcall(updateESP) end
end)

addToggle(TabESP, "كشف نقاط التعبئة (Refill Station ESP)", false, function(val)
    Config.RefillESP = val
    if not val then clearESP() else pcall(updateESP) end
end)

addSectionHeader(TabESP, "تحسين الأداء والفريمات (FPS & Visuals)")

local dmgTextConn = nil
addToggle(TabESP, "إخفاء أرقام الضرر (Remove Damage Text)", false, function(val)
    Config.RemoveDamageText = val
    local interface = PlayerGui:FindFirstChild("Interface")
    if val and interface then
        for _, obj in ipairs(interface:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Name == "Number" then
                obj.Visible = false
            end
        end
        dmgTextConn = interface.DescendantAdded:Connect(function(obj)
            if obj:IsA("TextLabel") and obj.Name == "Number" then
                obj.Visible = false
            end
        end)
    else
        if dmgTextConn then
            dmgTextConn:Disconnect()
            dmgTextConn = nil
        end
    end
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

-- [TAB 5: LOBBY, ROLL & SETTINGS]
addSectionHeader(TabMisc, "القائمة الرئيسية (Main Menu Roll)")

addToggle(TabMisc, "لف العائلات تلقائياً (Auto Family Roll)", false, function(val)
    Config.AutoRollFamily = val
end)

addStepper(TabMisc, "الفاصل الزمني للف (Roll Delay)", 1, 10, 1, Config.RollInterval, function(val)
    Config.RollInterval = val
end)

addSectionHeader(TabMisc, "التنقل السريع (Quick Teleport)")

addActionButton(TabMisc, "🏠 الانتقال إلى اللوبي (Return to Lobby)", function()
    TeleportService:Teleport(PLACE_IDS.Lobby, LocalPlayer)
end)

addActionButton(TabMisc, "🎮 الانتقال للقائمة الرئيسية (Main Menu)", function()
    TeleportService:Teleport(PLACE_IDS.MainMenu, LocalPlayer)
end)

addSectionHeader(TabMisc, "إدارة السكربت (Script Control)")

addActionButton(TabMisc, "❌ إغلاق وحذف السكربت بالكامل (Unload Script)", function()
    if getgenv and getgenv().AOTR_Delta_Cleanup then
        getgenv().AOTR_Delta_Cleanup()
    end
end)

--// Toggle Menu Visibility (Floating Button, Minimize Button & Keyboard Key)
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

print("[🛡️ AOT:R Protected Delta Hub] Loaded with Multi-Layer Anti-Ban & Stealth Protection!")
