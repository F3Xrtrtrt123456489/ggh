--	Functions.Notify({Title = "Used For Notifications."})
local LoadStart = tick()
if shared.Hastelepasta then return end
shared.Hastelepasta = true
getgenv().Abysall = { Legit = true }

local BaseUrl = "https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/"
getgenv().Abysall = {
	Environment = loadstring(game:HttpGet(BaseUrl .. "Components/Environment.luau"))(),
	ESPLibrary = loadstring(game:HttpGet(BaseUrl .. "Components/ESP.luau"))(),
	["16Notice"] = loadstring(game:HttpGet(BaseUrl .. "Components/16Notice.luau"))(),
	Legit = true
}
local Abysall = getgenv().Abysall

local function CloneReference(Object)
	if Abysall and Abysall.Environment.cloneref then
		return Abysall.Environment.cloneref(Object)
	end
	return Object
end
local Services = setmetatable({}, {
	__index = function(Self, Name)
		return CloneReference(game:GetService(Name))
	end
})

if Abysall.Environment.writefile and Abysall.Environment.readfile then
	if not Abysall.Environment.isfile("Abysall/UserData.json") then
		local Data = { TotalExecutions = 0, UILibrary = "Obsidian" }
		Abysall.Environment.writefile("Abysall/UserData.json", Services.HttpService:JSONEncode(Data))
	end
	local UserData = Abysall.Environment.readfile("Abysall/UserData.json")
	local Decoded = Services.HttpService:JSONDecode(UserData)
	if not Decoded.TotalExecutions then Decoded.TotalExecutions = 0 end
	Decoded.TotalExecutions = Decoded.TotalExecutions + 1
	if not Decoded.UILibrary then Decoded.UILibrary = "Obsidian" end
	Abysall.TotalExecutions = Decoded.TotalExecutions
	Abysall.UILibrary = Decoded.UILibrary
	Abysall.Environment.writefile("Abysall/UserData.json", Services.HttpService:JSONEncode(Decoded))
end

Abysall.Interface = loadstring(game:HttpGet(BaseUrl .. "Components/Interface.luau"))()
Abysall.Analytics = loadstring(game:HttpGet(BaseUrl .. "Components/Analytics.luau"))()
Abysall.SavePath = "Doors/Game"

local Library = Abysall.Interface.Library
local SaveManager = Abysall.Interface.SaveManager
local ThemeManager = Abysall.Interface.ThemeManager
local Toggles = Library.Toggles
local Options = Library.Options

local Globals = {}
local Connections = {}
local ESPConnections = {}
local Groupboxes = {}
local FakePrompts = {}
local Functions = {}
local PartProperties = {}
local Objects = {
	Prompts = {}, Objectives = {}, Doors = {}, HidingSpots = {}, Entities = {},
	SeekObstructions = {}, Items = {}, Chests = {}, Currency = {}, Ladders = {},
	Misc = {}, Obstructions = {}, EventTriggers = {}, JumpscareModules = {},
	SeekHighlights = {}, EyestalkHighlights = {}, SeekNodes = {}, SeekDuckBoards = {},
	SeekBridges = {}, PathLights = {}
}

Globals.IncompatibleMessage = "你的执行器不支持此功能。"

Functions.CheckCompatability = function(Array)
	for _, Name in Array do
		if not Abysall.Environment[Name] then
			return false
		end
	end
	return true
end

local LocalPlayer = Services.Players.LocalPlayer
local PortraitName = "MirrorRig_Portrait_" .. LocalPlayer.Name

local Entities = {
	["TV_Stand"] = { Alias = "Noise_TV", NotifyMessage = { Title = "噪音电视已生成。", Body = "不要靠近它。" } },
	[PortraitName] = { Alias = "Portrait", NotifyMessage = { Title = "肖像已生成。", Body = "用它来复制物品。" } },
	["StemsEntity"] = { Alias = "球", NotifyMessage = { Title = "球", Body = "球。" } },
	["NoiseModel"] = { Alias = "噪音", NotifyMessage = { Title = "实体'噪音'已生成。", Body = "别让它碰到你。" } },
	["Creak"] = { Alias = "吱嘎", NotifyMessage = { Title = "实体'吱嘎'已生成。", Body = "别碰他。" } },
	["DronesStampede"] = { Alias = "无人机群", NotifyMessage = { Title = "实体'无人机群'已生成。", Body = "找个躲藏点。" } },
	["TellerRig"] = { Alias = "出纳", NotifyMessage = { Title = "实体'出纳'已生成。", Body = "别担心，他只是烦人。" } },
	["Scribbles"] = { Alias = "涂鸦", NotifyMessage = { Title = "实体'涂鸦'已生成。", Body = "找个躲藏点。" } },
	["BashMoving"] = { Alias = "猛冲", NotifyMessage = { Title = "实体'猛冲'已生成。", Body = "找个躲藏点。" } },
	["RushMoving"] = { Alias = "冲刺", NotifyMessage = { Title = "实体'冲刺'已生成。", Body = "找个躲藏点。" } },
	["AmbushMoving"] = { Alias = "伏击", NotifyMessage = { Title = "实体'伏击'已生成。", Body = "找个躲藏点。" } },
	["Eyes"] = { Alias = "眼睛", NotifyMessage = { Title = "实体'眼睛'已生成。", Body = "避免看着它。" } },
	["Lookman"] = { Alias = "眼睛", NotifyMessage = { Title = "实体'眼睛'已生成。", Body = "避免看着它。" } },
	["BackdoorRush"] = { Alias = "闪电", NotifyMessage = { Title = "实体'闪电'已生成。", Body = "找个躲藏点。" } },
	["BackdoorLookman"] = { Alias = "看门人", NotifyMessage = { Title = "实体'看门人'已生成。", Body = "避免看着它的眼睛。" } },
	["Groundskeeper"] = { Alias = "守园人", NotifyMessage = { Title = "实体'守园人'已生成。", Body = "避免踩到草地。" } },
	["A60"] = { Alias = "A-60", NotifyMessage = { Title = "实体'A-60'已生成。", Body = "找个躲藏点。" } },
	["A120"] = { Alias = "A-120", NotifyMessage = { Title = "实体'A-120'已生成。", Body = "找个躲藏点。" } },
	["GloombatSwarm"] = { Alias = "暗蝠群", NotifyMessage = { Title = "实体'暗蝠群'已生成。", Body = "保持所有光源关闭。" } },
	["GlitchRush"] = { Alias = "RNIUSHCG==", NotifyMessage = { Title = "实体'RNIUSHCG=='已生成。", Body = "找个躲藏点。" } },
	["GlitchAmbush"] = { Alias = "AR0xMBUSH", NotifyMessage = { Title = "实体'AR0xMBUSH'已生成。", Body = "找个躲藏点。" } },
	["MonumentEntity"] = { Alias = "纪念碑", NotifyMessage = { Title = "实体'纪念碑'已生成。", Body = "当你看着它时它无法移动。" } },
	["JeffTheKiller"] = { Alias = "杀手杰夫", NotifyMessage = { Title = "实体'杀手杰夫'已生成。", Body = "避免碰到他。" } },
	["CustomEntity"] = { Alias = "自定义实体", NotifyMessage = { Title = "实体'自定义实体'已生成。", Body = "找个躲藏点。" } },
	["FrozenAmbush"] = { Alias = "冰冻伏击", NotifyMessage = { Title = "实体'冰冻伏击'已生成。", Body = "找个躲藏点。" } },
	["SallyMoving"] = { Alias = "莎莉", NotifyMessage = { Title = "实体'莎莉'已生成。", Body = "找到她的马并绑住它。" } }
}

local EntityIcons = {
	["RushMoving"] = "rbxassetid://10716032262",
	["AmbushMoving"] = "rbxassetid://10110576663",
	["A60"] = "rbxassetid://12571092295",
	["A120"] = "rbxassetid://12711591665",
	["BackdoorRush"] = "rbxassetid://16602023490",
	["Eyes"] = "rbxassetid://10183704772",
	["Lookman"] = "rbxassetid://10183704772",
	["BackdoorLookman"] = "rbxassetid://16764872677",
	["GloombatSwarm"] = "rbxassetid://79221203116470",
	["Halt"] = "rbxassetid://11331795398",
	["JeffTheKiller"] = "rbxassetid://94479432156278",
	["GlitchRush"] = "rbxassetid://73859273102919",
	["GlitchAmbush"] = "rbxassetid://88369678433359",
	["SallyMoving"] = "rbxassetid://10840888070",
	["MonumentEntity"] = "rbxassetid://88933556873017",
	["Groundskeeper"] = "rbxassetid://114991380115557"
}

local ItemNames = {
	["DinkyLamp"] = "台灯",
	["BottleCrate"] = "18+ 瓶子",
	["GweenSodaPack"] = "绿汽水包",
	["BrokenMonitor"] = "破损显示器",
	["JerryCan"] = "油桶",
	["SallyToyObtain"] = "莎莉玩具",
	["Leftovers"] = "午餐盒",
	["HoneyPot"] = "蜜罐",
	["FihFlakes"] = "鱼食",
	["SecretCD"] = "CD光盘",
	["Pizza"] = "披萨",
	["PaperPlanePickup"] = "纸飞机",
	["Lighter"] = "打火机",
	["Flashlight"] = "手电筒",
	["Lockpick"] = "开锁器",
	["Vitamins"] = "维生素",
	["Bandage"] = "绷带",
	["StarVial"] = "星光瓶",
	["StarBottle"] = "星光瓶",
	["StarJug"] = "星光桶",
	["Shakelight"] = "软糖手电筒",
	["Straplight"] = "绑带灯",
	["Bulklight"] = "聚光灯",
	["Battery"] = "电池",
	["Candle"] = "蜡烛",
	["Crucifix"] = "十字架",
	["CrucifixWall"] = "十字架",
	["Glowsticks"] = "荧光棒",
	["SkeletonKey"] = "万能钥匙",
	["Candy"] = "糖果",
	["ShieldMini"] = "迷你护盾药水",
	["ShieldBig"] = "大护盾药水",
	["BandagePack"] = "绷带包",
	["BatteryPack"] = "电池包",
	["RiftCandle"] = "月光蜡烛",
	["LaserPointer"] = "激光笔",
	["HolyGrenade"] = "神圣手雷",
	["Shears"] = "剪刀",
	["Smoothie"] = "冰沙",
	["Cheese"] = "奶酪",
	["Bread"] = "面包",
	["AlarmClock"] = "闹钟",
	["RiftSmoothie"] = "月光冰沙",
	["GweenSoda"] = "绿汽水",
	["GlitchCube"] = "故障碎片",
	["Scanner"] = "平板",
	["Bomb"] = "炸弹",
	["Knockbomb"] = "击退炸弹",
	["Nanner"] = "香蕉",
	["BigBomb"] = "大炸弹",
	["SnakeBox"] = "躲藏箱",
	["GoldGun"] = "金枪",
	["StopSign"] = "停车标志",
	["TipJar"] = "小费罐",
	["Lantern"] = "灯笼",
	["IronKey"] = "铁钥匙",
	["LotusPetal"] = "莲花瓣",
	["Compass"] = "指南针",
	["LotusPetalPickup"] = "莲花瓣",
	["LanternLitItem"] = "灯笼",
	["KeyIron"] = "铁钥匙",
	["IronKeyForCrypt"] = "铁钥匙",
	["LotusHolder"] = "莲花瓣",
	["Multitool"] = "多功能工具",
	["RiftJar"] = "裂隙罐",
	["AloeVera"] = "芦荟",
	["Donut"] = "甜甜圈",
	["Lotus"] = "莲花",
	["BoxingGloves"] = "拳击手套"
}
local CutsceneNames = {
	"Figure", "FigureEnd", "FigureHotelEnd", "FigureHotelFire",
	"SeekIntroFools", "SeekIntroHotel", "SeekIntroMines", "SeekIntroMines2",
	"SerewSeekDrain", "SewerSeekLower", "GrumbleNestEnd", "EyestalkIntro",
}

local Character
local Humanoid
local RootPart
local Collision
local CollisionClone
local CollisionPart
local CollisionPartClone
local Camera
local RemotesFolder = Services.ReplicatedStorage:FindFirstChild("RemotesFolder")
local LiveModifiers = Services.ReplicatedStorage:FindFirstChild("LiveModifiers")
local FloorReplicated = Services.ReplicatedStorage:FindFirstChild("FloorReplicated")
local CurrentRooms = Services.Workspace:FindFirstChild("CurrentRooms")
local Drops = Services.Workspace:FindFirstChild("Drops")
local GameData = Services.ReplicatedStorage:WaitForChild("GameData")
local Floor = GameData:WaitForChild("Floor").Value
local LatestRoom = GameData:WaitForChild("LatestRoom")
local FinishedLoadingRoom = GameData:FindFirstChild("FinishedLoadingRoom")
local RunService = game:GetService("RunService")

if FinishedLoadingRoom then
	FinishedLoadingRoom:Destroy()
end

local function GetHiddenContainer()
	if Functions.CheckCompatability({"gethui"}) then
		return Abysall.Environment.gethui()
	end
	return Services.CoreGui
end

local NotificationLibrary = {
	LiveNotifications = 0,
	Notifications = 1
}

local Container = Instance.new("ScreenGui")
Container.Name = Abysall.ESPLibrary:GenerateRandomString()
Container.Parent = GetHiddenContainer()
Container.DisplayOrder = 32767
Container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if not Library.Scheme then
	Library.Scheme = setmetatable({}, {
		__index = function(Self, Name)
			return Library[Name]
		end
	})
end

function NotificationLibrary:Notify(TitleText, Desc, Delay)
	task.spawn(function()
		local Notification = Instance.new("Frame")
		local Line = Instance.new("Frame")
		local Warning = Instance.new("ImageLabel")
		local UICorner = Instance.new("UICorner")
		local UICorner2 = Instance.new("UICorner")
		local Title = Instance.new("TextLabel")
		local Description = Instance.new("TextLabel")

		Notification.Name = "Notification"
		Notification.Parent = Container
		Notification.BackgroundColor3 = Library.Scheme.BackgroundColor
		Notification.BackgroundTransparency = 0.4
		Notification.BorderSizePixel = 0
		Notification.Position = UDim2.new(1, 5, 0, 60 + (60 * NotificationLibrary.LiveNotifications))
		Notification.Size = UDim2.new(0, 420, 0, 50)
		Notification:SetAttribute("ID", NotificationLibrary.Notifications)
		Notification:SetAttribute("CurrentPosition", Notification.Position)

		Line.Name = "Line"
		Line.Parent = Notification
		Line.BackgroundColor3 = Library.Scheme.AccentColor
		Line.BorderSizePixel = 0
		Line.Position = UDim2.new(0, 0, 1, -3)
		Line.Size = UDim2.new(0, 0, 0, 3)

		Warning.Name = "Warning"
		Warning.Parent = Notification
		Warning.BackgroundTransparency = 1
		Warning.Position = UDim2.new(0, 10, 0, 5)
		Warning.Size = UDim2.new(0, 40, 0, 40)
		Warning.Image = "rbxassetid://3944668821"
		Warning.ImageColor3 = Library.Scheme.AccentColor
		Warning.ScaleType = Enum.ScaleType.Fit

		UICorner.CornerRadius = UDim.new(0, 20)
		UICorner.Parent = Warning
		UICorner2.CornerRadius = UDim.new(0, 4)
		UICorner2.Parent = Notification

		Title.Name = "Title"
		Title.Parent = Notification
		Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Title.BackgroundTransparency = 1
		Title.Position = UDim2.new(0, 60, 0.155, 0)
		Title.Size = UDim2.new(0, 205, 0, 15)
		Title.Text = TitleText or "..."
		Title.TextColor3 = Library.Scheme.FontColor
		Title.TextSize = 10
		Title.TextStrokeTransparency = 0.75
		Title.TextXAlignment = Enum.TextXAlignment.Left

		Description.Name = "Description"
		Description.Parent = Notification
		Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Description.BackgroundTransparency = 1
		Description.Position = UDim2.new(0, 60, 0.483, 0)
		Description.Size = UDim2.new(0, 205, 0, 18)
		Description.Text = Desc or "..."
		Description.TextColor3 = Library.Scheme.FontColor
		Description.TextTransparency = 0.1
		Description.TextSize = 10
		Description.TextStrokeTransparency = 0.75
		Description.TextXAlignment = Enum.TextXAlignment.Left

		NotificationLibrary.LiveNotifications += 1
		NotificationLibrary.Notifications += 1

		Services.TweenService:Create(
			Notification,
			TweenInfo.new(1, Enum.EasingStyle.Exponential),
			{ Position = UDim2.new(1, -370, 0, Notification.Position.Y.Offset) }
		):Play()

		task.wait(0.25)

		if typeof(Delay) == "Instance" then
			Delay.Destroying:Wait()
		else
			Services.TweenService:Create(
				Line,
				TweenInfo.new(Delay - 0.25, Enum.EasingStyle.Linear),
				{ Size = UDim2.new(0, 400, 0, 3) }
			):Play()
			task.wait(Delay - 0.25)
		end

		Notification:SetAttribute("Destroying", true)

		Services.TweenService:Create(
			Notification,
			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 5, 0, Notification.Position.Y.Offset) }
		):Play()

		NotificationLibrary.LiveNotifications -= 1

		local NotifId = Notification:GetAttribute("ID")
		local NotifY = Notification:GetAttribute("CurrentPosition").Y.Offset

		for _, Object in Container:GetChildren() do
			if Object.Name == "Notification"
				and Object:GetAttribute("ID")
				and Object:GetAttribute("ID") > NotifId
				and Object:GetAttribute("Destroying") ~= true
				and Object.Position.Y.Offset ~= 60
			then
				local NewY = Object:GetAttribute("CurrentPosition").Y.Offset - 60
				Object:SetAttribute("CurrentPosition", UDim2.new(1, -450, 0, NewY))
				Services.TweenService:Create(
					Object,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
					{ Position = UDim2.new(1, -370, 0, NewY) }
				):Play()
			end
		end

		task.wait(0.75)
		Notification:Destroy()
	end)
