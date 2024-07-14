--[[

	Written by makkara because wave lib is slow

]]--

--// Services
local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local GuiService  = game:GetService("GuiService")
local TextService = game:GetService("TextService")

--// Variables
local Player = Players.LocalPlayer
local Mouse  = Player:GetMouse()

local UI = Instance.new("ScreenGui")
UI.IgnoreGuiInset = true
UI.Parent = Player.PlayerGui

local Drawing = {}
Drawing.Fonts = {
	"Arial";
	"HighwayGothic";
	"Roboto";
	"Ubuntu";
}

local AngleTable = {}
for i = 0, 359, 0.5 do
	local rad = math.rad(i)
	AngleTable[i] = {
		sin = math.sin(rad),
		cos = math.cos(rad)
	}
end

local function findClosestAngleIndex(directionX, directionY)
	local maxDot 	= -1
	local bestAngle = 0

	for angle, values in AngleTable do
		local dot = directionX * values.cos + directionY * values.sin
		
		if dot <= maxDot then
			continue
		end
		
		maxDot = dot
		bestAngle = angle
	end

	return bestAngle
end

local function Line()
	local Base = {
		Visible 	 = true;
		Color 		 = Color3.new(1,1,1);
		Transparency = 0;
		Thickness 	 = 1;
		To 		 	 = nil;
		From 		 = nil;
		PreviousTo   = nil;
		PreviousFrom = nil;
		LastDistance = 0;
	}
	
	local LineF = Instance.new("Frame")
	LineF.BackgroundTransparency = Base.Transparency
	LineF.BackgroundColor3 = Base.Color
	LineF.BorderSizePixel  = 0
	LineF.AnchorPoint	   = Vector2.new(0.5, 0.5)
	LineF.Visible = Base.Visible
	LineF.Size    = UDim2.new()
	LineF.Parent  = UI
	
	local function UpdateLine(Property)
		if Property == "To" or Property == "From" then
			
			-- Only update when both are set
			if Base.To == nil or Base.From == nil then
				return
			end
			
			-- Don't update if the values haven't actually changed
			if Base.To == Base.PreviousTo and Base.From == Base.PreviousFrom then
				return
			end
			
			-- No need to update if its not even visible
			if not Base.Visible then
				return
			end
			
			local DirectionX = Base.To.X  - Base.From.X
			local DirectionY = Base.To.Y  - Base.From.Y
			local CenterX 	 = (Base.To.X + Base.From.X) / 2
			local CenterY 	 = (Base.To.Y + Base.From.Y) / 2
			local Distance 	 = math.sqrt(DirectionX * DirectionX + DirectionY * DirectionY)
			
			local bestAngle  = findClosestAngleIndex(DirectionX, DirectionY)
			LineF.Position = UDim2.fromOffset(CenterX, CenterY)
			LineF.Rotation = bestAngle
			LineF.Size = UDim2.fromOffset(Distance, Base.Thickness)
			
			Base.PreviousTo   = Base.To
			Base.PreviousFrom = Base.From
			Base.LastDistance = Distance
		
		elseif Property == "Visible" then
			LineF.Visible = Base.Visible
			
			if Base.Visible then
				UpdateLine("To") -- Update line if visible was enabled
			end
		elseif Property == "Thickness" then
			LineF.Size = UDim2.fromOffset(Base.LastDistance, Base.Thickness)
		elseif Property == "Transparency" then
			LineF.BackgroundTransparency = Base.Transparency
		elseif Property == "Color" then
			LineF.BackgroundColor3 = Base.Color
		end
	end
	
	local Options = setmetatable({
		Remove = function()
			LineF:Destroy()
			Base = nil;
		end,	
	}, {
		__newindex = function(t1, Property, Value)
			rawset(Base, Property, Value)
			
			UpdateLine(Property)
		end,
	})
	
	
	return (Options)
end

