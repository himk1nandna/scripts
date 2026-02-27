-- Blade Ball Auto Parry v2
-- Симулирует нажатие F или клика мыши для парирования

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Настройки
local Settings = {
    Enabled = false,
    AutoParryDistance = 15,
    PredictionMultiplier = 0.18,
    AutoSpam = false,
    SpamDistance = 15, -- Увеличена дистанция для спама (было 10)
    SpamDelay = 0.025, -- Уменьшена задержка (было 0.04)
    Visualize = false,
    Chams = false,
    Theme = "Cyan", -- Текущая тема
    AutoFollow = false, -- Автоматическое следование за шаром
    FollowDistance = 4, -- Дистанция следования (3-5 метров)
    ShowParryRadius = true -- Показывать радиус парирования
}

-- Темы с цветами
local Themes = {
    Cyan = {
        Chams = Color3.fromRGB(0, 255, 255),
        Ball = Color3.fromRGB(0, 200, 255),
        Beam = Color3.fromRGB(0, 255, 255)
    },
    Purple = {
        Chams = Color3.fromRGB(200, 100, 255),
        Ball = Color3.fromRGB(255, 0, 255),
        Beam = Color3.fromRGB(200, 100, 255)
    },
    Red = {
        Chams = Color3.fromRGB(255, 100, 100),
        Ball = Color3.fromRGB(255, 50, 50),
        Beam = Color3.fromRGB(255, 100, 100)
    },
    Green = {
        Chams = Color3.fromRGB(100, 255, 100),
        Ball = Color3.fromRGB(50, 255, 50),
        Beam = Color3.fromRGB(100, 255, 100)
    },
    Yellow = {
        Chams = Color3.fromRGB(255, 255, 100),
        Ball = Color3.fromRGB(255, 255, 0),
        Beam = Color3.fromRGB(255, 255, 100)
    },
    Orange = {
        Chams = Color3.fromRGB(255, 150, 0),
        Ball = Color3.fromRGB(255, 100, 0),
        Beam = Color3.fromRGB(255, 150, 0)
    },
    Pink = {
        Chams = Color3.fromRGB(255, 150, 200),
        Ball = Color3.fromRGB(255, 100, 200),
        Beam = Color3.fromRGB(255, 150, 200)
    },
    White = {
        Chams = Color3.fromRGB(255, 255, 255),
        Ball = Color3.fromRGB(230, 230, 230),
        Beam = Color3.fromRGB(255, 255, 255)
    }
}

-- Функция получения текущих цветов темы
local function GetThemeColors()
    return Themes[Settings.Theme] or Themes.Cyan
end

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoParryGUI_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.BorderSizePixel = 0
Title.Text = "⚔️ Blade Ball Auto Parry"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Система перетаскивания GUI (только за заголовок)
local draggingGUI = false
local dragStart = nil
local startPos = nil

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingGUI = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingGUI and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -42, 0, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 24
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Title

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Кнопка сворачивания
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
MinimizeButton.Position = UDim2.new(1, -84, 0, 7)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 24
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = Title

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeButton

-- Свернутая кнопка BB (в левом верхнем углу GUI)
local MinimizedButton = Instance.new("TextButton")
MinimizedButton.Name = "MinimizedButton"
MinimizedButton.Size = UDim2.new(0, 60, 0, 60)
MinimizedButton.Position = UDim2.new(0, 0, 0, 0)
MinimizedButton.AnchorPoint = Vector2.new(0, 0)
MinimizedButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinimizedButton.BorderSizePixel = 0
MinimizedButton.Text = "BB"
MinimizedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizedButton.TextSize = 22
MinimizedButton.Font = Enum.Font.GothamBold
MinimizedButton.Visible = false
MinimizedButton.Active = true
MinimizedButton.Parent = MainFrame

local MinimizedCorner = Instance.new("UICorner")
MinimizedCorner.CornerRadius = UDim.new(0, 12)
MinimizedCorner.Parent = MinimizedButton

-- Обводка для свернутой кнопки
local MinimizedStroke = Instance.new("UIStroke")
MinimizedStroke.Color = Color3.fromRGB(80, 130, 255)
MinimizedStroke.Thickness = 2
MinimizedStroke.Parent = MinimizedButton

-- Система перетаскивания свернутой кнопки
local draggingMinimized = false
local dragStartMin = nil
local startPosMin = nil

MinimizedButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMinimized = true
        dragStartMin = input.Position
        startPosMin = MainFrame.Position
    end
end)

-- Контейнер
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -40, 1, -70)
Container.Position = UDim2.new(0, 20, 0, 60)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Левая колонка (чекбоксы)
local LeftColumn = Instance.new("Frame")
LeftColumn.Name = "LeftColumn"
LeftColumn.Size = UDim2.new(0.5, -10, 1, 0)
LeftColumn.Position = UDim2.new(0, 0, 0, 0)
LeftColumn.BackgroundTransparency = 1
LeftColumn.Parent = Container

-- Правая колонка (слайдер и кнопки)
local RightColumn = Instance.new("Frame")
RightColumn.Name = "RightColumn"
RightColumn.Size = UDim2.new(0.5, -10, 1, 0)
RightColumn.Position = UDim2.new(0.5, 10, 0, 0)
RightColumn.BackgroundTransparency = 1
RightColumn.Parent = Container

-- Чекбокс Auto Parry (главный)
local ParryFrame = Instance.new("Frame")
ParryFrame.Name = "ParryFrame"
ParryFrame.Size = UDim2.new(1, 0, 0, 40)
ParryFrame.Position = UDim2.new(0, 0, 0, 0)
ParryFrame.BackgroundTransparency = 1
ParryFrame.Parent = LeftColumn

local ParryLabel = Instance.new("TextLabel")
ParryLabel.Size = UDim2.new(1, -40, 1, 0)
ParryLabel.BackgroundTransparency = 1
ParryLabel.Text = "Auto Parry"
ParryLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
ParryLabel.TextSize = 15
ParryLabel.Font = Enum.Font.GothamBold
ParryLabel.TextXAlignment = Enum.TextXAlignment.Left
ParryLabel.Parent = ParryFrame

local ParryCheckbox = Instance.new("TextButton")
ParryCheckbox.Name = "ParryCheckbox"
ParryCheckbox.Size = UDim2.new(0, 32, 0, 32)
ParryCheckbox.Position = UDim2.new(1, -32, 0, 4)
ParryCheckbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ParryCheckbox.BorderSizePixel = 0
ParryCheckbox.Text = ""
ParryCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255)
ParryCheckbox.TextSize = 18
ParryCheckbox.Font = Enum.Font.GothamBold
ParryCheckbox.Parent = ParryFrame

local ParryCorner = Instance.new("UICorner")
ParryCorner.CornerRadius = UDim.new(0, 6)
ParryCorner.Parent = ParryCheckbox

-- Чекбокс Auto Spam
local SpamFrame = Instance.new("Frame")
SpamFrame.Name = "SpamFrame"
SpamFrame.Size = UDim2.new(1, 0, 0, 40)
SpamFrame.Position = UDim2.new(0, 0, 0, 50)
SpamFrame.BackgroundTransparency = 1
SpamFrame.Parent = LeftColumn

local SpamLabel = Instance.new("TextLabel")
SpamLabel.Size = UDim2.new(1, -40, 1, 0)
SpamLabel.BackgroundTransparency = 1
SpamLabel.Text = "Auto Spam"
SpamLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SpamLabel.TextSize = 15
SpamLabel.Font = Enum.Font.Gotham
SpamLabel.TextXAlignment = Enum.TextXAlignment.Left
SpamLabel.Parent = SpamFrame

