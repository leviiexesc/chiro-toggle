-- ============================================================
--  CHIRO UI | STANDALONE FLOATING TOGGLE BUTTON
--  Run this script separately on a different page / tab.
--  Features:
--    - Draggable anywhere on screen
--    - Animated rotating cyber glow stroke
--    - Live status dot (Green = Open, Grey = Closed)
--    - Spring click bounce animation
--    - Automatically finds and syncs with Chiro UI
-- ============================================================

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
    local ok, res = pcall(function() return CoreGui end)
    return (ok and res) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
end

local Parent = getGuiParent()

-- Clean up any previous standalone toggle
local existing = Parent:FindFirstChild("ChiroStandaloneToggle")
if existing then existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ChiroStandaloneToggle"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Parent

local function quickTween(obj, duration, props, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

-- Function to find the Chiro UI root frame
local function findChiroRoot()
    for _, guiName in ipairs({"ChiroUI_v8", "ChiroUI_v7", "ChiroUI_v6", "ChiroUI_ScreenGui", "ChiroUI"}) do
        local g = Parent:FindFirstChild(guiName)
        if g then
            local root = g:FindFirstChild("ChiroRoot", true)
            if root then return root, g end
        end
    end
    for _, child in ipairs(Parent:GetChildren()) do
        if child:IsA("ScreenGui") and child ~= ScreenGui then
            local root = child:FindFirstChild("ChiroRoot", true)
            if root then return root, child end
        end
    end
    return nil, nil
end

-- Floating Button Container
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatingToggleButton"
FloatBtn.Size = UDim2.fromOffset(48, 48)
FloatBtn.Position = UDim2.new(0, 24, 0.5, -24)
FloatBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
FloatBtn.BorderSizePixel = 0
FloatBtn.Text = ""
FloatBtn.AutoButtonColor = false
FloatBtn.ZIndex = 10000
FloatBtn.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 14)
Corner.Parent = FloatBtn

-- Cyber Dark Background Gradient
local BgGrad = Instance.new("UIGradient")
BgGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 26, 36)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 14)),
})
BgGrad.Rotation = 45
BgGrad.Parent = FloatBtn

-- Rotating Cyber Glow Stroke
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(80, 80, 100)
Stroke.Thickness = 1.6
Stroke.Parent = FloatBtn

local Grad = Instance.new("UIGradient")
local openGradColors = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 120, 240)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(34, 197, 94)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 120, 240)),
})
local closedGradColors = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 52)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 100, 125)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 52)),
})
Grad.Color = openGradColors
Grad.Parent = Stroke

local rot = 0
RunService.RenderStepped:Connect(function(dt)
    if FloatBtn and FloatBtn.Parent then
        rot = (rot + dt * 60) % 360
        Grad.Rotation = rot
    end
end)

-- Radial Glow Behind Icon
local GlowBackdrop = Instance.new("Frame")
GlowBackdrop.Size = UDim2.fromOffset(32, 32)
GlowBackdrop.Position = UDim2.new(0.5, -16, 0.5, -16)
GlowBackdrop.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
GlowBackdrop.BackgroundTransparency = 0.85
GlowBackdrop.BorderSizePixel = 0
GlowBackdrop.ZIndex = 10001
GlowBackdrop.Parent = FloatBtn

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(1, 0)
GlowCorner.Parent = GlowBackdrop

-- High-Tech Cyber Emblem Icon (Replaces Letter 'C')
local ToggleIcon = Instance.new("ImageLabel")
ToggleIcon.Name = "ToggleIcon"
ToggleIcon.Size = UDim2.fromOffset(24, 24)
ToggleIcon.Position = UDim2.new(0.5, -12, 0.5, -12)
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Image = "rbxassetid://10709775241" -- High-definition Chiro Cyber Shield / Emblem
ToggleIcon.ImageColor3 = Color3.fromRGB(34, 197, 94)
ToggleIcon.ScaleType = Enum.ScaleType.Fit
ToggleIcon.ZIndex = 10002
ToggleIcon.Parent = FloatBtn