local function Triangle()
	local Base = {
		Visible 	 = true;
		Color 		 = Color3.new(1,1,1);
		Transparency = 0;
		Thickness 	 = 1;
		PointA		 = nil;
		PointB		 = nil;
		PointC		 = nil;
		Lines = {
			PointA = 0;
			PointB = 0;
			PointC = 0;
		};
	}
	
	local function UpdateTriangle(Property)
		for LineName, Line in Base.Lines do
			local Line = typeof(Base.Lines[LineName]) == 'table' and Base.Lines[LineName] or Drawing.new("Line")
			
			if Base.Lines[Property] then -- If modifying a point position
				local To = LineName == "PointA" and "PointB" or LineName == "PointB" and "PointC" or "PointA"
				Line.From = Base[LineName]
				Line.To   = Base[To]
			elseif Property == "Visible" then
				Line.Visible = Base.Visible
				if Base.Visible then
					UpdateTriangle("PointA")
				end
			else
				Line[Property] = Base[Property]
			end
			
			Base.Lines[LineName] = Line
		end
		
	end
	
	local Options = setmetatable({
		Remove = function()
			for _, Line in Base.Lines do
				Line:Remove()
			end
			Base = nil;
		end,	
	}, {
		__newindex = function(t1, Property, Value)
			rawset(Base, Property, Value)

			UpdateTriangle(Property)
		end,
	})


	return (Options)
end

local function Quad()
	local Base = {
		Visible 	 = true;
		Color 		 = Color3.new(1,1,1);
		Transparency = 0;
		Thickness 	 = 1;
		PointA		 = nil;
		PointB		 = nil;
		PointC		 = nil;
		PointD		 = nil;
		Lines = {
			PointA = 0;
			PointB = 0;
			PointC = 0;
			PointD = 0;
		};
	}
	
	local function UpdateQuad(Property)
		for LineName, Line in Base.Lines do
			local Line = typeof(Base.Lines[LineName]) == 'table' and Base.Lines[LineName] or Drawing.new("Line")

			if Base.Lines[Property] then -- If modifying a point position
				local To = LineName == "PointA" and "PointB" or LineName == "PointB" and "PointC" or LineName == "PointC" and "PointD" or "PointA"
				Line.From = Base[LineName]
				Line.To   = Base[To]
			else
				Line[Property] = Base[Property]
			end

			Base.Lines[LineName] = Line
		end

	end

	local Options = setmetatable({
		Remove = function()
			for _, Line in Base.Lines do
				Line:Remove()
			end
			Base = nil;
		end,	
	}, {
		__newindex = function(t1, Property, Value)
			rawset(Base, Property, Value)
			
			UpdateQuad(Property)
		end,
	})

	return (Options)
end

local function Square()
	local Base = {
		Visible 	 = true;
		Color 		 = Color3.new(1,1,1);
		FilledColor  = Color3.new(1,1,1);
		Transparency = 0;
		Thickness 	 = 1;
		Size 		 = nil;
		Position	 = nil;
		Filled 		 = false;
		FilledTransparency = 0;
	}
	
	local Square = Instance.new("Frame")
	Square.AnchorPoint 	   = Vector2.new(0.5, 0.5)
	Square.BorderSizePixel = 0
	Square.Size 		   = UDim2.fromOffset(45, 45)
	Square.Position		   = UDim2.fromScale(0.5, 0.5)
	Square.Transparency    = Base.Filled and Base.FilledTransparency or 1
	
	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness 	   = Base.Thickness
	Stroke.Transparency    = Base.Transparency
	Stroke.Color 		   = Base.Color
	Stroke.Parent		   = Square
	
	Square.Parent = UI
	
	-- Switched to this style half way through and not changing others. womp womp idc
	local Properties = {
		FilledTransparency = function()
			Square.Transparency     = Base.Filled and Base.FilledTransparency or 1
		end,
		FilledColor = function()
			Square.BackgroundColor3 = Base.FilledColor
		end,
		Transparency = function()
			Stroke.Transparency    = Base.Transparency
		end,
		Thickness = function()
			Stroke.Thickness       = Base.Thickness
		end,
		Color = function()
			Stroke.Color  		   = Base.Color
		end,
		Filled = function()
			Square.Transparency    = Base.Filled and Base.FilledTransparency or 1
		end,
		Size = function()
			Square.Size			   = UDim2.fromOffset(Base.Size.X, Base.Size.Y)
		end,
		Position = function()
			Square.Position 	   = UDim2.fromOffset(Base.Position.X, Base.Position.Y)
		end
	}

	local function UpdateSquare(Property)
		if Properties[Property] then
			Properties[Property]()
		elseif Base[Property] ~= nil then
			Square[Property] = Base[Property]
		end
	end

	local Options = setmetatable({
		Remove = function()
			Square:Destroy()
			Base = nil;
		end,	
	}, {
		__newindex = function(t1, Property, Value)
			rawset(Base, Property, Value)

			UpdateSquare(Property)
		end,
	})

	return (Options)