local SpamCheckbox = Instance.new("TextButton")
SpamCheckbox.Name = "SpamCheckbox"
SpamCheckbox.Size = UDim2.new(0, 32, 0, 32)
SpamCheckbox.Position = UDim2.new(1, -32, 0, 4)
SpamCheckbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpamCheckbox.BorderSizePixel = 0
SpamCheckbox.Text = ""
SpamCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamCheckbox.TextSize = 18
SpamCheckbox.Font = Enum.Font.GothamBold
SpamCheckbox.Parent = SpamFrame

local SpamCorner = Instance.new("UICorner")
SpamCorner.CornerRadius = UDim.new(0, 6)
SpamCorner.Parent = SpamCheckbox

-- Чекбокс Визуализация
local VisFrame = Instance.new("Frame")
VisFrame.Name = "VisFrame"
VisFrame.Size = UDim2.new(1, 0, 0, 40)
VisFrame.Position = UDim2.new(0, 0, 0, 100)
VisFrame.BackgroundTransparency = 1
VisFrame.Parent = LeftColumn

local VisLabel = Instance.new("TextLabel")
VisLabel.Size = UDim2.new(1, -40, 1, 0)
VisLabel.BackgroundTransparency = 1
VisLabel.Text = "Визуализация"
VisLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
VisLabel.TextSize = 15
VisLabel.Font = Enum.Font.Gotham
VisLabel.TextXAlignment = Enum.TextXAlignment.Left
VisLabel.Parent = VisFrame

local VisCheckbox = Instance.new("TextButton")
VisCheckbox.Name = "VisCheckbox"
VisCheckbox.Size = UDim2.new(0, 32, 0, 32)
VisCheckbox.Position = UDim2.new(1, -32, 0, 4)
VisCheckbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
VisCheckbox.BorderSizePixel = 0
VisCheckbox.Text = ""
VisCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255)
VisCheckbox.TextSize = 18
VisCheckbox.Font = Enum.Font.GothamBold
VisCheckbox.Parent = VisFrame

local VisCorner = Instance.new("UICorner")
VisCorner.CornerRadius = UDim.new(0, 6)
VisCorner.Parent = VisCheckbox

-- Чекбокс Chams
local ChamsFrame = Instance.new("Frame")
ChamsFrame.Name = "ChamsFrame"
ChamsFrame.Size = UDim2.new(1, 0, 0, 40)
ChamsFrame.Position = UDim2.new(0, 0, 0, 150)
ChamsFrame.BackgroundTransparency = 1
ChamsFrame.Parent = LeftColumn

local ChamsLabel = Instance.new("TextLabel")
ChamsLabel.Size = UDim2.new(1, -40, 1, 0)
ChamsLabel.BackgroundTransparency = 1
ChamsLabel.Text = "Chams"
ChamsLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
ChamsLabel.TextSize = 15
ChamsLabel.Font = Enum.Font.Gotham
ChamsLabel.TextXAlignment = Enum.TextXAlignment.Left
ChamsLabel.Parent = ChamsFrame

local ChamsCheckbox = Instance.new("TextButton")
ChamsCheckbox.Name = "ChamsCheckbox"
ChamsCheckbox.Size = UDim2.new(0, 32, 0, 32)
ChamsCheckbox.Position = UDim2.new(1, -32, 0, 4)
ChamsCheckbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ChamsCheckbox.BorderSizePixel = 0
ChamsCheckbox.Text = ""
ChamsCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255)
ChamsCheckbox.TextSize = 18
ChamsCheckbox.Font = Enum.Font.GothamBold
ChamsCheckbox.Parent = ChamsFrame

local ChamsCorner = Instance.new("UICorner")
ChamsCorner.CornerRadius = UDim.new(0, 6)
ChamsCorner.Parent = ChamsCheckbox

-- Чекбокс Auto Follow
local FollowFrame = Instance.new("Frame")
FollowFrame.Name = "FollowFrame"
FollowFrame.Size = UDim2.new(1, 0, 0, 40)
FollowFrame.Position = UDim2.new(0, 0, 0, 200)
FollowFrame.BackgroundTransparency = 1
FollowFrame.Parent = LeftColumn

local FollowLabel = Instance.new("TextLabel")
FollowLabel.Size = UDim2.new(1, -40, 1, 0)
FollowLabel.BackgroundTransparency = 1
FollowLabel.Text = "Auto Follow"
FollowLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
FollowLabel.TextSize = 15
FollowLabel.Font = Enum.Font.Gotham
FollowLabel.TextXAlignment = Enum.TextXAlignment.Left
FollowLabel.Parent = FollowFrame

local FollowCheckbox = Instance.new("TextButton")
FollowCheckbox.Name = "FollowCheckbox"
FollowCheckbox.Size = UDim2.new(0, 32, 0, 32)
FollowCheckbox.Position = UDim2.new(1, -32, 0, 4)
FollowCheckbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FollowCheckbox.BorderSizePixel = 0
FollowCheckbox.Text = ""
FollowCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255)
FollowCheckbox.TextSize = 18
FollowCheckbox.Font = Enum.Font.GothamBold
FollowCheckbox.Parent = FollowFrame

local FollowCorner = Instance.new("UICorner")
FollowCorner.CornerRadius = UDim.new(0, 6)
FollowCorner.Parent = FollowCheckbox

-- Чекбокс Show Radius
local RadiusFrame = Instance.new("Frame")
RadiusFrame.Name = "RadiusFrame"
RadiusFrame.Size = UDim2.new(1, 0, 0, 40)
RadiusFrame.Position = UDim2.new(0, 0, 0, 250)
RadiusFrame.BackgroundTransparency = 1
RadiusFrame.Parent = LeftColumn

local RadiusLabel = Instance.new("TextLabel")
RadiusLabel.Size = UDim2.new(1, -40, 1, 0)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.Text = "Show Radius"
RadiusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
RadiusLabel.TextSize = 15
RadiusLabel.Font = Enum.Font.Gotham
RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
RadiusLabel.Parent = RadiusFrame

local RadiusCheckbox = Instance.new("TextButton")
RadiusCheckbox.Name = "RadiusCheckbox"
RadiusCheckbox.Size = UDim2.new(0, 32, 0, 32)
RadiusCheckbox.Position = UDim2.new(1, -32, 0, 4)
RadiusCheckbox.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
RadiusCheckbox.BorderSizePixel = 0
RadiusCheckbox.Text = "✓"
RadiusCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255)
RadiusCheckbox.TextSize = 18
RadiusCheckbox.Font = Enum.Font.GothamBold
RadiusCheckbox.Parent = RadiusFrame

local RadiusCorner = Instance.new("UICorner")
RadiusCorner.CornerRadius = UDim.new(0, 6)
RadiusCorner.Parent = RadiusCheckbox

-- Кнопка открытия окна тем
local ThemeButton = Instance.new("TextButton")
ThemeButton.Name = "ThemeButton"
ThemeButton.Size = UDim2.new(1, 0, 0, 45)
ThemeButton.Position = UDim2.new(0, 0, 0, 0)
ThemeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ThemeButton.BorderSizePixel = 0
ThemeButton.Text = "🎨 Выбор темы"
ThemeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeButton.TextSize = 16
ThemeButton.Font = Enum.Font.GothamBold
ThemeButton.Parent = RightColumn

local ThemeButtonCorner = Instance.new("UICorner")
ThemeButtonCorner.CornerRadius = UDim.new(0, 8)
ThemeButtonCorner.Parent = ThemeButton

-- Дистанция
local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Name = "DistanceLabel"
DistanceLabel.Size = UDim2.new(1, 0, 0, 25)
DistanceLabel.Position = UDim2.new(0, 0, 0, 55)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.Text = "Дистанция: " .. Settings.AutoParryDistance
DistanceLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DistanceLabel.TextSize = 14
DistanceLabel.Font = Enum.Font.Gotham
DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
DistanceLabel.Parent = RightColumn