end

Globals.DoorsNotify = function(NotifyOptions)
	local function PlaySound(Parent, SoundId, Volume)
		local Sound = Instance.new("Sound")
		Sound.SoundId = SoundId
		Sound.Volume = Volume or 1
		Sound.Parent = Parent
		task.spawn(function()
			task.wait(0.1)
			Sound:Play()
			Sound.Ended:Wait()
			Sound:Destroy()
		end)
	end

	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local UIContainer = PlayerGui:FindFirstChild("GlobalUI") or PlayerGui:FindFirstChild("MainUI")
	if not UIContainer then return end
	local AchievementsHolder = UIContainer:FindFirstChild("AchievementsHolder")
	if not AchievementsHolder then return end

	local Achievement = AchievementsHolder.Achievement:Clone()
	Achievement.Size = UDim2.new(0, 0, 0, 0)
	Achievement.Frame.Position = UDim2.new(1.1, 0, 0, 0)
	Achievement.Name = "LiveAchievement"
	Achievement.Visible = true
	Achievement.Frame.TextLabel.Text = NotifyOptions.Style or "通知"
	Achievement.Frame.Details.Title.Text = NotifyOptions.Title or "无标题"
	Achievement.Frame.Details.Desc.Text = NotifyOptions.Description or "无描述"
	Achievement.Frame.Details.Reason.Text = NotifyOptions.Reason or ""
	Achievement.Frame.ImageLabel.Image = (NotifyOptions.Image ~= "" and NotifyOptions.Image) or "rbxassetid://6023426923"

	local Color = NotifyOptions.Color or Color3.new(1, 1, 1)
	Achievement.Frame.TextLabel.TextColor3 = Color
	Achievement.Frame.UIStroke.Color = Color
	Achievement.Frame.Glow.ImageColor3 = Color
	Achievement.Parent = AchievementsHolder

	PlaySound(AchievementsHolder, "rbxassetid://10469938989", 1)

	task.spawn(function()
		Achievement:TweenSize(UDim2.new(1, 0, 0.2, 0), "In", "Quad", 0.8, true)
		task.wait(0.8)
		Achievement.Frame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.5, true)
		Services.TweenService:Create(
			Achievement.Frame.Glow,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ ImageTransparency = 1 }
		):Play()

		if typeof(NotifyOptions.Time) == "Instance" then
			NotifyOptions.Time.Destroying:Wait()
		else
			task.wait(NotifyOptions.Time or 5)
		end

		Achievement.Frame:TweenPosition(UDim2.new(1.1, 0, 0, 0), "In", "Quad", 0.5, true)
		task.wait(0.5)
		Achievement:TweenSize(UDim2.new(1, 0, -0.1, 0), "InOut", "Quad", 0.5, true)
		task.wait(0.5)
		Achievement:Destroy()
	end)
end

Globals.STX = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/Abysall/refs/heads/main/Components/STX.luau"))()

Functions.Notify = function(Settings)
	local HiddenContainer = GetHiddenContainer()
	if not Settings.Body then
		Settings.Body = "..."
	end

	if not Options.NotifyStyle or Options.NotifyStyle.Value == "Abysall" then
		local Sound = Instance.new("Sound", HiddenContainer)
		Sound.SoundId = "rbxassetid://8784885431"
		Sound.Volume = (Toggles.NotifyPlaySound and Toggles.NotifyPlaySound.Value and Options.NotifySoundVolume.Value) or (Toggles.NotifyPlaySound and 0 or 3)
		Sound.PlayOnRemove = true
		Sound:Destroy()
		NotificationLibrary:Notify(Settings.Title, Settings.Body, Settings.Time or 5)

	elseif Options.NotifyStyle.Value == "Doors" then
		local IsEntity = false
		local EntityName = ""
		for Index, Object in pairs(Entities) do
			if Object.NotifyMessage.Title == Settings.Title or Object.NotifyMessage.Body == Settings.Body then
				IsEntity = true
				EntityName = Index
			end
		end
		Globals.DoorsNotify({
			Title = "Abysall Hub",
			Description = Settings.Title,
			Reason = Settings.Body,
			Style = IsEntity and "警告" or "通知",
			Color = IsEntity and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 222, 189),
			Image = Settings.Image,
			Time = Settings.Time
		})

	elseif Options.NotifyStyle.Value == "STX" then
		local Sound = Instance.new("Sound", HiddenContainer)
		Sound.SoundId = "rbxassetid://4590657391"
		Sound.Volume = (Toggles.NotifyPlaySound and Toggles.NotifyPlaySound.Value and Options.NotifySoundVolume.Value) or (Toggles.NotifyPlaySound and 0 or 3)
		Sound.PlayOnRemove = true
		Sound:Destroy()
		if Settings.Image then
			Globals.STX:Notify(
				{Title = "Abysall Hub", Description = Settings.Title .. "\n" .. Settings.Body},
				{OutlineColor = Library.Scheme.AccentColor, Time = Settings.Time or 5, Type = "image"},
				{Image = Settings.Image, ImageColor = Color3.fromRGB(255, 255, 255)}
			)
		else
			Globals.STX:Notify(
				{Title = "Abysall Hub", Description = Settings.Title .. "\n" .. Settings.Body},
				{OutlineColor = Library.Scheme.AccentColor, Time = Settings.Time or 5, Type = "default"}
			)
		end

	else
		local Sound = Instance.new("Sound", HiddenContainer)
		Sound.SoundId = "rbxassetid://4590662766"
		Sound.Volume = (Toggles.NotifyPlaySound and Toggles.NotifyPlaySound.Value and Options.NotifySoundVolume.Value) or (Toggles.NotifyPlaySound and 0 or 3)
		Sound.PlayOnRemove = true
		Sound:Destroy()
		Library:OldNotify({ Title = Settings.Title, Description = Settings.Body, Time = Settings.Time })
	end
end

Functions.Caption = function(Text, PlaySound)
	if typeof(PlaySound) ~= "boolean" then
		PlaySound = true
	end
	local CaptionValue = Instance.new("NumberValue")
	local Caption = Globals.MainUI:WaitForChild("MainFrame"):WaitForChild("Caption"):Clone()
	local CaptionSound = Globals.MainUI:WaitForChild("Initiator"):WaitForChild("Main_Game"):WaitForChild("Reminder"):WaitForChild("Caption")
	local CaptionSoundClone = CaptionSound:Clone()
	CaptionSoundClone.Parent = CaptionSound.Parent
	CaptionSoundClone.Volume = 0.1

	Caption.Destroying:Connect(function()
		CaptionValue:Destroy()
	end)

	for _, Child in Globals.MainUI:GetChildren() do
		if Child.Name == "LiveCaption" then
			Child:Destroy()
		end
	end

	Caption.Parent = Globals.MainUI
	Caption.Visible = true
	Caption.Name = "LiveCaption"
	Caption.Text = Text

	if PlaySound then
		CaptionSoundClone:Play()
	end

	Services.Debris:AddItem(CaptionSoundClone, 5)

	local HolderTween = Services.TweenService:Create(CaptionValue, TweenInfo.new(3), { Value = 100 })
	HolderTween:Play()
	HolderTween.Completed:Connect(function()
		CaptionValue:Destroy()
		Services.TweenService:Create(Caption, TweenInfo.new(4, Enum.EasingStyle.Linear), { TextTransparency = 1 }):Play()
		Services.TweenService:Create(Caption, TweenInfo.new(4, Enum.EasingStyle.Linear), { TextStrokeTransparency = 1 }):Play()
	end)
end

Functions.GetHasteTime = function()
	local TimeRemaining = FloorReplicated.DigitalTimer.Value
	local Minutes = math.floor(TimeRemaining / 60)
	local Seconds = TimeRemaining - (Minutes * 60)
	local MinutesText = Minutes < 10 and ("0" .. tostring(Minutes)) or tostring(Minutes)
	local SecondsText = Seconds < 10 and ("0" .. tostring(Seconds)) or tostring(Seconds)
	return MinutesText .. ":" .. SecondsText
end

Library.OldNotify = Library.Notify
Library.Notify = function(Data, Body, Time)
	Functions.Notify({ Title = Body, Time = Time or 5 })
end

if not LocalPlayer.Character or not CurrentRooms:FindFirstChildOfClass("Model") then
	Functions.Notify({ Title = "等待游戏加载中..." })
	queue_on_teleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau"))()]])
	while not LocalPlayer.Character or not CurrentRooms:FindFirstChildOfClass("Model") do
		task.wait()
	end
	task.wait(4)
end

if not RemotesFolder then
	if Services.ReplicatedStorage:FindFirstChild("EntityInfo") then
		RemotesFolder = Services.ReplicatedStorage:FindFirstChild("EntityInfo")
	elseif Services.ReplicatedStorage:FindFirstChild("Bricks") then
		RemotesFolder = Services.ReplicatedStorage:FindFirstChild("Bricks")
	end
end

if Floor == "Hotel" and RemotesFolder.Name == "Bricks" then
	Floor = "OldHotel"
end

if not LiveModifiers then
	LiveModifiers = Instance.new("Folder")
end

if not FloorReplicated then
	FloorReplicated = Instance.new("Folder")
end

local FakeEvents = {
	Screech = Instance.new("RemoteEvent"),
	Shade = Instance.new("RemoteEvent"),
	A90 = Instance.new("RemoteEvent"),
	Surge = Instance.new("RemoteEvent"),
}
FakeEvents.Screech.Name = "Screech"
FakeEvents.Shade.Name = "ShadeResult"
FakeEvents.A90.Name = "A90"
FakeEvents.Surge.Name = "SurgeRemote"

FakeEvents.Screech_Real = RemotesFolder:WaitForChild("Screech")
FakeEvents.Shade_Real = RemotesFolder:WaitForChild("ShadeResult")
FakeEvents.A90_Real = RemotesFolder:FindFirstChild("A90")
FakeEvents.Surge_Real = RemotesFolder:FindFirstChild("SurgeRemote")

if RemotesFolder:FindFirstChild("FootstepRemoteThatWeNeed") then
	local RealRemote = RemotesFolder:FindFirstChild("FootstepRemoteThatWeNeed")
	RealRemote:Destroy()
	local FakeRemote = Instance.new("RemoteEvent", RemotesFolder)
	FakeRemote.Name = "FootstepRemoteThatWeNeed"
end

Globals.FogInstances = {}
Globals.OldFog = Services.Lighting.FogEnd

for _, Object in Services.Lighting:GetChildren() do
	if Object:IsA("Atmosphere") then
		Object:SetAttribute("Density_Old", Object.Density)
		local AtmoConnection = Object:GetPropertyChangedSignal("Density"):Connect(function()
			if Object.Density ~= 0 then
				Object:SetAttribute("Density_Old", Object.Density)
			end
			if Toggles.RemoveCameraFog.Value then
				Object.Density = 0
			end
		end)
		Object.Destroying:Once(function()
			AtmoConnection:Disconnect()
		end)
		table.insert(Connections, AtmoConnection)
		table.insert(Globals.FogInstances, Object)
	end
end

Globals.SeekNodesFolder = Instance.new("Folder", Services.Workspace)
Globals.SeekNodesFolder.Name = Abysall.ESPLibrary:GenerateRandomString()
Globals.RoomsNodesFolder = Instance.new("Folder", Services.Workspace)
Globals.RoomsNodesFolder.Name = Abysall.ESPLibrary:GenerateRandomString()

Functions.SendChat = function(Message)
	local Folder = Services.ReplicatedStorage:FindFirstChild("DefaultChatSystemEvents") or Instance.new("Folder")
	local Event = Folder:FindFirstChild("SayMessageRequest") or Instance.new("RemoteEvent")
	Event:FireServer(Message, "All")
	local Channel = (Services.TextChatService:FindFirstChild("TextChannels") and Services.TextChatService.TextChannels:FindFirstChild("RBXGeneral")) or Instance.new("TextChannel")
	Channel:SendAsync(Message)
end

Functions.IsCrouching = function()
	if Floor == "Fools" or Floor == "OldHotel" then
		return Character:GetAttribute("Crouching")
	end
	return CollisionPart.CollisionGroup == "PlayerCrouching"
end

Functions.GetInjuriesSpeed = function()
	return 0.075 * (Humanoid.MaxHealth - Humanoid.Health)
end

Functions.GetCurrentSpeed = function()
	local Speed = 15
	Speed += Character:GetAttribute("SpeedBoost") or 0
	Speed += Character:GetAttribute("SpeedBoostBehind") or 0
	Speed += Character:GetAttribute("SpeedBoostExtra") or 0
	Speed += (Floor == "Party" and 10 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFast") and 3 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFaster") and 6 or 0)
	Speed += (LiveModifiers:FindFirstChild("PlayerFastest") and 20 or 0)
	Speed -= (LiveModifiers:FindFirstChild("PlayerSlow") and 3 or 0)
	Speed -= (LiveModifiers:FindFirstChild("PlayerSlowHealth") and Functions.GetInjuriesSpeed() or 0)
	if Functions.IsCrouching() then
		if LiveModifiers:FindFirstChild("PlayerCrouchSlow") then
			Speed -= 8
		elseif LiveModifiers:FindFirstChild("PlayerSlow") then
			Speed -= 8
		else
			Speed -= 5
		end
	end
	return Speed
end

Functions.GetMousePosition = function()
	if Library.IsMobile then
		return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	end
	local MouseLocation = Services.UserInputService:GetMouseLocation()
	return Vector2.new(MouseLocation.X, MouseLocation.Y)
end

Functions.FormatOxygen = function(Oxygen)
	return "氧气: " .. (math.floor(Oxygen * 10) / 10) .. "%"
end

Functions.IsHidePersistent = function()
	return Floor == "Mines"
		or Floor == "Ripple"
		or Floor == "Party"
		or LiveModifiers:FindFirstChild("HideLevel2") ~= nil
end

Functions.GetPlayerFromMouse = function(TargetPart, MaxDistance)
	local Closest
	local ClosestDistance = math.huge
	for _, Player in Services.Players:GetPlayers() do
		local Char = Player.Character
		if Char then
			local Target = Char:FindFirstChild(TargetPart)
			if Target then
				local Result = Camera:WorldToViewportPoint(Target.Position)
				local ScreenPos = Vector2.new(Result.X, Result.Y)
				local Distance = (Functions.GetMousePosition() - ScreenPos).Magnitude
				if Player.Name ~= LocalPlayer.Name and Distance < ClosestDistance and Distance < MaxDistance then
					Closest = Target
					ClosestDistance = Distance
				end
			end
		end
	end
	return Closest
end

local EntityDistances = {
	["RushMoving"] = 85,
	["Scribbles"] = 100,
	["BashMoving"] = 150,
	["DronesStampede"] = 100,
	["AmbushMoving"] = 150,
	["A60"] = 125,
	["A120"] = 85,
	["GlitchRush"] = 90,
	["GlitchAmbush"] = 175,
	["BackdoorRush"] = 85,
	["CustomEntity"] = 85,
}

Functions.GetNearestEntity = function(CheckDisabled, List, UseRaycasting)
	local Nearest = { Distance = math.huge, Object = nil }
	for _, Entity in Objects.Entities do
		if not Entity or not Entity:IsA("Model") or not Entity:IsDescendantOf(Services.Workspace) then continue end
		if not EntityDistances[Entity.Name] or not Entity.PrimaryPart then continue end
		local EntityData = Entities[Entity.Name]
		if not EntityData then continue end
		if List and List[EntityData.Alias] then continue end
		local Distance = LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position)
		if Distance < EntityDistances[Entity.Name] and Distance < Nearest.Distance then
			if not CheckDisabled or Entity:GetAttribute("Inactive") ~= true then
				Nearest.Distance = Distance
				Nearest.Object = Entity
			end
		end
	end
	return Nearest.Object
end

Functions.GetNearestFigure = function()
	local Nearest = { Distance = math.huge, Object = nil }
	local FigureNames = { FigureRig = true, FigureRagdoll = true, Figure = true }
	for _, Object in Objects.Entities do
		if Object:IsA("Model") and Object.PrimaryPart and FigureNames[Object.Name] then
			local Distance = LocalPlayer:DistanceFromCharacter(Object.PrimaryPart.Position)
			if Distance < Nearest.Distance and Distance < 25 then
				Nearest.Distance = Distance
				Nearest.Object = Object
			end
		end
	end
	return Nearest.Object