end

local function Circle()
	local Base = {
		Visible 	 = true;
		Color 		 = Color3.new(1,1,1);
		FilledColor  = Color3.new(1,1,1);
		Transparency = 0;
		Thickness 	 = 1;
		Radius 		 = nil; -- Why do libs call this radius instead of diameter? it changes the diameter!
		Position	 = nil;
		Filled 		 = false;
		FilledTransparency = 0;
	}

	local Circle = Instance.new("Frame")
	Circle.AnchorPoint 	   = Vector2.new(0.5, 0.5)
	Circle.BorderSizePixel = 0
	Circle.Size 		   = UDim2.fromOffset(45, 45)
	Circle.Position		   = UDim2.fromScale(0.5, 0.5)
	Circle.Transparency    = Base.Filled and Base.FilledTransparency or 1

	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness 	   = Base.Thickness
	Stroke.Transparency    = Base.Transparency
	Stroke.Color 		   = Base.Color
	Stroke.Parent		   = Circle
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(1, 0)
	Corner.Parent 		= Circle

	Circle.Parent = UI

	local Properties = {
		FilledTransparency = function()
			Circle.Transparency     = Base.Filled and Base.FilledTransparency or 1
		end,
		FilledColor = function()
			Circle.BackgroundColor3 = Base.FilledColor
		end,
		Transparency = function()
			Stroke.Transparency    = Base.Transparency
		end,
		Thickness = function()
			Stroke.Thickness       = Base.Thickness
		end,
		Color = function()
			Stroke.Color  		   = Base.Color
		end,
		Filled = function()
			Circle.Transparency    = Base.Filled and Base.FilledTransparency or 1
		end,
		Radius = function()
			Circle.Size			   = UDim2.fromOffset(Base.Radius, Base.Radius)
		end,
		Position = function()
			Circle.Position 	   = UDim2.fromOffset(Base.Position.X, Base.Position.Y)
		end
	}

	local function UpdateCircle(Property)
		if Properties[Property] then
			Properties[Property]()
		elseif Base[Property] ~= nil then
			Circle[Property] = Base[Property]
		end
	end

	local Options = setmetatable({
		Remove = function()
			Base = nil;
			Circle:Destroy();
		end,	
	}, {
		__newindex = function(t1, Property, Value)
			rawset(Base, Property, Value)

			UpdateCircle(Property)
		end,
	})

	return (Options)
end