local DistanceSlider = Instance.new("Frame")
DistanceSlider.Name = "DistanceSlider"
DistanceSlider.Size = UDim2.new(1, 0, 0, 35)
DistanceSlider.Position = UDim2.new(0, 0, 0, 85)
DistanceSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DistanceSlider.BorderSizePixel = 0
DistanceSlider.Parent = RightColumn

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 6)
SliderCorner.Parent = DistanceSlider

local SliderFill = Instance.new("Frame")
SliderFill.Name = "Fill"
SliderFill.Size = UDim2.new(0.25, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = DistanceSlider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 6)
FillCorner.Parent = SliderFill

-- Кнопка слайдера (ползунок)
local SliderButton = Instance.new("Frame")
SliderButton.Name = "SliderButton"
SliderButton.Size = UDim2.new(0, 25, 0, 35)
SliderButton.Position = UDim2.new(0.25, -12, 0, 0)
SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderButton.BorderSizePixel = 0
SliderButton.Parent = DistanceSlider

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 12)
ButtonCorner.Parent = SliderButton

-- Отдельное окно для выбора тем
local ThemeWindow = Instance.new("Frame")
ThemeWindow.Name = "ThemeWindow"
ThemeWindow.Size = UDim2.new(0, 380, 0, 200)
ThemeWindow.Position = UDim2.new(0.5, -190, 0.5, -100)
ThemeWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ThemeWindow.BorderSizePixel = 0
ThemeWindow.Visible = false
ThemeWindow.Active = true
ThemeWindow.Parent = ScreenGui

local ThemeWindowCorner = Instance.new("UICorner")
ThemeWindowCorner.CornerRadius = UDim.new(0, 12)
ThemeWindowCorner.Parent = ThemeWindow

-- Заголовок окна тем
local ThemeTitle = Instance.new("TextLabel")
ThemeTitle.Name = "ThemeTitle"
ThemeTitle.Size = UDim2.new(1, 0, 0, 45)
ThemeTitle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ThemeTitle.BorderSizePixel = 0
ThemeTitle.Text = "🎨 Выбор цветовой темы"
ThemeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeTitle.TextSize = 18
ThemeTitle.Font = Enum.Font.GothamBold
ThemeTitle.Parent = ThemeWindow

local ThemeTitleCorner = Instance.new("UICorner")
ThemeTitleCorner.CornerRadius = UDim.new(0, 12)
ThemeTitleCorner.Parent = ThemeTitle

-- Кнопка закрытия окна тем
local ThemeCloseButton = Instance.new("TextButton")
ThemeCloseButton.Name = "ThemeCloseButton"
ThemeCloseButton.Size = UDim2.new(0, 30, 0, 30)
ThemeCloseButton.Position = UDim2.new(1, -37, 0, 7)
ThemeCloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ThemeCloseButton.BorderSizePixel = 0
ThemeCloseButton.Text = "×"
ThemeCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ThemeCloseButton.TextSize = 20
ThemeCloseButton.Font = Enum.Font.GothamBold
ThemeCloseButton.Parent = ThemeTitle

local ThemeCloseCorner = Instance.new("UICorner")
ThemeCloseCorner.CornerRadius = UDim.new(0, 6)
ThemeCloseCorner.Parent = ThemeCloseButton

-- Контейнер для кнопок тем
local ThemeContainer = Instance.new("Frame")
ThemeContainer.Name = "ThemeContainer"
ThemeContainer.Size = UDim2.new(1, -40, 1, -65)
ThemeContainer.Position = UDim2.new(0, 20, 0, 55)
ThemeContainer.BackgroundTransparency = 1
ThemeContainer.Parent = ThemeWindow

-- Кнопки тем (2 ряда по 4 кнопки)
local themeNames = {"Cyan", "Purple", "Red", "Green", "Yellow", "Orange", "Pink", "White"}
local themeButtons = {}

for i, themeName in ipairs(themeNames) do
    local row = math.floor((i - 1) / 4)
    local col = (i - 1) % 4
    
    local themeBtn = Instance.new("TextButton")
    themeBtn.Name = themeName .. "Theme"
    themeBtn.Size = UDim2.new(0, 75, 0, 55)
    themeBtn.Position = UDim2.new(0, col * 85, 0, row * 65)
    themeBtn.BackgroundColor3 = Themes[themeName].Chams
    themeBtn.BorderSizePixel = 0
    themeBtn.Text = themeName
    themeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeBtn.TextSize = 14
    themeBtn.Font = Enum.Font.GothamBold
    themeBtn.Parent = ThemeContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = themeBtn
    
    -- Добавляем обводку для текущей темы
    if themeName == Settings.Theme then
        local stroke = Instance.new("UIStroke")
        stroke.Name = "SelectedStroke"
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 3
        stroke.Parent = themeBtn
    end
    
    themeButtons[themeName] = themeBtn
    
    themeBtn.MouseButton1Click:Connect(function()
        -- Обновляем тему
        Settings.Theme = themeName
        
        -- Убираем обводку со всех кнопок
        for _, btn in pairs(themeButtons) do
            local oldStroke = btn:FindFirstChild("SelectedStroke")
            if oldStroke then
                oldStroke:Destroy()
            end
        end
        
        -- Добавляем обводку к выбранной кнопке
        local stroke = Instance.new("UIStroke")
        stroke.Name = "SelectedStroke"
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 3
        stroke.Parent = themeBtn
        
        -- Обновляем все визуальные элементы
        UpdateAllChams()
    end)
end

-- Мини GUI для отображения скорости шара
local VelocityDisplay = Instance.new("Frame")
VelocityDisplay.Name = "VelocityDisplay"
VelocityDisplay.Size = UDim2.new(0, 300, 0, 120)
VelocityDisplay.Position = UDim2.new(0, 20, 1, -140)
VelocityDisplay.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
VelocityDisplay.BorderSizePixel = 0
VelocityDisplay.Active = true
VelocityDisplay.Parent = ScreenGui

local VelocityCorner = Instance.new("UICorner")
VelocityCorner.CornerRadius = UDim.new(0, 10)
VelocityCorner.Parent = VelocityDisplay

local VelocityStroke = Instance.new("UIStroke")
VelocityStroke.Color = Color3.fromRGB(80, 130, 255)
VelocityStroke.Thickness = 2
VelocityStroke.Parent = VelocityDisplay

-- Заголовок (для перетаскивания)
local VelocityTitle = Instance.new("TextLabel")
VelocityTitle.Size = UDim2.new(1, 0, 0, 35)
VelocityTitle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
VelocityTitle.BorderSizePixel = 0
VelocityTitle.Text = "⚡ Ball Velocity"
VelocityTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
VelocityTitle.TextSize = 16
VelocityTitle.Font = Enum.Font.GothamBold
VelocityTitle.Parent = VelocityDisplay

local VelocityTitleCorner = Instance.new("UICorner")
VelocityTitleCorner.CornerRadius = UDim.new(0, 10)
VelocityTitleCorner.Parent = VelocityTitle

-- Текущая скорость
local CurrentVelocityLabel = Instance.new("TextLabel")
CurrentVelocityLabel.Size = UDim2.new(1, -20, 0, 30)
CurrentVelocityLabel.Position = UDim2.new(0, 10, 0, 45)
CurrentVelocityLabel.BackgroundTransparency = 1
CurrentVelocityLabel.Text = "Текущее: 0"
CurrentVelocityLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
CurrentVelocityLabel.TextSize = 16
CurrentVelocityLabel.Font = Enum.Font.GothamBold
CurrentVelocityLabel.TextXAlignment = Enum.TextXAlignment.Left
CurrentVelocityLabel.Parent = VelocityDisplay

-- Пиковая скорость
local PeakVelocityLabel = Instance.new("TextLabel")
PeakVelocityLabel.Size = UDim2.new(1, -20, 0, 30)
PeakVelocityLabel.Position = UDim2.new(0, 10, 0, 80)
PeakVelocityLabel.BackgroundTransparency = 1
PeakVelocityLabel.Text = "Пиковое: 0"
PeakVelocityLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
PeakVelocityLabel.TextSize = 16
PeakVelocityLabel.Font = Enum.Font.GothamBold
PeakVelocityLabel.TextXAlignment = Enum.TextXAlignment.Left
PeakVelocityLabel.Parent = VelocityDisplay

