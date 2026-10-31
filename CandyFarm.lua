
-- CandyFarm UI - Fixed Version

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local env = getgenv()

if env.CandyUICleanup then
    pcall(env.CandyUICleanup)
end

local running = false
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
    Size = UDim2.fromOffset(290, 250),
    Position = UDim2.new(0.5, -145, 0.5, -125),
    BackgroundColor3 = Color3.fromRGB(25,25,32),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true
}, gui)

make("UICorner", {
    CornerRadius = UDim.new(0,12)
}, frame)

local function button(txt, y, color)
    local b = make("TextButton", {
        Size = UDim2.fromOffset(250,35),
        Position = UDim2.fromOffset(20,y),
        BackgroundColor3 = color,
        Text = txt,
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 14
    }, frame)

    make("UICorner", {
        CornerRadius = UDim.new(0,7)
    }, b)

    return b
end

make("TextLabel", {
    Size = UDim2.fromOffset(290,35),
    BackgroundTransparency = 1,
    Text = "HALLOWEEN CANDY",
    TextColor3 = Color3.fromRGB(255,165,45),
    Font = Enum.Font.GothamBold,
    TextSize = 16
}, frame)

local status = make("TextLabel", {
    Size = UDim2.fromOffset(290,25),
    Position = UDim2.fromOffset(0,35),
    BackgroundTransparency = 1,
    Text = "STATUS: STOPPED",
    TextColor3 = Color3.fromRGB(255,90,90),
    Font = Enum.Font.GothamBold,
    TextSize = 13
}, frame)

local startBtn = button(
    "START [K]", 65, Color3.fromRGB(35,160,90)
)

local stopBtn = button(
    "STOP [J]", 105, Color3.fromRGB(200,65,65)
)

local unloadBtn = button(
    "UNLOAD", 190, Color3.fromRGB(85,85,100)
)

make("TextLabel", {
    Size = UDim2.fromOffset(130,35),
    Position = UDim2.fromOffset(20,145),
    BackgroundTransparency = 1,
    Text = "TP DELAY (SEC):",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.Gotham,
    TextSize = 12
}, frame)

local speedBox = make("TextBox", {
    Size = UDim2.fromOffset(100,30),
    Position = UDim2.fromOffset(155,147),
    BackgroundColor3 = Color3.fromRGB(45,45,55),
    TextColor3 = Color3.new(1,1,1),
    Text = "1",
    PlaceholderText = "1.0",
    ClearTextOnFocus = false,
    Font = Enum.Font.GothamBold,
    TextSize = 14
}, frame)

make("UICorner", {
    CornerRadius = UDim.new(0,6)
}, speedBox)

make("TextLabel", {
    Size = UDim2.fromOffset(290,20),
    Position = UDim2.fromOffset(0,228),
    BackgroundTransparency = 1,
    Text = "RIGHT SHIFT : SHOW / HIDE",
    TextColor3 = Color3.fromRGB(180,180,190),
    Font = Enum.Font.Gotham,
    TextSize = 11
}, frame)

local function stopFarm()
    running = false
    session += 1
    status.Text = "STATUS: STOPPED"
    status.TextColor3 = Color3.fromRGB(255,90,90)
    print("[Candy Farm] STOPPED")
end

local function getCandies()
    local result = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart")
        and obj.Name:match("^SPOOK_CANDY_") then
            table.insert(result,obj)
        end
    end

    return result
end

local function startFarm()
    if running then return end

    running = true
    session += 1
    visited = {}

    local id = session

    status.Text = "STATUS: RUNNING"
    status.TextColor3 = Color3.fromRGB(70,230,130)

    print("[Candy Farm] STARTED")

    task.spawn(function()
        while running and session == id do
            for _, candy in ipairs(getCandies()) do
                if not running or session ~= id then
                    break
                end

                local char = player.Character
                local root = char and char:FindFirstChild(
                    "HumanoidRootPart"
                )

                if root and candy.Parent
                and not visited[candy] then
                    visited[candy] = true

                    root.CFrame =
                        candy.CFrame * CFrame.new(0,2,0)

                    print("[Candy TP]", candy.Name)

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
    startBtn.MouseButton1Click:Connect(startFarm)
)

table.insert(connections,
    stopBtn.MouseButton1Click:Connect(stopFarm)
)

local function unload()
    stopFarm()

    for _, c in ipairs(connections) do
        c:Disconnect()
    end

    gui:Destroy()
    env.CandyUICleanup = nil

    print("[Candy Farm] UNLOADED")
end

table.insert(connections,
    unloadBtn.MouseButton1Click:Connect(unload)
)

table.insert(connections,
    UIS.InputBegan:Connect(function(input, processed)
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

env.CandyUICleanup = unload

print("[Candy UI] Loaded Successfully")
