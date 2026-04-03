local Library = {}

local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local CoreGui = game:GetService('CoreGui')
local GuiService = game:GetService('GuiService')

local Mobile = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then true else false

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

function Library:Parent()
    if not RunService:IsStudio() then
        return (gethui and gethui()) or CoreGui
    end
    return PlayerGui
end

function Library:Create(Class, Properties)
    local Creations = Instance.new(Class)
    for prop, value in Properties do
        Creations[prop] = value
    end
    return Creations
end

function Library:UDimToVector(udim, parent)
    local parentSize = parent and parent.AbsoluteSize or Vector2.new(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y)
    return Vector2.new(
        udim.X.Scale * parentSize.X + udim.X.Offset,
        udim.Y.Scale * parentSize.Y + udim.Y.Offset
    )
end

function Library:Tween(info)
    return TweenService:Create(info.v, TweenInfo.new(info.t, Enum.EasingStyle[info.s], Enum.EasingDirection[info.d]), info.g)
end

function Library:Draggable(a, IsResizing)
    local Dragging, DragInput, DragStart, StartPosition = nil, nil, nil, nil

    local function Update(input)
        if IsResizing() then return end
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        TweenService:Create(a, TweenInfo.new(0.3), {Position = pos}):Play()
    end

    a.InputBegan:Connect(function(input)
        if IsResizing() then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = a.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    a.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

function Library:Button(Parent): TextButton
    return Library:Create("TextButton", {
        Name = "Click",
        Parent = Parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.SourceSans,
        Text = "",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 14,
        ZIndex = Parent.ZIndex + 3
    })
end

function Library.Effect(c, p)
    p.ClipsDescendants = true

    local Mouse = LocalPlayer:GetMouse()
    local relativeX = Mouse.X - c.AbsolutePosition.X
    local relativeY = Mouse.Y - c.AbsolutePosition.Y

    if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
        return
    end

    local ClickButtonCircle = Library:Create("Frame", {
        Parent = p,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.95,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, relativeX, 0, relativeY),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = p.ZIndex
    })

    Library:Create("UICorner", {
        Parent = ClickButtonCircle,
        CornerRadius = UDim.new(1, 0)
    })

    local expandTween = TweenService:Create(ClickButtonCircle, TweenInfo.new(2.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
        BackgroundTransparency = 1
    })

    expandTween.Completed:Once(function()
        ClickButtonCircle:Destroy()
    end)

    expandTween:Play()
end

function Library:Asset(rbx)
    if typeof(rbx) == 'number' then
        return "rbxassetid://" .. rbx
    end
    if typeof(rbx) == 'string' and rbx:find('rbxassetid://') then
        return rbx
    end
    return rbx
end