-- Система перетаскивания Velocity Display
local draggingVelocity = false
local dragStartVel = nil
local startPosVel = nil

VelocityTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingVelocity = true
        dragStartVel = input.Position
        startPosVel = VelocityDisplay.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingVelocity and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartVel
        VelocityDisplay.Position = UDim2.new(
            startPosVel.X.Scale,
            startPosVel.X.Offset + delta.X,
            startPosVel.Y.Scale,
            startPosVel.Y.Offset + delta.Y
        )
    end
end)

-- Функция симуляции нажатия
local LastParryTime = 0
local LastSpamTime = 0
local isParrying = false
local clickCount = 0
local spawnTime = 0
local lastClickTime = 0

-- Отслеживание спавна игрока
LocalPlayer.CharacterAdded:Connect(function()
    spawnTime = tick()
    isParrying = false
    LastParryTime = 0
    LastSpamTime = 0
    lastClickTime = 0
    print("🔄 Spawned - waiting 3 seconds before parrying")
end)

-- Инициализация времени спавна при загрузке
if LocalPlayer.Character then
    spawnTime = tick()
end

local function SimulateParry(isSpam, ballSpeed)
    local currentTime = tick()
    
    -- Усиленная защита от клика при спавне (3 секунды)
    if currentTime - spawnTime < 3 then
        return
    end
    
    -- Адаптивная задержка в зависимости от скорости шара
    local minDelay
    if isSpam then
        if ballSpeed and ballSpeed > 300 then
            minDelay = 0.008 -- Экстремально быстрые шары (уменьшено)
        elseif ballSpeed and ballSpeed > 250 then
            minDelay = 0.010 -- Очень быстрые шары (уменьшено)
        elseif ballSpeed and ballSpeed > 150 then
            minDelay = 0.012 -- Быстрые шары (уменьшено)
        else
            minDelay = 0.014 -- Обычные шары (уменьшено)
        end
    else
        -- Для обычного парирования - минимальная задержка
        minDelay = 0.035
    end
    
    -- Защита от двойного клика
    if currentTime - lastClickTime < minDelay then
        return
    end
    
    if isParrying then return end
    
    isParrying = true
    lastClickTime = currentTime
    LastParryTime = currentTime
    if isSpam then
        LastSpamTime = currentTime
    end
    
    clickCount = clickCount + 1
    local currentClick = clickCount
    
    task.spawn(function()
        -- Симулируем клик мыши
        local mouse = LocalPlayer:GetMouse()
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
        
        -- Минимальная задержка клика (для спама еще короче)
        local clickDuration = isSpam and 0.008 or 0.01
        task.wait(clickDuration)
        
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
        
        if isSpam and ballSpeed then
            print("⚡ Spam #" .. currentClick .. " (Speed: " .. math.floor(ballSpeed) .. ")")
        else
            print(isSpam and "⚡ Spam #" .. currentClick or "⚔️ Parry #" .. currentClick)
        end
        
        -- Минимальная задержка перед следующим действием (для спама короче)
        task.wait(isSpam and 0.008 or 0.01)
        task.wait(waitTime)
        
        isParrying = false
    end)
end

-- Визуализация шаров
local ballVisuals = {} -- Хранит визуализацию для каждого шара

local function GetColorByDistance(distance)
    if distance <= 10 then
        return Color3.fromRGB(255, 0, 0) -- Красный - очень близко
    elseif distance <= 20 then
        return Color3.fromRGB(255, 165, 0) -- Оранжевый - близко
    else
        return Color3.fromRGB(0, 255, 0) -- Зеленый - далеко
    end
end

local function VisualizeBall(ball, distance)
    if not Settings.Visualize then return end
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local ballId = ball:GetDebugId()
    
    -- Используем цвета из текущей темы
    local themeColors = GetThemeColors()
    local ballColor = themeColors.Ball
    local beamColor = themeColors.Beam
    
    -- Если визуализация для этого шара уже существует, обновляем её
    if ballVisuals[ballId] then
        local vis = ballVisuals[ballId]
        
        -- Обновляем attachments
        if vis.att0 and vis.att0.Parent then
            vis.att0.Parent = ball
        end
        if vis.att1 and vis.att1.Parent then
            vis.att1.Parent = hrp
        end
        
        -- Обновляем цвет луча
        if vis.beam and vis.beam.Parent then
            vis.beam.Color = ColorSequence.new(beamColor)
        end
        
        -- Обновляем цвет частиц
        if vis.particle and vis.particle.Parent then
            vis.particle.Color = ColorSequence.new(ballColor)
        end
    else
        -- Создаем новую визуализацию
        local vis = {}
        
        -- Создаем attachments
        vis.att0 = Instance.new("Attachment")
        vis.att0.Parent = ball
        
        vis.att1 = Instance.new("Attachment")
        vis.att1.Parent = hrp
        
        -- Создаем луч
        vis.beam = Instance.new("Beam")
        vis.beam.Name = "_BallBeam"
        vis.beam.Attachment0 = vis.att0
        vis.beam.Attachment1 = vis.att1
        vis.beam.Color = ColorSequence.new(beamColor)
        vis.beam.Width0 = 1
        vis.beam.Width1 = 1
        vis.beam.FaceCamera = true
        vis.beam.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(0.5, 0.1),
            NumberSequenceKeypoint.new(1, 0.3)
        })
        vis.beam.LightEmission = 1
        vis.beam.LightInfluence = 0
        vis.beam.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        vis.beam.TextureMode = Enum.TextureMode.Wrap
        vis.beam.TextureLength = 2
        vis.beam.Parent = Workspace
        
        -- Создаем частицы
        vis.particle = Instance.new("ParticleEmitter")
        vis.particle.Name = "_VisParticle"
        vis.particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        vis.particle.Color = ColorSequence.new(ballColor)
        vis.particle.Size = NumberSequence.new(0.5)
        vis.particle.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        vis.particle.Lifetime = NumberRange.new(0.3, 0.5)
        vis.particle.Rate = 50
        vis.particle.Speed = NumberRange.new(2, 4)
        vis.particle.SpreadAngle = Vector2.new(180, 180)
        vis.particle.LightEmission = 1
        vis.particle.Parent = ball
        
        ballVisuals[ballId] = vis
    end
end

-- Очистка визуализации для конкретного шара
local function ClearBallVisualization(ballId)
    if ballVisuals[ballId] then
        local vis = ballVisuals[ballId]
        
        pcall(function() if vis.beam then vis.beam:Destroy() end end)
        pcall(function() if vis.att0 then vis.att0:Destroy() end end)
        pcall(function() if vis.att1 then vis.att1:Destroy() end end)
        pcall(function() if vis.particle then vis.particle:Destroy() end end)
        
        ballVisuals[ballId] = nil
    end
end

-- Очистка всей визуализации
local function ClearAllVisualization()
    for ballId, _ in pairs(ballVisuals) do
        ClearBallVisualization(ballId)
    end
    ballVisuals = {}
end

-- Система Chams для игроков
local playerChams = {}

local function ApplyChams(player)
    if not Settings.Chams then return end
    if player == LocalPlayer then return end -- Не применяем к себе
    
    local character = player.Character
    if not character then return end
    
    local playerId = player.UserId
    local themeColors = GetThemeColors()
    
    -- Если уже есть chams, обновляем цвет
    if playerChams[playerId] then
        local highlight = playerChams[playerId]
        if highlight and highlight.Parent then
            highlight.FillColor = themeColors.Chams
            highlight.OutlineColor = themeColors.Chams
            return
        end
    end
    
    -- Создаем новый Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "_PlayerChams"
    highlight.FillColor = themeColors.Chams
    highlight.OutlineColor = themeColors.Chams
    highlight.FillTransparency = 0.7 -- Увеличена прозрачность (было 0.4)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    playerChams[playerId] = highlight
