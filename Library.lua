local Library = {}

local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local CoreGui = game:GetService('CoreGui')
local GuiService = game:GetService('GuiService')

local Camera = workspace.CurrentCamera

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

function Library:BlurFrame(Parent)
    local BlurFolder = Instance.new('Folder', workspace)
    BlurFolder.Name = 'BlurSnox'

    local UID = math.random(1, 99999999)

    local DOF = Instance.new('DepthOfFieldEffect', game:GetService('Lighting'))
    DOF.FarIntensity = 0
    DOF.FocusDistance = 51.6
    DOF.InFocusRadius = 50
    DOF.NearIntensity = 1
    DOF.Name = "DPT_" .. UID

    local BlurSurface = Library:Create("Frame", {
        Parent = Parent,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
    })

    local BindKey
    do
        local Count = 0
        BindKey = function()
            Count = Count + 1
            return 'neon::' .. tostring(Count)
        end
    end

    do
        local function IsNotNaN(v) return v == v end
        local ok = IsNotNaN(Camera:ScreenPointToRay(0, 0).Origin.X)
        while not ok do
            RunService.RenderStepped:Wait()
            ok = IsNotNaN(Camera:ScreenPointToRay(0, 0).Origin.X)
        end
    end

    local DrawQuad
    do
        local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
        local SCALE = 0.2

        local function DrawTriangle(A, B, C, D, E)
            local AB = (A - B).Magnitude
            local BC = (B - C).Magnitude
            local CA = (C - A).Magnitude
            local longest = max(AB, BC, CA)
            local J, K, L

            if AB == longest then
                J, K, L = A, B, C
            elseif BC == longest then
                J, K, L = B, C, A
            else
                J, K, L = C, A, B
            end

            local M = ((K - J).X * (L - J).X + (K - J).Y * (L - J).Y + (K - J).Z * (L - J).Z) / (J - K).Magnitude
            local N = sqrt((L - J).Magnitude ^ 2 - M * M)
            local O = (J - K).Magnitude - M

            local P = CFrame.new(K, J)
            local Q = CFrame.Angles(pi / 2, 0, 0)
            local R = P
            local S = (R * Q).LookVector
            local T = J + CFrame.new(J, K).LookVector * M
            local U = CFrame.new(T, L).LookVector
            local V = S.X * U.X + S.Y * U.Y + S.Z * U.Z
            local W = CFrame.Angles(0, 0, acos(V))

            R = R * W
            if ((R * Q).LookVector - U).Magnitude > 0.01 then
                R = R * CFrame.Angles(0, 0, -2 * acos(V))
            end
            R = R * CFrame.new(0, N / 2, -(O + M / 2))

            local X = P * W * CFrame.Angles(0, pi, 0)
            if ((X * Q).LookVector - U).Magnitude > 0.01 then
                X = X * CFrame.Angles(0, 0, 2 * acos(V))
            end
            X = X * CFrame.new(0, N / 2, O / 2)

            if not D then
                D = Instance.new('Part')
                D.FormFactor = 'Custom'
                D.TopSurface = 0
                D.BottomSurface = 0
                D.Anchored = true
                D.CanCollide = false
                D.CastShadow = false
                D.Material = Enum.Material.Glass
                D.Size = Vector3.new(SCALE, SCALE, SCALE)
                local Mesh = Instance.new('SpecialMesh', D)
                Mesh.MeshType = Enum.MeshType.Wedge
                Mesh.Name = 'WedgeMesh'
            end

            D.WedgeMesh.Scale = Vector3.new(0, N / SCALE, M / SCALE)
            D.CFrame = R

            if not E then
                E = D:Clone()
            end

            E.WedgeMesh.Scale = Vector3.new(0, N / SCALE, O / SCALE)
            E.CFrame = X

            return D, E
        end

        DrawQuad = function(A, B, C, D, Parts)
            Parts[1], Parts[2] = DrawTriangle(A, B, C, Parts[1], Parts[2])
            Parts[3], Parts[4] = DrawTriangle(C, B, D, Parts[3], Parts[4])
        end
    end

    local RenderKey = BindKey()
    local Parts = {}
    local PartsFolder = Instance.new('Folder', BlurFolder)
    PartsFolder.Name = BlurSurface.Name

    local ParentChain = {}
    do
        local function CollectParents(obj)
            if obj:IsA('GuiObject') then
                ParentChain[#ParentChain + 1] = obj
                CollectParents(obj.Parent)
            end
        end
        CollectParents(BlurSurface)
    end

    local function UpdateOrientation(init)
        local Depth = 1 - 0.05 * BlurSurface.ZIndex

        local TL = BlurSurface.AbsolutePosition
        local BR = BlurSurface.AbsolutePosition + BlurSurface.AbsoluteSize
        local TR = Vector2.new(BR.X, TL.Y)
        local BL = Vector2.new(TL.X, BR.Y)

        do
            local TotalRot = 0
            for _, obj in ipairs(ParentChain) do
                TotalRot = TotalRot + obj.Rotation
            end
            if TotalRot ~= 0 and TotalRot % 180 ~= 0 then
                local Center = TL:Lerp(BR, 0.5)
                local sinR = math.sin(math.rad(TotalRot))
                local cosR = math.cos(math.rad(TotalRot))
                local function Rotate(v)
                    return Vector2.new(cosR * (v.X - Center.X) - sinR * (v.Y - Center.Y), sinR * (v.X - Center.X) + cosR * (v.Y - Center.Y)) + Center
                end
                TL = Rotate(TL)
                TR = Rotate(TR)
                BL = Rotate(BL)
                BR = Rotate(BR)
            end
        end

        DrawQuad(
            Camera:ScreenPointToRay(TL.X, TL.Y, Depth).Origin,
            Camera:ScreenPointToRay(TR.X, TR.Y, Depth).Origin,
            Camera:ScreenPointToRay(BL.X, BL.Y, Depth).Origin,
            Camera:ScreenPointToRay(BR.X, BR.Y, Depth).Origin,
            Parts
        )

        if init then
            for _, part in pairs(Parts) do
                part.Parent = PartsFolder
                part.Transparency = 0.98
                part.BrickColor = BrickColor.new('Institutional white')
            end
        end
    end

    UpdateOrientation(true)
    RunService:BindToRenderStep(RenderKey, 2000, UpdateOrientation)

    return {
        DOF = DOF,
        Surface = BlurSurface,
        Destroy = function()
            RunService:UnbindFromRenderStep(RenderKey)
            DOF:Destroy()
            BlurFolder:Destroy()
        end
    }
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

function Library:IsDropdownOpen(v)
    for _, v in v:GetChildren() do
        if v.Name == 'Dropdown' and v.Visible then
            return true
        end
    end
end

function Library:App(Args)
    local Window = {}

    local Title = Args.Title or "Mango"
    local Footer = Args.Footer or "Made by @newclosure"
    local Logo = Args.Logo or 120883238056764

    local Transarent = Args.Transparent or 0.1

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
        ImageTransparency = Transarent,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(256, 256, 256, 256),
        SliceScale = 0.0625,
    })

    local Blur = Library:BlurFrame(Background_1)

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
        Selectable = false,
    })

    do
        local UIListLayout: UIListLayout = Library:Create("UIListLayout", {
            Parent = Text_1,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        })

        local Title_1 = Library:Create("TextLabel", {
            BackgroundTransparency = 1,
            Name = "Title",
            Parent = Text_1,
            Size = UDim2.new(0, 0, 0, 14),
            Selectable = false,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(234, 234, 234),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true
        })

        local Sub_1 = Library:Create("TextLabel", {
            BackgroundTransparency = 1,
            Name = "Sub",
            Parent = Text_1,
            Size = UDim2.new(0, 0, 0, 9),
            Selectable = false,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 9,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            RichText = true
        })

        Title_1:GetPropertyChangedSignal('TextBounds'):Connect(function()
            Title_1.Size = UDim2.new(0, Title_1.TextBounds.X, 0, 14)
        end)

        Sub_1:GetPropertyChangedSignal('TextBounds'):Connect(function()
            Sub_1.Size = UDim2.new(0, Sub_1.TextBounds.X, 0, 9)
        end)

        UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Text_1.Size = UDim2.new(0, UIListLayout.AbsoluteContentSize.X + 10, 1, 0)
        end)

        function Window:Tags(Name, Color)
            local Tags_1 = Instance.new("Frame")
            local UICorner_1 = Instance.new("UICorner")
            local Title_1 = Instance.new("TextLabel")

            Tags_1.Name = "Tags"
            Tags_1.Parent = Left_1
            Tags_1.BackgroundColor3 = Color
            Tags_1.Size = UDim2.new(0, 80, 0, 25)
            Tags_1.Selectable = false

            UICorner_1.CornerRadius = UDim.new(1, 0)
            UICorner_1.Parent = Tags_1

            Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
            Title_1.BackgroundTransparency = 1
            Title_1.Name = "Title"
            Title_1.Parent = Tags_1
            Title_1.Position = UDim2.new(0.5, 0, 0.5, 0)
            Title_1.Selectable = false
            Title_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
            Title_1.RichText = true
            Title_1.Text = Name
            Title_1.TextSize = 12

            Title_1.Size = UDim2.new(0, Title_1.TextBounds.X + 10, 0, 14)
        end

        Title_1.Text = Title
        Sub_1.Text = Footer

        function Window:SetTitle(Text)
            Title_1.Text = Text
        end

        function Window:SetFooter(Text)
            Sub_1.Text = Text
        end
    end

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
        Scrolling_1.Size = UDim2.new(1, 0, 1, -50)
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

        do
            local UIListSide = Instance.new("UIListLayout")

            UIListSide.Padding = UDim.new(0, 7)
            UIListSide.Parent = TabSide_1
            UIListSide.SortOrder = Enum.SortOrder.LayoutOrder
            UIListSide.HorizontalAlignment = Enum.HorizontalAlignment.Center

            do
                local Collapse_1 = Instance.new("Frame")
                local Background_1 = Instance.new("ImageLabel")
                local Scale = Instance.new("Frame")
                local UIListLayout_1 = Instance.new("UIListLayout")
                local Title_1 = Instance.new("TextLabel")
                local Asset_1 = Instance.new("ImageLabel")
                local UIPadding_1 = Instance.new("UIPadding")

                Collapse_1.BackgroundTransparency = 1
                Collapse_1.Name = "Collapse"
                Collapse_1.Parent = TabSide_1
                Collapse_1.Size = UDim2.new(1, -14, 0, 36)
                Collapse_1.Selectable = false

                Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
                Background_1.BackgroundTransparency = 1
                Background_1.Name = "Background"
                Background_1.Parent = Collapse_1
                Background_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                Background_1.Size = UDim2.new(1, 0, 1, 0)
                Background_1.Image = "rbxassetid://80999662900595"
                Background_1.ImageContent = Content.fromUri("rbxassetid://80999662900595")
                Background_1.ImageTransparency = 0.9300000071525574
                Background_1.ScaleType = Enum.ScaleType.Slice
                Background_1.SliceCenter = Rect.new(256, 256, 256, 256)
                Background_1.SliceScale = 0.03515625

                Scale.BackgroundTransparency = 1
                Scale.Name = "Scale"
                Scale.Parent = Collapse_1
                Scale.Size = UDim2.new(1, 0, 1, 0)
                Scale.Selectable = false

                UIListLayout_1.Padding = UDim.new(0, 9)
                UIListLayout_1.Parent = Scale
                UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
                UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

                Title_1.BackgroundTransparency = 1
                Title_1.Name = "Title"
                Title_1.Parent = Scale
                Title_1.Size = UDim2.new(1, 0, 0, 15)
                Title_1.Selectable = false
                Title_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                Title_1.Text = "Collapse"
                Title_1.TextColor3 = Color3.fromRGB(234, 234, 234)
                Title_1.TextSize = 13
                Title_1.TextXAlignment = Enum.TextXAlignment.Left

                Asset_1.BackgroundTransparency = 1
                Asset_1.LayoutOrder = -1
                Asset_1.Name = "Asset"
                Asset_1.Parent = Scale
                Asset_1.Size = UDim2.new(0, 18, 0, 18)
                Asset_1.Image = "rbxassetid://88390037926738"

                Asset_1.ImageColor3 = Color3.fromRGB(161, 161, 170)
                Asset_1.ImageContent = Content.fromUri("rbxassetid://88390037926738")
                Asset_1.ImageTransparency = 0.10000000149011612

                UIPadding_1.Parent = Scale
                UIPadding_1.PaddingBottom = UDim.new(0, 10)
                UIPadding_1.PaddingLeft = UDim.new(0, 11)
                UIPadding_1.PaddingRight = UDim.new(0, 11)
                UIPadding_1.PaddingTop = UDim.new(0, 10)

                local ClickHide = Library:Button(Collapse_1)
                local IsCollapse = false

                local function OnSelect(value)
                    if value then
                        Library:Tween({v = Title_1, t = 0.2, s = "Quad", d = "Out", g = {TextTransparency = 0}}):Play()
                        Library:Tween({v = Asset_1, t = 0.2, s = "Quad", d = "Out", g = {ImageTransparency = 0.1}}):Play()
                    else
                        Library:Tween({v = Title_1, t = 0.2, s = "Quad", d = "Out", g = {TextTransparency = 0.5}}):Play()
                        Library:Tween({v = Asset_1, t = 0.2, s = "Quad", d = "Out", g = {ImageTransparency = 0.5}}):Play() 
                    end
                end

                local function OnVisual(value)
                    for _, v in Scrolling_1:GetChildren() do
                        if v.Name == 'NewTab' then
                            v.Scale.Title.Visible = value
                        end
                    end

                    for _, v in Scale_2:GetChildren() do
                        if v.Name == "Page" and v:FindFirstChild("UIPadding") then
                            local padding = v.UIPadding

                            if value then
                                Library:Tween({
                                    v = padding,
                                    t = 0.2,
                                    s = "Quad",
                                    d = "Out",
                                    g = {
                                        PaddingLeft = UDim.new(0, Width)
                                    }
                                }):Play()
                            else
                                Library:Tween({
                                    v = padding,
                                    t = 0.2,
                                    s = "Quad",
                                    d = "Out",
                                    g = {
                                        PaddingLeft = UDim.new(0, 52)
                                    }
                                }):Play()
                            end
                        end
                    end
                end

                ClickHide.MouseButton1Click:Connect(function()
                    IsCollapse = not IsCollapse

                    if IsCollapse then
                        OnSelect(false)
                        OnVisual(false)
                        Title_1.Visible = false
                        Asset_1.Image = "rbxassetid://93693463622958"
                        Library:Tween({v = TabSide_1, t = 0.2, s = "Quad", d = "Out", g = {Size = UDim2.new(0, 53, 1, 0)}}):Play()
                    else
                        Asset_1.Image = "rbxassetid://88390037926738"
                        OnSelect(true)
                        OnVisual(true)
                        Title_1.Visible = true
                        Library:Tween({v = TabSide_1, t = 0.2, s = "Quad", d = "Out", g = {Size = UDim2.new(0, Width, 1, 0)}}):Play()
                    end
                end)
            end
        end

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
                Library:Tween({v = Background_1, t = 0.2, s = "Quad", d = "Out", g = {ImageTransparency = 1}}):Play()
                Library:Tween({v = Title_1, t = 0.2, s = "Quad", d = "Out", g = {TextTransparency = 0.5}}):Play()
                Library:Tween({v = Asset_1, t = 0.2, s = "Quad", d = "Out", g = {ImageTransparency = 0.5}}):Play()
            end

            local function OnSelect()
                for _, v in Scrolling_1:GetChildren() do
                    if v.Name == "NewTab" and v ~= NewTab_1 then
                        Library:Tween({v = v.Background, t = 0.2, s = "Quad", d = "Out", g = {ImageTransparency = 1}}):Play()
                        Library:Tween({v = v.Scale.Title, t = 0.2, s = "Quad", d = "Out", g = {TextTransparency = 0.5}}):Play()
                        Library:Tween({v = v.Scale.Asset, t = 0.2, s = "Quad", d = "Out", g = {ImageTransparency = 0.5}}):Play()
                    end
                end

                for _, v in Scale_2:GetChildren() do
                    if v.Name == "Page" and v ~= Page_1 and v.Visible then
                        v.Position = UDim2.new(0, 0, 0, -10)
                        v.Visible = false
                    end
                end

                Library:Tween({v = Background_1, t = 0.2, s = "Quad", d = "Out", g = {ImageTransparency = 0.93}}):Play()
                Library:Tween({v = Title_1, t = 0.2, s = "Quad", d = "Out", g = {TextTransparency = 0}}):Play()
                Library:Tween({v = Asset_1, t = 0.2, s = "Quad", d = "Out", g = {ImageTransparency = 0.1}}):Play()

                Page_1.Position = UDim2.new(0, 0, 0, -10)
                Page_1.Visible = true

                Library:Tween({v = Page_1, t = 0.2, s = "Quad", d = "Out", g = {Position = UDim2.new(0, 0, 0, 0)}}):Play()
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
                    Library:Create("ImageLabel", {
                        BackgroundTransparency = 1,
                        Name = "Asset",
                        Parent = Template.Right,
                        Size = UDim2.new(0, 20, 0, 20),
                        Image = Library:Asset(Icon),
                        ImageTransparency = 0.5,
                    })
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

                Library:Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    Parent = Template.Right,
                    Size = UDim2.new(0, 25, 0, 25),
                    Image = Icon and Library:Asset(Icon) or "rbxassetid://130050888244501",
                    ImageTransparency = 0.5,
                })

                local Click = Library:Button(Template.Frame)

                local function OnTouch()
                    if Library:IsDropdownOpen(Window_1) then return end
                    task.spawn(Library.Effect, Click, Template.Frame)
                    Callback()
                end

                Click.MouseButton1Click:Connect(OnTouch)

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

                local Background_1 = Library:Create("Frame", {
                    BackgroundColor3 = Color3.fromRGB(16, 16, 16),
                    Name = "Background",
                    Parent = Template.Right,
                    Size = UDim2.new(0, 23, 0, 23),
                    Selectable = false,
                    BackgroundTransparency = 0.45
                })

                Library:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = Background_1,
                })

                local OnValue_1 = Library:Create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(234, 234, 234),
                    Name = "OnValue",
                    Parent = Background_1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    Selectable = false,
                    BackgroundTransparency = 1,
                })

                Library:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = OnValue_1,
                })

                local ImageLabel_1 = Library:Create("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Parent = OnValue_1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0.6000000238418579, 0, 0.6000000238418579, 0),
                    Image = "rbxassetid://121742282171603",
                    ImageColor3 = Color3.fromRGB(0, 0, 0),
                    ImageContent = Content.fromUri("rbxassetid://121742282171603"),
                    Transparency = 1,
                })

                local function OnChanged(value)
                    if value then
                        Callback(Value)
                        Library:Tween({v = OnValue_1, t = 0.5, s = "Exponential", d = "Out", g = {BackgroundTransparency = 0}}):Play()
                        Library:Tween({v = ImageLabel_1, t = 0.5, s = "Exponential", d = "Out", g = {ImageTransparency = 0}}):Play()
                    else
                        Callback(Value)
                        Library:Tween({v = OnValue_1, t = 0.5, s = "Exponential", d = "Out", g = {BackgroundTransparency = 1}}):Play()
                        Library:Tween({v = ImageLabel_1, t = 0.5, s = "Exponential", d = "Out", g = {ImageTransparency = 1}}):Play()
                    end
                end

                local function Init()
                    if Library:IsDropdownOpen(Window_1) then return end

                    task.spawn(Library.Effect, Click, Template.Frame)
                    Value = not Value
                    OnChanged(Value)
                end

                Click.MouseButton1Click:Connect(Init)

                OnChanged(Value)

                return Template
            end

            function Tab:Slider(Info)
                local Title = Info.Title or "Slider"
                local Min = Info.Min or 0
                local Max = Info.Max or 100
                local Rounding = Info.Rounding or 0
                local Value = Info.Value or Min
                local Callback = Info.Callback or function() end

                local Slider_1 = Library:Create("Frame", {
                    BackgroundTransparency = 1,
                    Name = "Slider",
                    Parent = PageScrolling_1,
                    Size = UDim2.new(1, 0, 0, 50),
                    Selectable = false,
                })

                Library:Create("ImageLabel", {
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
                    BackgroundTransparency = 0.45
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
                        g = {Size = UDim2.new(ratio, 0, 1, 0)}
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

                local ClickButton = Library:Button(Slider_1)
                Textbox_1.ZIndex = ClickButton.ZIndex + 1

                ClickButton.InputBegan:Connect(function(input)
                    if Library:IsDropdownOpen(Window_1) then return end

                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateSlider(GetValueFromInput(input))
                    end
                end)

                ClickButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if Library:IsDropdownOpen(Window_1) then return end

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

            function Tab:Dropdown(Info)
                local Title = Info.Title or "Dropdown"
                local List = Info.List or {}
                local Value = Info.Value
                local Callback = Info.Callback or function() end

                local Setting = {}

                local IsMulti = typeof(Value) == "table"

                local Template = Library:Template({
                    Title = Title,
                    Description = "N/A",
                    Parent = PageScrolling_1,
                })

                Library:Create("ImageLabel", {
                    BackgroundTransparency = 1,
                    Parent = Template.Right,
                    Size = UDim2.new(0, 20, 0, 20),
                    Image = Library:Asset(132291592681506),
                    ImageTransparency = 0.5,
                })

                local Open = Library:Button(Template.Frame)

                local Dropdown_1 = Library:Create("ImageLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundTransparency = 1,
                    Name = "Dropdown",
                    Parent = Window_1,
                    Position = UDim2.new(1, 0, 0, 50),
                    Size = UDim2.new(0, 150, 1, -70),
                    Image = "rbxassetid://80999662900595",
                    ImageColor3 = Color3.fromRGB(16, 16, 16),
                    ImageContent = Content.fromUri("rbxassetid://80999662900595"),
                    ImageTransparency = 0.10,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(256, 256, 256, 256),
                    SliceScale = 0.04,
                    Visible = false,
                })

                local Scale_dd = Library:Create("Frame", {
                    BackgroundTransparency = 1,
                    Name = "Scale",
                    Parent = Dropdown_1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Selectable = false,
                })

                local Scrolling_dd = Library:Create("ScrollingFrame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Name = "Scrolling",
                    Parent = Scale_dd,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ScrollBarThickness = 0,
                    Selectable = false,
                })

                local UIListLayout_dd = Library:Create("UIListLayout", {
                    Padding = UDim.new(0, 4),
                    Parent = Scrolling_dd,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                Library:Create("UIPadding", {
                    Parent = Scrolling_dd,
                    PaddingBottom = UDim.new(0, 5),
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                })

                UIListLayout_dd:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    Scrolling_dd.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_dd.AbsoluteContentSize.Y + 10)
                end)

                local selectedValues = {}
                local selectedOrder = 0
                local isOpen = false

                local function isValueInTable(val, tbl)
                    if type(tbl) ~= "table" then return false end
                    for _, v in pairs(tbl) do
                        if v == val then return true end
                    end
                    return false
                end

                local function Settext()
                    if IsMulti then
                        local keys = {}
                        for k in pairs(selectedValues) do table.insert(keys, k) end
                        table.sort(keys)
                        Template.Description.Text = #keys > 0 and table.concat(keys, ", ") or "N/A"
                    else
                        Template.Description.Text = Value and tostring(Value) or "N/A"
                    end
                end

                UserInputService.InputBegan:Connect(function(A)
                    if not isOpen then return end
                    local mouse = LocalPlayer:GetMouse()
                    local mx, my = mouse.X, mouse.Y
                    local DBP, DBS = Dropdown_1.AbsolutePosition, Dropdown_1.AbsoluteSize
                    if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
                        if not (mx >= DBP.X and mx <= DBP.X + DBS.X and my >= DBP.Y and my <= DBP.Y + DBS.Y) then
                            isOpen = false
                            Dropdown_1.Position = UDim2.new(1, 0, 0, 50)
                            Dropdown_1.Visible = false
                        end
                    end
                end)

                Open.MouseButton1Click:Connect(function()
                    if Library:IsDropdownOpen(Window_1) then return end

                    isOpen = not isOpen

                    if isOpen then
                        Dropdown_1.Visible = true
                        Library:Tween({v = Dropdown_1, t = 0.2, s = "Quad", d = "Out", g = {Position = UDim2.new(1, -25, 0, 50)}}):Play()
                    else
                        Dropdown_1.Position = UDim2.new(1, 0, 0, 50)
                        Dropdown_1.Visible = false
                    end
                end)

                function Setting:Clear(filter)
                    for _, v in ipairs(Scrolling_dd:GetChildren()) do
                        if v:IsA("Frame") and v.Name == "NewList" then
                            local shouldClear = filter == nil
                                or (type(filter) == "string" and v.Scale.Title.Text == filter)
                                or (type(filter) == "table" and isValueInTable(v.Scale.Title.Text, filter))
                            if shouldClear then v:Destroy() end
                        end
                    end

                    if filter == nil then
                        Value = IsMulti and {} or nil
                        selectedValues = {}
                        selectedOrder = 0
                        Template.Description.Text = "N/A"
                    end
                end

                function Setting:AddList(Name)
                    local NewList_1 = Library:Create("Frame", {
                        BackgroundTransparency = 1,
                        Name = "NewList",
                        Parent = Scrolling_dd,
                        Size = UDim2.new(1, 0, 0, 30),
                        Selectable = false,
                    })

                    local Background_nl = Library:Create("ImageLabel", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Name = "Background",
                        Parent = NewList_1,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 1, 0),
                        Image = "rbxassetid://80999662900595",
                        ImageContent = Content.fromUri("rbxassetid://80999662900595"),
                        ImageTransparency = 1,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(256, 256, 256, 256),
                        SliceScale = 0.03,
                    })

                    local Scale_nl = Library:Create("Frame", {
                        BackgroundTransparency = 1,
                        Name = "Scale",
                        Parent = NewList_1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Selectable = false,
                    })

                    Library:Create("UIListLayout", {
                        Padding = UDim.new(0, 9),
                        Parent = Scale_nl,
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    })

                    local Title_nl = Library:Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Name = "Title",
                        Parent = Scale_nl,
                        Size = UDim2.new(1, 0, 0, 15),
                        Selectable = false,
                        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = Name,
                        TextColor3 = Color3.fromRGB(234, 234, 234),
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTransparency = 0.5,
                    })

                    Library:Create("UIPadding", {
                        Parent = Scale_nl,
                        PaddingBottom = UDim.new(0, 10),
                        PaddingLeft = UDim.new(0, 15),
                        PaddingRight = UDim.new(0, 15),
                        PaddingTop = UDim.new(0, 10),
                    })

                    local function OnVisual(selected)
                        Library:Tween({v = Background_nl, t = 0.2, s = "Linear", d = "Out", g = {ImageTransparency = selected and 0.93 or 1}}):Play()
                        Library:Tween({v = Title_nl, t = 0.2, s = "Linear", d = "Out", g = {TextTransparency = selected and 0.1 or 0.5}}):Play()
                    end

                    local Click = Library:Button(NewList_1)

                    local function OnSelected()
                        if IsMulti then
                            if selectedValues[Name] then
                                selectedValues[Name] = nil
                                NewList_1.LayoutOrder = 0
                                OnVisual(false)
                            else
                                selectedOrder = selectedOrder - 1
                                selectedValues[Name] = selectedOrder
                                NewList_1.LayoutOrder = selectedOrder
                                OnVisual(true)
                            end

                            local selectedList = {}
                            for k in pairs(selectedValues) do table.insert(selectedList, k) end
                            table.sort(selectedList)
                            Value = selectedList
                            Settext()
                            pcall(Callback, selectedList)
                        else
                            for _, v in pairs(Scrolling_dd:GetChildren()) do
                                if v:IsA("Frame") and v.Name == "NewList" and v ~= NewList_1 then
                                    Library:Tween({v = v.Background, t = 0.2, s = "Linear", d = "Out", g = {ImageTransparency = 1}}):Play()
                                    Library:Tween({v = v.Scale.Title, t = 0.2, s = "Linear", d = "Out", g = {TextTransparency = 0.5}}):Play()
                                end
                            end

                            OnVisual(true)
                            Value = Name
                            Settext()
                            pcall(Callback, Value)
                        end
                    end

                    task.defer(function()
                        if IsMulti then
                            if isValueInTable(Name, Value) then
                                selectedOrder = selectedOrder - 1
                                selectedValues[Name] = selectedOrder
                                NewList_1.LayoutOrder = selectedOrder
                                OnVisual(true)
                                local selectedList = {}
                                for k in pairs(selectedValues) do table.insert(selectedList, k) end
                                table.sort(selectedList)
                                Settext()
                                pcall(Callback, selectedList)
                            end
                        else
                            if Name == Value then
                                OnVisual(true)
                                Settext()
                                pcall(Callback, Value)
                            end
                        end
                    end)

                    Click.MouseButton1Click:Connect(OnSelected)
                end

                for _, name in ipairs(List) do
                    Setting:AddList(name)
                end

                return Setting
            end

            function Tab:Textbox(Info)
                local Title = Info.Title
                local Description = Info.Description
                local Value = Info.Value or "N/A"
                local PlaceHolder = Info.PlaceHolder or "..."
                local Callback = Info.Callback or function( ... ) return ... end

                local Templete = Library:Template({
                    Title = Title,
                    Description = Description,
                    Parent = PageScrolling_1
                })

                local Background_1 = Instance.new("Frame")
                local UICorner_1 = Instance.new("UICorner")
                local TextBox_1 = Instance.new("TextBox")

                Background_1.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
                Background_1.BackgroundTransparency = 0.45
                Background_1.Name = "Background"
                Background_1.Parent = Templete.Right
                Background_1.Size = UDim2.new(0, 100, 0, 23)
                Background_1.Selectable = false

                UICorner_1.CornerRadius = UDim.new(0, 6)
                UICorner_1.Parent = Background_1

                TextBox_1.AnchorPoint = Vector2.new(0.5, 0.5)
                TextBox_1.BackgroundTransparency = 1
                TextBox_1.Parent = Background_1
                TextBox_1.Position = UDim2.new(0.5, 0, 0.5, 0)
                TextBox_1.Size = UDim2.new(1, -20, 1, 0)
                TextBox_1.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                TextBox_1.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
                TextBox_1.PlaceholderText = tostring(PlaceHolder)
                TextBox_1.Text = tostring(Value)
                TextBox_1.TextColor3 = Color3.fromRGB(234, 234, 234)
                TextBox_1.TextSize = 11
                TextBox_1.TextTruncate = Enum.TextTruncate.AtEnd
                TextBox_1.TextXAlignment = Enum.TextXAlignment.Right

                TextBox_1.FocusLost:Connect(function()
                    if TextBox_1.Text ~= "" then
                        Callback(TextBox_1.Text)
                    end
                end)
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
            Library:Tween({v = Template_1, t = 0.2, s = "Quad", d = "Out", g = {BackgroundTransparency = 0.95}}):Play()
        end)

        Template_1.MouseLeave:Connect(function()
            Library:Tween({v = Template_1, t = 0.2, s = "Quad", d = "Out", g = {BackgroundTransparency = 1}}):Play()
        end)

        Click.MouseButton1Click:Connect(Callback)
    end

    function Window:TweenSize(Target)
        Library:Tween({v = Window_1, t = 0.2, s = "Exponential", d = "Out", g = {Size = Target}}):Play()
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
        local IsWindowOpen = false

        local function ToggleBlur()
            if IsWindowOpen then
                Blur = Library:BlurFrame(Background_1)
            else
                Blur.Destroy()
            end
        end

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
                Text = "",
                BackgroundTransparency = 0.25
            })

            Library:Create("UICorner", {
                Parent = Pillow_1,
                CornerRadius = UDim.new(0, 14)
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
                IsWindowOpen = not IsWindowOpen
                Window_1.Visible = IsWindowOpen
                ToggleBlur()
            end)

            UserInputService.InputBegan:Connect(function(Input, Processed)
                if Processed then return end

                if Input.KeyCode == Enum.KeyCode.LeftControl then
                    IsWindowOpen = not IsWindowOpen
                    Window_1.Visible = IsWindowOpen
                    ToggleBlur()
                end
            end)
        end

        local TopRightButton = {
            [106352522036205] = {
                Order = 997,
                Size = UDim2.new(0, 20, 0, 20),
                Callback = function()
                    IsWindowOpen = not IsWindowOpen
                    Window_1.Visible = IsWindowOpen
                    ToggleBlur()
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
                            g = {Size = UDim2.new(0, MaxVec.X, 0, CurY)}
                        })
                        TweenX:Play()
                        TweenX.Completed:Wait()

                        Library:Tween({
                            v = Window_1,
                            t = 0.2,
                            s = "Exponential",
                            d = "Out",
                            g = {Size = CurrentMaximize}
                        }):Play()
                    else
                        local TweenY = Library:Tween({
                            v = Window_1,
                            t = 0.2,
                            s = "Exponential",
                            d = "Out",
                            g = {Size = UDim2.new(0, CurX, 0, MinVec.Y)}
                        })
                        TweenY:Play()
                        TweenY.Completed:Wait()

                        Library:Tween({
                            v = Window_1,
                            t = 0.2,
                            s = "Exponential",
                            d = "Out",
                            g = {Size = Minimize}
                        }):Play()
                    end
                end,
            },
            [126518941777580] = {
                Order = 999,
                Size = UDim2.new(0, 20, 0, 20),
                Callback = function()
                    Cosmic_1:Destroy()
                    Blur.Destroy()
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

--local Window = Library:App({
--    Title = "Xynapse",
--    Footer = "Made by vita6it",
--    Logo = 124715602753920,
--    Transparent = 0.1,
--    Width = 180,
--    Size = UDim2.new(0, 500, 0, 360),
--    Minimize = UDim2.new(0, 500, 0, 360),
--})

--Window:Tags("Premium", Color3.fromRGB(255, 255, 0))
--Window:Tags("Freemium", Color3.fromRGB(255, 255, 255))

--local Tab1 = Window:MakeTab({
--    Title = "Main",
--    Icon = 111555399052168,
--})

--local Tab2 = Window:MakeTab({
--    Title = "Settings",
--    Icon = 115960025411300,
--})

--Tab1:Select()

--Tab1:Section("General")

--Tab1:Label({
--    Title = "Hello World",
--    Description = "This is a label",
--})

--Tab1:Button({
--    Title = "Click Me",
--    Description = "Prints hello",
--    Callback = function()
--        print("Hello!")
--    end,
--})

--local MyToggle = Tab1:Toggle({
--    Title = "God Mode",
--    Description = "Enable god mode",
--    Value = false,
--    Callback = function(value)
--        print("Toggle:", value)
--    end,
--})

--Tab1:Slider({
--    Title = "Speed",
--    Min = 0,
--    Max = 100,
--    Value = 16,
--    Rounding = 0,
--    Callback = function(value)
--        print("Speed:", value)
--    end,
--})

--local MyDropdown = Tab1:Dropdown({
--    Title = "Select Game",
--    List = {"Bloxburg", "Arsenal", "Adopt Me"},
--    Value = "Arsenal",
--    Callback = function(value)
--        print("Selected:", value)
--    end,
--})

--local MyMultiDropdown = Tab2:Dropdown({
--    Title = "Select Multiple",
--    List = {"Option A", "Option B", "Option C"},
--    Value = {"Option A", "Option B"},
--    Callback = function(value)
--        print("Selected:", table.concat(value, ", "))
--    end,
--})

--Tab2:Button({
--    Title = "Add to Dropdown",
--    Callback = function()
--        MyDropdown:AddList("New Game")
--    end,
--})

--Tab2:Button({
--    Title = "Clear Dropdown",
--    Callback = function()
--        MyDropdown:Clear()
--    end,
--})

--Tab2:Slider({
--    Title = "Walkspeed",
--    Min = 16,
--    Max = 500,
--    Value = 16,
--    Rounding = 1,
--    Callback = function(value)

--    end,
--})

--Tab2:Slider({
--    Title = "JumpPower",
--    Min = 0,
--    Max = 500,
--    Value = 50,
--    Rounding = 0,
--    Callback = function(value)

--    end,
--})

--Tab2:Toggle({
--    Title = "Infinite Jump",
--    Value = false,
--    Callback = function(value)
--        _G.InfiniteJump = value
--    end,
--})

--Tab1:Textbox({
--    Title = "Textbox",
--    Description = "Enable god mode",
--    Value = "Hello",
--    Callback = function(value)
--        print("Toggle:", value)
--    end,
--})

return Library
