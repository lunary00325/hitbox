loadstring(game:HttpGet("https://raw.githubusercontent.com/Luna7070/585438/refs/heads/main/ui"))()

task.wait(0.8)

local BALL_SIZE = 5.5
local saveFile = "hitbox_size.txt"
local keyFile = "hitbox_menukey.txt"

-- Load saved size
pcall(function()
    if isfile(saveFile) then
        local num = tonumber(readfile(saveFile))
        if num and num >= 1 and num <= 12 then BALL_SIZE = num end
    end
end)

-- Load saved keybind
local MENU_KEY = 0x70
pcall(function()
    if isfile(keyFile) then
        local k = tonumber(readfile(keyFile))
        if k then MENU_KEY = k end
    end
end)

local function getKeyName(kc)
    local names = {
        [0x70] = "F1", [0x71] = "F2", [0x72] = "F3", [0x73] = "F4",
        [0x74] = "F5", [0x75] = "F6", [0x76] = "F7", [0x77] = "F8",
        [0x78] = "F9", [0x79] = "F10", [0x7A] = "F11", [0x7B] = "F12",
        [0x24] = "Home", [0x2D] = "Insert", [0x2E] = "Delete"
    }
    if names[kc] then return names[kc] end
    if kc >= 0x41 and kc <= 0x5A then return string.char(kc) end
    return "Key " .. kc
end

notify("Hitbox Expander", getKeyName(MENU_KEY) .. " for menu | Size: " .. string.format("%.1f", BALL_SIZE), 7)

-- ====================== BALL FOLDER ======================
local replicated = game:GetService("ReplicatedStorage")
local ball_folder = nil

local assets
repeat
    assets = replicated:FindFirstChild("Assets")
    if not assets then task.wait(1) end
until assets

ball_folder = assets:FindFirstChild("Ball")
if not ball_folder then
    notify("Hitbox Expander", "ERROR: Ball folder not found!", 5)
    return
end

local function expand_balls()
    pcall(function()
        for _, model in ball_folder:GetChildren() do
            if model:IsA("Model") then
                for _, part in model:GetDescendants() do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        part.Size = Vector3.new(BALL_SIZE, BALL_SIZE, BALL_SIZE)
                    end
                end
            end
        end
    end)
end

local function saveSize()
    pcall(function() writefile(saveFile, tostring(BALL_SIZE)) end)
end

local function saveKey()
    pcall(function() writefile(keyFile, tostring(MENU_KEY)) end)
end

-- ====================== UI ======================
local Win = GalaxLib:CreateWindow({
    Title = "Hitbox Expander made by Luna",
    Size = Vector2.new(380, 240),
    MenuKey = MENU_KEY,
})

Win._open = false

-- Silent keybind saving
local oldNotify = Win.Notify
function Win:Notify(msg, title, dur)
    if msg and msg:find("Toggle key changed to") then
        MENU_KEY = self.MenuKey
        saveKey()
    end
    oldNotify(self, msg, title, dur)
end

local Tab = Win:AddTab("Main")
local Sec = Tab:AddSection("Hitbox Settings")

Sec:AddSlider("Hitbox Size", {
    Min = 10,
    Max = 120,
    Default = BALL_SIZE * 10,
    Suffix = "",
}, function(value)
    BALL_SIZE = value / 10
    expand_balls()
    saveSize()
end)

-- Background refresh
task.spawn(function()
    expand_balls()
    local lastCheck = tick()
    while true do
        task.wait(0.03)
        if tick() - lastCheck >= 1.5 then
            expand_balls()
            lastCheck = tick()
        end
    end
end)

-- Auto-save keybind
task.spawn(function()
    while true do
        task.wait(0.5)
        if Win.MenuKey and Win.MenuKey ~= MENU_KEY then
            MENU_KEY = Win.MenuKey
            saveKey()
        end
    end
end)