end

local function RemoveChams(playerId)
    if playerChams[playerId] then
        pcall(function()
            playerChams[playerId]:Destroy()
        end)
        playerChams[playerId] = nil
    end
end

local function UpdateAllChams()
    if Settings.Chams then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                ApplyChams(player)
            end
        end
    else
        -- Удаляем все chams
        for playerId, _ in pairs(playerChams) do
            RemoveChams(playerId)
        end
    end
end

-- Отслеживание новых игроков
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Settings.Chams then
            ApplyChams(player)
        end
    end)
end)

-- Отслеживание ухода игроков
Players.PlayerRemoving:Connect(function(player)
    RemoveChams(player.UserId)
end)

-- Инициализация chams для существующих игроков
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Settings.Chams then
                ApplyChams(player)
            end
        end)
        
        if player.Character then
            task.spawn(function()
                task.wait(0.5)
                if Settings.Chams then
                    ApplyChams(player)
                end
            end)
        end
    end
end

-- Улучшенная функция предсказания с учетом ускорения и траектории
local function PredictBallPosition(ball, hrp)
    local ballPos = ball.Position
    local ballVelocity = ball.AssemblyLinearVelocity
    local playerPos = hrp.Position
    
    -- Если шар не движется, возвращаем текущую позицию
    if ballVelocity.Magnitude < 1 then
        return ballPos, (playerPos - ballPos).Magnitude, 0, 0
    end
    
    -- Вычисляем направление к игроку
    local directionToPlayer = (playerPos - ballPos).Unit
    local relativeVelocity = ballVelocity:Dot(directionToPlayer)
    
    -- Если шар летит от игрока, не предсказываем
    if relativeVelocity <= 0 then
        return ballPos, 999, 0, ballVelocity.Magnitude
    end
    
    -- Расстояние до игрока
    local distanceToPlayer = (playerPos - ballPos).Magnitude
    
    -- Скорость шара
    local ballSpeed = ballVelocity.Magnitude
    
    -- Время до достижения (базовое)
    local timeToReach = distanceToPlayer / ballSpeed
    
    -- Улучшенное предсказание с учетом ускорения
    local acceleration = ball:GetAttribute("Acceleration") or 0
    
    -- Экстремально агрессивный адаптивный множитель предсказания
    local adaptiveMult = Settings.PredictionMultiplier
    if ballSpeed > 400 then
        adaptiveMult = adaptiveMult * 3.2 -- Безумные скорости
    elseif ballSpeed > 350 then
        adaptiveMult = adaptiveMult * 3.0 -- Супер-экстремальные
    elseif ballSpeed > 300 then
        adaptiveMult = adaptiveMult * 2.7 -- Супер быстрые
    elseif ballSpeed > 250 then
        adaptiveMult = adaptiveMult * 2.4 -- Экстремально быстрые
    elseif ballSpeed > 200 then
        adaptiveMult = adaptiveMult * 2.2 -- Очень быстрые
    elseif ballSpeed > 150 then
        adaptiveMult = adaptiveMult * 2.0 -- Быстрые
    elseif ballSpeed > 100 then
        adaptiveMult = adaptiveMult * 1.8 -- Средне-быстрые
    elseif ballSpeed > 50 then
        adaptiveMult = adaptiveMult * 1.6 -- Средние
    end
    
    local predictedTime = timeToReach * adaptiveMult
    
    -- Формула предсказания с учетом ускорения: s = v*t + 0.5*a*t^2
    local predictedPos = ballPos + (ballVelocity * predictedTime)
    
    -- Учитываем ускорение если есть
    if acceleration > 0 then
        predictedPos = predictedPos + (ballVelocity.Unit * acceleration * predictedTime * predictedTime * 0.5)
    end
    
    -- Вычисляем финальную дистанцию до предсказанной позиции
    local predictedDistance = (playerPos - predictedPos).Magnitude
    
    return predictedPos, predictedDistance, timeToReach, ballSpeed
end

-- Улучшенное вычисление идеального момента для парирования
local function CalculateIdealParryDistance(ballSpeed, timeToReach)
    -- Базовая дистанция с экстремальными значениями для бешеных скоростей
    local baseDist
    
    if ballSpeed > 450 then
        -- Невероятно быстрые: 90-110
        baseDist = 90 + (ballSpeed - 450) * 0.13
    elseif ballSpeed > 400 then
        -- Безумно быстрые: 82-90
        baseDist = 82 + (ballSpeed - 400) * 0.16
    elseif ballSpeed > 350 then
        -- Супер-экстремальные: 72-82
        baseDist = 72 + (ballSpeed - 350) * 0.2
    elseif ballSpeed > 300 then
        -- Супер быстрые: 67-72
        baseDist = 67 + (ballSpeed - 300) * 0.1
    elseif ballSpeed > 250 then
        -- Экстремально быстрые: 58-67
        baseDist = 58 + (ballSpeed - 250) * 0.18
    elseif ballSpeed > 200 then
        -- Очень быстрые: 50-58
        baseDist = 50 + (ballSpeed - 200) * 0.16
    elseif ballSpeed > 150 then
        -- Быстрые: 42-50
        baseDist = 42 + (ballSpeed - 150) * 0.16
    elseif ballSpeed > 100 then
        -- Средне-быстрые: 34-42
        baseDist = 34 + (ballSpeed - 100) * 0.16
    elseif ballSpeed > 70 then
        -- Средние: 28-34
        baseDist = 28 + (ballSpeed - 70) * 0.2
    elseif ballSpeed > 40 then
        -- Медленные: 24-28
        baseDist = 24 + (ballSpeed - 40) * 0.133
    elseif ballSpeed > 20 then
        -- Очень медленные: 21-24
        baseDist = 21 + (ballSpeed - 20) * 0.15
    else
        -- Минимальная дистанция
        baseDist = 21
    end
    
    -- Экстремально агрессивные множители времени
    if timeToReach < 0.05 then
        baseDist = baseDist * 1.9 -- Мгновенно (новый уровень)
    elseif timeToReach < 0.08 then
        baseDist = baseDist * 1.8 -- Почти мгновенно
    elseif timeToReach < 0.12 then
        baseDist = baseDist * 1.7 -- Очень-очень быстро
    elseif timeToReach < 0.18 then
        baseDist = baseDist * 1.6 -- Очень быстро
    elseif timeToReach < 0.25 then
        baseDist = baseDist * 1.5 -- Быстро
    elseif timeToReach < 0.35 then
        baseDist = baseDist * 1.4 -- Средне-быстро
    elseif timeToReach < 0.5 then
        baseDist = baseDist * 1.3 -- Средне
    end
    
    -- Ограничиваем максимум 110 studs (увеличено с 100)
    return math.min(baseDist, 110)
end

-- Визуализация радиуса парирования
local parryRadiusCircle = nil
local parryRadiusAttachment = nil

