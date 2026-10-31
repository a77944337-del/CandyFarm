-- Driving Empire Halloween Candy TP Farm UI
-- K: start | J: stop | RightShift: show/hide

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local env = getgenv()

if env.CandyUICleanup then
    pcall(env.CandyUICleanup)
end

local running, session, minimized = false, 0, false
local visited, connections = {}, {}
local folder = workspace:WaitForChild("CollectibleSpawner", 15)
if not folder then
    warn("[Candy Farm] CollectibleSpawner not found")
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "HalloweenCandyFarm"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props) do obj[key] = value end
    obj.Parent = parent
    return obj
end

local frame = make("Frame", {
    Size = UDim2.fromOffset(290, 205),
    Position = UDim2.new(0.5, -145, 0.5, -102),
    BackgroundColor3 = Color3.fromRGB(25, 25, 32),
    BorderSizePixel = 0,
    Active = true
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, frame)

local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 43),
    BackgroundTransparency = 1,
    Active = true
}, frame)
make("TextLabel", {
    Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Text = "HALLOWEEN CANDY",
    TextColor3 = Color3.fromRGB(255, 165, 45),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left
}, header)
local minimize = make("TextButton", {
    Size = UDim2.fromOffset(30, 28),
    Position = UDim2.new(1, -37, 0, 7),
    BackgroundColor3 = Color3.fromRGB(50, 50, 60),
    Text = "-", TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 20
}, header)
make("UICorner", {CornerRadius = UDim.new(0, 6)}, minimize)

local content = make("Frame", {
    Size = UDim2.new(1, 0, 1, -43),
    Position = UDim2.fromOffset(0, 43),
    BackgroundTransparency = 1
}, frame)
local status = make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundTransparency = 1,
    Text = "STATUS: STOPPED",
    TextColor3 = Color3.fromRGB(255, 90, 90),
    Font = Enum.Font.GothamBold, TextSize = 14
}, content)
local startBtn = make("TextButton", {
    Size = UDim2.fromOffset(115, 42),
    Position = UDim2.fromOffset(22, 43),
    BackgroundColor3 = Color3.fromRGB(35, 160, 90),
    Text = "START [K]", TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 14
}, content)
local stopBtn = make("TextButton", {
    Size = UDim2.fromOffset(115, 42),
    Position = UDim2.fromOffset(153, 43),
    BackgroundColor3 = Color3.fromRGB(200, 65, 65),
    Text = "STOP [J]", TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 14
}, content)
for _, button in ipairs({startBtn, stopBtn}) do
    make("UICorner", {CornerRadius = UDim.new(0, 8)}, button)
end
local info = make("TextLabel", {
    Size = UDim2.new(1, -16, 0, 55),
    Position = UDim2.fromOffset(8, 94),
    BackgroundTransparency = 1,
    Text = "TP DELAY: 2 SECONDS\nRIGHT SHIFT: SHOW / HIDE",
    TextColor3 = Color3.fromRGB(180, 180, 190),
    Font = Enum.Font.Gotham, TextSize = 12,
    TextWrapped = true
}, content)

local function setStatus(active)
    status.Text = active and "STATUS: RUNNING" or "STATUS: STOPPED"
    status.TextColor3 = active and Color3.fromRGB(70, 230, 130) or Color3.fromRGB(255, 90, 90)
end

local function getCandies()
    local candies = {}
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:match("^SPOOK_CANDY_") then
            table.insert(candies, obj)
        end
    end
    return candies
end

local function stopFarm()
    running = false
    session += 1
    setStatus(false)
    info.Text = "TP DELAY: 2 SECONDS\nRIGHT SHIFT: SHOW / HIDE"
    print("[Candy Farm] STOPPED")
end

local function startFarm()
    if running then return end
    running = true
    session += 1
    local currentSession = session
    visited = {}
    setStatus(true)
    print("[Candy Farm] STARTED")

    task.spawn(function()
        while running and session == currentSession do
            for _, candy in ipairs(getCandies()) do
                if not running or session ~= currentSession then break end
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root and candy.Parent and not visited[candy] then
                    visited[candy] = true
                    root.CFrame = candy.CFrame * CFrame.new(0, 2, 0)
                    info.Text = "TARGET: " .. candy.Name .. "\nTP DELAY: 2 SECONDS"
                    print("[Candy TP]", candy:GetFullName())
                    task.wait(1)
                end
            end
            task.wait(1)
        end
    end)
end

table.insert(connections, startBtn.MouseButton1Click:Connect(startFarm))
table.insert(connections, stopBtn.MouseButton1Click:Connect(stopFarm))
table.insert(connections, minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    frame.Size = minimized and UDim2.fromOffset(290, 43) or UDim2.fromOffset(290, 205)
    minimize.Text = minimized and "+" or "-"
end))

-- Drag by header (works without deprecated Draggable property)
local dragging, dragStart, startPos = false, nil, nil
table.insert(connections, header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end))
table.insert(connections, UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))
table.insert(connections, UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))

table.insert(connections, UIS.InputBegan:Connect(function(input, processed)
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
end))

env.CandyUICleanup = function()
    stopFarm()
    for _, connection in ipairs(connections) do connection:Disconnect() end
    gui:Destroy()
end
print("[Candy UI] Loaded | K = START | J = STOP | RightShift = UI")
