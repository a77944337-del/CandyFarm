
-- Driving Empire Halloween Candy Farm + ATM UI
-- K: START CANDY FARM
-- J: STOP CANDY FARM
-- RightShift: SHOW / HIDE UI
-- ATM AUTO: UI toggle (interaction not yet connected)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local env = getgenv()

-- Clean up previous instance
if env.CandyUICleanup then
    pcall(env.CandyUICleanup)
end

local running = false
local atmRunning = false
local unloaded = false
local session = 0

local delayTime = 1
local atmHoldTime = 5.4

local visited = {}
local connections = {}

local gui = Instance.new("ScreenGui")
gui.Name = "HalloweenCandyFarm"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function make(class, props, parent)
    local obj = Instance.new(class)

    for k, v in pairs(props) do
        obj[k] = v
    end

    obj.Parent = parent
    return obj
end

local frame = make("Frame", {
    Size = UDim2.fromOffset(290, 355),
    Position = UDim2.new(0.5, -145, 0.5, -177),
    BackgroundColor3 = Color3.fromRGB(25, 25, 32),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true
}, gui)

make("UICorner", {
    CornerRadius = UDim.new(0, 12)
}, frame)

make("TextLabel", {
    Size = UDim2.fromOffset(250, 40),
    BackgroundTransparency = 1,
    Text = "CANDY FARM + ATM",
    TextColor3 = Color3.fromRGB(255, 165, 45),
    Font = Enum.Font.GothamBold,
    TextSize = 15
}, frame)

local minimizeBtn = make("TextButton", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.fromOffset(255, 6),
    BackgroundColor3 = Color3.fromRGB(55, 55, 65),
    Text = "-",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 20
}, frame)