local function UpdateParryRadius()
    if not Settings.ShowParryRadius or not Settings.Enabled then
        if parryRadiusCircle then
            parryRadiusCircle:Destroy()
            parryRadiusCircle = nil
        end
        if parryRadiusAttachment then
            parryRadiusAttachment:Destroy()
            parryRadiusAttachment = nil
        end
        return
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Находим ближайший шар для расчета динамического радиуса
    local balls = Workspace:FindFirstChild("Balls")
    local closestBall = nil
    local closestDistance = math.huge
    local targetBallSpeed = 0
    
    if balls then
        for _, ball in pairs(balls:GetChildren()) do
            if ball:IsA("BasePart") then
                local targetName = ball:GetAttribute("target")
                if targetName == LocalPlayer.Name then
                    local distance = (hrp.Position - ball.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestBall = ball
                        targetBallSpeed = ball.AssemblyLinearVelocity.Magnitude
                    end
                end
            end
        end
    end
    
    -- Вычисляем динамический радиус
    local displayRadius
    if closestBall then
        -- Если есть шар, летящий к нам - показываем идеальную дистанцию
        local timeToReach = targetBallSpeed > 0 and (closestDistance / targetBallSpeed) or 0
        displayRadius = CalculateIdealParryDistance(targetBallSpeed, timeToReach)
    else
        -- Если нет шара - показываем базовую дистанцию
        displayRadius = Settings.AutoParryDistance
    end
    
    -- Создаем или обновляем круг
    if not parryRadiusAttachment or not parryRadiusAttachment.Parent then
        parryRadiusAttachment = Instance.new("Attachment")
        parryRadiusAttachment.Name = "_ParryRadiusAttachment"
        parryRadiusAttachment.Parent = hrp
    end
    
    if not parryRadiusCircle or not parryRadiusCircle.Parent then
        parryRadiusCircle = Instance.new("Part")
        parryRadiusCircle.Name = "_ParryRadiusCircle"
        parryRadiusCircle.Shape = Enum.PartType.Cylinder
        parryRadiusCircle.Material = Enum.Material.Neon
        parryRadiusCircle.CanCollide = false
        parryRadiusCircle.Anchored = false
        parryRadiusCircle.Massless = true
        parryRadiusCircle.CastShadow = false
        parryRadiusCircle.Parent = Workspace
        
        -- Weld к игроку
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hrp
        weld.Part1 = parryRadiusCircle
        weld.Parent = parryRadiusCircle
    end
    
    -- Обновляем размер и цвет круга
    local themeColors = GetThemeColors()
    local circleColor = themeColors.Beam
    
    -- Градиентная прозрачность в зависимости от расстояния до шара
    local transparency
    if closestBall then
        local distanceRatio = closestDistance / displayRadius
        if distanceRatio < 0.3 then
            transparency = 0.3 -- Очень близко - более видимый
            circleColor = Color3.fromRGB(255, 50, 50) -- Красный
        elseif distanceRatio < 0.6 then
            transparency = 0.5 -- Близко - средняя видимость
            circleColor = Color3.fromRGB(255, 200, 0) -- Оранжевый
        else
            transparency = 0.7 -- Далеко - более прозрачный
            circleColor = themeColors.Beam -- Цвет темы
        end
    else
        transparency = 0.8 -- Нет шара - очень прозрачный
    end
    
    parryRadiusCircle.Size = Vector3.new(0.2, displayRadius * 2, displayRadius * 2)
    parryRadiusCircle.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90))
    parryRadiusCircle.Color = circleColor
    parryRadiusCircle.Transparency = transparency
end

-- Функция обновления отображения скорости
local function UpdateVelocityDisplay()
    local currentTime = tick()
    
    -- Обновляем не чаще чем раз в 0.05 секунды
    if currentTime - lastVelocityUpdate < 0.05 then
        return
    end
    lastVelocityUpdate = currentTime
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local balls = Workspace:FindFirstChild("Balls")
    if not balls then
        currentBallVelocity = 0
        CurrentVelocityLabel.Text = "Текущее: 0"
        return
    end
    
    -- Находим шар, летящий к нам
    local targetBall = nil
    local maxVelocity = 0
    
    for _, ball in pairs(balls:GetChildren()) do
        if ball:IsA("BasePart") then
            local targetName = ball:GetAttribute("target")
            if targetName == LocalPlayer.Name then
                local ballSpeed = ball.AssemblyLinearVelocity.Magnitude
                if ballSpeed > maxVelocity then
                    maxVelocity = ballSpeed
                    targetBall = ball
                end
            end
        end
    end
    
    if targetBall then
        currentBallVelocity = maxVelocity
        
        -- Обновляем пиковую скорость
        if currentBallVelocity > peakBallVelocity then
            peakBallVelocity = currentBallVelocity
        end
        
        -- Цвет в зависимости от скорости
        local velocityColor
        if currentBallVelocity > 300 then
            velocityColor = Color3.fromRGB(255, 50, 50) -- Красный - экстремально быстро
        elseif currentBallVelocity > 200 then
            velocityColor = Color3.fromRGB(255, 150, 0) -- Оранжевый - очень быстро
        elseif currentBallVelocity > 100 then
            velocityColor = Color3.fromRGB(255, 255, 0) -- Желтый - быстро
        else
            velocityColor = Color3.fromRGB(100, 255, 100) -- Зеленый - нормально
        end
        
        CurrentVelocityLabel.TextColor3 = velocityColor
        CurrentVelocityLabel.Text = "Текущее: " .. math.floor(currentBallVelocity)
        PeakVelocityLabel.Text = "Пиковое: " .. math.floor(peakBallVelocity)
    else
        currentBallVelocity = 0
        CurrentVelocityLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        CurrentVelocityLabel.Text = "Текущее: 0"
    end
end