function Library:Template(Args)
    local Parent = Args.Parent
    local Title = Args.Title
    local Description = Args.Description
    local PaddingRight = Args.PaddingRight or 15
    
    local Templete_1 = Instance.new("Frame")
    local Background_1 = Instance.new("ImageLabel")
    local Inner_1 = Instance.new("Frame")
    local Right_1 = Instance.new("Frame")
    local UIListLayout_1 = Instance.new("UIListLayout")
    local UIPadding_1 = Instance.new("UIPadding")
    local Left_1 = Instance.new("Frame")
    local UIListLayout_2 = Instance.new("UIListLayout")
    local UIPadding_2 = Instance.new("UIPadding")
    local Text_1 = Instance.new("Frame")
    local UIListLayout_3 = Instance.new("UIListLayout")
    local Title_1 = Instance.new("TextLabel")
    local Sub_1 = Instance.new("TextLabel")

    Templete_1.BackgroundTransparency = 1
    Templete_1.Name = "Templete"
    Templete_1.Parent = Parent
    Templete_1.Size = UDim2.new(1, 0, 0, not Description and 40 or 50)
    Templete_1.Selectable = false

    Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
    Background_1.BackgroundTransparency = 1
    Background_1.Name = "Background"
    Background_1.Parent = Templete_1
    Background_1.Position = UDim2.new(0.5, 0, 0.5, 0)
    Background_1.Size = UDim2.new(1, 0, 1, 0)
    Background_1.Image = "rbxassetid://80999662900595"
    Background_1.ImageContent = Content.fromUri("rbxassetid://80999662900595")
    Background_1.ImageTransparency = 0.9300000071525574
    Background_1.ScaleType = Enum.ScaleType.Slice
    Background_1.SliceCenter = Rect.new(256, 256, 256, 256)
    Background_1.SliceScale = 0.03515625

    Inner_1.BackgroundTransparency = 1
    Inner_1.Name = "Inner"
    Inner_1.Parent = Templete_1
    Inner_1.Size = UDim2.new(1, 0, 1, 0)
    Inner_1.Selectable = false

    Right_1.BackgroundTransparency = 1
    Right_1.Name = "Right"
    Right_1.Parent = Inner_1
    Right_1.Size = UDim2.new(1, 0, 1, 0)
    Right_1.Selectable = false

    UIListLayout_1.Padding = UDim.new(0, 15)
    UIListLayout_1.Parent = Right_1
    UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

    UIPadding_1.Parent = Right_1
    UIPadding_1.PaddingRight = UDim.new(0, PaddingRight)

    Left_1.BackgroundTransparency = 1
    Left_1.Name = "Left"
    Left_1.Parent = Inner_1
    Left_1.Size = UDim2.new(1, 0, 1, 0)
    Left_1.Selectable = false

    UIListLayout_2.Padding = UDim.new(0, 9)
    UIListLayout_2.Parent = Left_1
    UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

    UIPadding_2.Parent = Left_1
    UIPadding_2.PaddingLeft = UDim.new(0, 15)

    Text_1.BackgroundTransparency = 1
    Text_1.Name = "Text"
    Text_1.Parent = Left_1
    Text_1.Position = UDim2.new(0.06185548007488251, 0, 0, 0)
    Text_1.Size = UDim2.new(1, -50, 1, 0)
    Text_1.Selectable = false

    UIListLayout_3.Parent = Text_1
    UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center

    Title_1.BackgroundTransparency = 1
    Title_1.Name = "Title"
    Title_1.Parent = Text_1
    Title_1.Size = UDim2.new(1, 0, 0, 14)
    Title_1.Selectable = false
    Title_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title_1.Text = Title
    Title_1.TextColor3 = Color3.fromRGB(234, 234, 234)
    Title_1.TextSize = 14
    Title_1.TextXAlignment = Enum.TextXAlignment.Left
    Title_1.RichText = true
    
    if Description then
        Sub_1.BackgroundTransparency = 1
        Sub_1.Name = "Sub"
        Sub_1.Parent = Text_1
        Sub_1.Size = UDim2.new(1, 0, 0, 9)
        Sub_1.Selectable = false
        Sub_1.RichText = true
        Sub_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        Sub_1.Text = Description
        Sub_1.TextColor3 = Color3.fromRGB(255, 255, 255)
        Sub_1.TextSize = 11
        Sub_1.TextTransparency = 0.5
        Sub_1.TextXAlignment = Enum.TextXAlignment.Left
        Sub_1.TextYAlignment = Enum.TextYAlignment.Top 
    end
    
    return {
        Frame = Templete_1,
        Title = Title_1,
        Description = Sub_1,
        Right = Right_1
    }
end