local function Text()
	local Base = {
		Visible 	 = true;
		Text		 = "TextLabel";
		Transparency = 0;
		Size 		 = 18;
		Center 		 = false;
		Color		 = Color3.new(1,1,1);
		Outline 	 = false;
		OutlineColor = Color3.new(0,0,0);
		Position 	 = nil;
		Font 		 = 0;
	}

	local Text = Instance.new("TextLabel")
	local Bounds = TextService:GetTextSize(Base.Text, Base.Size, Drawing.Fonts[Base.Font + 1], Vector2.new(1920, 1080))
	Text.AnchorPoint 	  = Base.Center and Vector2.new(0.5, 0.5) or Vector2.new(0, 0)
	Text.Text 			  = Base.Text
	Text.Size 		      = UDim2.fromOffset(Bounds.X, Bounds.Y)
	Text.Position		  = UDim2.fromScale(0.5, 0.5)
	Text.Transparency     = Base.Filled and Base.FilledTransparency or 1
	Text.Font 			  = Enum.Font[Drawing.Fonts[Base.Font + 1]]
	Text.TextSize 		  = Base.Size
	Text.TextColor3       = Base.Color
	Text.TextTransparency = Base.Transparency
	Text.TextStrokeColor3 = Base.OutlineColor
	Text.TextStrokeTransparency = Base.Outline and 0 or 1
	Text.BackgroundTransparency = 1
	Text.Parent = UI

	-- Switched to this style half way through and not changing others. womp womp idc
	local Properties = {
		Position = function()
			Text.Position = UDim2.fromOffset(Base.Position.X, Base.Position.Y)
		end,
		Color = function()
			Text.TextColor3 = Base.Color
		end,
		Size = function()
			Text.TextSize = Base.Size
		end,
		Transparency = function()
			Text.TextTransparency = Base.Transparency
		end,
		Center = function()
			Text.AnchorPoint = Base.Center and Vector2.new(0.5, 0.5) or Vector2.new(0, 0)
			Text.TextXAlignment = Base.Center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
			Text.TextYAlignment = Base.Center and Enum.TextYAlignment.Center or Enum.TextYAlignment.Top
		end,
		Outline = function()
			Text.TextStrokeTransparency = Base.Outline and 0 or 1
		end,
		OutlineColor = function()
			Text.TextStrokeColor3 = Base.OutlineColor
		end,
		Font = function()
			Text.Font = Enum.Font[Drawing.Fonts[Base.Font + 1]]
		end,
		
	}

	local function UpdateText(Property)
		if Properties[Property] then
			Properties[Property]()
		elseif Base[Property] ~= nil then
			Text[Property] = Base[Property]
		end
	end

	local Options = setmetatable({
		Remove = function()
			Text:Destroy()
			Base = nil;
		end,	
	}, {
		__newindex = function(t1, Property, Value)
			rawset(Base, Property, Value)

			UpdateText(Property)
		end,
		__index = function(t1, Property)
			if Property == "TextBounds" then
				return TextService:GetTextSize(Base.Text, Base.Size, Enum.Font[Drawing.Fonts[Base.Font + 1]], Vector2.new(1920, 1080))
			end
		end,
	})

	return (Options)
end

Drawing.Types = {
	["Line"] 	 = Line;
	["Triangle"] = Triangle;
	["Quad"]	 = Quad;
	["Square"]	 = Square;
	["Circle"]	 = Circle;
	["Text"]	 = Text;
}

function Drawing.new(Type: string)
	assert(Drawing.Types[Type], `{Type} is not a valid Drawing type`)
	return Drawing.Types[Type]()
end