-- Функция следования за шаром
local function FollowBall()
    if not Settings.AutoFollow then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    local balls = Workspace:FindFirstChild("Balls")
    if not balls then return end
    
    -- Находим ближайший шар
    local closestBall = nil
    local closestDistance = math.huge
    
    for _, ball in pairs(balls:GetChildren()) do
        if ball:IsA("BasePart") then
            local distance = (hrp.Position - ball.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestBall = ball
            end
        end
    end
    
    if not closestBall then return end
    
    -- Вычисляем направление к шару
    local ballPos = closestBall.Position
    local playerPos = hrp.Position
    local direction = (ballPos - playerPos).Unit
    local distance = (ballPos - playerPos).Magnitude
    
    -- Целевая дистанция (3-5 метров, используем настройку)
    local targetDistance = Settings.FollowDistance
    
    -- Если слишком далеко или слишком близко, двигаемся
    if distance > targetDistance + 2 then
        -- Слишком далеко - идем к шару
        local targetPos = ballPos - (direction * targetDistance)
        humanoid:MoveTo(targetPos)
    elseif distance < targetDistance - 1 then
        -- Слишком близко - отходим от шара
        local targetPos = ballPos - (direction * targetDistance)
        humanoid:MoveTo(targetPos)
    else
        -- В нужной дистанции - останавливаемся
        humanoid:Move(Vector3.new(0, 0, 0))
    end
end

-- Основная логика
local lastBallCheck = {}
local lastBallDistance = {} -- Отслеживание последней дистанции для каждого шара
local lastParryBall = nil
local lastParryBallTime = 0
local currentTargetBall = nil

-- Отслеживание скорости шара
local currentBallVelocity = 0
local peakBallVelocity = 0
local lastVelocityUpdate = 0

local function CheckBallAndParry()
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local balls = Workspace:FindFirstChild("Balls")
    if not balls then 
        ClearAllVisualization()
        return 
    end
    
    local activeBalls = {}
    
    -- Ранняя проверка для AFK режима - обнаруживаем опасные шары заранее
    if Settings.Enabled then
        for _, ball in pairs(balls:GetChildren()) do
            if ball:IsA("BasePart") then
                local ballVelocity = ball.AssemblyLinearVelocity
                local ballSpeed = ballVelocity.Magnitude
                local currentDistance = (hrp.Position - ball.Position).Magnitude
                
                -- Проверяем направление к игроку
                local directionToPlayer = (hrp.Position - ball.Position).Unit
                local velocityToPlayer = ballVelocity:Dot(directionToPlayer)
                
                -- Если шар быстро летит к игроку (даже если target не установлен)
                if velocityToPlayer > 80 and currentDistance < 35 and ballSpeed > 100 then
                    local targetName = ball:GetAttribute("target")
                    local ballId = ball:GetDebugId()
                    local currentTime = tick()
                    
                    -- Проверяем что не парировали этот шар недавно
                    if lastParryBall ~= ballId or (currentTime - lastParryBallTime) >= 0.15 then
                        -- Если target это мы, или target еще не установлен но шар летит прямо к нам
                        if targetName == LocalPlayer.Name or (not targetName and velocityToPlayer > ballSpeed * 0.8) then
                            if currentTime - spawnTime >= 3 then
                                print("⚠️ AFK PROTECTION! Fast ball detected: " .. math.floor(ballSpeed) .. " speed, " .. math.floor(currentDistance) .. " dist")
                                lastParryBall = ballId
                                lastParryBallTime = currentTime
                                SimulateParry(false, ballSpeed)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Проходим по всем шарам
    for _, ball in pairs(balls:GetChildren()) do
        if ball:IsA("BasePart") then
            local ballId = ball:GetDebugId()
            activeBalls[ballId] = true
            
            local distance = (hrp.Position - ball.Position).Magnitude
            
            -- Визуализируем ВСЕ шары если включена визуализация
            if Settings.Visualize then
                VisualizeBall(ball, distance)
            end
            
            -- Логика парирования только для шаров, летящих к нам
            local targetName = ball:GetAttribute("target")
            if targetName == LocalPlayer.Name and Settings.Enabled then
                local currentTime = tick()
                
                -- Усиленная защита от клика при спавне (3 секунды)
                if currentTime - spawnTime < 3 then
                    continue
                end
                
                currentTargetBall = ball
                
                -- Получаем текущую дистанцию и скорость шара
                local ballVelocity = ball.AssemblyLinearVelocity
                local ballSpeed = ballVelocity.Magnitude
                local currentDistance = (hrp.Position - ball.Position).Magnitude
                
                -- Проверяем, что шар летит К игроку, а не ОТ него (важно для предотвращения даблклика)
                local directionToPlayer = (hrp.Position - ball.Position).Unit
                local velocityToPlayer = ballVelocity:Dot(directionToPlayer)
                
                -- Если шар не летит к игроку (летит от него после парирования), пропускаем
                if velocityToPlayer <= 5 then -- Небольшой порог для учета погрешности
                    continue
                end
                
                -- Дополнительная проверка: если шар уже отлетает (скорость направлена от игрока)
                local ballToPlayer = (hrp.Position - ball.Position)
                local isApproaching = ballVelocity:Dot(ballToPlayer) > 0
                
                if not isApproaching then
                    continue
                end
                
                -- Проверка изменения дистанции - если шар отдаляется, не парируем
                if lastBallDistance[ballId] then
                    local lastDist = lastBallDistance[ballId]
                    -- Если дистанция увеличилась (шар отлетает), пропускаем
                    if currentDistance > lastDist + 1 then -- +1 для учета погрешности
                        lastBallDistance[ballId] = currentDistance
                        continue
                    end
                end
                lastBallDistance[ballId] = currentDistance
                
                -- Вычисляем время до достижения
                local timeToReach = ballSpeed > 0 and (currentDistance / ballSpeed) or 999
                
                -- Вычисляем идеальную дистанцию для парирования на основе скорости
                local idealDistance = CalculateIdealParryDistance(ballSpeed, timeToReach)
                
                -- Защита от повторного парирования того же шара (адаптивная)
                -- Для ближнего боя - минимальная защита
                local parryProtection = currentDistance <= 8 and 0.08 or 0.12
                if lastParryBall == ballId and (currentTime - lastParryBallTime) < parryProtection then
                    continue
                end
                
                -- Проверка по времени (минимальная задержка для мгновенной реакции)
                -- Для ближнего боя используем экстремально малую задержку
                local checkDelay
                if currentDistance <= 5 then
                    checkDelay = 0.008 -- Мгновенная проверка для ближнего боя
                elseif currentDistance <= 10 then
                    checkDelay = 0.012 -- Очень быстрая проверка
                elseif ballSpeed > 250 then
                    checkDelay = 0.015 -- Для быстрых шаров
                elseif ballSpeed > 150 then
                    checkDelay = 0.020 -- Для средних шаров
                else
                    checkDelay = 0.025 -- Для медленных шаров
                end
                
                if lastBallCheck[ballId] and (currentTime - lastBallCheck[ballId]) < checkDelay then
                    continue
                end
                
                -- Auto Spam режим для близкой дистанции (адаптивная дистанция и скорость)
                if Settings.AutoSpam then
                    -- Адаптивная дистанция спама в зависимости от скорости шара
                    local adaptiveSpamDist = Settings.SpamDistance
                    local adaptiveSpamDelay = Settings.SpamDelay
                    
                    -- ЭКСТРЕМАЛЬНЫЙ режим для ближнего боя (игрок в игроке)
                    if currentDistance <= 8 then
                        -- Мгновенный спам на очень близкой дистанции
                        if currentDistance <= 3 then
                            adaptiveSpamDelay = 0.005 -- Максимально быстро
                        elseif currentDistance <= 5 then
                            adaptiveSpamDelay = 0.007 -- Очень быстро
                        else
                            adaptiveSpamDelay = 0.009 -- Быстро
                        end
                    elseif ballSpeed > 300 then
                        adaptiveSpamDist = Settings.SpamDistance + 20
                        adaptiveSpamDelay = 0.010
                    elseif ballSpeed > 250 then
                        adaptiveSpamDist = Settings.SpamDistance + 15
                        adaptiveSpamDelay = 0.012
                    elseif ballSpeed > 200 then
                        adaptiveSpamDist = Settings.SpamDistance + 12
                        adaptiveSpamDelay = 0.015
                    elseif ballSpeed > 150 then
                        adaptiveSpamDist = Settings.SpamDistance + 9
                        adaptiveSpamDelay = 0.018
                    elseif ballSpeed > 100 then
                        adaptiveSpamDist = Settings.SpamDistance + 6
                        adaptiveSpamDelay = 0.020
                    else
                        adaptiveSpamDelay = 0.022
                    end
                    
                    if currentDistance <= adaptiveSpamDist then
                        -- Дополнительная проверка: шар должен приближаться для спама
                        if isApproaching and velocityToPlayer > 3 then
                            if currentTime - LastSpamTime >= adaptiveSpamDelay then
                                LastSpamTime = currentTime
                                lastBallCheck[ballId] = currentTime
                                lastParryBall = ballId
                                lastParryBallTime = currentTime
                                SimulateParry(true, ballSpeed)
                            end
                        end
                        continue
                    end
                end
                
                -- Обычное парирование: используем ТЕКУЩУЮ дистанцию и сравниваем с идеальной
                -- МГНОВЕННОЕ парирование для ближнего боя (игрок в игроке)
                local instantParryDistance = 5 -- Мгновенное парирование на 5 метрах
                local criticalDistance = 20 -- Критическая дистанция для гарантированного парирования (увеличена с 15)
                
                -- Дополнительная проверка для AFK: если шар приближается быстро
                local isApproachingFast = velocityToPlayer > 50 and currentDistance < 30
                
                -- МГНОВЕННОЕ парирование если очень близко
                if currentDistance <= instantParryDistance then
                    print("⚡ INSTANT PARRY! Dist: " .. math.floor(currentDistance) .. " | Speed: " .. math.floor(ballSpeed))
                    lastBallCheck[ballId] = currentTime
                    lastParryBall = ballId
                    lastParryBallTime = currentTime
                    SimulateParry(false, ballSpeed)
                elseif currentDistance <= criticalDistance or currentDistance <= idealDistance or isApproachingFast then
                    local reason = "IDEAL"
                    if currentDistance <= criticalDistance then
                        reason = "CRITICAL"
                    elseif isApproachingFast then
                        reason = "FAST_APPROACH"
                    end
                    
                    print("🎯 Parry (" .. reason .. ")! Speed: " .. math.floor(ballSpeed) .. " | Dist: " .. math.floor(currentDistance) .. " | Ideal: " .. math.floor(idealDistance) .. " | Time: " .. string.format("%.2f", timeToReach))
                    lastBallCheck[ballId] = currentTime
                    lastParryBall = ballId
                    lastParryBallTime = currentTime
                    SimulateParry(false, ballSpeed)
                end
            end
        end
    end
    
    -- Удаляем визуализацию для шаров, которые исчезли
    for ballId, _ in pairs(ballVisuals) do
        if not activeBalls[ballId] then
            ClearBallVisualization(ballId)
        end
    end
    
    -- Если визуализация выключена, очищаем всю визуализацию
    if not Settings.Visualize then
        ClearAllVisualization()
    end
    
    -- Очистка старых записей
    for id, time in pairs(lastBallCheck) do
        if tick() - time > 0.5 then
            lastBallCheck[id] = nil
            lastBallDistance[id] = nil -- Очищаем и дистанцию
        end
    end
end

-- Обработчик Auto Spam
SpamCheckbox.MouseButton1Click:Connect(function()
    Settings.AutoSpam = not Settings.AutoSpam
    
    if Settings.AutoSpam then
        SpamCheckbox.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        SpamCheckbox.Text = "⚡"
    else
        SpamCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SpamCheckbox.Text = ""
    end
end)

-- Обработчик Визуализации
VisCheckbox.MouseButton1Click:Connect(function()
    Settings.Visualize = not Settings.Visualize
    
    if Settings.Visualize then
        VisCheckbox.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        VisCheckbox.Text = "✓"
    else
        VisCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        VisCheckbox.Text = ""
        ClearAllVisualization()
    end
end)

-- Обработчик Chams
ChamsCheckbox.MouseButton1Click:Connect(function()
    Settings.Chams = not Settings.Chams
    
    if Settings.Chams then
        ChamsCheckbox.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        ChamsCheckbox.Text = "✓"
        UpdateAllChams()
    else
        ChamsCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ChamsCheckbox.Text = ""
        UpdateAllChams()
    end
end)

-- Обработчик Auto Follow
FollowCheckbox.MouseButton1Click:Connect(function()
    Settings.AutoFollow = not Settings.AutoFollow
    
    if Settings.AutoFollow then
        FollowCheckbox.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        FollowCheckbox.Text = "✓"
    else
        FollowCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        FollowCheckbox.Text = ""
    end
end)

-- Обработчик Show Radius
RadiusCheckbox.MouseButton1Click:Connect(function()
    Settings.ShowParryRadius = not Settings.ShowParryRadius
    
    if Settings.ShowParryRadius then
        RadiusCheckbox.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        RadiusCheckbox.Text = "✓"
    else
        RadiusCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        RadiusCheckbox.Text = ""
        -- Удаляем круг при выключении
        if parryRadiusCircle then
            parryRadiusCircle:Destroy()
            parryRadiusCircle = nil
        end
        if parryRadiusAttachment then
            parryRadiusAttachment:Destroy()
            parryRadiusAttachment = nil
        end
    end
end)

-- Обработчик кнопки открытия окна тем
ThemeButton.MouseButton1Click:Connect(function()
    ThemeWindow.Visible = not ThemeWindow.Visible
end)

-- Обработчик закрытия окна тем
ThemeCloseButton.MouseButton1Click:Connect(function()
    ThemeWindow.Visible = false
end)

-- Обработчик слайдера
local draggingSlider = false

SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local sliderX = DistanceSlider.AbsolutePosition.X
        local sliderWidth = DistanceSlider.AbsoluteSize.X
        
        local relativeX = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        
        Settings.AutoParryDistance = math.floor(10 + (relativeX * 40))
        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        SliderButton.Position = UDim2.new(relativeX, -12, 0, 0)
        DistanceLabel.Text = "Дистанция: " .. Settings.AutoParryDistance
    end
end)