function Library:App(Args)
    local Window = {}

    local Title = Args.Title or "Mango"
    local Footer = Args.Footer or "Made by @newclosure"
    local Logo = Args.Logo or 120883238056764

    local Width = Args.Width or 180

    local Minimize = Args.Minimize or UDim2.new(0, 500, 0, 360)
    local Maximize = Args.Maximize or nil
    local Size = Args.Size or Minimize

    local function GetMaximize()
        if Maximize then return Maximize end
        local VP = workspace.CurrentCamera.ViewportSize
        return UDim2.new(0, VP.X * 0.8, 0, VP.Y * 0.95)
    end

    local Cosmic_1 = Library:Create("ScreenGui", {
        IgnoreGuiInset = true,
        Name = "Cosmic",
        Parent = Library:Parent(),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    })

    local Window_1 = Library:Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Name = "Window",
        Parent = Cosmic_1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = Size,
    })

    local Background_1 = Library:Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Name = "Background",
        Parent = Window_1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxassetid://80999662900595",
        ImageColor3 = Color3.fromRGB(16, 16, 16),
        ImageContent = Content.fromUri("rbxassetid://80999662900595"),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(256, 256, 256, 256),
        SliceScale = 0.0625,
    })

    Library:Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Name = "Shadow",
        Parent = Background_1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 120, 1, 120),
        ZIndex = -999,
        Image = "rbxassetid://8992230677",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageContent = Content.fromUri("rbxassetid://8992230677"),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(99, 99, 99, 99),
    })

    local Scale_1 = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Name = "Scale",
        Parent = Background_1,
        Size = UDim2.new(1, 0, 1, 0),
    })

    local Header_1 = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Name = "Header",
        Parent = Scale_1,
        Size = UDim2.new(1, 0, 0, 50),
        Selectable = false,
    })

    local Left_1 = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Name = "Left",
        Parent = Header_1,
        Size = UDim2.new(1, 0, 1, 0),
        Selectable = false,
    })

    Library:Create("UIListLayout", {
        Padding = UDim.new(0, 9),
        Parent = Left_1,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    Library:Create("ImageLabel", {
        BackgroundTransparency = 1,
        Name = "Logo",
        Parent = Left_1,
        Size = UDim2.new(0, 25, 0, 25),
        Image = Library:Asset(Logo),
    })

    Library:Create("UIPadding", {
        Parent = Left_1,
        PaddingLeft = UDim.new(0, 15),
    })

    local Text_1 = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Name = "Text",
        Parent = Left_1,
        Position = UDim2.new(0.06185548007488251, 0, 0, 0),
        Size = UDim2.new(0, 300, 1, 0),
        Selectable = false,
    })

    Library:Create("UIListLayout", {
        Parent = Text_1,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Name = "Title",
        Parent = Text_1,
        Size = UDim2.new(1, 0, 0, 14),
        Selectable = false,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = Title,
        TextColor3 = Color3.fromRGB(234, 234, 234),
        TextSize = 14,
        TextStrokeTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    Library:Create("TextLabel", {
        BackgroundTransparency = 1,
        Name = "Sub",
        Parent = Text_1,
        Size = UDim2.new(1, 0, 0, 9),
        Selectable = false,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Text = Footer,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 9,
        TextTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })

    local Right_1 = Library:Create("Frame", {
        BackgroundTransparency = 1,
        Name = "Right",
        Parent = Header_1,
        Size = UDim2.new(1, 0, 1, 0),
        Selectable = false,
    })

    Library:Create("UIListLayout", {
        Padding = UDim.new(0, 15),
        Parent = Right_1,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })

    Library:Create("UIPadding", {
        Parent = Right_1,
        PaddingRight = UDim.new(0, 15),
    })

    do
        local Inner_1 = Instance.new("Frame")
        local Scale_2 = Instance.new("Frame")
        local TabSide_1 = Instance.new("Frame")
        local Scrolling_1 = Instance.new("ScrollingFrame")
        local UIListLayout_1 = Instance.new("UIListLayout")
        local UIPadding_1 = Instance.new("UIPadding")
        local UIPadding_2 = Instance.new("UIPadding")

        Inner_1.BackgroundTransparency = 1
        Inner_1.Name = "Inner"
        Inner_1.Parent = Scale_1
        Inner_1.Size = UDim2.new(1, 0, 1, 0)
        Inner_1.Selectable = false

        Scale_2.BackgroundTransparency = 1
        Scale_2.Name = "Scale"
        Scale_2.Parent = Inner_1
        Scale_2.Size = UDim2.new(1, 0, 1, 0)
        Scale_2.Selectable = false

        TabSide_1.BackgroundTransparency = 1
        TabSide_1.Name = "TabSide"
        TabSide_1.Parent = Scale_2
        TabSide_1.Size = UDim2.new(0, Width, 1, 0)
        TabSide_1.Selectable = false

        Scrolling_1.BackgroundTransparency = 1
        Scrolling_1.Name = "Scrolling"
        Scrolling_1.Parent = TabSide_1
        Scrolling_1.Size = UDim2.new(1, 0, 1, 0)
        Scrolling_1.ScrollBarThickness = 0

        UIListLayout_1.Padding = UDim.new(0, 4)
        UIListLayout_1.Parent = Scrolling_1
        UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center

        UIPadding_1.Parent = Scrolling_1
        UIPadding_1.PaddingLeft = UDim.new(0, 7)
        UIPadding_1.PaddingRight = UDim.new(0, 7)
        UIPadding_1.PaddingTop = UDim.new(0, 1)

        UIPadding_2.Parent = Inner_1
        UIPadding_2.PaddingTop = UDim.new(0, 50)

        UIListLayout_1:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Scrolling_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_1.AbsoluteContentSize.Y + 10)
        end)

        function Window:MakeTab(Info)
            local Title = Info.Title or "Tabs"
            local Icon = Info.Icon or 0

            local NewTab_1 = Library:Create("Frame", {
                BackgroundTransparency = 1,
                Name = "NewTab",
                Parent = Scrolling_1,
                Size = UDim2.new(1, 0, 0, 36),
                Selectable = false,
            })

            local Background_1 = Library:Create("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Name = "Background",
                Parent = NewTab_1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 1, 0),
                Image = "rbxassetid://80999662900595",
                ImageContent = Content.fromUri("rbxassetid://80999662900595"),
                ImageTransparency = 1,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(256, 256, 256, 256),
                SliceScale = 0.03515625,
            })

            local Scale_1 = Library:Create("Frame", {
                BackgroundTransparency = 1,
                Name = "Scale",
                Parent = NewTab_1,
                Size = UDim2.new(1, 0, 1, 0),
                Selectable = false,
            })

            Library:Create("UIListLayout", {
                Padding = UDim.new(0, 9),
                Parent = Scale_1,
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            })

            local Title_1 = Library:Create("TextLabel", {
                BackgroundTransparency = 1,
                Name = "Title",
                Parent = Scale_1,
                Size = UDim2.new(1, 0, 0, 15),
                Selectable = false,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = Title,
                TextColor3 = Color3.fromRGB(234, 234, 234),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0.5,
            })

            local Asset_1 = Library:Create("ImageLabel", {
                BackgroundTransparency = 1,
                LayoutOrder = -1,
                Name = "Asset",
                Parent = Scale_1,
                Size = UDim2.new(0, 16, 0, 16),
                Image = Library:Asset(Icon),
                ImageColor3 = Color3.fromRGB(161, 161, 170),
                ImageTransparency = 0.5,
            })

            Library:Create("UIPadding", {
                Parent = Scale_1,
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 11),
                PaddingRight = UDim.new(0, 11),
                PaddingTop = UDim.new(0, 10),
            })

            local Page_1 = Library:Create("Frame", {
                BackgroundTransparency = 1,
                Name = "Page",
                Parent = Scale_2,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, -10),
                Selectable = false,
                Visible = false,
            })

            Library:Create("UIPadding", {
                Parent = Page_1,
                PaddingLeft = UDim.new(0, Width),
            })

            local PageScrolling_1 = Library:Create("ScrollingFrame", {
                BackgroundTransparency = 1,
                Name = "Scrolling",
                Parent = Page_1,
                Size = UDim2.new(1, 0, 1, 0),
                ScrollBarThickness = 0,
            })

            Library:Create("UIPadding", {
                Parent = PageScrolling_1,
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 15),
                PaddingTop = UDim.new(0, 1),
            })

            local PageLayout_1 = Library:Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                Parent = PageScrolling_1,
                SortOrder = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            })

            PageLayout_1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                PageScrolling_1.CanvasSize = UDim2.new(0, 0, 0, PageLayout_1.AbsoluteContentSize.Y + 10)
            end)

            local ClickTab = Library:Button(NewTab_1)

            local function OnDeselect()
                Library:Tween({ v = Background_1, t = 0.2, s = "Quad", d = "Out", g = { ImageTransparency = 1 } }):Play()
                Library:Tween({ v = Title_1,      t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 0.5 } }):Play()
                Library:Tween({ v = Asset_1,      t = 0.2, s = "Quad", d = "Out", g = { ImageTransparency = 0.5 } }):Play()
            end

            local function OnSelect()
                for _, v in Scrolling_1:GetChildren() do
                    if v.Name == "NewTab" and v ~= NewTab_1 then
                        Library:Tween({ v = v.Background, t = 0.2, s = "Quad", d = "Out", g = { ImageTransparency = 1 } }):Play()
                        Library:Tween({ v = v.Scale.Title, t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 0.5 } }):Play()
                        Library:Tween({ v = v.Scale.Asset, t = 0.2, s = "Quad", d = "Out", g = { ImageTransparency = 0.5 } }):Play()
                    end
                end

                for _, v in Scale_2:GetChildren() do
                    if v.Name == "Page" and v ~= Page_1 and v.Visible then
                        v.Position = UDim2.new(0, 0, 0, -10)
                        v.Visible = false
                    end
                end

                Library:Tween({ v = Background_1, t = 0.2, s = "Quad", d = "Out", g = { ImageTransparency = 0.93 } }):Play()
                Library:Tween({ v = Title_1, t = 0.2, s = "Quad", d = "Out", g = { TextTransparency = 0 } }):Play()
                Library:Tween({ v = Asset_1, t = 0.2, s = "Quad", d = "Out", g = { ImageTransparency = 0.1 } }):Play()

                Page_1.Position = UDim2.new(0, 0, 0, -10)
                Page_1.Visible = true

                Library:Tween({ v = Page_1, t = 0.2, s = "Quad", d = "Out", g = { Position = UDim2.new(0, 0, 0, 0) } }):Play()
            end

            ClickTab.MouseButton1Click:Connect(OnSelect)

            local Tab = {}
            
            function Tab:Section(Title)
                local Text_1 = Instance.new("Frame")
                local UIListLayout_1 = Instance.new("UIListLayout")
                local Title_1 = Instance.new("TextLabel")

                Text_1.AutomaticSize = Enum.AutomaticSize.Y
                Text_1.BackgroundTransparency = 1
                Text_1.Name = "Text"
                Text_1.Parent = PageScrolling_1
                Text_1.Size = UDim2.new(1, -5, 0, 0)
                Text_1.Selectable = false

                UIListLayout_1.Parent = Text_1
                UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

                Title_1.BackgroundTransparency = 1
                Title_1.Name = "Title"
                Title_1.Parent = Text_1
                Title_1.Size = UDim2.new(1, 0, 0, 18)
                Title_1.Selectable = false
                Title_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Title_1.Text = Title or "Section"
                Title_1.TextColor3 = Color3.fromRGB(234, 234, 234)
                Title_1.TextSize = 17
                Title_1.TextXAlignment = Enum.TextXAlignment.Left
                Title_1.AutomaticSize = Enum.AutomaticSize.Y
                Title_1.LineHeight = 1.1
            end
            
            function Tab:Label(Info)
                local Title = Info.Title
                local Description = Info.Description
                local Icon = Info.Icon
                
                local Template = Library:Template({
                    Title = Title,
                    Description = Description,
                    Parent = PageScrolling_1
                })
                
                if Icon then
                    local Asset_1 = Instance.new("ImageLabel")
                    Asset_1.BackgroundTransparency = 1
                    Asset_1.Name = "Asset"
                    Asset_1.Parent = Template.Right
                    Asset_1.Size = UDim2.new(0, 20, 0, 20)
                    Asset_1.Image = Library:Asset(Icon)
                    Asset_1.ImageTransparency = 0.5
                end
                
                function Template:Title(text)
                    Template.Title.Text = text
                end
                
                function Template:Desc(text)
                    Template.Description.Text = text
                end
                
                return Template
            end
            
            function Tab:Button(Info)
                local Title = Info.Title
                local Description = Info.Description
                local Icon = Info.Icon
                local Callback = Info.Callback or function() end

                local Template = Library:Template({
                    Title = Title,
                    Description = Description,
                    Parent = PageScrolling_1,
                    PaddingRight = not Icon and 10 or 15
                })
                
                local ImageLabel_1 = Instance.new("ImageLabel") do
                    ImageLabel_1.BackgroundTransparency = 1
                    ImageLabel_1.Parent = Template.Right
                    ImageLabel_1.Size = UDim2.new(0, 25, 0, 25)
                    ImageLabel_1.Image = Icon and Library:Asset(Icon) or "rbxassetid://130050888244501"
                    ImageLabel_1.ImageTransparency = 0.5 
                end
                
                local Click = Library:Button(Template.Frame) do
                    local function OnTouch()
                        task.spawn(Library.Effect, Click, Template.Frame)
                        Callback()
                    end

                    Click.MouseButton1Click:Connect(OnTouch) 
                end
                
                return Template
            end
            
            function Tab:Toggle(Info)
                local Title = Info.Title
                local Description = Info.Description
                local Value = Info.Value or false
                local Callback = Info.Callback or function() end

                local Template = Library:Template({
                    Title = Title,
                    Description = Description,
                    Parent = PageScrolling_1,
                })  

                local Click = Library:Button(Template.Frame)

                local Background_1 = Instance.new("Frame")
                local UICorner_1 = Instance.new("UICorner")
                local OnValue_1 = Instance.new("Frame")
                local UICorner_2 = Instance.new("UICorner")
                local ImageLabel_1 = Instance.new("ImageLabel")

                Background_1.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
                Background_1.Name = "Background"
                Background_1.Parent = Template.Right
                Background_1.Size = UDim2.new(0, 23, 0, 23)
                Background_1.Selectable = false

                UICorner_1.CornerRadius = UDim.new(0, 6)
                UICorner_1.Parent = Background_1

                OnValue_1.AnchorPoint = Vector2.new(0.5, 0.5)
                OnValue_1.BackgroundColor3 = Color3.fromRGB(234, 234, 234)
                OnValue_1.Name = "OnValue"
                OnValue_1.Parent = Background_1
                OnValue_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                OnValue_1.Size = UDim2.new(1, 0, 1, 0)
                OnValue_1.Selectable = false
                OnValue_1.BackgroundTransparency = 1

                UICorner_2.CornerRadius = UDim.new(0, 6)
                UICorner_2.Parent = OnValue_1

                ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
                ImageLabel_1.BackgroundTransparency = 1
                ImageLabel_1.Parent = OnValue_1
                ImageLabel_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                ImageLabel_1.Size = UDim2.new(0.6000000238418579, 0, 0.6000000238418579, 0)
                ImageLabel_1.Image = "rbxassetid://121742282171603"
                ImageLabel_1.ImageColor3 = Color3.fromRGB(0, 0, 0)
                ImageLabel_1.ImageContent = Content.fromUri("rbxassetid://121742282171603")
                ImageLabel_1.Transparency = 1
                
                local function OnChanged(value)
                    if value then
                        Callback(Value)
                        Library:Tween({ v = OnValue_1, t = 0.5, s = "Exponential", d = "Out", g = { BackgroundTransparency = 0 } }):Play()
                        Library:Tween({ v = ImageLabel_1, t = 0.5, s = "Exponential", d = "Out", g = { ImageTransparency = 0 } }):Play()
                    else
                        Callback(Value)
                        Library:Tween({ v = OnValue_1, t = 0.5, s = "Exponential", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
                        Library:Tween({ v = ImageLabel_1, t = 0.5, s = "Exponential", d = "Out", g = { ImageTransparency = 1 } }):Play()
                    end
                end

                local function Init()
                    task.spawn(Library.Effect, Click, Template.Frame)
                    Value = not Value
                    OnChanged(Value)
                end
                
                Click.MouseButton1Click:Connect(Init)

                OnChanged(Value)

                return Template
            end
            
            function Tab:Slider(Info)
                local Title   = Info.Title    or "Slider"
                local Min     = Info.Min      or 0
                local Max     = Info.Max      or 100
                local Rounding = Info.Rounding or 0
                local Value   = Info.Value    or Min
                local Callback = Info.Callback or function() end

                local Slider_1 = Library:Create("Frame", {
                    BackgroundTransparency = 1,
                    Name = "Slider",
                    Parent = PageScrolling_1,
                    Size = UDim2.new(1, 0, 0, 50),
                    Selectable = false,
                })

                local Background_1 = Library:Create("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Name = "Background",
                    Parent = Slider_1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    Image = "rbxassetid://80999662900595",
                    ImageContent = Content.fromUri("rbxassetid://80999662900595"),
                    ImageTransparency = 0.93,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(256, 256, 256, 256),
                    SliceScale = 0.03515625,
                })

                local Inner_1 = Library:Create("Frame", {
                    BackgroundTransparency = 1,
                    Name = "Inner",
                    Parent = Slider_1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Selectable = false,
                })

                local Left_1 = Library:Create("Frame", {
                    BackgroundTransparency = 1,
                    Name = "Left",
                    Parent = Inner_1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Selectable = false,
                })

                Library:Create("UIListLayout", {
                    Padding = UDim.new(0, 5),
                    Parent = Left_1,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                })

                Library:Create("UIPadding", {
                    Parent = Left_1,
                    PaddingLeft = UDim.new(0, 15),
                    PaddingRight = UDim.new(0, 15),
                })

                local Text_1 = Library:Create("Frame", {
                    BackgroundTransparency = 1,
                    Name = "Text",
                    Parent = Left_1,
                    Size = UDim2.new(0, 300, 0, 14),
                    Selectable = false,
                })

                Library:Create("UIListLayout", {
                    Parent = Text_1,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                })

                local Title_1 = Library:Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Name = "Title",
                    Parent = Text_1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Selectable = false,
                    RichText = true,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    Text = Title,
                    TextColor3 = Color3.fromRGB(234, 234, 234),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local Slider_2 = Library:Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                    Name = "Slider",
                    Parent = Left_1,
                    Size = UDim2.new(1, 0, 0, 5),
                    Selectable = false,
                })

                Library:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Slider_2,
                })

                local Value_1 = Library:Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Name = "Value",
                    Parent = Slider_2,
                    Size = UDim2.new(0, 0, 1, 0),
                    Selectable = false,
                })

                Library:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Value_1,
                })

                local Circle_1 = Library:Create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Name = "Circle",
                    Parent = Value_1,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    Selectable = false,
                })

                Library:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Circle_1,
                })

                local Right_1 = Library:Create("Frame", {
                    BackgroundTransparency = 1,
                    Name = "Right",
                    Parent = Inner_1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Selectable = false,
                })

                Library:Create("UIListLayout", {
                    Padding = UDim.new(0, 15),
                    Parent = Right_1,
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                })

                Library:Create("UIPadding", {
                    Parent = Right_1,
                    PaddingRight = UDim.new(0, 15),
                    PaddingTop = UDim.new(0, 15),
                })

                local Textbox_1 = Library:Create("TextBox", {
                    BackgroundTransparency = 1,
                    Name = "Textbox",
                    Parent = Right_1,
                    Size = UDim2.new(0, 100, 0, 10),
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
                    Text = tostring(Value),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    TextTransparency = 0.5,
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local pink  = Color3.fromRGB(255, 0, 127)
                local white = Color3.fromRGB(255, 255, 255)
                local dragging = false

                local function Round(n, decimals)
                    local factor = 10 ^ decimals
                    return math.floor(n * factor + 0.5) / factor
                end

                local function UpdateSlider(val)
                    val = math.clamp(val, Min, Max)
                    val = Round(val, Rounding)

                    local ratio = (val - Min) / (Max - Min)

                    Library:Tween({
                        v = Value_1,
                        t = 0.1, s = "Linear", d = "Out",
                        g = { Size = UDim2.new(ratio, 0, 1, 0) }
                    }):Play()

                    Textbox_1.Text = tostring(val)
                    Callback(val)

                    return val
                end

                local function GetValueFromInput(input)
                    local absX = Slider_2.AbsolutePosition.X
                    local absW = Slider_2.AbsoluteSize.X
                    local ratio = math.clamp((input.Position.X - absX) / absW, 0, 1)
                    return ratio * (Max - Min) + Min
                end

                local function SetDragging(state)
                    dragging = state
                end

                local ClickButton = Library:Button(Slider_1)
                Textbox_1.ZIndex = ClickButton.ZIndex + 1

                ClickButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        SetDragging(true)
                        UpdateSlider(GetValueFromInput(input))
                    end
                end)

                ClickButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        SetDragging(false)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                            or input.UserInputType == Enum.UserInputType.Touch
                        ) then
                        UpdateSlider(GetValueFromInput(input))
                    end
                end)

                Textbox_1.FocusLost:Connect(function()
                    local val = tonumber(Textbox_1.Text) or Value
                    Value = UpdateSlider(val)
                end)

                UpdateSlider(Value)
            end

            function Tab:Select()
                OnSelect()
            end

            return Tab
        end
    end

    function Window:TopRightButton(Logo, LayOut, Size, Callback)
        local Template_1 = Library:Create("Frame", {
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            LayoutOrder = LayOut or 997,
            Parent = Right_1,
            Size = UDim2.new(0, 30, 0, 30),
            Selectable = false,
        })

        Library:Create("UICorner", {
            CornerRadius = UDim.new(0, 10),
            Parent = Template_1,
        })

        Library:Create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Name = "Asset",
            Parent = Template_1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = Size or UDim2.new(0, 20, 0, 20),
            Image = Library:Asset(Logo),
            ImageTransparency = 0.5,
        })

        local Click = Library:Button(Template_1)

        Template_1.MouseEnter:Connect(function()
            Library:Tween({
                v = Template_1,
                t = 0.2,
                s = "Quad",
                d = "Out",
                g = { BackgroundTransparency = 0.95 }
            }):Play()
        end)

        Template_1.MouseLeave:Connect(function()
            Library:Tween({
                v = Template_1,
                t = 0.2,
                s = "Quad",
                d = "Out",
                g = { BackgroundTransparency = 1 }
            }):Play()
        end)

        Click.MouseButton1Click:Connect(Callback)
    end

    function Window:TweenSize(Target)
        Library:Tween({
            v = Window_1,
            t = 0.2,
            s = "Exponential",
            d = "Out",
            g = { Size = Target }
        }):Play()
    end

    local IsResizing = false

    do
        local Resize_1 = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Name = "Resize",
            Parent = Scale_1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Selectable = false,
        })

        local Holder_Left_1 = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Name = "Holder_Left",
            Parent = Resize_1,
            Size = UDim2.new(0, 10, 1, 0),
            Selectable = false,
        })

        local Holder_Right_1 = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Name = "Holder_Right",
            Parent = Resize_1,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 10, 1, 0),
            Selectable = false,
        })

        local Holder_Upper_1 = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Name = "Holder_Upper",
            Parent = Resize_1,
            Size = UDim2.new(1, 0, 0, 10),
            Selectable = false,
        })

        local Holder_Lower_1 = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Name = "Holder_Lower",
            Parent = Resize_1,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, 10),
            Selectable = false,
        })

        local Holder_TopLeft_1 = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Name = "Holder_TopLeft",
            Parent = Resize_1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 15, 0, 15),
            Selectable = false,
        })

        local Holder_TopRight_1 = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Name = "Holder_TopRight",
            Parent = Resize_1,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 15, 0, 15),
            Selectable = false,
        })

        local Holder_BottomLeft_1 = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Name = "Holder_BottomLeft",
            Parent = Resize_1,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(0, 15, 0, 15),
            Selectable = false,
        })

        local Holder_BottomRight_1 = Library:Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Name = "Holder_BottomRight",
            Parent = Resize_1,
            Position = UDim2.new(1, 0, 1, 0),
            Size = UDim2.new(0, 15, 0, 15),
            Selectable = false,
        })

        local function MakeResizable(Handle, Direction)
            local ResizeStart, StartSize, StartPos, StartUDim = nil, nil, nil, nil

            Handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    IsResizing = true
                    ResizeStart = input.Position
                    StartSize = Window_1.AbsoluteSize
                    StartUDim = Window_1.Position

                    local Inset = GuiService:GetGuiInset()
                    StartPos = Vector2.new(
                        Window_1.AbsolutePosition.X + Window_1.AbsoluteSize.X / 2,
                        Window_1.AbsolutePosition.Y + Window_1.AbsoluteSize.Y / 2 + Inset.Y
                    )

                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            IsResizing = false
                            ResizeStart = nil
                            StartSize = nil
                            StartPos = nil
                            StartUDim = nil
                        end
                    end)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if not IsResizing or not ResizeStart or not StartSize or not StartPos or not StartUDim then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end

                local Delta = input.Position - ResizeStart
                local MinVec = Library:UDimToVector(Minimize, nil)
                local MaxVec = Library:UDimToVector(GetMaximize(), nil)

                local NewWidth = StartSize.X
                local NewHeight = StartSize.Y
                local NewX = StartPos.X
                local NewY = StartPos.Y

                if Direction == "Right" or Direction == "TopRight" or Direction == "BottomRight" then
                    NewWidth = math.clamp(StartSize.X + Delta.X, MinVec.X, MaxVec.X)
                    NewX = StartPos.X + (NewWidth - StartSize.X) / 2
                elseif Direction == "Left" or Direction == "TopLeft" or Direction == "BottomLeft" then
                    NewWidth = math.clamp(StartSize.X - Delta.X, MinVec.X, MaxVec.X)
                    NewX = StartPos.X - (NewWidth - StartSize.X) / 2
                end

                if Direction == "Lower" or Direction == "BottomLeft" or Direction == "BottomRight" then
                    NewHeight = math.clamp(StartSize.Y + Delta.Y, MinVec.Y, MaxVec.Y)
                    NewY = StartPos.Y + (NewHeight - StartSize.Y) / 2
                elseif Direction == "Upper" or Direction == "TopLeft" or Direction == "TopRight" then
                    NewHeight = math.clamp(StartSize.Y - Delta.Y, MinVec.Y, MaxVec.Y)
                    NewY = StartPos.Y - (NewHeight - StartSize.Y) / 2
                end

                local Viewport = workspace.CurrentCamera.ViewportSize
                local ScaleX = StartUDim.X.Scale
                local ScaleY = StartUDim.Y.Scale
                local OffsetX = NewX - ScaleX * Viewport.X
                local OffsetY = NewY - ScaleY * Viewport.Y

                Window_1.Size = UDim2.new(0, NewWidth, 0, NewHeight)
                Window_1.Position = UDim2.new(ScaleX, OffsetX, ScaleY, OffsetY)
            end)
        end
        
        if not Mobile then
            MakeResizable(Holder_BottomRight_1, "BottomRight")
            MakeResizable(Holder_BottomRight_1, "BottomRight")
            MakeResizable(Holder_BottomLeft_1, "BottomLeft")
            MakeResizable(Holder_TopRight_1, "TopRight")
            MakeResizable(Holder_TopLeft_1, "TopLeft")
            MakeResizable(Holder_Lower_1, "Lower")
            MakeResizable(Holder_Upper_1, "Upper")
            MakeResizable(Holder_Right_1, "Right")
            MakeResizable(Holder_Left_1, "Left") 
        end
    end

    do
        do
            local ToggleScreen = Library:Create("ScreenGui", {
                Name = "Toggle",
                Parent = Library:Parent(),
                ZIndexBehavior = Enum.ZIndexBehavior.Global,
                IgnoreGuiInset = true
            })

            local Pillow_1 = Library:Create("TextButton", {
                Name = "Pillow",
                Parent = ToggleScreen,
                BackgroundColor3 = Color3.fromRGB(11, 11, 11),
                BorderSizePixel = 0,
                Position = UDim2.new(0.06, 0, 0.15, 0),
                Size = UDim2.new(0, 50, 0, 50),
                Text = ""
            })

            Library:Create("UICorner", {
                Parent = Pillow_1,
                CornerRadius = UDim.new(1, 0)
            })

            Library:Create("ImageLabel", {
                Name = "Logo",
                Parent = Pillow_1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0.5, 0, 0.5, 0),
                Image = Library:Asset(Logo)
            })

            Library:Draggable(Pillow_1, function() return IsResizing end)

            Pillow_1.MouseButton1Click:Connect(function()
                Window_1.Visible = not Window_1.Visible
            end)

            UserInputService.InputBegan:Connect(function(Input, Processed)
                if Processed then return end

                if Input.KeyCode == Enum.KeyCode.LeftControl then
                    Window_1.Visible = not Window_1.Visible
                end
            end)
        end
        
        local TopRightButton = {
            [106352522036205] = {
                Order = 997,
                Size = UDim2.new(0, 20, 0, 20),
                Callback = function()
                    Window_1.Visible = not Window_1.Visible
                end,
            },
            [72097270213792] = {
                Order = 998,
                Size = UDim2.new(0, 17, 0, 17),
                Callback = function()
                    local CurrentMaximize = GetMaximize()
                    local MinVec = Library:UDimToVector(Minimize, nil)
                    local MaxVec = Library:UDimToVector(CurrentMaximize, nil)
                    local CurX = Window_1.Size.X.Offset
                    local CurY = Window_1.Size.Y.Offset

                    local DistToMin = math.sqrt((CurX - MinVec.X)^2 + (CurY - MinVec.Y)^2)
                    local DistToMax = math.sqrt((CurX - MaxVec.X)^2 + (CurY - MaxVec.Y)^2)

                    if DistToMin <= DistToMax then
                        local TweenX = Library:Tween({
                            v = Window_1,
                            t = 0.2,
                            s = "Exponential",
                            d = "Out",
                            g = { Size = UDim2.new(0, MaxVec.X, 0, CurY) }
                        })
                        TweenX:Play()
                        TweenX.Completed:Wait()

                        Library:Tween({
                            v = Window_1,
                            t = 0.2,
                            s = "Exponential",
                            d = "Out",
                            g = { Size = CurrentMaximize }
                        }):Play()
                    else
                        local TweenY = Library:Tween({
                            v = Window_1,
                            t = 0.2,
                            s = "Exponential",
                            d = "Out",
                            g = { Size = UDim2.new(0, CurX, 0, MinVec.Y) }
                        })
                        TweenY:Play()
                        TweenY.Completed:Wait()

                        Library:Tween({
                            v = Window_1,
                            t = 0.2,
                            s = "Exponential",
                            d = "Out",
                            g = { Size = Minimize }
                        }):Play()
                    end
                end,
            },
            [126518941777580] = {
                Order = 999,
                Size = UDim2.new(0, 20, 0, 20),
                Callback = function()
                    Cosmic_1:Destroy()
                end,
            }
        }

        for Asset, Data in TopRightButton do
            Window:TopRightButton(Asset, Data.Order, Data.Size, Data.Callback)
        end

        Library:Draggable(Window_1, function() return IsResizing end)
    end

    return Window
end


return Library