--// Example for testing
--[==[
	local TargetFold = workspace.EspTargets
	for i = 1, 60 do
		local Part = Instance.new("Part")
		Part.Anchored = true
		Part.Size = Vector3.new(1.5, 1.5, 1.5)
		Part.Position = Vector3.new(15 - i*15, 4, 10)
		Part.Parent = TargetFold
	end

	local Camera = workspace.CurrentCamera

	local Targets = {
		Squares = {};
		Lines = {};
		Quads = {};
		Texts = {};
	}
	local lastUpdate = 0
	local frameInterval = 1 / 60

	RunService.PreSimulation:Connect(function()
		local currentTime = os.clock()
		if currentTime - lastUpdate < frameInterval then
			return
		end
		lastUpdate = currentTime
		
		for _, Target in TargetFold:GetChildren() do
			-- Line Test
			if not Targets.Lines[Target] then
				local Line = Drawing.new("Line")
				Line.Visible = false
				Line.Color = Color3.fromRGB(80, 80, 255)
				Line.Thickness = 2
				Line.Transparency = 0.25
				
				Targets.Lines[Target] = Line
			end

			local Pos2d, OnScreen = Camera:WorldToViewportPoint(Target.Position)
			
			local Line   = Targets.Lines[Target]
			Line.Visible = OnScreen
			Line.From = Vector2.new(Mouse.X, Mouse.Y) + GuiService:GetGuiInset()
			Line.To   = Vector2.new(Pos2d.X, Pos2d.Y)
			
			-- Triangle Test
			--[[
				if not Targets[Target] then
					local Triangle = Drawing.new("Triangle")
					Triangle.Visible = false
					Triangle.Color = Color3.fromRGB(80, 80, 255)
					Triangle.Thickness = 2
					Triangle.Transparency = 0

					Targets[Target] = Triangle
				end
				
				local Pos2d, OnScreen = Camera:WorldToViewportPoint(Target.Position)
				local Triangle = Targets[Target]
				Pos2d = Vector2.new(Pos2d.X, Pos2d.Y)
				
				Triangle.Visible = OnScreen
				Triangle.PointA = Pos2d + Vector2.new(0, -35)
				Triangle.PointB = Pos2d + Vector2.new(-35, 35)
				Triangle.PointC = Pos2d + Vector2.new(35, 35)
			]]
			
			-- Quad Test
			--[[
				if not Targets[Target] then
					local Quad = Drawing.new("Quad")
					Quad.Visible = false
					Quad.Color = Color3.fromRGB(80, 80, 255)
					Quad.Thickness = 2
					Quad.Transparency = 0

					Targets[Target] = Quad
				end
				
				local Pos2d, OnScreen = Camera:WorldToViewportPoint(Target.Position)
				local Quad = Targets[Target]
				Pos2d = Vector2.new(Pos2d.X, Pos2d.Y)
				
				Quad.Visible = OnScreen
				Quad.PointA = Pos2d + Vector2.new(-35, -35)
				Quad.PointB = Pos2d + Vector2.new(-35, 35)
				Quad.PointC = Pos2d + Vector2.new(35, 35)
				Quad.PointD = Pos2d + Vector2.new(35, -35)
			]]
			
			-- Square Test
			if not Targets.Squares[Target] then
				local Square = Drawing.new("Square")
				Square.Visible = false
				Square.Color = Color3.fromRGB(80, 80, 255)
				Square.Thickness = 2
				Square.Transparency = 0

				Targets.Squares[Target] = Square
			end
			
			local Pos2d, OnScreen = Camera:WorldToViewportPoint(Target.Position)
			local Square = Targets.Squares[Target]
			
			Square.Visible  = OnScreen
			Square.Size 	= Vector2.new(55, 55) * 100 / (Target.Position - Camera.CFrame.Position).Magnitude
			Square.Position = Vector2.new(Pos2d.X, Pos2d.Y)
			Square.Filled   = false
			Square.FilledColor = Color3.fromRGB(53, 255, 137)
			Square.FilledTransparency = 0.5
			
			-- Circle Test
			--[[
			if not Targets[Target] then
					local Circle = Drawing.new("Circle")
					Circle.Visible = false
					Circle.Color = Color3.fromRGB(80, 80, 255)
					Circle.Thickness = 2
					Circle.Transparency = 0

					Targets[Target] = Circle
				end
				
				local Pos2d, OnScreen = Camera:WorldToViewportPoint(Target.Position)
				local Circle = Targets[Target]
				
				Circle.Visible = OnScreen
				Circle.Radius = 25
				Circle.Position = Vector2.new(Pos2d.X, Pos2d.Y)
				Circle.Filled = true
				Circle.FilledTransparency = 0.5
				Circle.FilledColor = Color3.fromRGB(53, 255, 137)
			]]
			
			-- Text Test
			if not Targets.Texts[Target] then
				local Text = Drawing.new("Text")
				Text.Visible = false
				Text.Color = Color3.fromRGB(255, 64, 67)
				Text.Transparency = 0

				Targets.Texts[Target] = Text
			end
			
			local Pos2d, OnScreen = Camera:WorldToViewportPoint(Target.Position)
			local Text = Targets.Texts[Target]
			
			Text.Visible = OnScreen
			Text.Position = Vector2.new(Pos2d.X, Pos2d.Y)
			Text.Outline = true
			Text.Text = Target.Name
			Text.Center = false
			Text.Font = 0
			Text.Size = 4000 / (Target.Position - Camera.CFrame.Position).Magnitude
		end
	end)
]==]

return Drawing