-- Live Status Dot
local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.fromOffset(8, 8)
StatusDot.Position = UDim2.new(1, -9, 0, 3)
StatusDot.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 10003
StatusDot.Parent = FloatBtn

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local DotStroke = Instance.new("UIStroke")
DotStroke.Color = Color3.fromRGB(10, 10, 14)
DotStroke.Thickness = 1.2
DotStroke.Parent = StatusDot

-- State Updater (Open vs Closed visuals)
local function setVisualState(isOpen)
    if isOpen then
        quickTween(ToggleIcon, 0.22, { ImageColor3 = Color3.fromRGB(34, 197, 94), Rotation = 0 })
        quickTween(StatusDot, 0.22, { BackgroundColor3 = Color3.fromRGB(34, 197, 94) })
        quickTween(GlowBackdrop, 0.22, { BackgroundTransparency = 0.82, BackgroundColor3 = Color3.fromRGB(34, 197, 94) })
        Grad.Color = openGradColors
    else
        quickTween(ToggleIcon, 0.22, { ImageColor3 = Color3.fromRGB(150, 150, 165), Rotation = 0 })
        quickTween(StatusDot, 0.22, { BackgroundColor3 = Color3.fromRGB(75, 75, 88) })
        quickTween(GlowBackdrop, 0.22, { BackgroundTransparency = 1 })
        Grad.Color = closedGradColors
    end
end

-- Hover Animations
FloatBtn.MouseEnter:Connect(function()
    quickTween(FloatBtn, 0.15, { Size = UDim2.fromOffset(52, 52), Position = FloatBtn.Position - UDim2.fromOffset(2, 2) })
    quickTween(Stroke, 0.15, { Thickness = 2.2 })
end)
FloatBtn.MouseLeave:Connect(function()
    quickTween(FloatBtn, 0.15, { Size = UDim2.fromOffset(48, 48), Position = FloatBtn.Position + UDim2.fromOffset(2, 2) })
    quickTween(Stroke, 0.15, { Thickness = 1.6 })
end)

-- Dragging Logic
local dragging, dragStart, startPos, hasMoved = false, nil, nil, false
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        hasMoved = false
        dragStart = input.Position
        startPos = FloatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 4 then hasMoved = true end
        FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Click to Toggle with Smooth Window Animation
FloatBtn.MouseButton1Click:Connect(function()
    if hasMoved then return end

    -- Spring bounce button feedback
    quickTween(FloatBtn, 0.08, { Size = UDim2.fromOffset(42, 42) })
    task.delay(0.08, function()
        quickTween(FloatBtn, 0.18, { Size = UDim2.fromOffset(48, 48) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    local root, gui = findChiroRoot()
    if root then
        local willOpen = not root.Visible
        setVisualState(willOpen)

        if willOpen then
            root.Visible = true
            local targetPos = root.Position
            local mScale = root:FindFirstChildOfClass("UIScale")
            if mScale then
                mScale.Scale = 0.88
                quickTween(mScale, 0.28, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            else
                local origY = targetPos.Y.Offset
                root.Position = UDim2.new(targetPos.X.Scale, targetPos.X.Offset, targetPos.Y.Scale, origY + 16)
                quickTween(root, 0.26, { Position = targetPos }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end
        else
            local mScale = root:FindFirstChildOfClass("UIScale")
            if mScale then
                quickTween(mScale, 0.2, { Scale = 0.88 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            end
            task.delay(0.18, function()
                root.Visible = false
                if mScale then mScale.Scale = 1 end
            end)
        end
    else
        warn("[Chiro Toggle] Chiro UI window not found. Please execute chiro_v8.luau first.")
    end
end)

-- Periodic Sync Loop with Chiro UI visibility
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        local root = findChiroRoot()
        if root then
            setVisualState(root.Visible)
        else
            setVisualState(false)
        end
        task.wait(0.4)
    end
end)

print("[Chiro Standalone Toggle v8.0] Initialized successfully with Cyber Emblem icon and smooth window transitions.")