end
Functions.GetNearestHidingSpot = function()
	local Nearest = { Distance = math.huge, Object = nil }
	local LastHideSpot = Character:FindFirstChild("LastHideSpot")

	local function IsHidingSpotName(Name)
		if typeof(Name) ~= "string" then return false end
		return string.find(string.lower(Name), "hidingspot") or string.find(string.lower(Name), "hiding_spot")
	end

	local function GetHidePrompt(Object)
		if not Object then return nil end
		local Prompt = Object:FindFirstChild("HidePrompt") or Object:FindFirstChild("HidingPrompt")
		if Prompt then return Prompt end
		for _, Child in Object:GetDescendants() do
			if (Child:IsA("ProximityPrompt") or Child:IsA("InteractPrompt"))
				and (Child.Name == "HidePrompt" or Child.Name == "HidingPrompt" or IsHidingSpotName(Child.Name))
			then
				return Child
			end
		end
		if IsHidingSpotName(Object.Name) or IsHidingSpotName(Object.Parent and Object.Parent.Name) then
			return Object:FindFirstChild("HidePrompt") or Object:FindFirstChild("HidingPrompt")
		end
		return nil
	end

	local function TryObject(Object)
		if not Object or not Object:IsDescendantOf(Services.Workspace) then return end
		if not Object.PrimaryPart and not Object:FindFirstChildOfClass("BasePart") then return end
		local Prompt = GetHidePrompt(Object)
		if not Prompt then return end
		local PrimaryPart = Object.PrimaryPart or Object:FindFirstChildOfClass("BasePart")
		if not PrimaryPart then return end
		local Distance = LocalPlayer:DistanceFromCharacter(PrimaryPart.Position)
		if Distance < Prompt.MaxActivationDistance and Distance < Nearest.Distance then
			local Persistent = Functions.IsHidePersistent()
			if not Persistent or (LastHideSpot and LastHideSpot.Value ~= Object) or not LastHideSpot then
				Nearest.Distance = Distance
				Nearest.Object = Object
			end
		end
	end

	for _, Object in Objects.HidingSpots do
		TryObject(Object)
	end
	return Nearest.Object
end

Functions.GetNearestTurnNode = function()
	local Nearest = { Distance = math.huge, Object = nil }
	for _, Node in Objects.SeekNodes do
		local Distance = LocalPlayer:DistanceFromCharacter(Node.Position)
		if Distance < Options.AutoSteerMinecartTurnDistance.Value and Distance < Nearest.Distance then
			Nearest.Distance = Distance
			Nearest.Object = Node
		end
	end
	return Nearest.Object
end

Functions.GetNearestDuckBoard = function()
	local Nearest = { Distance = math.huge, Object = nil }
	for _, Board in Objects.SeekDuckBoards do
		if Board.PrimaryPart then
			local Distance = LocalPlayer:DistanceFromCharacter(Board.PrimaryPart.Position)
			if Distance < Options.AutoSteerMinecartDuckDistance.Value and Distance < Nearest.Distance then
				Nearest.Distance = Distance
				Nearest.Object = Board
			end
		end
	end
	return Nearest.Object
end

Functions.GetCurrentAnchor = function()
	local AnchorCode = Globals.MainUI.AnchorHintFrame.AnchorCode.Text
	for _, Anchor in Objects.Objectives do
		if Anchor.Name == "MinesAnchor" and Anchor:FindFirstChild("Sign") then
			if Anchor.Sign.TextLabel.Text == AnchorCode then
				return Anchor
			end
		end
	end
end

Functions.GetMinecart = function()
	return Camera:FindFirstChild("MinecartRig") ~= nil
end

Functions.HasItem = function(Name, OnlyCharacter)
	if not OnlyCharacter and LocalPlayer.Backpack:FindFirstChild(Name) then
		return LocalPlayer.Backpack:FindFirstChild(Name)
	elseif Character:FindFirstChild(Name) then
		return Character:FindFirstChild(Name)
	end
end

Functions.GetFlyVelocity = function()
	if Humanoid.MoveDirection == Vector3.zero then
		return Humanoid.MoveDirection
	end
	local LookFlat = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
	local FlatFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + LookFlat)
	local Velocity = (Camera.CFrame * CFrame.new(FlatFrame:VectorToObjectSpace(Humanoid.MoveDirection))).Position - Camera.CFrame.Position
	if Velocity == Vector3.zero then
		return Velocity
	end
	return Velocity.Unit
end

Globals.PromptContainer = Instance.new("Folder")
Globals.PromptContainer.Name = "PromptContainer"
Globals.PromptContainer.Parent = GetHiddenContainer()

local ESPBlacklist = {}

Functions.AddESP = function(ESPOptions, RoomBased)
	local Object = ESPOptions.Object
	if table.find(ESPBlacklist, Object) then
		return
	end
	if RoomBased then
		local CurrentRoom = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
		local ObjectRoom = tonumber(Object:GetAttribute("ParentRoom"))
		if ObjectRoom == CurrentRoom or (table.find(Objects.Doors, Object) and ObjectRoom == CurrentRoom + 1) then
			Abysall.ESPLibrary:AddESP(ESPOptions)
		end
		local RoomConnection = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
			if Abysall.ESPLibrary.ColorTable[Object] then
				ESPOptions.Color = Abysall.ESPLibrary.ColorTable[Object]
			end
			local NewCurrentRoom = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
			local ObjRoom = tonumber(Object:GetAttribute("ParentRoom"))
			if ObjRoom == NewCurrentRoom or (table.find(Objects.Doors, Object) and ObjRoom == NewCurrentRoom + 1) then
				Abysall.ESPLibrary:AddESP(ESPOptions)
			else
				Abysall.ESPLibrary:RemoveESP(Object)
			end
		end)
		table.insert(Connections, RoomConnection)
		ESPConnections[Object] = RoomConnection
		Object.Destroying:Once(function()
			RoomConnection:Disconnect()
			if Abysall then
				Abysall.ESPLibrary:RemoveESP(Object)
			end
			local Pos = table.find(Connections, RoomConnection)
			if Pos then table.remove(Connections, Pos) end
		end)
	else
		Abysall.ESPLibrary:AddESP(ESPOptions)
	end
end

Functions.RemoveESP = function(Object)
	local Conn = ESPConnections[Object]
	if Conn then
		Conn:Disconnect()
		ESPConnections[Object] = nil
		local Pos = table.find(Connections, Conn)
		if Pos then table.remove(Connections, Pos) end
	end
	Abysall.ESPLibrary:RemoveESP(Object)
end

Functions.BlacklistESP = function(Object)
	table.insert(ESPBlacklist, Object)
end

Functions.GetDoorNumber = function(Object)
	local DoorNumber = tonumber(Object.Parent.Name) or tonumber(Object.Parent.Parent.Name)
	if DoorNumber then
		DoorNumber = DoorNumber + 1
	end
	if Floor == "Mines" then
		DoorNumber = DoorNumber + 100
	end
	if Floor == "Backdoor" then
		DoorNumber = DoorNumber - 50
	end
	return tostring(DoorNumber)
end

Functions.GetLibraryCode = function()
	local Paper = Character:FindFirstChild("LibraryHintPaper")
		or Character:FindFirstChild("LibraryHintPaperHard")
		or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaper")
		or LocalPlayer.Backpack:FindFirstChild("LibraryHintPaperHard")
	if Paper and Paper:FindFirstChild("UI") then
		local Code = {}
		local CodeLength = Floor == "Fools" and 10 or 5
		for I = 1, CodeLength do Code[I] = "_" end
		local HintChildren = LocalPlayer.PlayerGui.PermUI.Hints:GetChildren()
		local UIChildren = Paper.UI:GetChildren()
		for _, Hint in HintChildren do
			for _, UIChild in UIChildren do
				if Hint:IsA("ImageLabel") and UIChild:IsA("ImageLabel")
					and Hint.ImageRectOffset == UIChild.ImageRectOffset
					and Code[tonumber(UIChild.Name)]
				then
					Code[tonumber(UIChild.Name)] = Hint.TextLabel.Text
				end
			end
		end
		return table.concat(Code)
	end
	return Floor == "Fools" and "__________" or "_____"
end

Globals.UsedRandomCodes = {}

Functions.GetRandomCode = function()
	local CodeTemplate = Functions.GetLibraryCode()
	if not CodeTemplate then return nil end
	local NewCode
	local Tries = 0
	repeat
		NewCode = CodeTemplate:gsub("_", function()
			return tostring(math.random(0, 9))
		end)
		Tries = Tries + 1
	until not Globals.UsedRandomCodes[NewCode] or Tries >= 10
	Globals.UsedRandomCodes[NewCode] = true
	return NewCode
end

local Window = Library:CreateWindow({
	Title = "Abysall Hub Continued",
	Footer = "dsc.gg/abysallhubcontinued",
	NotifySide = "Right",
	ShowCustomCursor = false,
	AutoShow = true,
	Center = true,
	TabPadding = 3,
	MenuFadeTime = 0,
	CornerRadius = 6,
})

Abysall.Interface.ApplyInfoTab(Window)

local Tabs = {
	General = Window:AddTab("常规", "house"),
	Exploits = Window:AddTab("漏洞", "shield"),
	Visuals = Window:AddTab("视觉", "eye"),
	Floors = Window:AddTab("楼层", "earth"),
	Archives = Window:AddTab("新 - 档案室", "rbxassetid://104508835882225"),
	Stairwell = Window:AddTab("新 - 楼梯间", "rbxassetid://80017304328364"),
}

Groupboxes.General_Character = Tabs.General:AddLeftGroupbox("角色")
Groupboxes.General_Character:AddSlider("SpeedBoostSlider", {
	Text = "速度加成",
	Min = 0,
	Max = 100,
	Default = 0,
	Rounding = 0,
	Compact = true
})
Groupboxes.General_Character:AddToggle("SpeedBoostToggle", {
	Text = "启用速度加成",
	Default = false,
	Tooltip = "按指定数值增加你的行走速度。"
})
Groupboxes.General_Character:AddToggle("FlyToggle", {
	Text = "飞行",
	Default = false,
	Tooltip = "允许你自由飞行。"
})
Toggles.FlyToggle:AddKeyPicker("FlyKeybind", {
	Text = "飞行",
	Default = "F",
	Mode = "Toggle",
	SyncToggleState = true
})
Groupboxes.General_Character:AddSlider("FlySpeed", {
	Text = "飞行速度",
	Min = 0,
	Max = 115,
	Default = 20,
	Rounding = 0,
	Compact = true
})
Groupboxes.General_Character:AddDivider()
Groupboxes.General_Character:AddToggle("NoclipToggle", {
	Text = "穿墙",
	Default = false,
	Tooltip = "允许你的角色穿过固体物体。"
})
Groupboxes.General_Character:AddToggle("RemoveClosetDelay", {
	Text = "移除衣柜延迟",
	Default = false,
	Tooltip = "移除动画结束后无法立即离开衣柜的短暂窗口。"
})
Groupboxes.General_Character:AddToggle("RemoveAcceleration", {
	Text = "移除惯性",
	Default = false,
	Tooltip = "防止你的角色在移动时滑动。"
})

local CustomPhysics

Options.SpeedBoostSlider:OnChanged(function(Value)
	if RemotesFolder:FindFirstChild("Crouch") then
		RemotesFolder.Crouch:FireServer(Value and true or Functions.IsCrouching(), true)
	end
end)

Toggles.NoclipToggle:AddKeyPicker("NoclipKeybind", {
	Text = "穿墙",
	Default = "N",
	Mode = "Toggle",
	SyncToggleState = true
})

Toggles.RemoveAcceleration:OnChanged(function(Value)
	for Index, Old in PartProperties do
		Index.CustomPhysicalProperties = Value and CustomPhysics or Old
	end
end)

Groupboxes.General_Character:AddDivider()
Groupboxes.General_Character:AddToggle("EnableCharacterJump", {
	Text = "启用跳跃",
	Default = false,
	Tooltip = "允许你的角色跳跃。"
})
Groupboxes.General_Character:AddToggle("EnableCharacterSlide", {
	Text = "启用滑铲",
	Default = false,
	Tooltip = "允许你的角色滑铲。"
})
Groupboxes.General_Character:AddToggle("InfiniteJumps", {
	Text = "无限跳跃",
	Default = false,
	Tooltip = "允许你在空中跳跃。"
})

local OldJump = false
local OldSlide = false

Toggles.SpeedBoostToggle:OnChanged(function(Value)
	if Humanoid then
		Humanoid.WalkSpeed = Functions.GetCurrentSpeed() + (Value and Options.SpeedBoostSlider.Value or 0)
	end
end)

Toggles.EnableCharacterJump:OnChanged(function(Value)
	if Character then
		Character:SetAttribute("CanJump", Value and true or OldJump)
	end
end)

Toggles.EnableCharacterSlide:OnChanged(function(Value)
	if Character then
		Character:SetAttribute("CanSlide", Value and true or OldSlide)
	end
end)

Groupboxes.General_Self = Tabs.General:AddLeftGroupbox("自身")
Groupboxes.General_Self:AddToggle("DoorReachToggle", {
	Text = "开门范围",
	Default = false,
	Tooltip = "允许你从更远处开门。"
})
Groupboxes.General_Self:AddToggle("DisableIdleKick", {
	Text = "禁用挂机踢出",
	Default = false,
	Tooltip = "防止因挂机20分钟被踢出。"
})

Toggles.DisableIdleKick:OnChanged(function(Value)
	if Functions.CheckCompatability({"getconnections"}) then
		for _, Conn in Abysall.Environment.getconnections(LocalPlayer.Idled) do
			if Value then Conn:Disable() else Conn:Enable() end
		end
	end
end)

LocalPlayer.Idled:Connect(function()
	if Toggles.DisableIdleKick.Value then
		Services.VirtualUser:CaptureController()
		Services.VirtualUser:ClickButton2(Vector2.new())
	end
end)

Groupboxes.General_Self:AddDivider()
Groupboxes.General_Self:AddSlider("PromptReachSlider", {
	Text = "交互范围倍率",
	Min = 1,
	Max = 2,
	Default = 1,
	Rounding = 1,
	Compact = true
})
Groupboxes.General_Self:AddToggle("InstantPrompts", {
	Text = "即时交互",
	Default = false,
	Tooltip = "允许你立即触发所有交互提示。"
})
Groupboxes.General_Self:AddToggle("PromptClip", {
	Text = "穿墙交互",
	Default = false,
	Tooltip = "允许你穿过墙壁与提示交互。"
})

Options.PromptReachSlider:OnChanged(function(Value)
	for _, Prompt in Objects.Prompts do
		Prompt.MaxActivationDistance = Prompt:GetAttribute("MaxActivationDistance_Old") * Value
	end
end)

Toggles.InstantPrompts:OnChanged(function(Value)
	for _, Prompt in Objects.Prompts do
		Prompt.HoldDuration = Value and 0 or Prompt:GetAttribute("HoldDuration_Old")
	end
end)

Toggles.PromptClip:OnChanged(function(Value)
	for _, Prompt in Objects.Prompts do
		Prompt.RequiresLineOfSight = Value and false or Prompt:GetAttribute("RequiresLineOfSight_Old")
	end
end)

Groupboxes.Self_Automation = Tabs.General:AddRightGroupbox("自动化")
Groupboxes.Self_Automation:AddToggle("AutoBreakerBox", {
	Text = "自动断路器盒",
	Default = false,
	Tooltip = "自动解决断路器盒。"
})
Groupboxes.Self_Automation:AddToggle("AutoSolveAnchors", {
	Text = "自动解决锚点",
	Default = false,
	Tooltip = "靠近锚点时自动输入正确密码。"
})

Toggles.AutoBreakerBox:OnChanged(function(Value)
	if Value and CurrentRooms:FindFirstChild("ElevatorBreaker", true) then
		if not Globals.BreakerBoxInteracted then
			if not Globals.BreakerBoxNotified then
				Functions.Notify({ Title = "与断路器盒交互。", Body = "它将自动被解决。" })
				Globals.BreakerBoxInteracted = true
			end
		else
			RemotesFolder.EBF:FireServer()
		end
	end
end)

