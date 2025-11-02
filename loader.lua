-- =============================================
-- SCRIPT 1: KEY SYSTEM LOADER
-- Upload ini ke: https://github.com/USERNAME/REPO/main/loader.lua
-- =============================================

pcall(function()

-- =============================================
-- KONFIGURASI
-- =============================================
local KEY_GITHUB_URL = "https://raw.githubusercontent.com/xbravll/Key-Loader/refs/heads/main/keys.json"
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/xbravll/LENIRRA_POWER/refs/heads/main/AnimLNR.lua"

-- Format keys.json di GitHub:
-- {
--   "keys": {
--     "KEY123": "2025-12-31",
--     "TESTKEY": "2025-11-30",
--     "PREMIUM2025": "2026-01-15"
--   }
-- }

-- Variables and Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
cloneref = cloneref or function(o) return o end
local LNRGoGui = cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")

local player = Players.LocalPlayer

-- Check if already loaded
if LNRGoGui:FindFirstChild("LNRKeySystem") then
    return
end

-- =============================================
-- KEY SYSTEM FUNCTIONS
-- =============================================

local function saveKeyToFile(key, expDate)
    if isfile and writefile then
        pcall(function()
            local keyData = {
                key = key,
                expDate = expDate,
                savedAt = os.time()
            }
            writefile("LNRKey.json", HttpService:JSONEncode(keyData))
        end)
    end
end

local function loadKeyFromFile()
    if isfile and readfile then
        local success, result = pcall(function()
            if isfile("LNRKey.json") then
                local data = readfile("LNRKey.json")
                return HttpService:JSONDecode(data)
            end
        end)
        if success then
            return result
        end
    end
    return nil
end

local function deleteKeyFile()
    if isfile and delfile then
        pcall(function()
            if isfile("LNRKey.json") then
                delfile("LNRKey.json")
            end
        end)
    end
end

local function parseDate(dateStr)
    -- Format: YYYY-MM-DD
    local year, month, day = dateStr:match("(%d+)-(%d+)-(%d+)")
    if year and month and day then
        return os.time({year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = 23, min = 59, sec = 59})
    end
    return nil
end

local function isKeyExpired(expDate)
    local expTime = parseDate(expDate)
    if not expTime then return true end
    return os.time() > expTime
end

local function validateKeyFromGithub(key)
    local success, result = pcall(function()
        local response = game:HttpGet(KEY_GITHUB_URL)
        local data = HttpService:JSONDecode(response)
        
        if data and data.keys and data.keys[key] then
            local expDate = data.keys[key]
            if not isKeyExpired(expDate) then
                return true, expDate
            else
                return false, "Key expired"
            end
        else
            return false, "Invalid key"
        end
    end)
    
    if success then
        return result
    else
        return false, "Failed to connect to server: " .. tostring(result)
    end
end

local function loadMainScript()
    local success, err = pcall(function()
        local script = game:HttpGet(MAIN_SCRIPT_URL)
        loadstring(script)()
    end)
    
    if not success then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Load Error",
            Text = "Failed to load main script",
            Duration = 5
        })
    end
end

-- =============================================
-- KEY LOGIN GUI
-- =============================================

