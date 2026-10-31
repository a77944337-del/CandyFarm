-- Driving Empire Halloween Candy TP Farm UI
-- K = START | J = STOP | RightShift = toggle UI
local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local player = Players.LocalPlayer
local env = getgenv()
if env.CandyUICleanup then pcall(env.CandyUICleanup) end
local folder = workspace:WaitForChild('CollectibleSpawner', 15)
if not folder then warn('[Candy Farm] CollectibleSpawner not found'); return end
local running, unloaded, minimized, session = false, false, false, 0
local tpDelay = 1
local visited, connections = {}, {}
local gui = Instance.new('ScreenGui')
gui.Name = 'HalloweenCandyFarm'; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild('PlayerGui')
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local frame = make('Frame', {Size=UDim2.fromOffset(290,280), Position=UDim2.new(.5,-145,.5,-140), BackgroundColor3=Color3.fromRGB(25,25,32), BorderSizePixel=0, Active=true}, gui)
make('UICorner',{CornerRadius=UDim.new(0,12)},frame)
local header = make('Frame',{Size=UDim2.new(1,0,0,43),BackgroundTransparency=1,Active=true},frame)
make('TextLabel',{Size=UDim2.new(1,-50,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,Text='HALLOWEEN CANDY',TextColor3=Color3.fromRGB(255,165,45),Font=Enum.Font.GothamBold,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left},header)
local minimize = make('TextButton',{Size=UDim2.fromOffset(30,28),Position=UDim2.new(1,-37,0,7),BackgroundColor3=Color3.fromRGB(50,50,60),Text='-',TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=20},header)
make('UICorner',{CornerRadius=UDim.new(0,6)},minimize)
local content = make('Frame',{Size=UDim2.new(1,0,1,-43),Position=UDim2.fromOffset(0,43),BackgroundTransparency=1},frame)
local status = make('TextLabel',{Size=UDim2.new(1,0,0,32),BackgroundTransparency=1,Text='STATUS: STOPPED',TextColor3=Color3.fromRGB(255,90,90),Font=Enum.Font.GothamBold,TextSize=14},content)
local function button(text,x,y,w,color)
    local b=make('TextButton',{Size=UDim2.fromOffset(w,40),Position=UDim2.fromOffset(x,y),BackgroundColor3=color,Text=text,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=14},content)
    make('UICorner',{CornerRadius=UDim.new(0,8)},b)
    return b
end
local startBtn=button('START [K]',22,39,115,Color3.fromRGB(35,160,90))
local stopBtn=button('STOP [J]',153,39,115,Color3.fromRGB(200,65,65))
local unloadBtn=button('UNLOAD',22,91,246,Color3.fromRGB(75,75,90))
local delayLabel=make('TextLabel',{Size=UDim2.fromOffset(140,28),Position=UDim2.fromOffset(22,139),BackgroundTransparency=1,Text='TP DELAY (SEC):',TextColor3=Color3.fromRGB(220,220,225),Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},content)
local delayInput=make('TextBox',{Size=UDim2.fromOffset(95,30),Position=UDim2.fromOffset(173,138),BackgroundColor3=Color3.fromRGB(48,48,60),Text='1',PlaceholderText='0.1 - 10',ClearTextOnFocus=false,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=14},content)
make('UICorner',{CornerRadius=UDim.new(0,6)},delayInput)
local info=make('TextLabel',{Size=UDim2.new(1,-16,0,43),Position=UDim2.fromOffset(8,174),BackgroundTransparency=1,Text='RIGHT SHIFT: SHOW / HIDE',TextColor3=Color3.fromRGB(180,180,190),Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true},content)
local function formatDelay()
    return string.format('%g',tpDelay)
end
table.insert(connections,delayInput.FocusLost:Connect(function()
    local value=tonumber(delayInput.Text)
    if value and value==value and value>=0.1 and value<=10 then
        tpDelay=value
    end
    delayInput.Text=formatDelay()
    print('[Candy Farm] TP delay:',tpDelay,'seconds')
end))
local function waitCancelable(seconds, currentSession)
    local elapsed=0
    while elapsed<seconds do
        if not running or unloaded or session~=currentSession then return false end
        local step=math.min(0.05,seconds-elapsed)
        task.wait(step)
        elapsed+=step
    end
    return running and not unloaded and session==currentSession
end
local function setStatus(active)
    if unloaded then return end
    status.Text=active and 'STATUS: RUNNING' or 'STATUS: STOPPED'
    status.TextColor3=active and Color3.fromRGB(70,230,130) or Color3.fromRGB(255,90,90)
end
local function getCandies()
    local result={}
    for _,obj in ipairs(folder:GetDescendants()) do
        if obj:IsA('BasePart') and obj.Name:match('^SPOOK_CANDY_') then
            table.insert(result,obj)
        end
    end
    return result
end
local function stopFarm()
    running=false; session+=1
    if not unloaded then
        setStatus(false)
        info.Text='RIGHT SHIFT: SHOW / HIDE'
    end
    print('[Candy Farm] STOPPED')
end
local function startFarm()
    if running or unloaded then return end
    running=true; session+=1; visited={}
    local currentSession=session
    setStatus(true)
    print('[Candy Farm] STARTED')
    task.spawn(function()
        while running and not unloaded and session==currentSession do
            for _,candy in ipairs(getCandies()) do
                if not running or unloaded or session~=currentSession then break end
                local character=player.Character