Groupboxes.Self_Automation:AddToggle("AutoHeartbeatMinigame", {
	Text = "自动心跳小游戏",
	Default = false,
	Tooltip = "防止'Figure'小游戏失败。",
	Disabled = not Functions.CheckCompatability({"hookmetamethod", "newcclosure", "getnamecallmethod"}),
	DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Self_Automation:AddDivider()
Groupboxes.Self_Automation:AddToggle("AutoUnlockPadlockToggle", {
	Text = "自动解锁挂锁",
	Default = false,
	Tooltip = "自动将密码输入图书馆挂锁。"
})
Groupboxes.Self_Automation:AddSlider("AutoUnlockPadlockSlider", {
	Text = "解锁距离",
	Min = 1,
	Max = 50,
	Default = 10,
	Rounding = 0,
	Compact = true
})
Groupboxes.Self_Automation:AddToggle("AutoLibraryGuessCode", {
	Text = "猜测图书馆密码",
	Default = false,
	Tooltip = "尝试猜测图书馆密码，但收集一些书也是必要的。"
})
Groupboxes.Self_Automation:AddDivider()
Groupboxes.Self_Automation:AddToggle("AutoInteractToggle", {
	Text = "自动交互",
	Default = false,
	Tooltip = "自动触发附近的交互提示。"
})
Toggles.AutoInteractToggle:AddKeyPicker("AutoInteractKeybind", {
	Text = "自动交互",
	Default = "R",
	Mode = "Toggle",
	SyncToggleState = true
})
Groupboxes.Self_Automation:AddDropdown("AutoInteractIgnoreList", {
	Text = "忽略列表",
	Values = { "故障碎片", "杰夫物品", "掉落物品", "货币", "矿车", "锁" },
	Default = { "故障碎片", "杰夫物品", "掉落物品" },
	Multi = true,
	AllowNull = true
})
Groupboxes.Self_Automation:AddDivider()
Groupboxes.Self_Automation:AddToggle("AutoClosetToggle", {
	Text = "自动躲藏",
	Default = false,
	Tooltip = "当实体靠近时自动躲进附近的衣柜。"
})
Toggles.AutoClosetToggle:AddKeyPicker("AutoClosetKeybind", {
	Text = "自动躲藏",
	Default = "Q",
	Mode = "Toggle",
	SyncToggleState = true
})
Groupboxes.Self_Automation:AddDropdown("AutoClosetEntityList", {
	Text = "忽略列表",
	Values = { "冲刺", "伏击", "闪电", "无人机群", "涂鸦", "A-60", "A-120", "AR0xMBUSH", "RNIUSHCG==" },
	Multi = true,
	AllowNull = true
})
Groupboxes.Self_Automation:AddToggle("SpectateEntityToggle", {
	Text = "观察实体",
	Default = false,
	Tooltip = "自动躲藏时观察实体。"
})
Groupboxes.Self_Automation:AddDropdown("SpecateEntityMode", {
	Values = {"玩家到实体", "实体到玩家"},
	Default = 1,
	AllowNull = true
})

Groupboxes.Self_Misc = Tabs.General:AddRightGroupbox("杂项")
Groupboxes.Self_Misc:AddButton({
	Text = "再玩一次",
	Tooltip = "让你加入新的一局，再次点击取消。",
	DoubleClick = true,
	Func = function() RemotesFolder.PlayAgain:FireServer() end
})
Groupboxes.Self_Misc:AddButton({
	Text = "返回大厅",
	Tooltip = "让你传送回大厅。",
	DoubleClick = true,
	Func = function() RemotesFolder.Lobby:FireServer() end
})
Groupboxes.Self_Misc:AddButton({
	Text = "复活",
	Tooltip = "让你复活，如果你有复活次数且本局未使用过。",
	DoubleClick = true,
	Func = function() RemotesFolder.Revive:FireServer() end
})
Groupboxes.Self_Misc:AddButton({
	Text = "重置角色",
	Tooltip = "在服务器上杀死你的角色。(如果不支持replicatesignal大约需要20秒)",
	DoubleClick = true,
	Func = function()
		Globals.SelfKilled = true
		if Functions.CheckCompatability({"replicatesignal"}) then
			Abysall.Environment.replicatesignal(LocalPlayer.Kill)
		else
			if RemotesFolder:FindFirstChild("Underwater") then
				RemotesFolder.Underwater:FireServer(true)
			else
				Humanoid.Health = 0
			end
		end
	end
})

Groupboxes.Debug = Tabs.General:AddRightGroupbox("调试")
Groupboxes.Debug:AddButton({
	Text = "虚空",
	Tooltip = "将你的角色传送到Y -120。",
	Func = function()
		if not Character then return end
		local Pivot = Character:GetPivot()
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
		Character:PivotTo(Pivot + Vector3.new(0, -120 - Pivot.Position.Y, 0))
	end
})
Groupboxes.Debug:AddButton({
	Text = "退出衣柜",
	Tooltip = "退出当前衣柜。",
	Func = function()
		if RemotesFolder and RemotesFolder:FindFirstChild("CamLock") then
			RemotesFolder.CamLock:FireServer()
		end
	end
})

local TpNextDoorConnection

local function getNextClosedDoor()
	if not Character then return nil end
	local GameData = game:GetService("ReplicatedStorage"):FindFirstChild("GameData")
	if not GameData then return nil end
	local LatestRoom = GameData:FindFirstChild("LatestRoom")
	if not LatestRoom then return nil end
	local startRoom = LatestRoom.Value
	local bestDoor = nil
	local bestNumber = math.huge
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name == "Door" and obj:IsA("Model") then
			local openAttr = obj:GetAttribute("Open")
			if openAttr == false or openAttr == nil then
				local roomModel = obj.Parent
				local roomNum = tonumber(roomModel and roomModel.Name)
				if roomNum and roomNum >= startRoom and roomNum < bestNumber then
					bestNumber = roomNum
					bestDoor = obj
				end
			end
		end
	end
	return bestDoor
end

Groupboxes.Debug:AddButton({
	Text = "传送下一扇门",
	Tooltip = "将你传送到下一个顺序未打开的门。",
	Func = function()
		local door = getNextClosedDoor()
		if door then
			Character:PivotTo(door:GetPivot())
		end
	end
})

Toggles.TpNextDoor = Groupboxes.Debug:AddToggle("TpNextDoor", {
	Text = "自动传送下一扇门",
	Tooltip = "持续将你传送到下一个顺序未打开的门。",
	Default = false
})

Toggles.TpNextDoor:OnChanged(function(TpNextDoorEnabled)
	if TpNextDoorConnection then
		task.cancel(TpNextDoorConnection)
		TpNextDoorConnection = nil
	end
	if not TpNextDoorEnabled then
		return
	end
	TpNextDoorConnection = task.spawn(function()
		while Toggles.TpNextDoor.Value do
			local door = getNextClosedDoor()
			if door and Character then
				Character:PivotTo(door:GetPivot())
			end
			task.wait(0.15)
		end
		TpNextDoorConnection = nil
	end)
end)
Groupboxes.Exploits_Bypass = Tabs.Exploits:AddLeftGroupbox("绕过 / 解决")
Groupboxes.Exploits_Bypass:AddToggle("BypassGiggle", { Text = "绕过傻笑", Default = false, Tooltip = "防止'傻笑'攻击你。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassDupe", { Text = "绕过假门", Default = false, Tooltip = "防止你打开'假门'。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassEyes", { Text = "绕过眼睛", Default = false, Tooltip = "防止'眼睛'伤害你。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassLookman", { Text = "绕过看门人", Default = false, Tooltip = "防止'看门人'伤害你。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassGloombatEggs", { Text = "绕过暗蝠蛋", Default = false, Tooltip = "防止踩到'暗蝠'蛋受伤。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassSeekObstructions", { Text = "绕过追逐障碍", Default = false, Tooltip = "防止'追逐'中的障碍伤害你。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassVacuum", { Text = "绕过真空", Default = false, Tooltip = "防止你掉入'真空'假门。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassKillbricks", { Text = "绕过致命砖块", Default = false, Tooltip = "防止'岩浆'伤害你。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassSeekingWall", { Text = "绕过追逐墙", Default = false, Tooltip = "防止'恐怖墙'伤害你。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassSnare", { Text = "绕过陷阱", Default = false, Tooltip = "防止'陷阱'困住你。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassBanana", { Text = "绕过香蕉皮", Default = false, Tooltip = "防止'香蕉皮'让你滑倒（有时无效）。" })
Groupboxes.Exploits_Bypass:AddToggle("BypassJeff", { Text = "绕过杰夫", Default = false, Tooltip = "防止'杀手杰夫'刺你（有时无效）。" })

Toggles.BypassGiggle:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "GiggleCeiling" then
			Object:WaitForChild("Hitbox").CanTouch = not Value
		end
	end
end)

Toggles.BypassDupe:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "DoorFake" or Object.Name == "FakeDoor" then
			Object:WaitForChild("Hidden").CanTouch = not Value
			if Object:FindFirstChild("Lock") then
				Object.Lock.UnlockPrompt.Enabled = not Value
			end
		end
	end
end)

Toggles.BypassEyes:OnChanged(function(Value)
	if Value and Globals.IsEyes then
		if Floor == "Fools" or Floor == "OldHotel" then
			RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
		else
			RemotesFolder.MotorReplication:FireServer(-650)
		end
	end
end)

Toggles.BypassLookman:OnChanged(function(Value)
	if Value and Globals.IsLookman then
		if Floor == "Fools" or Floor == "OldHotel" then
			RemotesFolder.MotorReplication:FireServer(0, (Globals.SpoofOffset == 200 and 65 or -65), 0, false)
		else
			RemotesFolder.MotorReplication:FireServer(-650)
		end
	end
end)

Toggles.BypassGloombatEggs:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		for _, Part in Object:GetDescendants() do
			if Part:IsA("BasePart") then
				Part.CanTouch = not Value
			end
		end
	end
end)

Toggles.BypassSeekObstructions:OnChanged(function(Value)
	for _, Object in Objects.SeekObstructions do
		Object.CanTouch = not Value
		if Object.Name == "SeekFloodline" then
			Object.CanCollide = Value
		end
	end
	for _, Object in Objects.SeekBridges do
		Object.CanCollide = Value
		Object.Transparency = Value and 0 or 1
	end
end)

Toggles.BypassVacuum:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "SideroomSpace" then
			Object:WaitForChild("Collision").CanCollide = Value
			Object:WaitForChild("Collision").CanTouch = not Value
		end
	end
end)

Toggles.BypassKillbricks:OnChanged(function(Value)
	for _, Object in Objects.Obstructions do
		if Object.Name == "Lava" then Object.CanTouch = not Value end
	end
end)

Toggles.BypassSeekingWall:OnChanged(function(Value)
	for _, Object in Objects.Obstructions do
		if Object.Name == "ScaryWall" then
			for _, Part in Object:GetDescendants() do
				if Part:IsA("BasePart") then
					Part.CanTouch = not Value
					Part.CanCollide = not Value
				end
			end
		end
	end
end)

Toggles.BypassSnare:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "Snare" then
			for _, Part in Object:GetDescendants() do
				if Part:IsA("BasePart") then Part.CanTouch = not Value end
			end
		end
	end
end)

Toggles.BypassBanana:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "BananaPeel" then Object.CanTouch = not Value end
	end
end)

Toggles.BypassJeff:OnChanged(function(Value)
	for _, Object in Objects.Entities do
		if Object.Name == "JeffTheKiller" then
			for _, Part in Object:GetDescendants() do
				if Part:IsA("BasePart") then
					Part.CanCollide = not Value
					Part.CanTouch = not Value
				end
			end
			Object:WaitForChild("Humanoid").Health = 0
		end
	end
end)

-- 档案室
Groupboxes.Archives_Misc = Tabs.Archives:AddRightGroupbox("漏洞 / 防制")
Groupboxes.Archives_Misc:AddToggle("AntiRansom", { Text = "防赎金", Default = false, Tooltip = "防止'赎金'攻击你。" })
Groupboxes.Archives_Misc:AddToggle("AntiClosetTrash", { Text = "防衣柜垃圾", Default = false, Tooltip = "防止'衣柜垃圾'生成。" })
Groupboxes.Archives_Misc:AddToggle("ForgetMeNotSolver", { Text = "勿忘我跳过器", Default = false, Tooltip = "自动跳过勿忘我门。" })
Groupboxes.Archives_Misc:AddToggle("TimeShower", { Text = "时间显示", Default = false, Tooltip = "显示档案室时钟时间。" })
Groupboxes.Archives_Misc:AddToggle("BypassDronesStampede", { Text = "停止时间/防踩踏", Default = false, Tooltip = "防止'无人机群'攻击你。" })
Groupboxes.Archives_Misc:AddToggle("HonchoCorrectBoxESP", { Text = "老板正确箱子透视", Default = false, Tooltip = "透视档案室正确箱子。" })

TimeShowerLabel = Instance.new("TextLabel")
TimeShowerLabel.Name = "TimeShower"
TimeShowerLabel.AnchorPoint = Vector2.new(0, 1)
TimeShowerLabel.Position = UDim2.new(0, 12, 1, -12)
TimeShowerLabel.Size = UDim2.new(0, 180, 0, 32)
TimeShowerLabel.BackgroundTransparency = 1
TimeShowerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeShowerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TimeShowerLabel.TextStrokeTransparency = 0.35
TimeShowerLabel.Font = Enum.Font.GothamBold
TimeShowerLabel.TextSize = 18
TimeShowerLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeShowerLabel.Text = "时间: --:--"
TimeShowerLabel.Visible = false
TimeShowerLabel.Parent = Container

Toggles.HonchoCorrectBoxESP:OnChanged(function(Value)
	if HonchoCorrectBoxConnection then
		HonchoCorrectBoxConnection:Disconnect()
		HonchoCorrectBoxConnection = nil
	end
	for _, Object in pairs(HonchoESPObjects) do
		if Object and Object.Parent then
			Functions.RemoveESP(Object)
		end
	end
	table.clear(HonchoESPObjects)
	table.clear(HonchoProcessedRooms)
	if not Value then
		return
	end

	local function ProcessHonchoRoom(Room)
		if not tonumber(Room.Name) then
			return
		end
		if HonchoProcessedRooms[Room] then
			return
		end
		HonchoProcessedRooms[Room] = true
		task.wait(3)
		if not Toggles.HonchoCorrectBoxESP.Value or not Room.Parent then
			HonchoProcessedRooms[Room] = nil
			return
		end
		local HonchoRoom = Room:FindFirstChild("ArchivesHonchoRoom", true)
		if not HonchoRoom then
			HonchoProcessedRooms[Room] = nil
			return
		end
		local BoxIDs = {}
		local depositCount = 0
		for _, Desc in ipairs(Room:GetDescendants()) do
			if Desc.Name == "ArchivesPackageDeposit" then
				depositCount += 1
				local BoxID = Desc:GetAttribute("BoxID")
				if BoxID ~= nil then
					BoxIDs[BoxID] = true
				end
			end
		end
		if next(BoxIDs) == nil then
			HonchoProcessedRooms[Room] = nil
			return
		end
		local RoomNumber = tonumber(Room.Name)
		for _, Child in HonchoRoom:GetDescendants() do
			if Child.Name == "ArchivesStorageBox" then
				local ToolBoxID = Child:GetAttribute("Tool_BoxID")
				if ToolBoxID ~= nil and BoxIDs[ToolBoxID] then
					if Toggles.HonchoCorrectBoxESP.Value then
						if not Child:GetAttribute("ParentRoom") then
							Child:SetAttribute("ParentRoom", RoomNumber)
						end
						local Color = (Options.ObjectiveESPColor and Options.ObjectiveESPColor.Value) or Color3.fromRGB(0, 255, 0)
						Functions.AddESP({
							Object = Child,
							Text = "正确箱子",
							Color = Color
						}, true)
						table.insert(HonchoESPObjects, Child)
						Child.Destroying:Once(function()
							Functions.RemoveESP(Child)
							local pos = table.find(HonchoESPObjects, Child)
							if pos then
								table.remove(HonchoESPObjects, pos)
							end
						end)
					end
				end
			end
		end
	end

	local currentRooms = workspace:FindFirstChild("CurrentRooms")
	if not currentRooms then
		return
	end
	for _, Room in ipairs(currentRooms:GetChildren()) do
		task.spawn(ProcessHonchoRoom, Room)
	end
	HonchoCorrectBoxConnection = currentRooms.ChildAdded:Connect(function(Room)
		task.spawn(ProcessHonchoRoom, Room)
	end)
end)

local function GetArchivesClockLabel(Room)
	local Assets = Room and Room:FindFirstChild("Assets", true)
	local Clock = Assets and Assets:FindFirstChild("ArchivesClock", true)
	local Time = Clock and Clock:FindFirstChild("Time", true)
	local TextLabel = Time and Time:FindFirstChild("TextLabel")
	if TextLabel and TextLabel:IsA("TextLabel") then
		return TextLabel
	end
	return nil
end

local function ResolveClockLabel()
	if TimeShowerSourceLabel and TimeShowerSourceLabel.Parent and TimeShowerSourceLabel:IsDescendantOf(game) then
		return TimeShowerSourceLabel
	end
	local currentRooms = workspace:FindFirstChild("CurrentRooms")
	if not currentRooms then return nil end
	local rooms = {}
	for _, room in ipairs(currentRooms:GetChildren()) do
		local num = tonumber(room.Name)
		if num then
			table.insert(rooms, {room = room, num = num})
		end
	end
	table.sort(rooms, function(a, b)
		return a.num > b.num
	end)
	local endIndex = math.min(6, #rooms)
	for i = 1, endIndex do
		local label = GetArchivesClockLabel(rooms[i].room)
		if label then
			TimeShowerSourceLabel = label
			return label
		end
	end
	return nil
end

local function ResolveClockRemote()
	local label = ResolveClockLabel()
	if not label then return nil end
	local clock = label:FindFirstAncestor("ArchivesClock")
	if not clock then return nil end
	local remote = clock:FindFirstChild("LookedAtRemote", true)
	return (remote and remote:IsA("RemoteEvent")) and remote or nil
end

task.spawn(function()
	local lastCheckedRoomCount = 0
	while game:IsLoaded() do
		local currentRooms = workspace:FindFirstChild("CurrentRooms")
		if currentRooms then
			local roomCount = 0
			for _, child in ipairs(currentRooms:GetChildren()) do
				if tonumber(child.Name) then
					roomCount += 1
				end
			end
			if roomCount > 0 and (lastCheckedRoomCount == 0 or (roomCount - lastCheckedRoomCount) >= 10) then
				ResolveClockLabel()
				lastCheckedRoomCount = roomCount
			end
		end
		task.wait(0.5)
	end
end)

local function StopTimeShower()
	TimeShowerToken += 1
	if TimeShowerConnection then
		TimeShowerConnection:Disconnect()
		TimeShowerConnection = nil
	end
	if TimeShowerLabel then
		TimeShowerLabel.Visible = false
		TimeShowerLabel.Text = "时间: --:--"
	end
end

Toggles.TimeShower:OnChanged(function(Value)
	StopTimeShower()
	if not Value then return end
	local Token = TimeShowerToken
	TimeShowerLabel.Visible = true
	TimeShowerConnection = Services.RunService.Heartbeat:Connect(function()
		if Token ~= TimeShowerToken then return end
		local TextLabel = ResolveClockLabel()
		if TextLabel then
			TimeShowerLabel.Text = "时间: " .. TextLabel.Text
		else
			TimeShowerLabel.Text = "时间: --:--"
		end
	end)
end)

Toggles.BypassDronesStampede:OnChanged(function(enabled)
	if BypassDronesStampedeConnection then
		task.cancel(BypassDronesStampedeConnection)
		BypassDronesStampedeConnection = nil
	end
	if not enabled then return end
	BypassDronesStampedeConnection = task.spawn(function()
		while Toggles.BypassDronesStampede.Value do
			local remote = ResolveClockRemote()
			if remote then
				remote:FireServer()
			end
			task.wait(1)
		end
	end)
end)

Groupboxes.Archives_Bypasses = Tabs.Archives:AddLeftGroupbox("绕过")
Groupboxes.Archives_Bypasses:AddToggle("BypassWater", { Text = "绕过电水", Default = false, Tooltip = "防止电水伤害你。" })
Groupboxes.Archives_Bypasses:AddToggle("BypassAlma", { Text = "绕过阿尔玛", Default = false, Tooltip = "防止'阿尔玛'生成。" })
Groupboxes.Archives_Bypasses:AddToggle("BypassDrones", { Text = "绕过无人机", Default = false, Tooltip = "防止'无人机'攻击你。" })
Groupboxes.Archives_Bypasses:AddToggle("AntiScribbles", { Text = "绕过涂鸦", Default = false, Tooltip = "防止'涂鸦'攻击你。" })

Groupboxes.Archives_Experimental = Tabs.Archives:AddLeftGroupbox("实验性")

Toggles.AntiClosetTrash:OnChanged(function(Value)
	if AntiClosetTrash_Connection then
		AntiClosetTrash_Connection:Disconnect()
		AntiClosetTrash_Connection = nil
	end
	if not Value then
		return
	end
	AntiClosetTrash_Connection = workspace.ChildAdded:Connect(function(Child)
		if not Toggles.AntiClosetTrash.Value then
			return
		end
		local Name = Child.Name
		if (Name:sub(1, 6) == "Binder"
			or Name:sub(1, 4) == "Shoe"
			or Name:sub(1, 5) == "Shelf")
			then
			Child:Destroy()
		end
	end)
end)

Toggles.AntiRansom:OnChanged(function(Value)
	if AntiRansom_Connection then
		AntiRansom_Connection:Disconnect()
		AntiRansom_Connection = nil
	end
	if not Value then
		return
	end
	AntiRansom_Connection = workspace.ChildAdded:Connect(function(Child)
		if Child.Name == "Ransom" and Toggles.AntiRansom.Value then
			Child:Destroy()
			print("赎金消失了嘿嘿嘿嘿嘿嘿嘿嘿")
		end
	end)
end)

Toggles.ForgetMeNotSolver:OnChanged(function(Value)
	if ForgetMeNotConnection then
		ForgetMeNotConnection:Disconnect()
		ForgetMeNotConnection = nil
	end
	ForgetMeNotRunning = false
	ForgetMeNotProcessing = {}
	ForgetMeNotNotified = {}
	if not Value then
		return
	end
	ForgetMeNotRunning = true

	local function GetCharacter()
		return game.Players.LocalPlayer.Character
			or game.Players.LocalPlayer.CharacterAdded:Wait()
	end

	local function GetNextRoom(Number)
		while ForgetMeNotRunning do
			for RoomNumber = Number + 1, Number + 5 do
				local NextRoom = workspace.CurrentRooms:FindFirstChild(tostring(RoomNumber))
				if NextRoom then
					return NextRoom
				end
			end
			task.wait(0.1)
		end
		return nil
	end

	local function FireLookAts(Room)
		for i = 1, 6 do
			local Obj = Room:FindFirstChild(tostring(i))
			if Obj then
				local LookAt = Obj:FindFirstChild("LookAt")
				if LookAt then
					pcall(function()
						LookAt:FireServer()
					end)
				end
			end
		end
	end

	local function Run(Room)
		if not ForgetMeNotRunning or ForgetMeNotProcessing[Room] then
			return
		end
		ForgetMeNotProcessing[Room] = true
		task.wait(2)
		if not ForgetMeNotRunning or not Room.Parent then
			ForgetMeNotProcessing[Room] = nil
			return
		end
		if not Room:FindFirstChild("ForgetMeNotVineDoors", true) then
			ForgetMeNotProcessing[Room] = nil
			return
		end
		FireLookAts(Room)
		local NextRoom = GetNextRoom(tonumber(Room.Name))
		if not NextRoom then
			ForgetMeNotProcessing[Room] = nil
			return
		end
		local Door = NextRoom:FindFirstChild("Door")
		if not Door then
			ForgetMeNotProcessing[Room] = nil
			return
		end
		if Door:GetAttribute("Opened") == true then
			ForgetMeNotProcessing[Room] = nil
			return
		end
		if not Room:FindFirstChild(game.Players.LocalPlayer.Name, true) then
			if not ForgetMeNotNotified[Room] then
				ForgetMeNotNotified[Room] = true
				Functions.Notify({Title = "请进入第一扇勿忘我门"})
			end
			repeat
				task.wait()
			until Room:FindFirstChild(game.Players.LocalPlayer.Name, true)
				or not ForgetMeNotRunning
				or not Room.Parent
			if not ForgetMeNotRunning or not Room.Parent then
				ForgetMeNotProcessing[Room] = nil
				return
			end
		end
		if not ForgetMeNotRunning or Door:GetAttribute("Opened") == true then
			ForgetMeNotProcessing[Room] = nil
			return
		end
		local Hidden = Door:WaitForChild("Hidden", 10)
		if not Hidden or not ForgetMeNotRunning or Door:GetAttribute("Opened") == true then
			ForgetMeNotProcessing[Room] = nil
			return
		end
		task.wait(3)
		if not ForgetMeNotRunning or not NextRoom.Parent or Door:GetAttribute("Opened") == true then
			ForgetMeNotProcessing[Room] = nil
			return
		end
		while ForgetMeNotRunning and NextRoom.Parent and Door:GetAttribute("Opened") ~= true do
			local Character = GetCharacter()
			if Character then
				if Hidden:IsA("BasePart") then
					Character:PivotTo(Hidden.CFrame)
				elseif Hidden:IsA("Model") then
					Character:PivotTo(Hidden:GetPivot())
				end
			end
			pcall(function()
				Door.ClientOpen:Fire()
			end)
			pcall(function()
				Door.ClientOpen:FireServer()
			end)
			task.wait()
		end
		if ForgetMeNotRunning and Door:GetAttribute("Opened") == true then
			local Character = GetCharacter()
			if Character then
				Character:PivotTo(CFrame.new(0, -120, 0))
				Character:PivotTo(CFrame.new(0, -120, 0))
				Character:PivotTo(CFrame.new(0, -120, 0))
				Character:PivotTo(CFrame.new(0, -120, 0))
				Functions.Notify({Title = "如果卡在勿忘我中使用调试虚空"})
			end
			ForgetMeNotNotified[Room] = nil
		end
		ForgetMeNotProcessing[Room] = nil
	end

	local function CheckRooms()
		local LatestRoomNumber = tonumber(LatestRoom.Value) or 0
		local FirstRoomNumber = math.max(0, LatestRoomNumber - 4)
		for RoomNumber = FirstRoomNumber, LatestRoomNumber do
			if not ForgetMeNotRunning then
				return
			end
			local Room = workspace.CurrentRooms:FindFirstChild(tostring(RoomNumber))
			if Room and not ForgetMeNotProcessing[Room] then
				task.spawn(Run, Room)
			end
		end
	end

	ForgetMeNotConnection = workspace.CurrentRooms.ChildAdded:Connect(function(Room)
		if not tonumber(Room.Name) then
			return
		end
		task.spawn(function()
			task.wait(2)
			if ForgetMeNotRunning and Room.Parent then
				task.spawn(Run, Room)
			end
		end)
	end)

	task.spawn(function()
		while ForgetMeNotRunning do
			CheckRooms()
			task.wait(2)
		end
	end)

	CheckRooms()
end)

Toggles.BypassWater:OnChanged(function(Value)
	Functions.Notify({Title = "位置伪装会破坏此功能！"})
	if WaterBypassConnection then
		WaterBypassConnection:Disconnect()
		WaterBypassConnection = nil
	end
	if Value then
		local function ProcessWaterBypassRoom(WaterBypassRoom)
			if not tonumber(WaterBypassRoom.Name) then
				return
			end
			task.wait(3)
			local WaterBypassWater = WaterBypassRoom:FindFirstChild("Water")
			if not WaterBypassWater or WaterParts[WaterBypassWater] then
				return
			end
			local WaterBypassPart = Instance.new("Part")
			WaterBypassPart.Name = "WaterBypass"
			WaterBypassPart.Anchored = true
			WaterBypassPart.CanCollide = true
			WaterBypassPart.CanTouch = false
			WaterBypassPart.CanQuery = false
			WaterBypassPart.Transparency = 0.25
			WaterBypassPart.Color = Color3.fromRGB(0, 150, 255)
			WaterBypassPart.Material = Enum.Material.ForceField
			if WaterBypassWater:IsA("BasePart") then
				WaterBypassPart.Size = WaterBypassWater.Size + Vector3.new(0, 0.5, 0)
				WaterBypassPart.CFrame = WaterBypassWater.CFrame * CFrame.new(0, 0.25, 0)
			elseif WaterBypassWater:IsA("Model") then
				local WaterBypassCFrame, WaterBypassSize = WaterBypassWater:GetBoundingBox()
				WaterBypassPart.Size = WaterBypassSize + Vector3.new(0, 0.5, 0)
				WaterBypassPart.CFrame = WaterBypassCFrame * CFrame.new(0, 0.25, 0)
			else
				WaterBypassPart.Size = Vector3.new(10, 1.5, 10)
				WaterBypassPart.CFrame = WaterBypassWater:GetPivot() * CFrame.new(0, 0.25, 0)
			end
			if WaterBypassPart.Size.Y > 3 then
				WaterBypassPart:Destroy()
				Functions.Notify({
					Title = "水绕过已移除：软锁。",
				})
				return
			end
			WaterBypassPart.Parent = WaterBypassRoom
			WaterParts[WaterBypassWater] = WaterBypassPart
		end
		local WaterBypassLatestRoomNumber = tonumber(LatestRoom.Value) or 0
		for WaterBypassRoomNumber = math.max(0, WaterBypassLatestRoomNumber - 4), WaterBypassLatestRoomNumber do
			local WaterBypassRoom = workspace.CurrentRooms:FindFirstChild(tostring(WaterBypassRoomNumber))
			if WaterBypassRoom then
				task.spawn(ProcessWaterBypassRoom, WaterBypassRoom)
			end
		end
		WaterBypassConnection = workspace.CurrentRooms.ChildAdded:Connect(function(WaterBypassRoom)
			task.spawn(ProcessWaterBypassRoom, WaterBypassRoom)
		end)
	else
		for _, WaterBypassPart in pairs(WaterParts) do
			if WaterBypassPart then
				WaterBypassPart:Destroy()
			end
		end
		table.clear(WaterParts)
	end
end)

Toggles.BypassAlma:OnChanged(function(Value)
	if AlmaConnection then
		AlmaConnection:Disconnect()
		AlmaConnection = nil
	end
	if Value then
		for _, child in ipairs(workspace:GetChildren()) do
			if child.Name == "Alma" then
				child:Destroy()
			end
		end
		AlmaConnection = workspace.ChildAdded:Connect(function(child)
			if child.Name == "Alma" then
				child:Destroy()
			end
		end)
	end
end)

Toggles.AntiScribbles:OnChanged(function(Value)
	if AntiScribbles_Connection then
		AntiScribbles_Connection:Disconnect()
		AntiScribbles_Connection = nil
	end
	if not Value then
		return
	end
	AntiScribbles_Connection = workspace.ChildAdded:Connect(function(Child)
		if Child.Name == "Scribbles" and Toggles.AntiScribbles.Value then
			local ExploitSribbleWarning = Child:FindFirstChild("IfYoureExploitingDeleteThis")
			if ExploitSribbleWarning then
				ExploitSribbleWarning:Destroy()
			end
		end
	end)
end)

Toggles.BypassDronesStampede:OnChanged(function(BypassDronesStampedeEnabled)
	if BypassDronesStampedeConnection then
		task.cancel(BypassDronesStampedeConnection)
		BypassDronesStampedeConnection = nil
	end
	if not BypassDronesStampedeEnabled then
		return
	end
	BypassDronesStampedeConnection = task.spawn(function()
		while Toggles.BypassDronesStampede.Value do
			if not TimeShowerSourceLabel then
				task.wait(0.25)
				continue
			end
			local clockLabel = TimeShowerSourceLabel
			local clock = clockLabel:FindFirstAncestor("ArchivesClock")
			if not clock or not clock.Parent then
				task.wait(0.25)
				continue
			end
			local lookedAtRemote = clock:FindFirstChild("LookedAtRemote", true)
			if not lookedAtRemote or not lookedAtRemote:IsA("RemoteEvent") then
				task.wait(0.25)
				continue
			end
			while Toggles.BypassDronesStampede.Value
				and TimeShowerSourceLabel == clockLabel
				and clock.Parent
			do
				lookedAtRemote:FireServer()
				task.wait(0.5)
			end
		end
	end)
end)

Toggles.BypassDrones:OnChanged(function(Value)
	local RS = game:GetService("ReplicatedStorage")
	local function ProcessDrones(drones)
		local WalkedInto = drones:FindFirstChild("WalkedInto") or drones:WaitForChild("WalkedInto", 3)
		if WalkedInto and not DroneWalkedIntoParents[WalkedInto] then
			DroneWalkedIntoParents[WalkedInto] = drones
			WalkedInto.Parent = RS
		end
	end
	if Value then
		for _, child in ipairs(workspace:GetChildren()) do
			if child.Name == "Drones" then
				ProcessDrones(child)
			end
		end
		if DroneConnection then
			DroneConnection:Disconnect()
		end
		DroneConnection = workspace.ChildAdded:Connect(function(child)
			if child.Name == "Drones" then
				ProcessDrones(child)
			end
		end)
	else
		for WalkedInto, originalParent in pairs(DroneWalkedIntoParents) do
			if WalkedInto and WalkedInto.Parent and originalParent and originalParent.Parent then
				WalkedInto.Parent = originalParent
			end
		end
		table.clear(DroneWalkedIntoParents)
		if DroneConnection then
			DroneConnection:Disconnect()
			DroneConnection = nil
		end
	end
end)
-- 楼梯间
Groupboxes.Stairwell_Misc = Tabs.Stairwell:AddLeftGroupbox("漏洞 / 防制")
Groupboxes.Stairwell_Experimental = Tabs.Stairwell:AddLeftGroupbox("实验性")

Groupboxes.Stairwell_Experimental:AddButton({
	Text = "拉取掉落物品",
	Func = function() BringDroppedItems() end,
	DoubleClick = false,
	Tooltip = "拉取所有掉落物品。"
})

Groupboxes.Stairwell_Experimental:AddToggle("EnableDroppedItemsInterval", {
	Text = "启用间隔",
	Default = false,
	Tooltip = "按所选间隔自动拉取掉落物品。"
})

Groupboxes.Stairwell_Experimental:AddSlider("DroppedItemsInterval", {
	Text = "间隔",
	Default = 1,
	Min = 0,
	Max = 60,
	Rounding = 1,
	Compact = false,
	Tooltip = "拉取掉落物品的频率。"
})

Toggles.EnableDroppedItemsInterval:OnChanged(function(enabled)
	if enabled then
		if droppedItemsIntervalRunning then return end
		droppedItemsIntervalRunning = true
		task.spawn(function()
			while Toggles.EnableDroppedItemsInterval.Value do
				BringDroppedItems()
				local interval = Options.DroppedItemsInterval.Value
				if interval <= 0 then
					task.wait()
				else
					task.wait(interval)
				end
			end
			droppedItemsIntervalRunning = false
		end)
	end
end)

Groupboxes.Stairwell_Experimental:AddToggle("AntiNoise", {
	Text = "防噪音",
	Default = false,
	Tooltip = "防止游戏在移动时产生噪音。"
})

Groupboxes.Stairwell_Experimental:AddToggle("BypassNoise", {
	Text = "噪音电视破坏者",
	Default = false,
	Tooltip = "在拿着电视时破坏噪音的电视。"
})

Toggles.AntiNoise:OnChanged(function(value)
	for i, conn in ipairs(Connections) do
		if conn.Disconnect then
			conn:Disconnect()
			table.remove(Connections, i)
		end
	end
	local antiNoiseConn = RunService.PreSimulation:Connect(function(dt)
		if not value then return end
		if not LocalPlayer:GetAttribute("Alive") then return end
		local character = LocalPlayer.Character
		if not character then return end
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local camera = workspace.CurrentCamera
		if not rootPart or not humanoid or not camera then return end
		if humanoid.Health <= 0 then return end
		if rootPart.Anchored then return end
		local state = humanoid:GetState()
		if state == Enum.HumanoidStateType.Dead
			or state == Enum.HumanoidStateType.Ragdoll
			or state == Enum.HumanoidStateType.Climbing
			or state == Enum.HumanoidStateType.Swimming
		then
			return
		end
		humanoid.AutoRotate = false
		humanoid:Move(Vector3.zero, false)
		local inputVector = Controls:GetMoveVector()
		local inputMagnitude = inputVector.Magnitude
		if inputMagnitude <= 0 then
			rootPart.AssemblyLinearVelocity = Vector3.zero
			return
		end
		local cameraCFrame = camera.CFrame
		local cameraForward = Vector3.new(cameraCFrame.LookVector.X, 0, cameraCFrame.LookVector.Z)
		local cameraRight = Vector3.new(cameraCFrame.RightVector.X, 0, cameraCFrame.RightVector.Z)
		if cameraForward.Magnitude < 0.001 or cameraRight.Magnitude < 0.001 then return end
		cameraForward = cameraForward.Unit
		cameraRight = cameraRight.Unit
		local worldDirection = (cameraRight * inputVector.X) + (cameraForward * -inputVector.Z)
		if worldDirection.Magnitude <= 0 then return end
		worldDirection = worldDirection.Unit
		local finalSpeed = humanoid.WalkSpeed * math.clamp(inputMagnitude, 0, 1)
		local clampedDt = math.clamp(dt, 0, 1 / 30)
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.CFrame = rootPart.CFrame + (worldDirection * finalSpeed * clampedDt)
		rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + worldDirection)
	end)
	table.insert(Connections, antiNoiseConn)
end)

Toggles.BypassNoise:OnChanged(function(value)
	for i = #Connections, 1, -1 do
		local existingConnection = Connections[i]
		if existingConnection and existingConnection.Disconnect then
			existingConnection:Disconnect()
		end
		table.remove(Connections, i)
	end
	if not value then return end
	local bypassNoiseLocalPlayerUserId = localUserId or (localPlayer and localPlayer.UserId) or (LocalPlayer and LocalPlayer.UserId)

	local function checkBypassNoiseTvStand(targetTvStand)
		if not targetTvStand:IsA("Model") then return end
		if targetTvStand.Name ~= "TV_Stand" then return end
		if targetTvStand:GetAttribute("LastPusherId") ~= bypassNoiseLocalPlayerUserId then return end
		local tvStandCurrentCFrame = targetTvStand:GetPivot()
		if tvStandCurrentCFrame.Position.Y > -119 then
			targetTvStand:PivotTo(CFrame.new(tvStandCurrentCFrame.Position.X, -120, tvStandCurrentCFrame.Position.Z))
			Functions.Notify({ Title = "卸下电视。" })
		end
	end

	local function checkBypassNoiseAllTvStands()
		local bypassNoiseMiscFolder = workspace:FindFirstChild("Misc")
		if not bypassNoiseMiscFolder then return end
		for _, bypassNoiseMiscChild in ipairs(bypassNoiseMiscFolder:GetChildren()) do
			checkBypassNoiseTvStand(bypassNoiseMiscChild)
		end
	end

	local bypassNoiseMiscFolder = workspace:FindFirstChild("Misc")
	if bypassNoiseMiscFolder then
		local bypassNoiseMiscChildAddedConnection = bypassNoiseMiscFolder.ChildAdded:Connect(function(bypassNoiseNewChild)
			task.wait(0.1)
			checkBypassNoiseTvStand(bypassNoiseNewChild)
		end)
		Connections[#Connections + 1] = bypassNoiseMiscChildAddedConnection
	end

	task.spawn(function()
		while Toggles.BypassNoise.Value do
			checkBypassNoiseAllTvStands()
			task.wait(1)
		end
	end)
end)

Groupboxes.Exploits_BypassRight = Tabs.Exploits:AddRightGroupbox("绕过")
Groupboxes.Exploits_BypassRight:AddToggle("DisableAnticheat", {
	Text = "反作弊绕过",
	Default = false,
	Tooltip = "与梯子交互后完全禁用反作弊。"
})
Groupboxes.Exploits_BypassRight:AddToggle("VelocityManipulationToggle", {
	Text = "速度操控",
	Default = false,
	Tooltip = "缓慢向前移动你的角色，减轻游戏的反穿墙检测。"
})

Toggles.DisableAnticheat:OnChanged(function(Value)
	if Globals.AnticheatDisabled == true and not Value then
		RemotesFolder.ClimbLadder:FireServer()
		Globals.AnticheatDisabled = false
	end
end)

Toggles.VelocityManipulationToggle:AddKeyPicker("VelocityManipulationKeybind", {
	Text = "速度操控",
	Default = "V",
	Mode = Library.IsMobile and "Toggle" or "Hold",
	SyncToggleState = true
})

Groupboxes.Exploits_BypassRight:AddDropdown("VelocityManipulationMode", {
	Values = {"速度", "旋转"},
	Text = "操控方法",
	Default = 1,
})

Groupboxes.Exploits_BypassRight:AddDivider()

Groupboxes.Exploits_BypassRight:AddToggle("InfiniteItemsToggle", {
	Text = "无限物品",
	Default = false,
	Tooltip = "允许某些物品在使用时不消耗耐久。",
	Disabled = not Functions.CheckCompatability({"fireproximityprompt"}),
	DisabledTooltip = Globals.IncompatibleMessage
})

Groupboxes.Exploits_BypassRight:AddDropdown("InfiniteItemsList", {
	Text = "物品列表",
	Values = { "开锁器", "万能钥匙", "剪刀", "多功能工具" },
	Multi = true,
	AllowNull = true,
	Disabled = not Functions.CheckCompatability({"fireproximityprompt"}),
	DisabledTooltip = Globals.IncompatibleMessage
})

Groupboxes.Exploits_BypassRight:AddToggle("InfCrucifix", {
	Text = "无限十字架",
	Default = false,
	Tooltip = "有风险！你可能会死亡或丢失十字架。建议低延迟和稳定帧率。",
	Risky = Floor ~= "Ballz",
})

local InfCrucifixDropTable = {
	RushMoving = 54,
	AmbushMoving = 67,
	A60 = 70,
	GlitchRush = 120,
	GlitchAmbush = 155,
	A120 = 75,
}

Toggles.InfCrucifix:OnChanged(function(Value)
	print("我还活着")
	local InfCrucifixRaycastParams = RaycastParams.new()
	InfCrucifixRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local InfCrucifixConnection
	InfCrucifixConnection = RunService.RenderStepped:Connect(function()
		if not Toggles.InfCrucifix.Value then
			if InfCrucifixConnection then
				InfCrucifixConnection:Disconnect()
			end
			return
		end
		local InfCrucifixCharacter = game.Players.LocalPlayer
		if not InfCrucifixCharacter then
			return
		end
		local InfCrucifixCollision = InfCrucifixCharacter:FindFirstChild("CollisionPart")
		if not InfCrucifixCollision then
			return
		end
		InfCrucifixRaycastParams.FilterDescendantsInstances = {InfCrucifixCharacter}
		for _, InfCrucifixEntity in ipairs(Workspace:GetChildren()) do
			local InfCrucifixMaxDistance = InfCrucifixDropTable[InfCrucifixEntity.Name]
			if not InfCrucifixMaxDistance or not InfCrucifixEntity.PrimaryPart then
				continue
			end
			InfCrucifixEntity.PrimaryPart.CanCollide = true
			InfCrucifixEntity.PrimaryPart.CanQuery = true
			local InfCrucifixOrigin = InfCrucifixCollision.Position
			local InfCrucifixDirection = InfCrucifixEntity.PrimaryPart.Position - InfCrucifixOrigin
			local InfCrucifixRayResult = Workspace:Raycast(InfCrucifixOrigin, InfCrucifixDirection, InfCrucifixRaycastParams)
			if not InfCrucifixRayResult or not InfCrucifixRayResult.Instance:IsDescendantOf(InfCrucifixEntity) then
				continue
			end
			local InfCrucifixDistance = (InfCrucifixCollision.Position - InfCrucifixEntity.PrimaryPart.Position).Magnitude
			if InfCrucifixDistance >= InfCrucifixMaxDistance then
				continue
			end
			local InfCrucifixTool = InfCrucifixCharacter:FindFirstChildOfClass("Tool")
			if not InfCrucifixTool or InfCrucifixTool.Name ~= "Crucifix" then
				continue
			end
			task.spawn(function()
				ReplicatedStorage.RemotesFolder.DropItem:FireServer(InfCrucifixTool)
				task.wait(0.54)
				print("嗨")
				local InfCrucifixDrops = Workspace:FindFirstChild("Drops")
				if not InfCrucifixDrops then
					return
				end
				local InfCrucifixDropped = InfCrucifixDrops:FindFirstChild("Crucifix")
				if not InfCrucifixDropped then
					return
				end
				local InfCrucifixPrompt = InfCrucifixDropped:FindFirstChildOfClass("ProximityPrompt")
				if InfCrucifixPrompt then
					fireproximityprompt(InfCrucifixPrompt)
				end
			end)
			print("嗨")
			task.wait(0.6)
		end
	end)
end)

Groupboxes.Exploits_BypassRight:AddDivider()
Groupboxes.Exploits_BypassRight:AddToggle("PositionSpoof", {
	Text = "位置伪装",
	Default = false,
	Tooltip = "让你的角色在服务器上显示在地下，保护你免受冲刺类实体的伤害。"
})
Groupboxes.Exploits_BypassRight:AddToggle("CrouchSpoof", {
	Text = "蹲下伪装",
	Default = false,
	Tooltip = "让游戏认为你一直在蹲下。"
})

Toggles.PositionSpoof:OnChanged(function(Value)
	if Floor ~= "Fools" and Floor ~= "OldHotel" then
		if Value then
			RootPart.CFrame = RootPart.CFrame * CFrame.new(0, -2.346, 0)
			Humanoid.HipHeight = 0.05
			RemotesFolder.Crouch:FireServer(true, true)
		else
			RootPart.CFrame = RootPart.CFrame * CFrame.new(0, 2.346, 0)
			Humanoid.HipHeight = 2.396
		end
	end
end)

Toggles.PositionSpoof:AddKeyPicker("PositionSpoof", {
	Text = "位置伪装",
	Default = "B",
	Mode = "Toggle",
	SyncToggleState = true
})

Toggles.CrouchSpoof:OnChanged(function(Value)
	if RemotesFolder:FindFirstChild("Crouch") then
		RemotesFolder.Crouch:FireServer(Value and true or Functions.IsCrouching(), true)
	end
end)

Groupboxes.Exploits_Remove = Tabs.Exploits:AddRightGroupbox("移除")
Groupboxes.Exploits_Remove:AddToggle("RemoveScreech", { Text = "移除尖叫", Default = false, Tooltip = "防止'尖叫'生成。" })
Groupboxes.Exploits_Remove:AddToggle("RemoveHalt", { Text = "移除停止", Default = false, Tooltip = "防止'停止'生成。" })
Groupboxes.Exploits_Remove:AddToggle("RemoveA90", { Text = "移除A-90", Default = false, Tooltip = "防止'A-90'生成。" })
Groupboxes.Exploits_Remove:AddToggle("RemoveDread", { Text = "移除恐惧", Default = false, Tooltip = "防止'恐惧'生成。" })
Groupboxes.Exploits_Remove:AddToggle("RemoveSurge", { Text = "移除电涌", Default = false, Tooltip = "防止'电涌'生成。"})
Groupboxes.Exploits_Remove:AddDivider()
Groupboxes.Exploits_Remove:AddToggle("NoScreechDamage", { Text = "无尖叫伤害", Default = false, Tooltip = "防止'尖叫'伤害你。" })
Groupboxes.Exploits_Remove:AddToggle("NoHaltDamage", { Text = "无停止伤害", Default = false, Tooltip = "防止'停止'伤害你。" })
Groupboxes.Exploits_Remove:AddToggle("NoA90Damage", { Text = "无A-90伤害", Default = false, Tooltip = "防止'A-90'伤害你。" })
Groupboxes.Exploits_Remove:AddToggle("NoSurgeDamage", { Text = "无电涌伤害", Default = false, Tooltip = "防止'电涌'伤害你。" })

Toggles.NoScreechDamage:OnChanged(function(Value)
	if Value then
		FakeEvents.Screech.Parent = RemotesFolder
		FakeEvents.Screech_Real.Parent = nil
	else
		FakeEvents.Screech_Real.Parent = RemotesFolder
		FakeEvents.Screech.Parent = nil
	end
end)

Toggles.NoHaltDamage:OnChanged(function(Value)
	if Value then
		FakeEvents.Shade.Parent = RemotesFolder
		FakeEvents.Shade_Real.Parent = nil
	else
		FakeEvents.Shade_Real.Parent = RemotesFolder
		FakeEvents.Shade.Parent = nil
	end
end)

Toggles.NoA90Damage:OnChanged(function(Value)
	if RemotesFolder:FindFirstChild("A90") then
		if Value then
			FakeEvents.A90.Parent = RemotesFolder
			FakeEvents.A90_Real.Parent = nil
		else
			FakeEvents.A90_Real.Parent = RemotesFolder
			FakeEvents.A90.Parent = nil
		end
	end
end)

Toggles.NoSurgeDamage:OnChanged(function(Value)
	if RemotesFolder:FindFirstChild("SurgeRemote") then
		if Value then
			FakeEvents.Surge.Parent = RemotesFolder
			FakeEvents.Surge_Real.Parent = nil
		else
			FakeEvents.Surge_Real.Parent = RemotesFolder
			FakeEvents.Surge.Parent = nil
		end
	end
end)

local Modules = {}

Toggles.RemoveScreech:OnChanged(function(Value)
	if Value then
		task.spawn(function()
			while Toggles.RemoveScreech.Value do
				local Camera = workspace:FindFirstChild("Camera")
				if Camera then
					local Screech = Camera:FindFirstChild("Screech")
					if Screech then
						Screech:Destroy()
					end
				end
				task.wait()
			end
		end)
	end
end)

Toggles.RemoveHalt:OnChanged(function(Value)
	Modules.Shade.Name = Value and "Shade_Disabled" or "Shade"
end)

Toggles.RemoveA90:OnChanged(function(Value)
	if Modules.A90 then
		Modules.A90.Name = Value and "A90_Disabled" or "A90"
	end
end)

Toggles.RemoveDread:OnChanged(function(Value)
	if Modules.Dread then
		Modules.Dread.Name = Value and "Dread_Disabled" or "Dread"
	end
end)

Toggles.RemoveSurge:OnChanged(function(Value)
	if Globals.SurgeFrame then
		Globals.SurgeFrame.Name = (Value and "SurgeVignette_Disabled" or "SurgeVignette")
	end
end)

Groupboxes.Exploits_Audio = Tabs.Exploits:AddLeftGroupbox("音频")
Globals.JamMuffle = Services.SoundService:WaitForChild("Main"):FindFirstChild("Jamming") or Instance.new("EqualizerSoundEffect")

Groupboxes.Exploits_Audio:AddToggle("RemoveFootstepSounds", {
	Text = "移除脚步声",
	Default = false,
	Tooltip = "移除行走时的声音。"
})
Groupboxes.Exploits_Audio:AddToggle("RemoveJamminMusic", {
	Text = "移除干扰音乐",
	Default = false,
	Tooltip = "移除'干扰'修改器的音乐和闷音效果。"
})
Groupboxes.Exploits_Audio:AddToggle("RemoveInteractingSounds", {
	Text = "移除交互声音",
	Default = false,
	Tooltip = "移除与交互提示互动时的声音。"
})

Toggles.RemoveJamminMusic:OnChanged(function(Value)
	local Jam = Globals.MainUI.Initiator.Main_Game.Health:FindFirstChild("Jam")
	if Jam then
		Jam.Volume = Value and 0 or 0.45
		Globals.JamMuffle.Enabled = LiveModifiers:FindFirstChild("Jammin") and not Value or false
	end
end)

Toggles.RemoveInteractingSounds:OnChanged(function(Value)
	local PS = Globals.MainUI.Initiator.Main_Game.PromptService
	PS.Triggered.Volume = Value and 0 or 0.04
	PS.Holding.Volume = Value and 0 or 0.1
	PS.Notification.Volume = Value and 0 or 0.03
	Globals.MainUI.Initiator.Main_Game.Reminder.Caption.Volume = Value and 0 or 0.1
end)

Groupboxes.Visuals_LeftTab = Tabs.Visuals:AddLeftTabbox("相机 / 效果")
Groupboxes.Visuals_Camera = Groupboxes.Visuals_LeftTab:AddTab("相机")

Groupboxes.Visuals_Camera:AddToggle("AmbientToggle", {
	Text = "环境光",
	Default = false,
	Tooltip = "将光照颜色更改为指定值。"
})
Groupboxes.Visuals_Camera:AddSlider("FieldOfView", {
	Text = "视野",
	Min = 1,
	Max = 120,
	Default = 70,
	Rounding = 0
})
Groupboxes.Visuals_Camera:AddToggle("FOVToggle", {
	Text = "自定义视野",
	Default = false,
	Tooltip = "仅在启用时应用视野滑块。"
})
Toggles.FOVToggle:AddKeyPicker("FovToggle", {
	Text = "自定义视野",
	Default = "O",
	Mode = "Toggle",
	SyncToggleState = true
})

Groupboxes.Visuals_Camera:AddDivider()
Groupboxes.Visuals_Camera:AddToggle("RemoveCameraShake", {
	Text = "移除相机抖动",
	Default = false,
	Tooltip = "防止相机抖动。",
	Disabled = not Functions.CheckCompatability({"require"}),
	DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Visuals_Camera:AddToggle("RemoveCameraBobbing", {
	Text = "移除相机晃动",
	Default = false,
	Tooltip = "防止移动时相机晃动。",
	Disabled = not Functions.CheckCompatability({"require"}),
	DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Visuals_Camera:AddToggle("RemoveCutscenes", {
	Text = "移除过场动画",
	Default = false,
	Tooltip = "移除所有非必要的过场动画。"
})
Groupboxes.Visuals_Camera:AddToggle("RemoveCameraFog", {
	Text = "移除雾气",
	Default = false,
	Tooltip = "移除相机上的所有雾气效果。"
})

Groupboxes.Visuals_Camera:AddDivider()
Groupboxes.Visuals_Camera:AddToggle("ThirdPersonToggle", {
	Text = "第三人称",
	Default = false,
	Tooltip = "拉远相机，让你从背后看到自己的角色。"
})
Toggles.ThirdPersonToggle:AddKeyPicker("ThirdPersonKeybind", {
	Text = "第三人称",
	Default = "T",
	Mode = "Toggle",
	SyncToggleState = true
})
Groupboxes.Visuals_Camera:AddSlider("ThirdPersonOffsetX", {
	Text = "X偏移",
	Min = -10,
	Max = 10,
	Default = 1.5,
	Rounding = 1,
	Compact = true
})
Groupboxes.Visuals_Camera:AddSlider("ThirdPersonOffsetY", {
	Text = "Y偏移",
	Min = -10,
	Max = 10,
	Default = 1,
	Rounding = 1,
	Compact = true
})
Groupboxes.Visuals_Camera:AddSlider("ThirdPersonOffsetZ", {
	Text = "Z偏移",
	Min = -10,
	Max = 10,
	Default = 5,
	Rounding = 1,
	Compact = true
})
Groupboxes.Visuals_Camera:AddToggle("ThirdPersonWallCheck", {
	Text = "墙壁检测",
	Default = false,
	Tooltip = "防止第三人称穿墙。"
})

Groupboxes.Visuals_Camera:AddDivider()
Groupboxes.Visuals_Camera:AddToggle("ViewmodelOffsetToggle", {
	Text = "视图模型偏移",
	Default = false,
	Tooltip = "在持有物品时更改视图模型的偏移。",
	Disabled = not Functions.CheckCompatability({"require"}),
	DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Visuals_Camera:AddSlider("ViewmodelOffsetX", {
	Text = "X偏移",
	Min = -10,
	Max = 10,
	Default = 0,
	Rounding = 1,
	Compact = true,
	Disabled = not Functions.CheckCompatability({"require"}),
	DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Visuals_Camera:AddSlider("ViewmodelOffsetY", {
	Text = "Y偏移",
	Min = -10,
	Max = 10,
	Default = 0,
	Rounding = 1,
	Compact = true,
	Disabled = not Functions.CheckCompatability({"require"}),
	DisabledTooltip = Globals.IncompatibleMessage
})
Groupboxes.Visuals_Camera:AddSlider("ViewmodelOffsetZ", {
	Text = "Z偏移",
	Min = -10,
	Max = 10,
	Default = 0,
	Rounding = 1,
	Compact = true,
	Disabled = not Functions.CheckCompatability({"require"}),
	DisabledTooltip = Globals.IncompatibleMessage
})

Toggles.AmbientToggle:AddColorPicker("AmbientColor", {
	Text = "环境光",
	Default = Color3.fromRGB(255, 255, 255),
	Transparency = 0
})

Toggles.AmbientToggle:OnChanged(function(Value)
	local OldAmbient = CurrentRooms:FindFirstChild(tostring(LocalPlayer:GetAttribute("CurrentRoom"))):GetAttribute("Ambient")
	Services.TweenService:Create(Services.Lighting, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
		Ambient = Value and Options.AmbientColor.Value or OldAmbient
	}):Play()
end)

local Main_Game
local ClientModules

Toggles.RemoveCameraBobbing:OnChanged(function(Value)
	if Main_Game then Main_Game.spring.Speed = Value and 9e9 or 8 end
end)

Toggles.RemoveCameraFog:OnChanged(function(Value)
	Services.Lighting.FogEnd = Value and 10000000 or Globals.OldFog
	for _, Object in Globals.FogInstances do
		Object.Density = Value and 0 or Object:GetAttribute("Density_Old")
	end
end)

Toggles.RemoveCutscenes:OnChanged(function(Value)
	local Cutscenes = Globals.MainUI.Initiator.Main_Game.RemoteListener.Cutscenes
	for _, Object in pairs(Cutscenes:GetChildren()) do
		if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") or table.find(CutsceneNames, Object:GetAttribute("OriginalName")) and Object:IsA("ModuleScript") then
			Object.Name = (Value and Object.Name .. "_Disabled" or Object:GetAttribute("OriginalName"))
		end
	end
	for _, Object in pairs(FloorReplicated:GetChildren()) do
		if table.find(CutsceneNames, Object.Name) and Object:IsA("ModuleScript") or table.find(CutsceneNames, Object:GetAttribute("OriginalName")) and Object:IsA("ModuleScript") then
			Object.Name = (Value and Object.Name .. "_Disabled" or Object:GetAttribute("OriginalName"))
		end
	end
end)

Groupboxes.Visuals_Effects = Groupboxes.Visuals_LeftTab:AddTab("效果")

Groupboxes.Visuals_Effects:AddToggle("TransparentHidingSpotsToggle", {
	Text = "透明躲藏点",
	Default = false,
	Tooltip = "当你进入躲藏点时使其透明。"
})
Groupboxes.Visuals_Effects:AddSlider("TransparentHidingSpotsSlider", {
	Text = "透明度",
	Min = 0,
	Max = 1,
	Default = 0.5,
	Rounding = 2,
	Compact = true
})

local function ApplyHidingTransparency(Value, SliderValue)
	for _, Object in Objects.HidingSpots do
		local IsHiding = false
		for _, Child in Object:GetDescendants() do
			if Child.Name == "HiddenPlayer" and Child.Value == Character then
				IsHiding = true
				break
			end
		end
		for _, Part in Object:GetDescendants() do
			if Part:IsA("BasePart") and Part:GetAttribute("Transparency_Old") then
				Services.TweenService:Create(Part, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
					Transparency = (Value and IsHiding) and SliderValue or Part:GetAttribute("Transparency_Old")
				}):Play()
			end
		end
	end
end

Toggles.TransparentHidingSpotsToggle:OnChanged(function(Value)
	ApplyHidingTransparency(Value, Options.TransparentHidingSpotsSlider.Value)
end)

Options.TransparentHidingSpotsSlider:OnChanged(function(Value)
	ApplyHidingTransparency(Toggles.TransparentHidingSpotsToggle.Value, Value)
end)

Groupboxes.Visuals_Effects:AddDivider()
Groupboxes.Visuals_Effects:AddToggle("DisableGlitchJumpscare", { Text = "禁用故障惊吓", Default = false, Tooltip = "禁用'故障'的惊吓。" })
Groupboxes.Visuals_Effects:AddToggle("DisableTimothyJumpscare", { Text = "禁用蜘蛛惊吓", Default = false, Tooltip = "禁用'蜘蛛'的惊吓。" })
Groupboxes.Visuals_Effects:AddToggle("DisableVoidJumpscare", { Text = "禁用虚空惊吓", Default = false, Tooltip = "禁用'虚空'的惊吓。" })
Groupboxes.Visuals_Effects:AddDivider()
Groupboxes.Visuals_Effects:AddToggle("DisableHideVignette", { Text = "禁用躲藏晕影", Default = false, Tooltip = "禁用躲藏时的屏幕效果。" })
Groupboxes.Visuals_Effects:AddToggle("DisableFiredampEffect", { Text = "禁用沼气效果", Default = false, Tooltip = "禁用沼气屏幕效果。" })
Groupboxes.Visuals_Effects:AddToggle("DisableEntityJumpscares", { Text = "禁用实体惊吓", Default = false, Tooltip = "禁用冲刺和伏击等实体的惊吓。" })

Toggles.DisableGlitchJumpscare:OnChanged(function(Value)
	Modules.Glitch.Name = Value and "Glitch_Disabled" or "Glitch"
end)

Toggles.DisableTimothyJumpscare:OnChanged(function(Value)
	Modules.SpiderJumpscare.Name = Value and "SpiderJumpscare_Disabled" or "SpiderJumpscare"
end)

Toggles.DisableVoidJumpscare:OnChanged(function(Value)
	if Modules.Void then Modules.Void.Name = Value and "Void_Disabled" or "Void" end
end)

Toggles.DisableHideVignette:OnChanged(function(Value)
	local Vignette = Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette")
	if Vignette then Vignette.Image = Value and "Disabled" or "rbxassetid://6100076320" end
end)

Toggles.DisableFiredampEffect:OnChanged(function(Value)
	for _, Object in CurrentRooms:GetChildren() do
		if Value then
			Object:SetAttribute("Firedamp", false)
			for _, FiredampObj in Camera:GetChildren() do
				if FiredampObj.Name == "LiveFiredamp" then FiredampObj:Destroy() end
			end
		else
			Object:SetAttribute("Firedamp", Object:GetAttribute("Firedamp_Old"))
		end
	end
	local Old = LocalPlayer:GetAttribute("CurrentRoom")
	LocalPlayer:SetAttribute("CurrentRoom", 0)
	task.wait()
	LocalPlayer:SetAttribute("CurrentRoom", Old)
end)

Toggles.DisableEntityJumpscares:OnChanged(function(Value)
	local Jumpscares = Globals.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares")
		or Globals.MainUI.Initiator.Main_Game.RemoteListener:FindFirstChild("Jumpscares_Disabled")
	if Jumpscares then
		Jumpscares.Name = Value and "Jumpscares_Disabled" or "Jumpscares"
		for _, Object in Objects.JumpscareModules do
			Object.Name = Value and (Object:GetAttribute("OriginalName") .. "_Disabled") or Object:GetAttribute("OriginalName")
		end
	end
end)
local AutoInteractBlacklist = {
	HidePrompt=true, RiftPrompt=true, StarRiftPrompt=true, InteractPrompt=true, ClimbPrompt=true,
	DonatePrompt=true, DialoguePrompt=true, RevivePrompt=true, EnterPrompt=true, AnimatePrompt=true,
	ToolEventPrompt=true, Prompt=true, PropPrompt=true
}
local TriggerDebounce = false

local function GetHidingSpotModel(Prompt)
	if not Prompt or not Prompt.Parent then return false end
	local Model = Prompt.Parent
	while Model and not Model:IsA("Model") do
		Model = Model.Parent
	end
	if not Model then return nil end
	local Name = string.lower(Model.Name)
	if not string.find(Name, "hidingspot") and not string.find(Name, "hiding_spot") then
		return nil
	end
	return Model
end

local function HasHidePrompt(Model)
	return Model and (Model:FindFirstChild("HidePrompt") or Model:FindFirstChild("HidingPrompt")) ~= nil
end

local function IsHidingSpotPrompt(Prompt)
	if not Prompt or not Prompt.Parent then return false end
	if Prompt.Name ~= "HidePrompt" and Prompt.Name ~= "HidingPrompt" then return false end
	return HasHidePrompt(GetHidingSpotModel(Prompt))
end

Functions.TriggerPrompt = function(Prompt)
	if not Prompt or not Prompt.Parent then return end
	if Character:GetAttribute("Hiding") == true then return end
	local HidingSpot = GetHidingSpotModel(Prompt)
	if HidingSpot and Prompt.Name ~= "InteractPrompt" then return end
	local IsHidingSpotInteractPrompt = HidingSpot and Prompt.Name == "InteractPrompt"
	if AutoInteractBlacklist[Prompt.Name] and not IsHidingSpotPrompt(Prompt) and not IsHidingSpotInteractPrompt then return end
	if (Prompt.Name == "HidePrompt" or Prompt.Name == "HidingPrompt") and not IsHidingSpotPrompt(Prompt) then return end
	if (Prompt.Name == "HidePrompt" or Prompt.Name == "HidingPrompt" or IsHidingSpotPrompt(Prompt)) then
		if not Toggles.AutoClosetToggle.Value then return end
		local Entity = Functions.GetNearestEntity(true, Options.AutoClosetEntityList.Value)
		if not Entity then return end
		local EntityDistance = LocalPlayer:DistanceFromCharacter(Entity.PrimaryPart.Position)
		if EntityDistance > (EntityDistances[Entity.Name] or 150) then return end
	end
	if TriggerDebounce then return end
	local ParentItem = Functions.HasItem(Prompt.Parent.Name)
	if ParentItem and ParentItem:GetAttribute("Durability") and ParentItem:GetAttribute("DurabilityMax")
		and ParentItem:GetAttribute("Durability") >= ParentItem:GetAttribute("DurabilityMax")
	then return end
	local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
	local IsLockPrompt = LockPromptNames[Prompt.Name]
		or (Prompt.Parent and Prompt.Parent:GetAttribute("Locked") == true)
		or (Prompt.Parent and Prompt.Parent.Parent and Prompt.Parent.Parent.Name == "Locker_Small_Locked" and Prompt.Name == "ActivateEventPrompt")
	if IsLockPrompt then
		if Options.AutoInteractIgnoreList.Value["锁"] then return end
		local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
		local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
		local HasKey = false
		for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
		for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
		if not HasKey then return end
	end
	if Prompt.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
	if Prompt.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
	if Prompt.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
	if Functions.HasItem("Shears", true) and IsLockPrompt and Prompt.Parent.Name ~= "CuttableVines" and Prompt.Parent.Name ~= "Chest_Vine" and Prompt.Parent.Name ~= "Cellar" then return end
	if Prompt.Parent.Name == "GlitchCube" and Options.AutoInteractIgnoreList.Value["故障碎片"] then return end
	if (Prompt.Parent.Name == "KeyObtain" and (Functions.HasItem("Key") or Functions.HasItem("KeyBackdoor")))
		or (Prompt.Parent.Name == "ElectricalKeyObtain" and Functions.HasItem("KeyElectrical"))
	then return end
	if Prompt:IsDescendantOf(Drops) and Options.AutoInteractIgnoreList.Value["掉落物品"] then return end
	if Prompt.Parent.Name == "TrackLever" then return end
	if Prompt.Name == "ActivateEventPrompt" and (Prompt.ActionText == "关闭"
		or Prompt.Parent.Name == "ElevatorBreaker"
		or (Prompt.Parent.Parent and Prompt.Parent.Parent.Name == "IndustrialGate"))
	then return end
	if Prompt.Name == "ActivateEventPrompt" and (Prompt.Parent.Name == "Padlock" or Prompt.Parent.Name == "MinesAnchor") then return end
	if Prompt.Parent.Name == "LeverForGate" and Prompt:GetAttribute("Interactions") then return end
	if Prompt.Parent.Parent and (Prompt.Parent.Parent.Name == "DoorFake" or Prompt.Parent.Parent.Name == "FakeDoor") then return end
	if Prompt.Parent:GetAttribute("JeffShop") and Options.AutoInteractIgnoreList.Value["杰夫物品"] then return end
	if Prompt:GetAttribute("AutoInteractIgnore") then return end
	if Prompt.Name == "PushPrompt" and Options.AutoInteractIgnoreList.Value["矿车"] then return end
	if (Prompt.Parent.Name == "GoldPile" or Prompt.Parent.Name == "StardustPickup") and Options.AutoInteractIgnoreList.Value["货币"] then return end
	if Prompt.Parent.Name == "Bandage" then
		local BPack = Functions.HasItem("BandagePack")
		if Humanoid.Health >= Humanoid.MaxHealth and not BPack then return end
		if BPack and BPack:GetAttribute("Durability") >= BPack:GetAttribute("DurabilityMax") then return end
	end
	if Prompt.Parent.Name == "Battery" then
		local Tool = Character:FindFirstChildOfClass("Tool")
		local BPack = Functions.HasItem("BatteryPack")
		if not Tool and not BPack then return end
		if Tool and Tool:GetAttribute("LightSource") then
			if Tool:GetAttribute("Durability") and Tool:GetAttribute("DurabilityMax")
				and Tool:GetAttribute("Durability") > Tool:GetAttribute("DurabilityMax")
			then return end
		elseif not BPack then
			return
		end
		if BPack and BPack:GetAttribute("Durability") >= BPack:GetAttribute("DurabilityMax") then return end
	end
	if Prompt.Name == "HerbPrompt" then
		local Effects = Globals.MainUI.MainFrame.Healthbar:FindFirstChild("Effects")
		if Effects and Effects.HerbGreenEffect.Visible then return end
	end
	if (Prompt.Parent.Name == "LibraryHintPaper" or Prompt.Parent.Name == "PickupItem") and (Functions.HasItem("LibraryHintPaper") or Functions.HasItem("LibraryHintPaperHard")) then return end
	if Prompt.Parent.Name == "AlarmClock" and Functions.HasItem("AlarmClock") then return end
	if Prompt.Parent.Name == "KeyObtainFake" or Prompt.Parent.Name == "TithingPlate" then return end
	-- 档案室
	if Prompt.parent.Name == "ArchivesStorageBox" then return end
	if Prompt.Parent.Name == "Briefcase" then return end
	if Prompt.Name == "SinkPrompt" or Prompt.Parent.Name == "Faucet" then return end
	if Prompt.Parent.Name == "PaperPlanePickup" or Prompt.Parent.Name == "PaperPlane" then return end
	if Prompt.Name == "ManualOpenPrompt" or Prompt.Name == "EntryPrompt" then return end
	if Prompt.Parent.Parent.Name == "ArchivesLargePrinter" then return end
	if Prompt.Name == "TrashcanPrompt" then return end
	if Prompt.Parent.Name == "Keyboard" then return end
	if Prompt.Name == "CartPrompt" or Prompt.Parent.Parent.Name == "ArchivesOfficeChair" then return end
	if Prompt.Parent.Name == "ArchivesTerminal" then return end
	if Prompt.Name == "VendorPrompt" then return end
	if Prompt.Parent.Name == "SeatPart" or Prompt.Name == "SeatPrompt" then return end
	-- 楼梯间
	if Prompt.Parent.name == "CobblerFriendly" then return end
	if Prompt.Parent.Name == "StairwellTerminal" then return end
	if Prompt.Parent.Parent.Name == "MeldChord" then return end

	Functions.FirePrompt(Prompt)
	TriggerDebounce = true
	if Floor == "OldHotel" then task.wait() end
	TriggerDebounce = false
end

Globals.LastAutoInteractFire = tick()

Connections.AutoInteract = Services.RunService.Heartbeat:Connect(function()
	local Active = Toggles.AutoInteractToggle.Value or Options.AutoInteractKeybind:GetState()
	if not Active then return end
	if tick() - Globals.LastAutoInteractFire < 1/60 then return end
	for _, Prompt in Objects.Prompts do
		if Prompt:GetAttribute("ParentRoom") and tonumber(Prompt:GetAttribute("ParentRoom")) ~= tonumber(LocalPlayer:GetAttribute("CurrentRoom")) then continue end
		if Prompt.Parent and (Prompt.Parent:IsA("BasePart") or Prompt.Parent:IsA("Model")) then
			local Distance
			if Prompt.Parent:IsA("BasePart") then
				Distance = LocalPlayer:DistanceFromCharacter(Prompt.Parent.Position)
			else
				Distance = LocalPlayer:DistanceFromCharacter(Prompt.Parent:GetPivot().Position)
			end
			if Distance <= Prompt.MaxActivationDistance and Prompt.Enabled or Distance <= Prompt.MaxActivationDistance and Prompt.Name == "LongPushPrompt" or Distance <= Prompt.MaxActivationDistance and Prompt.Name == "BigPropPrompt" then
				task.spawn(Functions.TriggerPrompt, Prompt)
			end
		end
	end
	Globals.LastAutoInteractFire = tick()
end)

Connections.InfiniteItemsHandler = Services.ProximityPromptService.PromptTriggered:Connect(function(Object)
	if not Object:GetAttribute("FakePrompt") then return end
	local ToolNames = { "Lockpick","Shears","SkeletonKey","Key","GeneratorFuse","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
	local AnimateToolNames = { "Lockpick","Shears","SkeletonKey","Key","KeyElectrical","KeyBackdoor","KeyIron", "Multitool" }
	local Tool
	for _, N in ToolNames do Tool = Character:FindFirstChild(N) if Tool then break end end
	local Prompt = Object
	local LockPromptNames = { UnlockPrompt=true, SkullPrompt=true, LockPrompt=true, ThingToEnable=true, FusesPrompt=true }
	local IsLockPrompt = LockPromptNames[Object.Name]
		or (Object.Parent and Object.Parent:GetAttribute("Locked") == true)
		or (Object.Parent and Object.Parent.Parent and Object.Parent.Parent.Name == "Locker_Small_Locked" and Object.Name == "ActivateEventPrompt")
	if IsLockPrompt then
		if Options.AutoInteractIgnoreList.Value["锁"] then return end
		local KeyItems = { "Key","GeneratorFuse","KeyBackdoor","KeyElectrical","KeyIron","Lockpick","SkeletonKey","Shears","Multitool" }
		local OffhandKeyItems = { "Key","GeneratorFuse","KeyElectrical","KeyIron" }
		local HasKey = false
		for _, K in KeyItems do if Functions.HasItem(K, true) then HasKey = true break end end
		for _, K in OffhandKeyItems do if Functions.HasItem(K) then HasKey = true break end end
		if not HasKey then return end
	end
	if Prompt.Parent.Name == "CuttableVines" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Chest_Vine" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Cellar" and not Functions.HasItem("Shears", true) and not Functions.HasItem("Multitool", true) then return end
	if Prompt.Parent.Name == "SkullLock" and not Functions.HasItem("SkeletonKey", true) then return end
	if Prompt.Parent.Name == "Lock1" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) or Prompt.Parent.Name == "Lock2" and not Functions.HasItem("Lockpick", true) and not Functions.HasItem("Multitool", true) then return end
	if Functions.HasItem("Shears", true) and IsLockPrompt and Prompt.Parent.Name ~= "CuttableVines" and Prompt.Parent.Name ~= "Chest_Vine" and Prompt.Parent.Name ~= "Cellar" then return end

	if Tool and table.find(AnimateToolNames, Tool.Name) and Globals.UseAnimation and Globals.UseAnimationBreak then
		Globals.UseAnimation:Stop()
		Globals.UseAnimationBreak:Stop()
		Globals.UseAnimationBreak:Play()
		if Tool.Name == "Shears" then Tool:WaitForChild("Handle"):WaitForChild("sound_prompt"):Play() end
	end

	local AnyTool = Character:FindFirstChildOfClass("Tool")
	local ToolData = AnyTool and ItemNames[AnyTool.Name]
	if AnyTool and ToolData and Toggles.InfiniteItemsToggle.Value and Options.InfiniteItemsList.Value[ToolData] then
		Drops.ChildAdded:Once(function(NewTool)
			local Prompt = NewTool:FindFirstChild("ModulePrompt")
			local RealPrompt = FakePrompts[Object]
			Functions.FirePrompt(Prompt)
			Functions.FirePrompt(RealPrompt)
		end)
		Character.ChildAdded:Once(function(NewTool)
			if NewTool.Name == "Shears" then NewTool:WaitForChild("Handle"):WaitForChild("sound_promptend"):Play() end
		end)
		RemotesFolder.DropItem:FireServer(AnyTool)
	else
		local RealPrompt = FakePrompts[Object]
		Functions.FirePrompt(RealPrompt)
	end
end)
Connections.FloorReplicatedHandler = FloorReplicated.DescendantAdded:Connect(function(Object)
	if Object.Name == "GlitchScreech" then
		Modules.GlitchScreech = Object
		if Toggles.RemoveScreech.Value then Object.Name = "GlitchScreech_Disabled" end
	end
	if Object.Name:find("Jumpscare") and Object:IsA("ModuleScript")
		and not Object.Name:find("Eyestalk") and not Object.Name:find("Groundskeeper") and not Object.Name:find("Monument")
	then
		Object:SetAttribute("OriginalName", Object.Name)
		if Toggles.DisableEntityJumpscares.Value then Object.Name = Object.Name .. "_Disabled" end
		table.insert(Objects.JumpscareModules, Object)
	end
end)

if FloorReplicated:FindFirstChild("DigitalTimer") then
	Connections.HasteTimerConnection = FloorReplicated.DigitalTimer:GetPropertyChangedSignal("Value"):Connect(function()
		if Toggles.NotifyHasteTime.Value then Functions.Caption(Functions.GetHasteTime(), true) end
	end)
end

Connections.FogHandler = Services.Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
	if Services.Lighting.FogEnd ~= 10000000 then
		Globals.OldFog = Services.Lighting.FogEnd
	end
	if Toggles.RemoveCameraFog.Value then
		Services.Lighting.FogEnd = 10000000
	end
end)

Connections.FogHandler2 = Services.Lighting.DescendantAdded:Connect(function(Object)
	if not Object:IsA("Atmosphere") then return end
	Object:SetAttribute("Density_Old", Object.Density)
	if Toggles.RemoveCameraFog.Value then Object.Density = 0 end
	local AtmoConn2 = Object:GetPropertyChangedSignal("Density"):Connect(function()
		if Object.Density ~= 0 then Object:SetAttribute("Density_Old", Object.Density) end
		if Toggles.RemoveCameraFog.Value then Object.Density = 0 end
	end)
	Object.Destroying:Once(function() AtmoConn2:Disconnect() end)
	table.insert(Connections, AtmoConn2)
	table.insert(Globals.FogInstances, Object)
end)

local RusherAliases = {
	Rush=true, Bash=true, Scribbles=true, DronesStampede=true, Ambush=true, Eyes=true, Lookman=true, Blitz=true,
	["A-60"]=true, ["A-120"]=true, AR0xMBUSH=true, ["RNIUSHCG=="]=true, ["自定义实体"]=true
}

local function HandleEntitySpawn(Entity)
	if not Entity or typeof(Entity) ~= "Instance" then return end
	local Model = Entity
	if Entity:IsA("Humanoid") then
		Model = Entity.Parent
	end
	if not Model or not Model:IsA("Model") then return end
	local EntityData = Entities[Model.Name]
	if not EntityData then return end
	if Model:GetAttribute("Abysall_EntityHandled") then return end
	Model:SetAttribute("Abysall_EntityHandled", true)
	while not Model.PrimaryPart do
		for _, Child in Model:GetChildren() do
			if Child:IsA("BasePart") then Model.PrimaryPart = Child end
		end
		if not Model.PrimaryPart then task.wait() end
	end
	task.wait(0.1)
	if not Model.PrimaryPart or LocalPlayer:DistanceFromCharacter(Model.PrimaryPart.Position) >= 10000 then return end
	local Alias = EntityData.Alias
	local RealAlias = Alias
	if Options.EntityList.Value[Alias] and Toggles.NotifyEntities.Value then
		local NotifyTitle = EntityData.NotifyMessage.Title
		local NotifyBody = EntityData.NotifyMessage.Body
		local NotifyImage = EntityIcons[Model.Name]
		if Model.Name == "RushMoving" and Model.PrimaryPart.Name ~= "RushNew" then
			NotifyTitle = NotifyTitle:gsub("冲刺", Model.PrimaryPart.Name)
			NotifyImage = Model.PrimaryPart:WaitForChild("Attachment").ParticleEmitter.Texture
			Alias = Model.PrimaryPart.Name
		end
		Functions.Notify({ Title = NotifyTitle, Body = NotifyBody, Image = NotifyImage, Time = Toggles.NotifyKeepNotifications.Value and Model or nil })
		if Toggles.EntityChatToggle.Value then
			Functions.SendChat(Alias .. " " .. Options.EntityChatMessage.Value)
		end
	end
	if Model.Name ~= "GloombatSwarm" then
		if Toggles.EntityESPToggle.Value and Options.EntityESPOptions.Value[RealAlias] then
			if Model.Name == "MonumentEntity" then
				Functions.AddESP({ Object = Model.Top, Text = Alias, Color = Options.EntityESPColor.Value })
			else
				Functions.AddESP({ Object = Model, Text = Alias, Color = Options.EntityESPColor.Value })
			end
		end
		table.insert(Objects.Entities, Model)
	end
	if RusherAliases[EntityData.Alias] then
		Instance.new("Humanoid", Model).Name = "HighlightHumanoid"
		local Root = Model.PrimaryPart
		if Root then Root.Transparency = 0.999 Root.Material = Enum.Material.Plastic end
	end
	if Model.Name == "Lookman" then
		CurrentRooms.ChildAdded:Wait()
		task.wait(10)
		Model:Destroy()
	end
end

Connections.EntityHandler = Services.Workspace.ChildAdded:Connect(HandleEntitySpawn)
Connections.EntityDescendantHandler = Services.Workspace.DescendantAdded:Connect(function(Descendant)
	local EntityModel = Descendant:IsA("Humanoid") and Descendant.Parent or Descendant
	if EntityModel and EntityModel:IsA("Model") and Entities[EntityModel.Name] then
		task.defer(function()
			HandleEntitySpawn(Descendant)
		end)
	end
end)

local LastClean = tick()
Connections.Cleaner = Services.RunService.Heartbeat:Connect(function()
	if tick() - LastClean <= 0.5 then return end
	LastClean = tick()
	for ArrayName, Array in Objects do
		local I = #Array
		while I >= 1 do
			local Object = Array[I]
			if Object == nil or not Object:IsDescendantOf(Services.Workspace) then
				table.remove(Array, I)
				local Conn = ESPConnections[Object]
				if Conn then
					Conn:Disconnect()
					ESPConnections[Object] = nil
					local Pos = table.find(Connections, Conn)
					if Pos then table.remove(Connections, Pos) end
				end
			end
			I -= 1
		end
	end
end)

local LastPromptFix = tick()
Connections.PromptFixer = Services.RunService.Heartbeat:Connect(function()
	if tick() - LastPromptFix <= 0.5 then return end
	LastPromptFix = tick()
	for _, Prompt in Objects.Prompts do
		if Prompt:HasTag("DisableWhenEnabledOnClient") then
			Prompt:RemoveTag("DisableWhenEnabledOnClient")
		end
	end
end)

if LocalPlayer.Character then
	task.spawn(function() Functions.HandleCharacter(LocalPlayer.Character) end)
end

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
	if Connections.MainHandler then
		Connections.MainHandler:Disconnect()
		Connections.MainHandler = nil
	end
	task.wait(0.5)
	Functions.HandleCharacter(NewCharacter)
end)
Library:OnUnload(function()
	StopTimeShower(true)
	for Key, Connection in Connections do
		if type(Key) == "string" then
			pcall(function() Connection:Disconnect() end)
		else
			pcall(function() Key:Disconnect() end)
			pcall(function() Connection:Disconnect() end)
		end
	end
	for _, Object in Objects.Entities do
		if Object.Name == "Snare" or Object.Name == "GiggleCeiling" then
			local Hitbox = Object:FindFirstChild("Hitbox")
			if Hitbox then Hitbox.CanTouch = true end
		end
		if Object.Name == "GloomPile" then
			for _, Part in Object:GetDescendants() do
				if Part:IsA("BasePart") then Part.CanTouch = true end
			end
		end
		if Object.Name == "FakeDoor" or Object.Name == "DoorFake" then
			local Hidden = Object:FindFirstChild("Hidden")
			if Hidden then Hidden.CanTouch = true end
			local Lock = Object:FindFirstChild("Lock")
			if Lock and Lock:FindFirstChild("UnlockPrompt") then Lock.UnlockPrompt.Enabled = true end
		end
		if Object.Name == "SideroomSpace" then
			local Coll = Object:FindFirstChild("Collision")
			if Coll then Coll.CanCollide = false Coll.CanTouch = true end
		end
	end
	for _, Object in Objects.SeekBridges do Object:Destroy() end
	for _, Fog in Globals.FogInstances do
		Fog.Density = Fog:GetAttribute("Density_Old")
	end
	Services.Lighting.FogEnd = Globals.OldFog
	local Vignette = Globals.MainUI:FindFirstChild("HideVignette") or Globals.MainUI.MainFrame:FindFirstChild("HideVignette")
	if Vignette then Vignette.Image = "rbxassetid://6100076320" end
	local ModuleRestores = {
		Screech = "Screech", Glitch = "Glitch", Shade = "Shade",
		SpiderJumpscare = "SpiderJumpscare", A90 = "A90", Dread = "Dread", Void = "Void"
	}
	for Key, OriginalName in ModuleRestores do
		if Modules[Key] then Modules[Key].Name = OriginalName end
	end
	FakeEvents.Screech:Destroy()
	FakeEvents.Screech_Real.Parent = RemotesFolder
	FakeEvents.Shade:Destroy()
	FakeEvents.Shade_Real.Parent = RemotesFolder
	if FakeEvents.A90_Real then
		FakeEvents.A90:Destroy()
		FakeEvents.A90_Real.Parent = RemotesFolder
	end
	if FakeEvents.Surge_Real then
		FakeEvents.Surge:Destroy()
		FakeEvents.Surge_Real.Parent = RemotesFolder
	end
	Globals.SeekNodesFolder:Destroy()
	Globals.RoomsNodesFolder:Destroy()
	Globals.ManipulateBody:Destroy()
	local OldAmbient = CurrentRooms:FindFirstChild(tostring(LocalPlayer:GetAttribute("CurrentRoom"))):GetAttribute("Ambient")
	Services.TweenService:Create(Services.Lighting, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), { Ambient = OldAmbient }):Play()
	for _, Prompt in Objects.Prompts do
		if FakePrompts[Prompt] then
			FakePrompts[Prompt].Parent = Prompt.Parent
			Prompt:Destroy()
		end
		if Prompt.Parent then
			Prompt.HoldDuration = Prompt:GetAttribute("HoldDuration_Old") or Prompt.HoldDuration
			Prompt.RequiresLineOfSight = Prompt:GetAttribute("RequiresLineOfSight_Old") or Prompt.RequiresLineOfSight
			Prompt.MaxActivationDistance = Prompt:GetAttribute("MaxActivationDistance_Old") or Prompt.MaxActivationDistance
		end
	end
	Character:SetAttribute("CanJump", OldJump)
	Character:SetAttribute("CanSlide", OldSlide)
	for _, Object in Services.Workspace:GetDescendants() do
		task.spawn(function() Functions.RemoveESP(Object) end)
	end
	Humanoid.WalkSpeed = Functions.GetCurrentSpeed()
	Humanoid.JumpPower = 5
	Humanoid.HipHeight = 2.367
	local BaseY = 0.18
	Collision.Position = RootPart.Position + Vector3.new(0, BaseY, 0)
	CollisionPart.Position = RootPart.Position + Vector3.new(0, BaseY, 0)
	CollisionPartClone.Position = RootPart.Position + Vector3.new(0, BaseY, 0)
	if Character:FindFirstChild("LowerTorso") and Character.LowerTorso:FindFirstChild("Root") then
		Character.LowerTorso.Root.C1 = Globals.OriginalC1
	end
	if Collision:FindFirstChild("CollisionCrouch") then
		Collision.CollisionCrouch.Position = RootPart.Position + Vector3.new(0, -0.982, 0)
	end
	CollisionClone:Destroy()
	CollisionPartClone:Destroy()
	Abysall.ESPLibrary:Unload()
	if Main_Game then
		Main_Game.fovtarget = 70
		Main_Game.spring.Speed = 8
		Main_Game.tooloffset = Vector3.zero
	end
	if Globals.OriginalGetMoveVector then
		local Controls = require(LocalPlayer.PlayerScripts.PlayerModule):GetControls()
		Controls.GetMoveVector = Globals.OriginalGetMoveVector
	end
	getgenv().Abysall = nil
	shared.Hastelepasta = false
end)

if game.Players.LocalPlayer.Name == "Robloxiant0g2w2g3q" then
	for i = 1, 10 do
		Functions.Notify({ Title = "你好，主播……" })
		task.wait()
	end
end

while not Globals.MainUI do
	task.wait()
end

Abysall.Interface.ApplySettingsTab(Window)

Functions.Notify({
	Title = "成功加载，耗时 " .. math.floor((tick() - LoadStart) * 1000) / 1000 .. " 秒。",
	Body = "按 '" .. tostring(Options.MenuKeybind.Value) .. "' 切换界面。"
})