-- Клик по слайдеру
DistanceSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouseX = input.Position.X
        local sliderX = DistanceSlider.AbsolutePosition.X
        local sliderWidth = DistanceSlider.AbsoluteSize.X
        
        local relativeX = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        
        Settings.AutoParryDistance = math.floor(10 + (relativeX * 40))
        SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        SliderButton.Position = UDim2.new(relativeX, -12, 0, 0)
        DistanceLabel.Text = "Дистанция: " .. Settings.AutoParryDistance
    end
end)

-- Обработчик Auto Parry
ParryCheckbox.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
    
    if Settings.Enabled then
        ParryCheckbox.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        ParryCheckbox.Text = "✓"
    else
        ParryCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ParryCheckbox.Text = ""
    end
end)

-- Обработчик закрытия
CloseButton.MouseButton1Click:Connect(function()
    -- Отключаем все функции
    Settings.Enabled = false
    Settings.AutoSpam = false
    Settings.Visualize = false
    Settings.Chams = false
    Settings.AutoFollow = false
    Settings.ShowParryRadius = false
    
    -- Останавливаем движение персонажа
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:Move(Vector3.new(0, 0, 0))
    end
    
    -- Удаляем круг радиуса
    if parryRadiusCircle then
        parryRadiusCircle:Destroy()
        parryRadiusCircle = nil
    end
    if parryRadiusAttachment then
        parryRadiusAttachment:Destroy()
        parryRadiusAttachment = nil
    end
    
    -- Очищаем всю визуализацию
    ClearAllVisualization()
    
    -- Удаляем все chams
    for playerId, _ in pairs(playerChams) do
        RemoveChams(playerId)
    end
    
    -- Очищаем таблицы
    playerChams = {}
    ballVisuals = {}
    lastBallCheck = {}
    lastBallDistance = {}
    
    -- Сбрасываем скорости
    currentBallVelocity = 0
    peakBallVelocity = 0
    
    -- Уничтожаем GUI
    ScreenGui:Destroy()
    
    print("⚔️ Auto Parry полностью выключен и удален")
end)

-- Обработчик сворачивания
MinimizeButton.MouseButton1Click:Connect(function()
    print("🔽 Сворачиваем GUI")
    
    -- Скрываем все элементы кроме кнопки BB
    Title.Visible = false
    Container.Visible = false
    MinimizedButton.Visible = true
    
    -- Уменьшаем размер MainFrame до размера кнопки BB
    MainFrame.Size = UDim2.new(0, 60, 0, 60)
    MainFrame.BackgroundTransparency = 1 -- Делаем фон прозрачным
end)

-- Основной цикл
RunService.Heartbeat:Connect(function()
    CheckBallAndParry()
    FollowBall()
    UpdateParryRadius()
    UpdateVelocityDisplay()
end)

-- Обработчики для сворачивания/разворачивания GUI
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if draggingMinimized then
            local wasDragging = dragStartMin and (input.Position - dragStartMin).Magnitude >= 5
            draggingMinimized = false
            
            -- Если не было перетаскивания (клик на месте), открываем GUI
            if not wasDragging then
                -- Разворачиваем GUI
                MinimizedButton.Visible = false
                
                task.wait(0.05)
                
                MainFrame.Size = UDim2.new(0, 500, 0, 380)
                MainFrame.BackgroundTransparency = 0
                MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                
                Title.Visible = true
                Container.Visible = true
                
                -- Явно показываем все дочерние элементы Container
                for _, child in pairs(Container:GetChildren()) do
                    if child:IsA("Frame") then
                        child.Visible = true
                    end
                end
                
                print("🔄 GUI развернут, Container children:", #Container:GetChildren())
            end
        end
        if draggingGUI then
            draggingGUI = false
        end
        if draggingVelocity then
            draggingVelocity = false
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingMinimized and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStartMin
        MainFrame.Position = UDim2.new(
            startPosMin.X.Scale,
            startPosMin.X.Offset + delta.X,
            startPosMin.Y.Scale,
            startPosMin.Y.Offset + delta.Y
        )
    end
end)

-- Добавление GUI
ScreenGui.Parent = PlayerGui

print("⚔️ Auto Parry загружен!")
print("📊 Компактный минималистичный интерфейс")
