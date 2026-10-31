
-- Driving Empire Halloween Candy Farm
-- K: START | J: STOP | RightShift: UI

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local env = getgenv()

-- Remove previous instance
if env.CandyUICleanup then
    pcall(env.CandyUICleanup)
end

local running = false
local unloaded = false
local session = 0
local delayTime = 1
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
    Size = UDim2.fromOffset(290, 290),
    Position = UDim2.new(0.5, -145, 0.5, -145),
    BackgroundColor3 = Color3.fromRGB(25, 25, 32),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true
}, gui)

make("UICorner", {
    CornerRadius = UDim.new(0, 12)
}, frame)

local title = make("TextLabel", {
    Size = UDim2.fromOffset(250, 40),
    BackgroundTransparency = 1,
    Text = "HALLOWEEN CANDY FARM",
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
    Size = UDim2.fromOffset(290, 28),
    BackgroundTransparency = 1,
    Text = "STATUS: STOPPED",
    TextColor3 = Color3.fromRGB(255, 90, 90),
    Font = Enum.Font.GothamBold,
    TextSize = 13
}, content)

local function button(txt, y, color)
    local b = make("TextButton", {
        Size = UDim2.fromOffset(250, 36),
        Position = UDim2.fromOffset(20, y),
        BackgroundColor3 = color,
        Text = txt,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14
    }, content)

    make("UICorner", {
        CornerRadius = UDim.new(0, 7)
    }, b)

    return b
end

local startBtn = button(
    "START [K]", 32,
    Color3.fromRGB(35, 160, 90)
)

local stopBtn = button(
    "STOP [J]", 74,
    Color3.fromRGB(200, 65, 65)
)

local unloadBtn = button(
    "UNLOAD", 166,
    Color3.fromRGB(85, 85, 100)
)

make("TextLabel", {
    Size = UDim2.fromOffset(130, 34),
    Position = UDim2.fromOffset(20, 119),
    BackgroundTransparency = 1,
    Text = "TP DELAY (SEC):",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.Gotham,
    TextSize = 12
}, content)

local speedBox = make("TextBox", {
    Size = UDim2.fromOffset(100, 30),
    Position = UDim2.fromOffset(155, 121),
    BackgroundColor3 = Color3.fromRGB(45, 45, 55),
    TextColor3 = Color3.new(1, 1, 1),
    Text = "1",
    PlaceholderText = "1.0",
    ClearTextOnFocus = false,
    Font = Enum.Font.GothamBold,
    TextSize = 14
}, content)

make("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, speedBox)

local info = make("TextLabel", {
    Size = UDim2.fromOffset(270, 22),
    Position = UDim2.fromOffset(10, 207),
    BackgroundTransparency = 1,
    Text = "PUMPKIN > LOLLY > CANDY",
    TextColor3 = Color3.fromRGB(180, 180, 190),
    Font = Enum.Font.Gotham,
    TextSize = 11
}, content)

local hint = make("TextLabel", {
    Size = UDim2.fromOffset(270, 18),
    Position = UDim2.fromOffset(10, 229),
    BackgroundTransparency = 1,
    Text = "RIGHT SHIFT : SHOW / HIDE",
    TextColor3 = Color3.fromRGB(150, 150, 165),
    Font = Enum.Font.Gotham,
    TextSize = 10
}, content)

local function setStatus(active)
    status.Text = active
        and "STATUS: RUNNING"
        or "STATUS: STOPPED"

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

            -- Pumpkin inside Spookfest2026Pumpkin
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

    -- Priority order
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
    if running or unloaded then return end

    running = true
    session += 1
    visited = {}

    local currentSession = session

    setStatus(true)
    print("[Candy Farm] STARTED")

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

                    info.Text = "TARGET: " .. target.Name

                    print(
                        "[Candy TP]",
                        target:GetFullName()
                    )

                    task.wait(delayTime)
                end
            end

            task.wait(1)
        end
    end)
end

-- TP speed input
table.insert(connections,
    speedBox.FocusLost:Connect(function()
        local n = tonumber(speedBox.Text)

        if n and n >= 0.1 and n <= 10 then
            delayTime = n
            print("[Candy Farm] TP Delay:", n)
        end

        speedBox.Text = tostring(delayTime)
    end)
)

-- Button events
table.insert(connections,
    startBtn.MouseButton1Click:Connect(startFarm)
)

table.insert(connections,
    stopBtn.MouseButton1Click:Connect(stopFarm)
)

-- Unload
local function unload()
    if unloaded then return end

    stopFarm()
    unloaded = true

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    table.clear(connections)
    gui:Destroy()

    if env.CandyUICleanup == unload then
        env.CandyUICleanup = nil
    end

    print("[Candy Farm] UNLOADED")
end

table.insert(connections,
    unloadBtn.MouseButton1Click:Connect(unload)
)

-- Keyboard controls
table.insert(connections,
    UIS.InputBegan:Connect(function(input, processed)
        if unloaded then return end
        if UIS:GetFocusedTextBox() then return end

        if input.KeyCode == Enum.KeyCode.RightShift then
            gui.Enabled = not gui.Enabled
            return
        end

        if processed then return end

        if input.KeyCode == Enum.KeyCode.K then
            startFarm()

        elseif input.KeyCode == Enum.KeyCode.J then
            stopFarm()
        end
    end)
)

-- Minimize UI
local minimized = false

table.insert(connections,
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized

        frame.Size = minimized
            and UDim2.fromOffset(290, 40)
            or UDim2.fromOffset(290, 290)

        minimizeBtn.Text = minimized and "+" or "-"
    end)
)

env.CandyUICleanup = unload

print("[Candy UI] Loaded Successfully")
print("[Candy UI] K=START | J=STOP")
print("[Candy UI] RightShift=SHOW/HIDE")