local function createKeyGUI()
    local keyScreenGui = Instance.new("ScreenGui")
    keyScreenGui.Name = "LNRKeySystem"
    keyScreenGui.ResetOnSpawn = false
    keyScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    keyScreenGui.Parent = LNRGoGui
    
    -- Blur Effect
    local blur = Instance.new("BlurEffect")
    blur.Size = 20
    blur.Parent = game.Lighting
    
    -- Main Key Frame
    local keyFrame = Instance.new("Frame")
    keyFrame.Name = "KeyFrame"
    keyFrame.Size = UDim2.new(0, 450, 0, 350)
    keyFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    keyFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    keyFrame.BorderSizePixel = 0
    keyFrame.Parent = keyScreenGui
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 12)
    keyCorner.Parent = keyFrame
    
    local keyStroke = Instance.new("UIStroke")
    keyStroke.Color = Color3.fromRGB(70, 130, 255)
    keyStroke.Thickness = 2
    keyStroke.Transparency = 0.5
    keyStroke.Parent = keyFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 60)
    titleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = keyFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleFix = Instance.new("Frame")
    titleFix.Size = UDim2.new(1, 0, 0, 12)
    titleFix.Position = UDim2.new(0, 0, 1, -12)
    titleFix.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ LENNIRAxZONE Key System"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleBar
    
    -- Status indicator
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(1, -25, 0.5, -4)
    statusDot.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    statusDot.BorderSizePixel = 0
    statusDot.Parent = titleBar
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot
    
    -- Subtitle
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, -40, 0, 40)
    subtitleLabel.Position = UDim2.new(0, 20, 0, 80)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "🔐 Enter your key to continue"
    subtitleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    subtitleLabel.TextSize = 14
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.Parent = keyFrame
    
    -- Key Input Container
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, -40, 0, 50)
    inputContainer.Position = UDim2.new(0, 20, 0, 140)
    inputContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    inputContainer.BorderSizePixel = 0
    inputContainer.Parent = keyFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputContainer
    
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Color3.fromRGB(70, 130, 255)
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.7
    inputStroke.Parent = inputContainer
    
    -- Key Input
    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(1, -20, 1, -10)
    keyInput.Position = UDim2.new(0, 10, 0, 5)
    keyInput.BackgroundTransparency = 1
    keyInput.Text = ""
    keyInput.PlaceholderText = "Enter your key here..."
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    keyInput.TextSize = 14
    keyInput.Font = Enum.Font.Gotham
    keyInput.ClearTextOnFocus = false
    keyInput.Parent = inputContainer
    
    -- Status Message
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -40, 0, 30)
    statusLabel.Position = UDim2.new(0, 20, 0, 200)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = keyFrame
    
    -- Submit Button
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(1, -40, 0, 45)
    submitBtn.Position = UDim2.new(0, 20, 0, 240)
    submitBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    submitBtn.BorderSizePixel = 0
    submitBtn.Text = "✓ Verify Key"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextSize = 14
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Parent = keyFrame
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 8)
    submitCorner.Parent = submitBtn
    
    -- Get Key Button
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(1, -40, 0, 35)
    getKeyBtn.Position = UDim2.new(0, 20, 0, 295)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    getKeyBtn.BorderSizePixel = 0
    getKeyBtn.Text = "📋 Copy Discord Link"
    getKeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    getKeyBtn.TextSize = 12
    getKeyBtn.Font = Enum.Font.Gotham
    getKeyBtn.Parent = keyFrame
    
    local getKeyCorner = Instance.new("UICorner")
    getKeyCorner.CornerRadius = UDim.new(0, 8)
    getKeyCorner.Parent = getKeyBtn
    
    -- Animations
    submitBtn.MouseEnter:Connect(function()
        TweenService:Create(submitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 150, 255)}):Play()
    end)
    
    submitBtn.MouseLeave:Connect(function()
        TweenService:Create(submitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 130, 255)}):Play()
    end)
    
    getKeyBtn.MouseEnter:Connect(function()
        TweenService:Create(getKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 60)}):Play()
    end)
    
    getKeyBtn.MouseLeave:Connect(function()
        TweenService:Create(getKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
    end)
    
    -- Get Key Button Click
    getKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("https://discord.gg/YOUR_DISCORD_LINK")
            statusLabel.Text = "✓ Discord link copied to clipboard!"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
            task.delay(3, function()
                statusLabel.Text = ""
            end)
        else
            statusLabel.Text = "⚠ Clipboard not supported"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end)
    
    -- Submit Button Click
    local function verifyKey()
        local key = keyInput.Text:gsub("%s+", "") -- Remove whitespace
        
        if key == "" then
            statusLabel.Text = "⚠ Please enter a key"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            return
        end
        
        submitBtn.Text = "⏳ Verifying..."
        submitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
        keyInput.TextEditable = false
        
        local isValid, expDateOrError = validateKeyFromGithub(key)
        
        if isValid then
            statusLabel.Text = "✓ Key verified! Loading script..."
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
            statusDot.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
            
            -- Save key
            saveKeyToFile(key, expDateOrError)
            
            -- Close key GUI with animation
            task.wait(1)
            TweenService:Create(keyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            
            task.wait(0.3)
            blur:Destroy()
            keyScreenGui:Destroy()
            
            -- Load main script
            loadMainScript()
            
        else
            statusLabel.Text = "✗ " .. expDateOrError
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            submitBtn.Text = "✓ Verify Key"
            submitBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
            keyInput.TextEditable = true
            statusDot.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    submitBtn.MouseButton1Click:Connect(verifyKey)
    
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            verifyKey()
        end
    end)
    
    -- Entrance animation
    keyFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(keyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 450, 0, 350)
    }):Play()
    
    -- Animated status dot
    spawn(function()
        while keyScreenGui.Parent do
            TweenService:Create(statusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.3
            }):Play()
            wait(0.8)
            TweenService:Create(statusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0
            }):Play()
            wait(0.8)
        end
    end)
end

-- =============================================
-- MAIN EXECUTION
-- =============================================

-- Check for saved key
local savedKeyData = loadKeyFromFile()

if savedKeyData and savedKeyData.key and savedKeyData.expDate then
    -- Validate saved key
    if not isKeyExpired(savedKeyData.expDate) then
        -- Re-validate with GitHub
        local isValid, expDateOrError = validateKeyFromGithub(savedKeyData.key)
        
        if isValid then
            -- Key is still valid, load main script directly
            game.StarterGui:SetCore("SendNotification", {
                Title = "Welcome Back!",
                Text = "Key verified! Loading...",
                Duration = 3
            })
            
            task.wait(1)
            loadMainScript()
            return
        else
            -- Key is invalid, delete saved key
            deleteKeyFile()
        end
    else
        -- Key expired, delete it
        deleteKeyFile()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Key Expired",
            Text = "Please enter a new key",
            Duration = 5
        })
    end
end

-- Show key GUI if no valid saved key
createKeyGUI()

end)

--[[
============================
CARA SETUP:
============================

1. Buat repository di GitHub (private/public)

2. Buat file "keys.json" dengan format:
{
  "keys": {
    "KEY123": "2025-12-31",
    "TESTKEY": "2025-11-30",
    "PREMIUM2025": "2026-01-15"
  }
}

3. Upload script animation hub (script asli) sebagai "main.lua"

4. Upload script ini sebagai "loader.lua"

5. Ubah di line 10-11:
   - KEY_GITHUB_URL dengan link keys.json Anda
   - MAIN_SCRIPT_URL dengan link main.lua Anda

6. Untuk execute:
   loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/loader.lua"))()

============================
FITUR:
============================
✓ Key validation dari GitHub
✓ Auto-save key ke file JSON
✓ Auto-login jika key masih valid
✓ Hapus key jika expired
✓ Modern UI design
✓ Smooth animations
✓ Copy Discord link
✓ Error handling

============================

]]