make("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, minimizeBtn)

local content = make("Frame", {
    Size = UDim2.new(1, 0, 1, -40),
    Position = UDim2.fromOffset(0, 40),
    BackgroundTransparency = 1
}, frame)

local status = make("TextLabel", {
    Size = UDim2.fromOffset(290, 26),
    BackgroundTransparency = 1,
    Text = "CANDY: STOPPED",
    TextColor3 = Color3.fromRGB(255, 90, 90),
    Font = Enum.Font.GothamBold,
    TextSize = 13
}, content)

local function button(txt, y, color)
    local b = make("TextButton", {
        Size = UDim2.fromOffset(250, 34),
        Position = UDim2.fromOffset(20, y),
        BackgroundColor3 = color,
        Text = txt,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13
    }, content)

    make("UICorner", {
        CornerRadius = UDim.new(0, 7)
    }, b)

    return b
end

local startBtn = button(
    "START CANDY [K]", 30,
    Color3.fromRGB(35, 160, 90)
)

local stopBtn = button(
    "STOP CANDY [J]", 69,
    Color3.fromRGB(200, 65, 65)
)

make("TextLabel", {
    Size = UDim2.fromOffset(130, 25),
    Position = UDim2.fromOffset(20, 109),
    BackgroundTransparency = 1,
    Text = "TP DELAY (SEC):",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.Gotham,
    TextSize = 12
}, content)

local speedBox = make("TextBox", {
    Size = UDim2.fromOffset(100, 27),
    Position = UDim2.fromOffset(155, 108),
    BackgroundColor3 = Color3.fromRGB(45, 45, 55),
    TextColor3 = Color3.new(1, 1, 1),
    Text = "1",
    ClearTextOnFocus = false,
    Font = Enum.Font.GothamBold,
    TextSize = 14
}, content)

make("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, speedBox)

local atmStatus = make("TextLabel", {
    Size = UDim2.fromOffset(250, 24),
    Position = UDim2.fromOffset(20, 143),
    BackgroundTransparency = 1,
    Text = "ATM: NOT CONNECTED",
    TextColor3 = Color3.fromRGB(255, 190, 90),
    Font = Enum.Font.GothamBold,
    TextSize = 12
}, content)

local atmBtn = button(
    "ATM AUTO: OFF", 169,
    Color3.fromRGB(100, 85, 170)
)

local atmTimeLabel = make("TextLabel", {
    Size = UDim2.fromOffset(130, 25),
    Position = UDim2.fromOffset(20, 211),
    BackgroundTransparency = 1,
    Text = "HOLD TIME (SEC):",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.Gotham,
    TextSize = 12
}, content)

local atmTimeBox = make("TextBox", {
    Size = UDim2.fromOffset(100, 27),
    Position = UDim2.fromOffset(155, 210),
    BackgroundColor3 = Color3.fromRGB(45, 45, 55),
    TextColor3 = Color3.new(1, 1, 1),
    Text = "5.4",
    ClearTextOnFocus = false,
    Font = Enum.Font.GothamBold,
    TextSize = 14
}, content)

make("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, atmTimeBox)

make("TextLabel", {
    Size = UDim2.fromOffset(270, 22),
    Position = UDim2.fromOffset(10, 246),
    BackgroundTransparency = 1,
    Text = "PUMPKIN > LOLLY > CANDY",
    TextColor3 = Color3.fromRGB(180, 180, 190),
    Font = Enum.Font.Gotham,
    TextSize = 11
}, content)

make("TextLabel", {
    Size = UDim2.fromOffset(270, 18),
    Position = UDim2.fromOffset(10, 267),
    BackgroundTransparency = 1,
    Text = "RIGHT SHIFT: SHOW / HIDE",
    TextColor3 = Color3.fromRGB(150, 150, 165),
    Font = Enum.Font.Gotham,
    TextSize = 10
}, content)

local unloadBtn = button(
    "UNLOAD", 290,
    Color3.fromRGB(85, 85, 100)
)

local function setStatus(active)
    status.Text = active
        and "CANDY: RUNNING"
        or "CANDY: STOPPED"

    status.TextColor3 = active
        and Color3.fromRGB(70, 230, 130)
        or Color3.fromRGB(255, 90, 90)
end

-- Find Halloween collectibles
local function getCandies()
    local result = {}
    local folder = workspace:FindFirstChild(
        "CollectibleSpawner"
    )

    if not folder then
        return result
    end

    local pumpkins = {}
    local lollies = {}
    local candies = {}

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:upper()

            if name == "PUMPKIN"
            and obj.Parent
            and obj.Parent.Name:upper()
                == "SPOOKFEST2026PUMPKIN" then

                table.insert(pumpkins, obj)

            elseif name:match("^SPOOK_LOLLY_") then
                table.insert(lollies, obj)

            elseif name:match("^SPOOK_CANDY_") then
                table.insert(candies, obj)
            end
        end
    end

    for _, obj in ipairs(pumpkins) do
        table.insert(result, obj)
    end

    for _, obj in ipairs(lollies) do
        table.insert(result, obj)
    end

    for _, obj in ipairs(candies) do
        table.insert(result, obj)
    end

    return result
end

local function stopFarm()
    running = false
    session += 1
    setStatus(false)
    print("[Candy Farm] STOPPED")
end

local function startFarm()
    if running or unloaded then
        return
    end

    running = true
    session += 1
    visited = {}

    local currentSession = session
    setStatus(true)

    task.spawn(function()
        while running
        and not unloaded
        and session == currentSession do

            local targets = getCandies()

            for _, target in ipairs(targets) do
                if not running
                or unloaded
                or session ~= currentSession then
                    break
                end

                local char = player.Character
                local root = char and char:FindFirstChild(
                    "HumanoidRootPart"
                )

                if root
                and target.Parent
                and not visited[target] then

                    visited[target] = true

                    root.CFrame =
                        target.CFrame * CFrame.new(0, 2, 0)

                    atmStatus.Text =
                        atmRunning
                        and "ATM: ENABLED (NOT CONNECTED)"
                        or "ATM: NOT CONNECTED"

                    print("[Candy TP]", target:GetFullName())
                    task.wait(delayTime)
                end
            end

            task.wait(1)
        end
    end)
end

table.insert(connections,
    speedBox.FocusLost:Connect(function()
        local n = tonumber(speedBox.Text)

        if n and n >= 0.1 and n <= 10 then
            delayTime = n
        end

        speedBox.Text = tostring(delayTime)
    end)
)

table.insert(connections,
    atmTimeBox.FocusLost:Connect(function()
        local n = tonumber(atmTimeBox.Text)

        if n and n >= 0.1 and n <= 30 then
            atmHoldTime = n
        end

        atmTimeBox.Text = tostring(atmHoldTime)
        print("[ATM] Hold time configured:", atmHoldTime)
    end)
)

table.insert(connections,
    startBtn.MouseButton1Click:Connect(startFarm)
)

table.insert(connections,
    stopBtn.MouseButton1Click:Connect(stopFarm)
)

table.insert(connections,
    atmBtn.MouseButton1Click:Connect(function()
        if unloaded then
            return
        end

        atmRunning = not atmRunning

        atmBtn.Text = atmRunning
            and "ATM AUTO: ON"
            or "ATM AUTO: OFF"

        atmBtn.BackgroundColor3 = atmRunning
            and Color3.fromRGB(35, 145, 90)
            or Color3.fromRGB(100, 85, 170)

        atmStatus.Text = atmRunning
            and "ATM: ENABLED (NOT CONNECTED)"
            or "ATM: NOT CONNECTED"

        print("[ATM] Toggle:", atmRunning)
        print("[ATM] Hold time:", atmHoldTime)
    end)
)

local function unload()
    if unloaded then
        return
    end

    stopFarm()
    atmRunning = false
    unloaded = true

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    table.clear(connections)
    gui:Destroy()

    if env.CandyUICleanup == unload then
        env.CandyUICleanup = nil
    end

    print("[Candy UI] UNLOADED")
end

table.insert(connections,
    unloadBtn.MouseButton1Click:Connect(unload)
)

local minimized = false

table.insert(connections,
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized

        frame.Size = minimized
            and UDim2.fromOffset(290, 40)
            or UDim2.fromOffset(290, 395)

        minimizeBtn.Text = minimized and "+" or "-"
    end)
)

table.insert(connections,
    UIS.InputBegan:Connect(function(input, processed)
        if unloaded then
            return
        end

        if UIS:GetFocusedTextBox() then
            return
        end

        if input.KeyCode == Enum.KeyCode.RightShift then
            gui.Enabled = not gui.Enabled
            return
        end

        if processed then
            return
        end

        if input.KeyCode == Enum.KeyCode.K then
            startFarm()
        elseif input.KeyCode == Enum.KeyCode.J then
            stopFarm()
        end
    end)
)

env.CandyUICleanup = unload

print("[Candy UI] Loaded")
print("[Candy UI] K=START | J=STOP | RightShift=SHOW/HIDE")
print("[ATM] UI added; actual ATM interaction is not connected.")
