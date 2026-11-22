--[[
	╔════════════════════════════════════════════════════════════════════╗
	║   M4teoUI  ·  Librería GUI moderna para ejecutores de Roblox       ║
	║   Developed by M4teoScripts                                        ║
	╚════════════════════════════════════════════════════════════════════╝

	USO RÁPIDO
	----------
	local Library = loadstring(game:HttpGet("https://TU-URL/M4teoUI.lua"))()

	local Window = Library:CreateWindow({
		Title = "Mi Hub", Subtitle = "v1.0", Icon = "home",
		ToggleKey = Enum.KeyCode.RightShift,
	})

	local Tab = Window:AddTab({ Name = "Principal", Icon = "home" })
	Tab:AddTitle("Hola"); Tab:AddSubtitle("Bienvenido")
	Tab:AddButton({ Name = "Click", Callback = function() print("ok") end })

	Elementos: AddTitle · AddSubtitle · AddLabel · AddParagraph · AddSection · AddDivider
	           AddButton · AddToggle · AddSlider · AddDropdown · AddMultiDropdown
	           AddInput · AddKeybind
	Ventana:   Window:AddTab · SelectTab · Toggle · Minimize · SetScale · Notify · Destroy
	Librería:  Library:Notify · SetAccent · SetSound · SaveConfig · LoadConfig · Destroy
]]

-- ═══════════════════════════════════════════════════════════════════════
--  SERVICIOS Y ENTORNO
-- ═══════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local ENV = (getgenv and getgenv()) or _G

-- Si ya había una instancia cargada, se destruye antes de crear la nueva
if ENV.M4teoUI and type(ENV.M4teoUI.Destroy) == "function" then
	pcall(function() ENV.M4teoUI:Destroy() end)
end

local EASE, DIR = Enum.EasingStyle, Enum.EasingDirection
local FONT = {
	Regular = Enum.Font.Gotham,
	Medium = Enum.Font.GothamMedium,
	Bold = Enum.Font.GothamBold,
	Black = Enum.Font.GothamBlack,
}
local WHITE = Color3.new(1, 1, 1)

-- ═══════════════════════════════════════════════════════════════════════
--  LIBRERÍA / TEMA / MÉTRICAS
-- ═══════════════════════════════════════════════════════════════════════
local Library = {
	Name = "M4teoUI",
	Version = "1.0.0",
	Credit = "Developed by M4teoScripts",
	Flags = {},
	Options = {},
	Windows = {},
	IsMobile = IsMobile,
	Settings = { Sounds = true, Volume = 0.6, Animations = true, Notifications = true },
	_conns = {},
	_scale = 1,
	_capturing = false,
}

local Theme = {
	Background = Color3.fromRGB(15, 15, 24),
	Surface = Color3.fromRGB(27, 28, 42),
	SurfaceHover = Color3.fromRGB(38, 40, 60),
	Dark = Color3.fromRGB(8, 8, 14),
	Outline = Color3.fromRGB(62, 64, 90),
	Text = Color3.fromRGB(242, 244, 255),
	SubText = Color3.fromRGB(150, 156, 188),
	Accent = Color3.fromRGB(124, 92, 255),
	Accent2 = Color3.fromRGB(0, 200, 255),
}
Library.Theme = Theme

Library.PresetOrder = { "Violeta", "Océano", "Rubí", "Esmeralda", "Rosa", "Atardecer", "Oro" }
Library.Presets = {
	["Violeta"] = { Color3.fromRGB(124, 92, 255), Color3.fromRGB(0, 200, 255) },
	["Océano"] = { Color3.fromRGB(0, 140, 255), Color3.fromRGB(0, 235, 200) },
	["Rubí"] = { Color3.fromRGB(255, 60, 90), Color3.fromRGB(255, 150, 60) },
	["Esmeralda"] = { Color3.fromRGB(30, 220, 120), Color3.fromRGB(0, 190, 255) },
	["Rosa"] = { Color3.fromRGB(255, 80, 180), Color3.fromRGB(160, 90, 255) },
	["Atardecer"] = { Color3.fromRGB(255, 120, 40), Color3.fromRGB(255, 60, 120) },
	["Oro"] = { Color3.fromRGB(255, 200, 40), Color3.fromRGB(255, 130, 0) },
}

-- Métricas adaptadas: móvil = objetivos táctiles grandes (≥44px) / PC = más compacto
local M
if IsMobile then
	M = { Top = 46, Elem = 46, Opt = 40, Text = 15, Small = 13, TabBar = 54, Side = 0, Banner = 24,
		Pad = 10, TabBtn = 0, TrackW = 46, TrackH = 24, Knob = 18, SliderTrack = 8, TopBtn = 34 }
else
	M = { Top = 44, Elem = 38, Opt = 32, Text = 14, Small = 12, TabBar = 0, Side = 158, Banner = 22,
		Pad = 10, TabBtn = 38, TrackW = 40, TrackH = 20, Knob = 14, SliderTrack = 6, TopBtn = 30 }
end

local NOTIF_W = IsMobile and 280 or 310

-- Íconos integrados (puedes pasar también un rbxassetid o un emoji propio)
local Icons = {
	home = "🏠", settings = "⚙️", combat = "⚔️", player = "👤", visuals = "👁️", misc = "✨",
	info = "ℹ️", success = "✅", warning = "⚠️", error = "❌", dot = "●", star = "⭐",
	world = "🌍", tools = "🛠️", teleport = "📍", fire = "🔥", bolt = "⚡", lock = "🔒",
	user = "👥", code = "💻", music = "🎵", gift = "🎁", search = "🔍", list = "📋",
}

-- ═══════════════════════════════════════════════════════════════════════
--  UTILIDADES BASE
-- ═══════════════════════════════════════════════════════════════════════
local Defaults = {
	Frame = { BorderSizePixel = 0, BackgroundColor3 = Theme.Surface },
	CanvasGroup = { BorderSizePixel = 0, BackgroundTransparency = 1 },
	TextLabel = { BorderSizePixel = 0, BackgroundTransparency = 1, Font = FONT.Regular, Text = "",
		TextColor3 = Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left },
	TextButton = { BorderSizePixel = 0, BackgroundTransparency = 1, AutoButtonColor = false, Text = "",
		Font = FONT.Regular, TextColor3 = Theme.Text, TextSize = 14 },
	TextBox = { BorderSizePixel = 0, BackgroundTransparency = 1, Font = FONT.Medium, Text = "",
		TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText, TextSize = 14,
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left },
	ImageLabel = { BorderSizePixel = 0, BackgroundTransparency = 1 },
	ImageButton = { BorderSizePixel = 0, BackgroundTransparency = 1, AutoButtonColor = false },
	ScrollingFrame = { BorderSizePixel = 0, BackgroundTransparency = 1, ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new() },
}

local function Create(class, props, children)
	local inst = Instance.new(class)
	local d = Defaults[class]
	if d then
		for k, v in pairs(d) do inst[k] = v end
	end
	local parent
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then parent = v else inst[k] = v end
		end
	end
	if children then
		for _, c in ipairs(children) do c.Parent = inst end
	end
	if parent then inst.Parent = parent end
	return inst
end

local function Tween(obj, props, time, style, dir)
	if not obj or not obj.Parent then return end
	if not Library.Settings.Animations then time = 0 end
	local tw = TweenService:Create(obj, TweenInfo.new(time or 0.25, style or EASE.Quint, dir or DIR.Out), props)
	tw:Play()
	return tw
end

local function Safe(fn, ...)
	if type(fn) ~= "function" then return end
	local ok, err = pcall(fn, ...)
	if not ok then warn("[M4teoUI] Error en callback: " .. tostring(err)) end
end

local function Corner(parent, r)
	return Create("UICorner", { CornerRadius = UDim.new(0, r), Parent = parent })
end

local function Pad(parent, l, t, r, b)
	return Create("UIPadding", {
		PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r or l), PaddingBottom = UDim.new(0, b or t), Parent = parent,
	})
end

local function Gray(v) return Color3.new(v, v, v) end

-- Degradado vertical que da volumen (luz arriba, sombra abajo)
local function Gradient3D(parent, top, bottom)
	return Create("UIGradient", {
		Rotation = 90, Color = ColorSequence.new(Gray(top or 1), Gray(bottom or 0.75)), Parent = parent,
	})
end

local function IsPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function TextH(text, size, font, width)
	local ok, v = pcall(function()
		return TextService:GetTextSize(text, size, font, Vector2.new(math.max(width, 20), 10000))
	end)
	return ok and math.ceil(v.Y) or size
end

local function Decimals(n)
	local s = string.format("%.10f", n)
	s = s:gsub("0+$", "")
	local d = s:match("%.(%d*)")
	return d and #d or 0
end

local function Viewport()
	local gui = Library._gui
	if gui and gui.AbsoluteSize.X > 50 then return gui.AbsoluteSize end
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function Protect(gui)
	if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
	local parent
	if type(gethui) == "function" then
		local ok, res = pcall(gethui)
		if ok then parent = res end
	end
	parent = parent or CoreGui
	local ok = pcall(function() gui.Parent = parent end)
	if not ok or not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

function Library:_Connect(signal, fn)
	local c = signal:Connect(fn)
	self._conns[#self._conns + 1] = c
	return c
end

-- ═══════════════════════════════════════════════════════════════════════
--  BUCLE DE ANIMACIONES (bordes rotativos, destellos, etc.)
-- ═══════════════════════════════════════════════════════════════════════
local Rotators, Updaters, AccentListeners = {}, {}, {}

local function AddUpdater(fn) Updaters[#Updaters + 1] = fn end

local function AccentSeq()
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Accent),
		ColorSequenceKeypoint.new(0.5, Theme.Accent2),
		ColorSequenceKeypoint.new(1, Theme.Accent),
	})
end

local function SeqOf(c1, c2)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(0.5, c2), ColorSequenceKeypoint.new(1, c1),
	})
end

-- UIStroke con UIGradient que gira continuamente
local function AnimatedStroke(parent, thickness, transparency, speed, offset, seq)
	local stroke = Create("UIStroke", {
		Color = WHITE, Thickness = thickness or 2, Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent,
	})
	local grad = Create("UIGradient", { Color = seq or AccentSeq(), Parent = stroke })
	Rotators[#Rotators + 1] = { Grad = grad, Speed = speed or 90, Offset = offset or 0, Accent = (seq == nil) }
	return stroke, grad
end

local function OnAccent(inst, fn)
	AccentListeners[#AccentListeners + 1] = { Inst = inst, Fn = fn }
end

local function FireAccent()
	for i = #AccentListeners, 1, -1 do
		local l = AccentListeners[i]
		if not l.Inst.Parent then
			table.remove(AccentListeners, i)
		else
			pcall(l.Fn)
		end
	end
end

-- Degradado de acento (se recolorea solo al cambiar de tema)
local function AccentGrad(parent, rotation)
	local g = Create("UIGradient", { Color = ColorSequence.new(Theme.Accent, Theme.Accent2), Rotation = rotation or 0, Parent = parent })
	OnAccent(parent, function() g.Color = ColorSequence.new(Theme.Accent, Theme.Accent2) end)
	return g
end

AddUpdater(function(_, t)
	for i = #Rotators, 1, -1 do
		local r = Rotators[i]
		if not r.Grad.Parent then
			table.remove(Rotators, i)
		else
			r.Grad.Rotation = (t * r.Speed + r.Offset) % 360
		end
	end
end)

do
	local frame = 0
	Library._loop = RunService.RenderStepped:Connect(function(dt)
		frame = frame + 1
		if IsMobile and frame % 2 == 1 then return end -- 30fps de animación decorativa en móvil
		local t = os.clock()
		for i = #Updaters, 1, -1 do
			local ok, keep = pcall(Updaters[i], dt, t)
			if not ok or keep == false then table.remove(Updaters, i) end
		end
	end)
	Library._conns[#Library._conns + 1] = Library._loop
end

function Library:SetAccent(a, b)
	if typeof(a) ~= "Color3" then return end
	if typeof(b) ~= "Color3" then
		local h, s, v = a:ToHSV()
		b = Color3.fromHSV((h + 0.12) % 1, math.clamp(s, 0.4, 1), v)
	end
	Theme.Accent, Theme.Accent2 = a, b
	local seq = AccentSeq()
	for _, r in ipairs(Rotators) do
		if r.Accent and r.Grad.Parent then r.Grad.Color = seq end
	end
	FireAccent()
end

-- ═══════════════════════════════════════════════════════════════════════
--  ÍCONOS
-- ═══════════════════════════════════════════════════════════════════════
local function IsAsset(v)
	return type(v) == "number" or (type(v) == "string" and (v:find("rbxasset") ~= nil or v:find("^https?://") ~= nil))
end

local function MakeIcon(parent, icon, size)
	if IsAsset(icon) then
		local id = type(icon) == "number" and ("rbxassetid://" .. icon) or icon
		return Create("ImageLabel", {
			Name = "Icon", Image = id, ImageColor3 = WHITE, Size = UDim2.fromOffset(size, size),
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = parent,
		})
	end
	local glyph = Icons[string.lower(tostring(icon or "dot"))] or tostring(icon)
	return Create("TextLabel", {
		Name = "Icon", Text = glyph, Font = FONT.Bold, TextSize = math.floor(size * 0.85), TextColor3 = WHITE,
		TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(size + 6, size + 6),
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = parent,
	})
end

local function SetIconColor(icon, color)
	if icon:IsA("ImageLabel") then Tween(icon, { ImageColor3 = color }, 0.2)
	else Tween(icon, { TextColor3 = color }, 0.2) end
end

-- ═══════════════════════════════════════════════════════════════════════
--  SONIDOS  (puedes cambiar los IDs con Library:SetSound)
-- ═══════════════════════════════════════════════════════════════════════
local SOUND_ID = "rbxassetid://6895079853"
local SOUND_FALLBACK = "rbxasset://sounds/electronicpingshort.wav"
local SoundDefs = {
	Click = { Volume = 0.55, Speed = 1.00 },
	Hover = { Volume = 0.10, Speed = 1.90 },
	Open = { Volume = 0.70, Speed = 1.25 },
	Close = { Volume = 0.70, Speed = 0.80 },
	ToggleOn = { Volume = 0.60, Speed = 1.35 },
	ToggleOff = { Volume = 0.60, Speed = 0.85 },
	Slider = { Volume = 0.22, Speed = 1.80 },
	Notify = { Volume = 0.70, Speed = 1.50 },
	Success = { Volume = 0.70, Speed = 1.70 },
	Error = { Volume = 0.80, Speed = 0.60 },
}
for _, d in pairs(SoundDefs) do
	d.Id = SOUND_ID
	d.Fallback = SOUND_FALLBACK
end

function Library:PlaySound(name)
	if not self.Settings.Sounds or not self._sounds then return end
	local s, def = self._sounds[name], SoundDefs[name]
	if not s or not def then return end
	s.Volume = def.Volume * self.Settings.Volume
	s.PlaybackSpeed = def.Speed
	s.TimePosition = 0
	s:Play()
end

function Library:SetSound(name, id, volume, speed)
	local def = SoundDefs[name]
	if not def then return end
	if type(id) == "number" then id = "rbxassetid://" .. id end
	def.Id = id or def.Id
	def.Volume = volume or def.Volume
	def.Speed = speed or def.Speed
	if self._sounds and self._sounds[name] then self._sounds[name].SoundId = def.Id end
end

-- ═══════════════════════════════════════════════════════════════════════
--  INICIALIZACIÓN (ScreenGui, sonidos, contenedor de notificaciones)
-- ═══════════════════════════════════════════════════════════════════════
function Library:_Init()
	if self._gui then return end
	local gui = Instance.new("ScreenGui")
	gui.Name = "M4teoUI_" .. HttpService:GenerateGUID(false):sub(1, 8)
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 9999
	Protect(gui)
	self._gui = gui

	local folder = Create("Folder", { Name = "Sounds", Parent = gui })
	self._sounds = {}
	for name, def in pairs(SoundDefs) do
		local s = Create("Sound", { Name = name, SoundId = def.Id, Volume = def.Volume, PlaybackSpeed = def.Speed, Parent = folder })
		self._sounds[name] = s
		task.delay(4, function()
			if s.Parent and not s.IsLoaded then s.SoundId = def.Fallback end
		end)
	end

	local holder = Create("Frame", {
		Name = "Notifications", BackgroundTransparency = 1, ZIndex = 100,
		AnchorPoint = IsMobile and Vector2.new(0.5, 0) or Vector2.new(1, 0),
		Position = IsMobile and UDim2.new(0.5, 0, 0, 12) or UDim2.new(1, -16, 0, 16),
		Size = UDim2.new(0, NOTIF_W, 1, -32), Parent = gui,
	})
	Create("UIListLayout", {
		Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top, Parent = holder,
	})
	self._notifHolder = holder
	self._notifOrder = 0
end

function Library:Destroy()
	for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
	self._conns = {}
	if self._gui then self._gui:Destroy() self._gui = nil end
	self.Windows = {}
	if ENV.M4teoUI == self then ENV.M4teoUI = nil end
end

-- ═══════════════════════════════════════════════════════════════════════
--  NOTIFICACIONES ANIMADAS
-- ═══════════════════════════════════════════════════════════════════════
local NotifTypes = {
	info = { Color = Color3.fromRGB(70, 160, 255), Icon = "info", Title = "Información", Sound = "Notify" },
	success = { Color = Color3.fromRGB(60, 220, 130), Icon = "success", Title = "Éxito", Sound = "Success" },
	warning = { Color = Color3.fromRGB(255, 190, 50), Icon = "warning", Title = "Advertencia", Sound = "Notify" },
	error = { Color = Color3.fromRGB(255, 75, 90), Icon = "error", Title = "Error", Sound = "Error" },
}

function Library:Notify(opts)
	if type(opts) ~= "table" then opts = { Content = tostring(opts) } end
	if not self.Settings.Notifications then return end
	self:_Init()

	local kind = NotifTypes[opts.Type or "info"] and (opts.Type or "info") or "info"
	local def = NotifTypes[kind]
	local width = NOTIF_W
	local title = tostring(opts.Title or def.Title)
	local content = tostring(opts.Content or "")
	local duration = tonumber(opts.Duration) or 4
	local textW = width - 66

	local titleH = TextH(title, 14, FONT.Bold, textW)
	local contentH = content ~= "" and TextH(content, 13, FONT.Regular, textW) or 0
	local H = math.max(58, 14 + titleH + (contentH > 0 and (3 + contentH) or 0) + 18)

	self._notifOrder = self._notifOrder + 1
	local slot = Create("Frame", {
		Name = "Slot", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = self._notifOrder, Parent = self._notifHolder,
	})
	local startPos = IsMobile and UDim2.fromOffset(0, -(H + 40)) or UDim2.fromOffset(width + 40, 0)
	local pack = Create("Frame", {
		Name = "Pack", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, H + 4), Position = startPos, Parent = slot,
	})

	-- Sombra suave + base 3D + tarjeta
	Create("ImageLabel", {
		Image = "rbxassetid://1316045217", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(10, 10, 118, 118),
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 6), Size = UDim2.new(1, 36, 1, 36),
		ZIndex = 0, Parent = pack,
	})
	local base = Create("Frame", { BackgroundColor3 = Theme.Dark, Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, H), Parent = pack })
	Corner(base, 12)
	local card = Create("Frame", { Name = "Card", BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 0, H), ClipsDescendants = true, Parent = pack })
	Corner(card, 12)
	Gradient3D(card, 1, 0.74)
	AnimatedStroke(card, 2, 0.05, 130, 0, SeqOf(def.Color, Color3.fromRGB(255, 255, 255):Lerp(def.Color, 0.35)))

	-- Ícono con rebote
	local iconBg = Create("Frame", {
		BackgroundColor3 = def.Color, BackgroundTransparency = 0.78, Position = UDim2.fromOffset(12, 12),
		Size = UDim2.fromOffset(34, 34), Parent = card,
	})
	Corner(iconBg, 17)
	Create("UIStroke", { Color = def.Color, Thickness = 1.5, Transparency = 0.4, Parent = iconBg })
	local icon = MakeIcon(iconBg, opts.Icon or def.Icon, 18)
	local iconScale = Create("UIScale", { Scale = 0, Parent = iconBg })

	Create("TextLabel", {
		Text = title, Font = FONT.Bold, TextSize = 14, Position = UDim2.fromOffset(56, 12),
		Size = UDim2.fromOffset(textW, titleH), TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Parent = card,
	})
	if contentH > 0 then
		Create("TextLabel", {
			Text = content, Font = FONT.Regular, TextSize = 13, TextColor3 = Theme.SubText,
			Position = UDim2.fromOffset(56, 15 + titleH), Size = UDim2.fromOffset(textW, contentH),
			TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Parent = card,
		})
	end

	-- Barra de progreso
	local track = Create("Frame", { BackgroundColor3 = Theme.Dark, Position = UDim2.new(0, 12, 1, -8), Size = UDim2.new(1, -24, 0, 3), Parent = card })
	Corner(track, 2)
	local bar = Create("Frame", { BackgroundColor3 = def.Color, Size = UDim2.fromScale(1, 1), Parent = track })
	Corner(bar, 2)

	local closed = false
	local function close()
		if closed then return end
		closed = true
		Tween(pack, { Position = startPos }, 0.35, EASE.Back, DIR.In)
		task.delay(0.22, function() Tween(slot, { Size = UDim2.new(1, 0, 0, 0) }, 0.25, EASE.Quint) end)
		task.delay(0.65, function() if slot then slot:Destroy() end end)
	end

	local click = Create("TextButton", { Size = UDim2.fromScale(1, 1), ZIndex = 10, Parent = card })
	click.Activated:Connect(function() self:PlaySound("Click") close() end)

	-- Entrada
	Tween(slot, { Size = UDim2.new(1, 0, 0, H + 4) }, 0.3, EASE.Quint)
	task.delay(0.08, function() Tween(pack, { Position = UDim2.fromOffset(0, 0) }, 0.55, EASE.Back) end)
	task.delay(0.32, function() Tween(iconScale, { Scale = 1 }, 0.5, EASE.Back) end)
	self:PlaySound(def.Sound)

	if duration > 0 and duration < 3600 then
		TweenService:Create(bar, TweenInfo.new(duration, EASE.Linear), { Size = UDim2.fromScale(0, 1) }):Play()
		task.delay(duration, close)
	end

	return { Close = close, Instance = slot, Icon = icon }
end

-- ═══════════════════════════════════════════════════════════════════════
--  COMPONENTES COMUNES (tarjetas 3D, interacción, ripple)
-- ═══════════════════════════════════════════════════════════════════════
local function CreateCard(parent, innerH, order)
	local wrapper = Create("Frame", {
		Name = "Element", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, innerH + 3), LayoutOrder = order, Parent = parent,
	})
	local base = Create("Frame", { Name = "Base", BackgroundColor3 = Theme.Dark, Position = UDim2.fromOffset(0, 3), Size = UDim2.new(1, 0, 1, -3), Parent = wrapper })
	Corner(base, 9)
	local card = Create("Frame", { Name = "Card", BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 1, -3), ClipsDescendants = true, Parent = wrapper })
	Corner(card, 9)
	Gradient3D(card, 1, 0.74)
	local stroke = Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Transparency = 0.35, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = card })
	return wrapper, card, stroke
end

local function Pressable(hit, card, stroke, opts)
	opts = opts or {}
	local hovered, pressed = false, false
	local function visual()
		local on = hovered or pressed
		Tween(stroke, { Color = on and Theme.Accent or Theme.Outline, Transparency = on and 0.05 or 0.35 }, 0.2)
		Tween(card, { BackgroundColor3 = on and Theme.SurfaceHover or Theme.Surface }, 0.2)
	end
	local function release()
		if not pressed then return end
		pressed = false
		if not opts.NoPress then
			Tween(card, { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 1, -3) }, 0.28, EASE.Back)
		end
		visual()
	end
	hit.MouseEnter:Connect(function()
		hovered = true
		visual()
		if not IsMobile then Library:PlaySound("Hover") end
	end)
	hit.MouseLeave:Connect(function()
		hovered = false
		if pressed then release() else visual() end
	end)
	hit.InputBegan:Connect(function(input)
		if IsPress(input) then
			pressed = true
			if not opts.NoPress then
				Tween(card, { Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 1, -5) }, 0.08)
			end
			visual()
		end
	end)
	hit.InputEnded:Connect(function(input)
		if IsPress(input) then
			if input.UserInputType == Enum.UserInputType.Touch then hovered = false end
			release()
		end
	end)
end

local function Ripple(card, input)
	if not Library.Settings.Animations then return end
	local scale = Library._scale
	local w, h = card.AbsoluteSize.X / scale, card.AbsoluteSize.Y / scale
	local x = w / 2
	if input and input.Position then x = (input.Position.X - card.AbsolutePosition.X) / scale end
	local d = w * 1.5
	local r = Create("Frame", {
		BackgroundColor3 = WHITE, BackgroundTransparency = 0.85, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, h / 2), Size = UDim2.fromOffset(0, 0), ZIndex = 0, Parent = card,
	})
	Corner(r, 999)
	Tween(r, { Size = UDim2.fromOffset(d, d), BackgroundTransparency = 1 }, 0.55, EASE.Quint)
	task.delay(0.6, function() r:Destroy() end)
end

local function ScaleButton(btn)
	local sc = Create("UIScale", { Scale = 1, Parent = btn })
	btn.InputBegan:Connect(function(i) if IsPress(i) then Tween(sc, { Scale = 0.88 }, 0.08) end end)
	btn.InputEnded:Connect(function(i) if IsPress(i) then Tween(sc, { Scale = 1 }, 0.3, EASE.Back) end end)
	return sc
end

local function RegisterFlag(opts, obj)
	if opts.Flag then
		Library.Options[opts.Flag] = obj
		Library.Flags[opts.Flag] = obj:Get()
	end
end

-- ═══════════════════════════════════════════════════════════════════════
--  CLASE TAB  (todos los elementos)
-- ═══════════════════════════════════════════════════════════════════════
local TabClass = {}
TabClass.__index = TabClass

function TabClass:_Order()
	self._order = self._order + 1
	return self._order
end

-- ── Título ────────────────────────────────────────────────────────────
function TabClass:AddTitle(text)
	local frame = Create("Frame", { Name = "Title", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = self:_Order(), Parent = self._scroll })
	local label = Create("TextLabel", {
		Text = tostring(text), Font = FONT.Black, TextSize = M.Text + 6, Position = UDim2.fromOffset(2, 0),
		Size = UDim2.new(1, -4, 0, 28), TextTruncate = Enum.TextTruncate.AtEnd, Parent = frame,
	})
	local bar = Create("Frame", { BackgroundColor3 = WHITE, Position = UDim2.fromOffset(2, 30), Size = UDim2.fromOffset(0, 3), Parent = frame })
	Corner(bar, 2)
	AccentGrad(bar, 0)
	Tween(bar, { Size = UDim2.fromOffset(52, 3) }, 0.7, EASE.Quint)
	return { Instance = frame, Set = function(_, t) label.Text = tostring(t) end }
end

-- ── Subtítulo ─────────────────────────────────────────────────────────
function TabClass:AddSubtitle(text)
	local frame = Create("Frame", { Name = "Subtitle", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), LayoutOrder = self:_Order(), Parent = self._scroll })
	local label = Create("TextLabel", {
		Text = tostring(text), Font = FONT.Medium, TextSize = M.Text, TextColor3 = Theme.SubText,
		Position = UDim2.fromOffset(2, 0), Size = UDim2.new(1, -4, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = frame,
	})
	return { Instance = frame, Set = function(_, t) label.Text = tostring(t) end }
end

-- ── Sección ───────────────────────────────────────────────────────────
function TabClass:AddSection(name)
	name = string.upper(tostring(name))
	local frame = Create("Frame", { Name = "Section", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), LayoutOrder = self:_Order(), Parent = self._scroll })
	local okSize, sz = pcall(function() return TextService:GetTextSize(name, M.Small, FONT.Bold, Vector2.new(1000, 30)) end)
	local tw = okSize and math.ceil(sz.X) or (#name * M.Small * 0.7)
	local label = Create("TextLabel", {
		Text = name, Font = FONT.Bold, TextSize = M.Small, TextColor3 = Theme.Accent,
		Position = UDim2.fromOffset(2, 0), Size = UDim2.new(0, tw + 2, 1, 0), Parent = frame,
	})
	OnAccent(label, function() label.TextColor3 = Theme.Accent end)
	local line = Create("Frame", {
		BackgroundColor3 = WHITE, BackgroundTransparency = 0.55, AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, tw + 12, 0.5, 0), Size = UDim2.new(1, -(tw + 12), 0, 1), Parent = frame,
	})
	AccentGrad(line, 0)
	return { Instance = frame, Set = function(_, t) label.Text = string.upper(tostring(t)) end }
end

-- ── Divisor ───────────────────────────────────────────────────────────
function TabClass:AddDivider()
	local frame = Create("Frame", { Name = "Divider", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 10), LayoutOrder = self:_Order(), Parent = self._scroll })
	Create("Frame", { BackgroundColor3 = Theme.Outline, BackgroundTransparency = 0.4, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.new(1, 0, 0, 1), Parent = frame })
	return { Instance = frame }
end

-- ── Párrafo (título + texto con salto de línea) ───────────────────────
function TabClass:AddParagraph(opts)
	opts = opts or {}
	local tw = self.Window._contentW - 28
	local title, content = tostring(opts.Title or ""), tostring(opts.Content or "")
	local wrapper, card, stroke = CreateCard(self._scroll, 30, self:_Order())
	local tLabel = Create("TextLabel", { Font = FONT.Bold, TextSize = M.Text, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Parent = card })
	local cLabel = Create("TextLabel", { Font = FONT.Regular, TextSize = M.Small + 1, TextColor3 = Theme.SubText, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Parent = card })

	local obj = { Instance = wrapper, Type = "Paragraph" }
	local function layout(animate)
		local th = title ~= "" and TextH(title, M.Text, FONT.Bold, tw) or 0
		local ch = content ~= "" and TextH(content, M.Small + 1, FONT.Regular, tw) or 0
		local gap = (th > 0 and ch > 0) and 4 or 0
		tLabel.Text, cLabel.Text = title, content
		tLabel.Position, tLabel.Size = UDim2.fromOffset(14, 12), UDim2.fromOffset(tw, th)
		cLabel.Position, cLabel.Size = UDim2.fromOffset(14, 12 + th + gap), UDim2.fromOffset(tw, ch)
		local inner = 24 + th + gap + ch
		if animate then
			Tween(wrapper, { Size = UDim2.new(1, 0, 0, inner + 3) }, 0.3)
		else
			wrapper.Size = UDim2.new(1, 0, 0, inner + 3)
		end
	end
	layout(false)
	function obj:Get() return content end
	function obj:Set(t, c)
		if c == nil then content = tostring(t) else title, content = tostring(t), tostring(c) end
		layout(true)
	end
	return obj
end

-- ── Etiqueta ──────────────────────────────────────────────────────────
function TabClass:AddLabel(text)
	local p = self:AddParagraph({ Content = tostring(text) })
	p.Type = "Label"
	return p
end

-- ── Botón ─────────────────────────────────────────────────────────────
function TabClass:AddButton(opts)
	if type(opts) == "string" then opts = { Name = opts } end
	opts = opts or {}
	local wrapper, card, stroke = CreateCard(self._scroll, M.Elem, self:_Order())
	local label = Create("TextLabel", {
		Text = opts.Name or "Botón", Font = FONT.Medium, TextSize = M.Text, Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -56, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	local arrow = Create("TextLabel", {
		Text = "›", Font = FONT.Black, TextSize = M.Text + 8, TextColor3 = Theme.Accent, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, -1), Size = UDim2.fromOffset(20, 24), TextXAlignment = Enum.TextXAlignment.Center, Parent = card,
	})
	OnAccent(arrow, function() arrow.TextColor3 = Theme.Accent end)
	local hit = Create("TextButton", { Name = "Hit", Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = card })
	Pressable(hit, card, stroke)
	hit.Activated:Connect(function(input)
		Library:PlaySound("Click")
		Ripple(card, input)
		Tween(arrow, { Position = UDim2.new(1, -6, 0.5, -1) }, 0.12)
		task.delay(0.12, function() Tween(arrow, { Position = UDim2.new(1, -14, 0.5, -1) }, 0.35, EASE.Back) end)
		Safe(opts.Callback)
	end)
	local obj = { Instance = wrapper, Type = "Button" }
	function obj:SetText(t) label.Text = tostring(t) end
	function obj:Fire() Safe(opts.Callback) end
	return obj
end

-- ── Toggle ────────────────────────────────────────────────────────────
function TabClass:AddToggle(opts)
	opts = opts or {}
	local wrapper, card, stroke = CreateCard(self._scroll, M.Elem, self:_Order())
	Create("TextLabel", {
		Text = opts.Name or "Toggle", Font = FONT.Medium, TextSize = M.Text, Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -(M.TrackW + 36), 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	local track = Create("Frame", {
		BackgroundColor3 = Theme.Dark, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(M.TrackW, M.TrackH), Parent = card,
	})
	Corner(track, 99)
	Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = track })
	local fill = Create("Frame", { BackgroundColor3 = WHITE, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = track })
	Corner(fill, 99)
	AccentGrad(fill, 0)
	local ks = M.TrackH - 6
	local knob = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(185, 188, 210), AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(ks, ks), ZIndex = 3, Parent = track,
	})
	Corner(knob, 99)
	Gradient3D(knob, 1, 0.8)
	local glow = Create("UIStroke", { Color = Theme.Accent, Thickness = 2, Transparency = 1, Parent = knob })
	OnAccent(glow, function() glow.Color = Theme.Accent end)

	local hit = Create("TextButton", { Name = "Hit", Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = card })
	Pressable(hit, card, stroke)

	local state = false
	local obj = { Instance = wrapper, Type = "Toggle" }
	local function apply(v, silent)
		state = v and true or false
		if opts.Flag then Library.Flags[opts.Flag] = state end
		Tween(fill, { BackgroundTransparency = state and 0 or 1 }, 0.25)
		Tween(knob, {
			Position = state and UDim2.new(1, -(ks + 3), 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = state and WHITE or Color3.fromRGB(185, 188, 210),
		}, 0.35, EASE.Back)
		Tween(glow, { Transparency = state and 0.35 or 1 }, 0.25)
		if not silent then Library:PlaySound(state and "ToggleOn" or "ToggleOff") end
	end
	function obj:Set(v, silent)
		apply(v, silent)
		Safe(opts.Callback, state)
	end
	function obj:Get() return state end
	hit.Activated:Connect(function(input)
		Ripple(card, input)
		obj:Set(not state)
	end)
	apply(opts.Default == true, true)
	RegisterFlag(opts, obj)
	if opts.Default then task.defer(function() Safe(opts.Callback, state) end) end
	return obj
end

-- ── Slider con lectura numérica en vivo ───────────────────────────────
function TabClass:AddSlider(opts)
	opts = opts or {}
	local min, max = opts.Min or 0, opts.Max or 100
	local inc = opts.Increment or 1
	local fmt = "%." .. math.max(Decimals(inc), Decimals(min)) .. "f"
	local suffix = opts.Suffix or ""
	local value = math.clamp(opts.Default or min, min, max)
	local rowH = 22
	local inner = M.Elem + 16

	local wrapper, card, stroke = CreateCard(self._scroll, inner, self:_Order())
	Create("TextLabel", {
		Text = opts.Name or "Slider", Font = FONT.Medium, TextSize = M.Text, Position = UDim2.fromOffset(14, 7),
		Size = UDim2.new(1, -120, 0, rowH), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	local valueLabel = Create("TextLabel", {
		Font = FONT.Bold, TextSize = M.Text, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 7), Size = UDim2.fromOffset(100, rowH), Parent = card,
	})
	OnAccent(valueLabel, function() valueLabel.TextColor3 = Theme.Accent end)

	local barY = 7 + rowH + (inner - 7 - rowH) / 2
	local track = Create("Frame", {
		BackgroundColor3 = Theme.Dark, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0, barY),
		Size = UDim2.new(1, -28, 0, M.SliderTrack), Parent = card,
	})
	Corner(track, 99)
	Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Transparency = 0.3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = track })
	local fill = Create("Frame", { BackgroundColor3 = WHITE, Size = UDim2.fromScale(0, 1), Parent = track })
	Corner(fill, 99)
	AccentGrad(fill, 0)
	local knob = Create("Frame", {
		BackgroundColor3 = WHITE, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(M.Knob, M.Knob), ZIndex = 3, Parent = track,
	})
	Corner(knob, 99)
	Gradient3D(knob, 1, 0.8)
	AnimatedStroke(knob, 2, 0, 160, math.random(0, 359))
	local knobScale = Create("UIScale", { Scale = 1, Parent = knob })

	local hitH = M.Knob + 22
	local hit = Create("TextButton", {
		Name = "Hit", Position = UDim2.new(0, 0, 0, barY - hitH / 2), Size = UDim2.new(1, 0, 0, hitH), ZIndex = 6, Parent = card,
	})

	local obj = { Instance = wrapper, Type = "Slider" }
	local lastTick = 0
	local function snap(v)
		v = math.clamp(v, min, max)
		v = math.floor((v - min) / inc + 0.5) * inc + min
		v = math.clamp(v, min, max)
		return tonumber(string.format(fmt, v)) or v
	end
	local function render(v, fast)
		local a = (max == min) and 0 or (v - min) / (max - min)
		valueLabel.Text = string.format(fmt, v) .. suffix
		local t = fast and 0.08 or 0.3
		Tween(fill, { Size = UDim2.fromScale(a, 1) }, t, fast and EASE.Quad or EASE.Quint)
		Tween(knob, { Position = UDim2.fromScale(a, 0.5) }, t, fast and EASE.Quad or EASE.Quint)
	end
	function obj:Set(v, fromInput)
		v = snap(tonumber(v) or min)
		local changed = v ~= value
		value = v
		if opts.Flag then Library.Flags[opts.Flag] = v end
		render(v, fromInput)
		if changed or not fromInput then
			if fromInput and os.clock() - lastTick > 0.04 then
				lastTick = os.clock()
				Library:PlaySound("Slider")
			end
			Safe(opts.Callback, v)
		end
	end
	function obj:Get() return value end

	local dragging, dragInput = false, nil
	local function fromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		obj:Set(min + (max - min) * rel, true)
	end
	local function stopDrag()
		if not dragging then return end
		dragging, dragInput = false, nil
		self._scroll.ScrollingEnabled = true
		Tween(knobScale, { Scale = 1 }, 0.3, EASE.Back)
		Tween(stroke, { Color = Theme.Outline, Transparency = 0.35 }, 0.25)
	end
	hit.InputBegan:Connect(function(input)
		if IsPress(input) then
			dragging, dragInput = true, input
			self._scroll.ScrollingEnabled = false -- evita que el scroll robe el gesto en móvil
			Tween(knobScale, { Scale = 1.35 }, 0.25, EASE.Back)
			Tween(stroke, { Color = Theme.Accent, Transparency = 0.05 }, 0.2)
			Library:PlaySound("Click")
			fromX(input.Position.X)
		end
	end)
	Library:_Connect(UserInputService.InputChanged, function(input)
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
			fromX(input.Position.X)
		end
	end)
	Library:_Connect(UserInputService.InputEnded, function(input)
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1) then stopDrag() end
	end)

	render(value, false)
	RegisterFlag(opts, obj)
	task.defer(function() Safe(opts.Callback, value) end)
	return obj
end

-- ── Dropdown / Multi-dropdown ─────────────────────────────────────────
local function BuildDropdown(tab, opts, multi)
	opts = opts or {}
	local options = {}
	for _, v in ipairs(opts.Options or opts.Values or {}) do options[#options + 1] = v end

	local selected, single = {}, nil
	local isOpen = false
	local inner, gap = M.Elem, 4
	local wrapper, card, stroke = CreateCard(tab._scroll, inner, tab:_Order())

	Create("TextLabel", {
		Text = opts.Name or (multi and "Multi-Dropdown" or "Dropdown"), Font = FONT.Medium, TextSize = M.Text,
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.5, -14, 0, inner), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	local valueLabel = Create("TextLabel", {
		Font = FONT.Medium, TextSize = M.Small + 1, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -36, 0, 0), Size = UDim2.new(0.5, -30, 0, inner),
		TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	local arrow = Create("TextLabel", {
		Text = "▾", Font = FONT.Bold, TextSize = M.Text + 2, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.fromOffset(20, inner), Parent = card,
	})
	local divider = Create("Frame", { BackgroundColor3 = Theme.Outline, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, inner), Size = UDim2.new(1, -20, 0, 1), Parent = card })
	local header = Create("TextButton", { Name = "Header", Size = UDim2.new(1, 0, 0, inner), ZIndex = 5, Parent = card })
	Pressable(header, card, stroke, { NoPress = true })

	local list = Create("ScrollingFrame", {
		Name = "List", Position = UDim2.fromOffset(8, inner + 6), Size = UDim2.new(1, -16, 0, 0), ScrollBarThickness = 2,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = card,
	})
	Create("UIListLayout", { Padding = UDim.new(0, gap), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

	local items = {}
	local obj = { Instance = wrapper, Type = multi and "MultiDropdown" or "Dropdown" }

	local function isSelected(o) if multi then return selected[o] == true end return single == o end
	local function getValue()
		if not multi then return single end
		local arr = {}
		for _, o in ipairs(options) do if selected[o] then arr[#arr + 1] = o end end
		return arr
	end
	local function display()
		if not multi then
			valueLabel.Text = single ~= nil and tostring(single) or "Seleccionar..."
			return
		end
		local arr = getValue()
		if #arr == 0 then valueLabel.Text = "Ninguno"
		elseif #arr <= 2 then
			local parts = {}
			for _, v in ipairs(arr) do parts[#parts + 1] = tostring(v) end
			valueLabel.Text = table.concat(parts, ", ")
		else valueLabel.Text = tostring(arr[1]) .. ", " .. tostring(arr[2]) .. " +" .. (#arr - 2) end
	end
	local function paint(animate)
		local t = animate and 0.2 or 0
		for o, it in pairs(items) do
			local on = isSelected(o)
			Tween(it.Item, { BackgroundTransparency = on and 0.7 or 1 }, t)
			Tween(it.Text, { TextColor3 = on and Theme.Text or Theme.SubText }, t)
			Tween(it.Check, { TextTransparency = on and 0 or 1 }, t)
		end
		display()
	end
	local function listH()
		local n = math.min(#options, 5)
		return n > 0 and (n * M.Opt + (n - 1) * gap) or 0
	end
	local function setOpen(state)
		if state and #options == 0 then return end
		isOpen = state
		local lh = listH()
		if state then list.Visible = true end
		Tween(list, { Size = UDim2.new(1, -16, 0, state and lh or 0) }, 0.32)
		Tween(wrapper, { Size = UDim2.new(1, 0, 0, state and (inner + lh + 12 + 3) or (inner + 3)) }, 0.32, EASE.Quint)
		Tween(arrow, { Rotation = state and 180 or 0 }, 0.35, EASE.Back)
		Tween(divider, { BackgroundTransparency = state and 0.5 or 1 }, 0.25)
		if not state then
			task.delay(0.33, function() if not isOpen then list.Visible = false end end)
		end
	end

	local function fire()
		local v = getValue()
		if opts.Flag then Library.Flags[opts.Flag] = v end
		Safe(opts.Callback, v)
	end
	local function choose(o)
		Library:PlaySound("Click")
		if multi then
			selected[o] = (not selected[o]) or nil
			paint(true)
			fire()
		else
			single = o
			paint(true)
			fire()
			setOpen(false)
		end
	end

	local function build()
		for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
		items = {}
		for i, o in ipairs(options) do
			local item = Create("TextButton", {
				Name = tostring(o), BackgroundColor3 = WHITE, BackgroundTransparency = 1,
				Size = UDim2.new(1, -6, 0, M.Opt), LayoutOrder = i, Parent = list,
			})
			Corner(item, 7)
			AccentGrad(item, 0)
			local txt = Create("TextLabel", {
				Text = tostring(o), Font = FONT.Medium, TextSize = M.Small + 1, TextColor3 = Theme.SubText,
				Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -40, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = item,
			})
			local check = Create("TextLabel", {
				Text = "✓", Font = FONT.Black, TextSize = M.Text, TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 1,
				AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(20, M.Opt), Parent = item,
			})
			item.MouseEnter:Connect(function()
				if not isSelected(o) then Tween(item, { BackgroundTransparency = 0.88 }, 0.15) end
			end)
			item.MouseLeave:Connect(function()
				if not isSelected(o) then Tween(item, { BackgroundTransparency = 1 }, 0.15) end
			end)
			item.Activated:Connect(function() choose(o) end)
			items[o] = { Item = item, Text = txt, Check = check }
		end
		paint(false)
	end

	function obj:Set(v)
		if multi then
			selected = {}
			if type(v) == "table" then
				for k, val in pairs(v) do
					if type(k) == "number" then selected[val] = true elseif val then selected[k] = true end
				end
			end
		else
			single = v
		end
		paint(true)
		fire()
	end
	function obj:Get() return getValue() end
	function obj:Refresh(newOptions, keep)
		options = {}
		for _, v in ipairs(newOptions or {}) do options[#options + 1] = v end
		if not keep then selected, single = {}, nil end
		build()
		if isOpen then
			local lh = listH()
			Tween(list, { Size = UDim2.new(1, -16, 0, lh) }, 0.25)
			Tween(wrapper, { Size = UDim2.new(1, 0, 0, inner + lh + 12 + 3) }, 0.25)
		end
	end
	function obj:Open() setOpen(true) end
	function obj:Close() setOpen(false) end

	header.Activated:Connect(function(input)
		Library:PlaySound("Click")
		Ripple(card, input)
		setOpen(not isOpen)
	end)

	-- Valor por defecto
	if multi then
		if type(opts.Default) == "table" then for _, v in ipairs(opts.Default) do selected[v] = true end end
	else
		single = opts.Default
	end
	build()
	RegisterFlag(opts, obj)
	task.defer(function() Safe(opts.Callback, getValue()) end)
	return obj
end

function TabClass:AddDropdown(opts) return BuildDropdown(self, opts, false) end
function TabClass:AddMultiDropdown(opts) return BuildDropdown(self, opts, true) end

-- ── Input de texto ────────────────────────────────────────────────────
function TabClass:AddInput(opts)
	opts = opts or {}
	local wrapper, card, stroke = CreateCard(self._scroll, M.Elem, self:_Order())
	local boxW = math.floor(self.Window._contentW * 0.46)
	Create("TextLabel", {
		Text = opts.Name or "Input", Font = FONT.Medium, TextSize = M.Text, Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -(boxW + 28), 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	local box = Create("Frame", {
		BackgroundColor3 = Theme.Dark, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(boxW, M.Elem - 12), Parent = card,
	})
	Corner(box, 7)
	local boxStroke = Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = box })
	local tb = Create("TextBox", {
		Text = tostring(opts.Default or ""), PlaceholderText = opts.Placeholder or "Escribe aquí...", TextSize = M.Small + 1,
		Position = UDim2.fromOffset(9, 0), Size = UDim2.new(1, -18, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd,
		ClearTextOnFocus = opts.ClearOnFocus == true, Parent = box,
	})

	local obj = { Instance = wrapper, Type = "Input" }
	local value = tb.Text
	tb.Focused:Connect(function()
		Library:PlaySound("Click")
		Tween(boxStroke, { Color = Theme.Accent, Thickness = 2, Transparency = 0 }, 0.2)
		Tween(box, { BackgroundColor3 = Theme.Background }, 0.2)
	end)
	if opts.Numeric then
		tb:GetPropertyChangedSignal("Text"):Connect(function()
			local clean = tb.Text:gsub("[^%d%.%-]", "")
			if clean ~= tb.Text then tb.Text = clean end
		end)
	end
	if opts.MaxLength then
		tb:GetPropertyChangedSignal("Text"):Connect(function()
			if #tb.Text > opts.MaxLength then tb.Text = tb.Text:sub(1, opts.MaxLength) end
		end)
	end
	tb.FocusLost:Connect(function(enter)
		Tween(boxStroke, { Color = Theme.Outline, Thickness = 1, Transparency = 0.2 }, 0.2)
		Tween(box, { BackgroundColor3 = Theme.Dark }, 0.2)
		value = tb.Text
		if opts.Flag then Library.Flags[opts.Flag] = value end
		Safe(opts.Callback, value, enter)
		if opts.ClearAfter then tb.Text = "" end
	end)
	function obj:Set(t)
		tb.Text = tostring(t)
		value = tb.Text
		if opts.Flag then Library.Flags[opts.Flag] = value end
		Safe(opts.Callback, value, false)
	end
	function obj:Get() return value end
	function obj:Focus() tb:CaptureFocus() end
	RegisterFlag(opts, obj)
	return obj
end

-- ── Keybind ───────────────────────────────────────────────────────────
function TabClass:AddKeybind(opts)
	opts = opts or {}
	local key = opts.Default or Enum.KeyCode.Unknown
	local wrapper, card, stroke = CreateCard(self._scroll, M.Elem, self:_Order())
	Create("TextLabel", {
		Text = opts.Name or "Keybind", Font = FONT.Medium, TextSize = M.Text, Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -130, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = card,
	})
	local box = Create("Frame", {
		BackgroundColor3 = Theme.Dark, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(96, M.Elem - 12), Parent = card,
	})
	Corner(box, 7)
	Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = box })
	local keyLabel = Create("TextLabel", {
		Font = FONT.Bold, TextSize = M.Small + 1, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1), Parent = box,
	})
	OnAccent(keyLabel, function() keyLabel.TextColor3 = Theme.Accent end)
	local hit = Create("TextButton", { Name = "Hit", Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = card })
	Pressable(hit, card, stroke)

	local waiting = false
	local obj = { Instance = wrapper, Type = "Keybind" }
	local function show() keyLabel.Text = waiting and "..." or (key == Enum.KeyCode.Unknown and "Ninguna" or key.Name) end
	function obj:Set(k)
		if typeof(k) == "EnumItem" then key = k end
		if opts.Flag then Library.Flags[opts.Flag] = key end
		show()
		Safe(opts.Changed, key)
	end
	function obj:Get() return key end

	hit.Activated:Connect(function(input)
		Library:PlaySound("Click")
		Ripple(card, input)
		waiting = true
		Library._capturing = true
		show()
	end)
	Library:_Connect(UserInputService.InputBegan, function(input, gpe)
		if waiting then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				waiting = false
				task.defer(function() Library._capturing = false end)
				if input.KeyCode ~= Enum.KeyCode.Escape then
					obj:Set(input.KeyCode)
				else
					show()
				end
			end
			return
		end
		if not gpe and key ~= Enum.KeyCode.Unknown and input.KeyCode == key then
			Safe(opts.Callback, key)
		end
	end)
	show()
	RegisterFlag(opts, obj)
	return obj
end

-- ═══════════════════════════════════════════════════════════════════════
--  CLASE VENTANA
-- ═══════════════════════════════════════════════════════════════════════
local WindowClass = {}
WindowClass.__index = WindowClass

function WindowClass:_FitScale()
	local vp = Viewport()
	return math.min(1, (vp.X * 0.96) / self._W, (vp.Y * 0.92) / self._H)
end

function WindowClass:_ApplyScale()
	local s = math.clamp(self:_FitScale() * self._userScale, 0.4, 1.6)
	self._devScale.Scale = s
	Library._scale = s
end

function WindowClass:SetScale(v)
	self._userScale = math.clamp(tonumber(v) or 1, 0.5, 1.5)
	self:_ApplyScale()
end

function WindowClass:Notify(opts) return Library:Notify(opts) end

-- Mostrar / ocultar con animación
function WindowClass:Toggle(state)
	if state == nil then state = not self.Visible end
	if state == self.Visible then return end
	self.Visible = state
	Library:PlaySound(state and "Open" or "Close")
	if state then
		self._wrapper.Visible = true
		self._animScale.Scale = 0.8
		self._body.GroupTransparency = 1
		Tween(self._animScale, { Scale = 1 }, 0.55, EASE.Back)
		Tween(self._body, { GroupTransparency = 0 }, 0.35)
		Tween(self._border, { Transparency = 0 }, 0.5)
		Tween(self._glow, { Transparency = 0.72 }, 0.6)
		Tween(self._shadow, { ImageTransparency = 0.45 }, 0.5)
	else
		Tween(self._animScale, { Scale = 0.86 }, 0.32, EASE.Quint, DIR.In)
		Tween(self._body, { GroupTransparency = 1 }, 0.28)
		Tween(self._border, { Transparency = 1 }, 0.25)
		Tween(self._glow, { Transparency = 1 }, 0.25)
		Tween(self._shadow, { ImageTransparency = 1 }, 0.25)
		task.delay(0.34, function()
			if not self.Visible and self._wrapper then self._wrapper.Visible = false end
		end)
		if not self._hintShown then
			self._hintShown = true
			local how = IsMobile and "el botón flotante" or ("la tecla " .. self._toggleKey.Name .. " o el botón flotante")
			Library:Notify({ Type = "info", Title = "Interfaz oculta", Content = "Pulsa " .. how .. " para volver a abrirla.", Duration = 4 })
		end
	end
end

function WindowClass:Minimize(state)
	if state == nil then state = not self.Minimized end
	if state == self.Minimized then return end
	self.Minimized = state
	Library:PlaySound(state and "Close" or "Open")
	self._minLabel.Text = state and "□" or "–"
	Tween(self._wrapper, { Size = UDim2.fromOffset(self._W, state and M.Top or self._H) }, 0.45, EASE.Quint)
	if state then
		task.delay(0.45, function() if self.Minimized then self._content.Visible = false end end)
	else
		self._content.Visible = true
	end
end

function WindowClass:SelectTab(tab)
	if type(tab) == "string" then
		for _, t in ipairs(self.Tabs) do if t.Name == tab then tab = t break end end
	end
	if type(tab) ~= "table" or self.ActiveTab == tab then return end
	local old = self.ActiveTab
	self.ActiveTab = tab
	if old then old:_Hide() end
	tab:_Show()
	for _, t in ipairs(self.Tabs) do
		if t._setButton then t._setButton(t == tab) end
	end
	if self._gearLabel then
		Tween(self._gearLabel, { Rotation = tab.Hidden and 90 or 0 }, 0.45, EASE.Back)
	end
end

function TabClass:_Show()
	self._token = (self._token or 0) + 1
	local page = self._page
	page.Visible = true
	page.Position = UDim2.fromOffset(0, 18)
	page.GroupTransparency = 1
	Tween(page, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 }, 0.4)
end

function TabClass:_Hide()
	self._token = (self._token or 0) + 1
	local token = self._token
	Tween(self._page, { GroupTransparency = 1 }, 0.15)
	task.delay(0.17, function()
		if self._token == token and self._page then self._page.Visible = false end
	end)
end

function WindowClass:AddTab(opts)
	if type(opts) == "string" then opts = { Name = opts } end
	opts = opts or {}
	local tab = setmetatable({
		Window = self, Name = opts.Name or "Tab", Icon = opts.Icon or "dot", Hidden = opts.Hidden == true, _order = 0,
	}, TabClass)

	-- Página (CanvasGroup para poder desvanecerla) + ScrollingFrame fluido
	local page = Create("CanvasGroup", { Name = tab.Name, Size = UDim2.fromScale(1, 1), Visible = false, GroupTransparency = 1, Parent = self._pages })
	local scroll = Create("ScrollingFrame", {
		Name = "Scroll", Size = UDim2.fromScale(1, 1), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = IsMobile and 4 or 3, Parent = page,
	})
	OnAccent(scroll, function() scroll.ScrollBarImageColor3 = Theme.Accent end)
	Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
	Pad(scroll, 0, 2, 8, 10)
	tab._page, tab._scroll = page, scroll
	self.Tabs[#self.Tabs + 1] = tab

	if not tab.Hidden then
		local btn = Create("TextButton", { Name = tab.Name, LayoutOrder = #self.Tabs, Parent = self._tabList })
		btn.Size = IsMobile and UDim2.new(0, 76, 1, -10) or UDim2.new(1, 0, 0, M.TabBtn)
		local fill = Create("Frame", { Name = "Fill", BackgroundColor3 = WHITE, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = btn })
		Corner(fill, 9)
		AccentGrad(fill, 0)
		local fstroke = Create("UIStroke", { Color = Theme.Accent, Thickness = 1.2, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = fill })
		OnAccent(fstroke, function() fstroke.Color = Theme.Accent end)

		local holder, text
		if IsMobile then
			holder = Create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 4), Size = UDim2.new(1, 0, 0, 26), Parent = btn })
			text = Create("TextLabel", {
				Text = tab.Name, Font = FONT.Medium, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Center,
				Position = UDim2.new(0, 2, 1, -18), Size = UDim2.new(1, -4, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
			})
		else
			holder = Create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.fromOffset(26, M.TabBtn), Parent = btn })
			text = Create("TextLabel", {
				Text = tab.Name, Font = FONT.Medium, TextSize = M.Text, TextColor3 = Theme.SubText,
				Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -46, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd, Parent = btn,
			})
		end
		local icon = MakeIcon(holder, tab.Icon, IsMobile and 20 or 18)
		ScaleButton(btn)

		local active, hovered = false, false
		tab._setButton = function(on)
			active = on
			Tween(fill, { BackgroundTransparency = on and 0.1 or (hovered and 0.9 or 1) }, 0.3)
			Tween(fstroke, { Transparency = on and 0.15 or 1 }, 0.3)
			Tween(text, { TextColor3 = on and WHITE or Theme.SubText }, 0.25)
			SetIconColor(icon, on and WHITE or Theme.SubText)
		end
		btn.MouseEnter:Connect(function()
			hovered = true
			if not active then Tween(fill, { BackgroundTransparency = 0.9 }, 0.2) end
		end)
		btn.MouseLeave:Connect(function()
			hovered = false
			if not active then Tween(fill, { BackgroundTransparency = 1 }, 0.2) end
		end)
		btn.Activated:Connect(function()
			if self.ActiveTab ~= tab then Library:PlaySound("Click") end
			self:SelectTab(tab)
			-- pequeño "pop" del ícono
			Tween(icon, { Rotation = 12 }, 0.12)
			task.delay(0.12, function() Tween(icon, { Rotation = 0 }, 0.4, EASE.Back) end)
		end)
		tab._button = btn
		if not self.ActiveTab or self.ActiveTab.Hidden then
			if not self._firstSelected then
				self._firstSelected = true
				self:SelectTab(tab)
			end
		end
	end
	return tab
end

function WindowClass:Destroy()
	if self._wrapper then self._wrapper:Destroy() self._wrapper = nil end
	if self._orb then self._orb:Destroy() self._orb = nil end
	for i, w in ipairs(Library.Windows) do if w == self then table.remove(Library.Windows, i) break end end
end

-- ═══════════════════════════════════════════════════════════════════════
--  CONFIGURACIONES (guardar / cargar flags en archivos JSON)
-- ═══════════════════════════════════════════════════════════════════════
local CONFIG_DIR = "M4teoUI_Configs"

function Library:SaveConfig(name)
	if not (writefile and makefolder and isfolder) then return false, "Tu ejecutor no soporta writefile" end
	name = (name and name ~= "") and name or "default"
	pcall(function() if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end end)
	local data = {}
	for flag, v in pairs(self.Flags) do
		if typeof(v) == "EnumItem" then data[flag] = { __key = v.Name }
		elseif type(v) == "boolean" or type(v) == "number" or type(v) == "string" or type(v) == "table" then data[flag] = v end
	end
	local ok, err = pcall(function() writefile(CONFIG_DIR .. "/" .. name .. ".json", HttpService:JSONEncode(data)) end)
	return ok, err
end

function Library:LoadConfig(name)
	if not (readfile and isfile) then return false, "Tu ejecutor no soporta readfile" end
	name = (name and name ~= "") and name or "default"
	local path = CONFIG_DIR .. "/" .. name .. ".json"
	if not isfile(path) then return false, "No existe la configuración '" .. name .. "'" end
	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if not ok then return false, data end
	for flag, v in pairs(data) do
		local opt = self.Options[flag]
		if opt then
			if type(v) == "table" and v.__key then v = Enum.KeyCode[v.__key] end
			pcall(function() opt:Set(v) end)
		end
	end
	return true
end

-- ═══════════════════════════════════════════════════════════════════════
--  CREAR VENTANA
-- ═══════════════════════════════════════════════════════════════════════
function Library:CreateWindow(opts)
	opts = opts or {}
	self:_Init()
	if opts.Accent then self:SetAccent(opts.Accent, opts.Accent2) end

	local Window = setmetatable({
		Library = self, Tabs = {}, Visible = false, Minimized = false, _userScale = 1,
		_toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift,
	}, WindowClass)
	local gui = self._gui
	local vp = Viewport()

	-- Tamaño: en móvil se adapta al viewport; en PC usa un tamaño fijo con escalado automático
	local W, H
	if opts.Size then
		W, H = opts.Size.X.Offset, opts.Size.Y.Offset
	elseif IsMobile then
		W = math.clamp(math.floor(vp.X * 0.92), 320, 560)
		H = math.clamp(math.floor(vp.Y * 0.86), 280, 420)
	else
		W, H = 640, 430
	end
	Window._W, Window._H = W, H

	local contentH = H - M.Top
	local pagesW = IsMobile and (W - M.Pad * 2) or (W - M.Side - M.Pad * 2)
	local pagesH = contentH - M.Banner - (IsMobile and M.TabBar or 0) - M.Pad * 2
	Window._contentW = pagesW - 8

	-- Contenedor con escala de dispositivo
	local wrapper = Create("Frame", {
		Name = "Window", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Visible = false,
		Size = UDim2.fromOffset(W, H), Parent = gui,
	})
	local devScale = Create("UIScale", { Parent = wrapper })
	Window._wrapper, Window._devScale = wrapper, devScale
	Window:_ApplyScale()
	wrapper.Position = UDim2.new(0.5, 0, 0.5, -math.floor(H * devScale.Scale / 2))

	local root = Create("Frame", { Name = "Root", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), Parent = wrapper })
	local animScale = Create("UIScale", { Scale = 0.8, Parent = root })
	Window._animScale = animScale

	-- Sombra, cuerpo 3D, brillo exterior y borde animado
	local shadow = Create("ImageLabel", {
		Name = "Shadow", Image = "rbxassetid://1316045217", ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(10, 10, 118, 118),
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 10), Size = UDim2.new(1, 70, 1, 70), ZIndex = 0, Parent = root,
	})
	local body = Create("CanvasGroup", {
		Name = "Body", BackgroundTransparency = 0, BackgroundColor3 = Theme.Background, GroupTransparency = 1,
		Size = UDim2.fromScale(1, 1), Active = true, ZIndex = 1, Parent = root,
	})
	Corner(body, 14)
	Gradient3D(body, 1, 0.82)
	local glowFrame = Create("Frame", { Name = "Glow", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 6, 1, 6), ZIndex = 2, Parent = root })
	Corner(glowFrame, 17)
	local glowStroke = AnimatedStroke(glowFrame, 7, 1, 80, 0)
	local borderFrame = Create("Frame", { Name = "Border", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = root })
	Corner(borderFrame, 14)
	local borderStroke = AnimatedStroke(borderFrame, 2.5, 1, 80, 0)
	Window._shadow, Window._body, Window._glow, Window._border = shadow, body, glowStroke, borderStroke

	-- Reflejo superior (efecto cristal 3D)
	local gloss = Create("Frame", { BackgroundColor3 = WHITE, BackgroundTransparency = 0.85, Position = UDim2.fromOffset(14, 1), Size = UDim2.new(1, -28, 0, 1), ZIndex = 10, Parent = body })
	Create("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = gloss })

	-- ── Barra superior ───────────────────────────────────────────────
	local top = Create("Frame", { Name = "TopBar", BackgroundColor3 = Theme.Surface, Size = UDim2.new(1, 0, 0, M.Top), Active = true, ZIndex = 2, Parent = body })
	Gradient3D(top, 1, 0.76)
	Create("Frame", { BackgroundColor3 = Theme.Outline, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), ZIndex = 3, Parent = top })

	local logoS = M.Top - 18
	local logo = Create("Frame", { Name = "Logo", BackgroundColor3 = WHITE, Position = UDim2.new(0, 12, 0.5, -logoS / 2), Size = UDim2.fromOffset(logoS, logoS), ZIndex = 3, Parent = top })
	Corner(logo, 9)
	AccentGrad(logo, 45)
	AnimatedStroke(logo, 1.5, 0.25, 120)
	MakeIcon(logo, opts.Icon or "M", logoS * 0.6)

	local titleX = 12 + logoS + 10
	local btnsW = 3 * (M.TopBtn + 6) + 8
	local subtitle = tostring(opts.Subtitle or "")
	Create("TextLabel", {
		Text = tostring(opts.Title or "M4teoUI"), Font = FONT.Black, TextSize = M.Text + 2,
		Position = UDim2.fromOffset(titleX, subtitle ~= "" and 5 or 0), Size = UDim2.new(1, -(titleX + btnsW), 0, subtitle ~= "" and 20 or M.Top),
		TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = top,
	})
	if subtitle ~= "" then
		Create("TextLabel", {
			Text = subtitle, Font = FONT.Medium, TextSize = 11, TextColor3 = Theme.SubText,
			Position = UDim2.fromOffset(titleX, 25), Size = UDim2.new(1, -(titleX + btnsW), 0, 14),
			TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3, Parent = top,
		})
	end

	local function TopButton(glyph, slot, hover)
		local b = Create("TextButton", {
			Name = "Btn" .. slot, BackgroundTransparency = 0, BackgroundColor3 = Theme.SurfaceHover, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -(10 + slot * (M.TopBtn + 6)), 0.5, 0), Size = UDim2.fromOffset(M.TopBtn, M.TopBtn), ZIndex = 4, Parent = top,
		})
		Corner(b, 8)
		Gradient3D(b, 1, 0.72)
		Create("UIStroke", { Color = Theme.Outline, Thickness = 1, Transparency = 0.3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = b })
		local l = Create("TextLabel", {
			Text = glyph, Font = FONT.Bold, TextSize = M.Text + 3, TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1), ZIndex = 5, Parent = b,
		})
		ScaleButton(b)
		b.MouseEnter:Connect(function() Tween(b, { BackgroundColor3 = hover() }, 0.2) end)
		b.MouseLeave:Connect(function() Tween(b, { BackgroundColor3 = Theme.SurfaceHover }, 0.2) end)
		return b, l
	end
	local closeBtn = TopButton("×", 0, function() return Color3.fromRGB(220, 60, 80) end)
	local minBtn, minLabel = TopButton("–", 1, function() return Theme.Accent end)
	local gearBtn, gearLabel = TopButton("⚙", 2, function() return Theme.Accent end)
	Window._minLabel, Window._gearLabel = minLabel, gearLabel

	closeBtn.Activated:Connect(function() Library:PlaySound("Click") Window:Toggle(false) end)
	minBtn.Activated:Connect(function() Library:PlaySound("Click") Window:Minimize() end)

	-- Arrastre desde la barra superior (ratón y táctil)
	do
		local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
		top.InputBegan:Connect(function(input)
			if IsPress(input) then
				dragging, dragInput, dragStart, startPos = true, input, input.Position, wrapper.Position
			end
		end)
		Library:_Connect(UserInputService.InputChanged, function(input)
			if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
				local d = input.Position - dragStart
				wrapper.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
		Library:_Connect(UserInputService.InputEnded, function(input)
			if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1) then dragging = false end
		end)
	end

	-- ── Contenido (tamaño fijo; el cuerpo lo recorta al minimizar) ─────
	local content = Create("Frame", { Name = "Content", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, M.Top), Size = UDim2.fromOffset(W, contentH), Parent = body })
	Window._content = content

	-- Barra de pestañas: lateral en PC / inferior (zona del pulgar) en móvil
	if IsMobile then
		local bar = Create("Frame", {
			Name = "TabBar", BackgroundColor3 = Theme.Surface, Position = UDim2.fromOffset(0, contentH - M.Banner - M.TabBar),
			Size = UDim2.fromOffset(W, M.TabBar), Parent = content,
		})
		Gradient3D(bar, 1, 0.78)
		Create("Frame", { BackgroundColor3 = Theme.Outline, Size = UDim2.new(1, 0, 0, 1), Parent = bar })
		local lst = Create("ScrollingFrame", {
			Name = "Tabs", Size = UDim2.fromScale(1, 1), ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X,
			AutomaticCanvasSize = Enum.AutomaticSize.X, Parent = bar,
		})
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Parent = lst,
		})
		Pad(lst, 8, 0, 8, 0)
		Window._tabList = lst
	else
		local side = Create("Frame", { Name = "Sidebar", BackgroundColor3 = Theme.Surface, Size = UDim2.fromOffset(M.Side, contentH - M.Banner), Parent = content })
		Gradient3D(side, 1, 0.8)
		Create("Frame", { BackgroundColor3 = Theme.Outline, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0), Parent = side })
		local lst = Create("ScrollingFrame", {
			Name = "Tabs", Size = UDim2.new(1, -1, 1, 0), ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y, Parent = side,
		})
		Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = lst })
		Pad(lst, 10, 10, 10, 10)
		Window._tabList = lst
	end

	-- Contenedor de páginas
	Window._pages = Create("Frame", {
		Name = "Pages", BackgroundTransparency = 1, ClipsDescendants = true,
		Position = UDim2.fromOffset(IsMobile and M.Pad or (M.Side + M.Pad), M.Pad), Size = UDim2.fromOffset(pagesW, pagesH), Parent = content,
	})

	-- ── Banner dorado brillante ──────────────────────────────────────
	local banner = Create("Frame", {
		Name = "Banner", BackgroundColor3 = WHITE, Position = UDim2.new(0, 0, 1, -M.Banner), Size = UDim2.new(1, 0, 0, M.Banner),
		ClipsDescendants = true, ZIndex = 5, Parent = content,
	})
	Create("UIGradient", {
		Rotation = 90, Parent = banner,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 238, 150)),
			ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 200, 40)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(176, 116, 0)),
		}),
	})
	Create("Frame", { BackgroundColor3 = Color3.fromRGB(255, 248, 200), Size = UDim2.new(1, 0, 0, 1), ZIndex = 6, Parent = banner })
	local shine = Create("Frame", { BackgroundColor3 = WHITE, Size = UDim2.fromScale(1, 1), ZIndex = 6, Parent = banner })
	local shineGrad = Create("UIGradient", {
		Rotation = 20, Parent = shine,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.42, 1), NumberSequenceKeypoint.new(0.5, 0.25),
			NumberSequenceKeypoint.new(0.58, 1), NumberSequenceKeypoint.new(1, 1),
		}),
	})
	local credit = Create("TextLabel", {
		Text = "✦  " .. Library.Credit .. "  ✦", Font = FONT.Black, TextSize = M.Small, TextColor3 = Color3.fromRGB(70, 42, 0),
		TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 7, Parent = banner,
	})
	Create("UIStroke", { Color = Color3.fromRGB(255, 244, 190), Thickness = 0.8, Transparency = 0.45, Parent = credit })
	AddUpdater(function(_, t)
		if not shineGrad.Parent then return false end
		shineGrad.Offset = Vector2.new(((t * 0.4) % 2.4) - 1.2, 0)
	end)

	-- ── Registro, teclas y escala ─────────────────────────────────────
	self.Windows[#self.Windows + 1] = Window

	self:_Connect(UserInputService.InputBegan, function(input, gpe)
		if gpe or self._capturing then return end
		if input.KeyCode == Window._toggleKey then Window:Toggle() end
	end)
	self:_Connect(gui:GetPropertyChangedSignal("AbsoluteSize"), function() Window:_ApplyScale() end)

	-- ── Botón flotante (arrastrable, zona cómoda para el pulgar) ───────
	if opts.FloatingButton ~= false then
		local size = IsMobile and 56 or 46
		local orb = Create("TextButton", {
			Name = "Orb", BackgroundColor3 = WHITE, AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 50,
			Position = IsMobile and UDim2.new(1, -(size / 2 + 14), 0.62, 0) or UDim2.new(0, size / 2 + 20, 0.5, 0),
			Size = UDim2.fromOffset(size, size), Parent = gui,
		})
		Corner(orb, size / 2)
		AccentGrad(orb, 45)
		AnimatedStroke(orb, 3, 0, 140)
		local orbScale = Create("UIScale", { Parent = orb })
		local shineOrb = Create("Frame", {
			BackgroundColor3 = WHITE, BackgroundTransparency = 0.78, Position = UDim2.fromScale(0.16, 0.06), Size = UDim2.fromScale(0.68, 0.38), Parent = orb,
		})
		Corner(shineOrb, 99)
		local orbIcon = MakeIcon(orb, opts.Icon or "M", size * 0.46)
		orbIcon.Position = UDim2.fromScale(0.5, 0.55)
		Window._orb = orb

		AddUpdater(function(_, t)
			if not orbScale.Parent then return false end
			orbScale.Scale = 1 + math.sin(t * 2.2) * 0.035
		end)

		local dragging, moved, dragInput, dragStart, startPos = false, false, nil, nil, nil
		orb.InputBegan:Connect(function(input)
			if IsPress(input) then
				dragging, moved, dragInput, dragStart, startPos = true, false, input, input.Position, orb.Position
			end
		end)
		self:_Connect(UserInputService.InputChanged, function(input)
			if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
				local d = input.Position - dragStart
				if d.Magnitude > 7 then moved = true end
				if moved then
					orb.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				end
			end
		end)
		self:_Connect(UserInputService.InputEnded, function(input)
			if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
				dragging = false
				if not moved then
					Window:Toggle()
					Tween(orbScale, { Scale = 0.85 }, 0.08)
				end
			end
		end)
	end

	-- ── Menú de ajustes integrado ─────────────────────────────────────
	local settings = Window:AddTab({ Name = "Ajustes", Icon = "settings", Hidden = true })
	Window._settingsTab = settings
	settings:AddTitle("Ajustes")
	settings:AddSubtitle("Personaliza la interfaz a tu gusto")

	settings:AddSection("Apariencia")
	settings:AddDropdown({
		Name = "Tema de color", Options = Library.PresetOrder,
		Callback = function(v)
			local p = v and Library.Presets[v]
			if p then Library:SetAccent(p[1], p[2]) end
		end,
	})
	settings:AddSlider({
		Name = "Escala de la interfaz", Min = 50, Max = 130, Default = 100, Increment = 5, Suffix = "%",
		Callback = function(v) Window:SetScale(v / 100) end,
	})
	settings:AddToggle({
		Name = "Animaciones", Default = true,
		Callback = function(v) Library.Settings.Animations = v end,
	})

	settings:AddSection("Sonido y avisos")
	settings:AddToggle({
		Name = "Efectos de sonido", Default = true,
		Callback = function(v) Library.Settings.Sounds = v end,
	})
	settings:AddSlider({
		Name = "Volumen", Min = 0, Max = 100, Default = 60, Increment = 5, Suffix = "%",
		Callback = function(v) Library.Settings.Volume = v / 100 end,
	})
	settings:AddToggle({
		Name = "Notificaciones", Default = true,
		Callback = function(v) Library.Settings.Notifications = v end,
	})
	do
		local kinds, idx = { "info", "success", "warning", "error" }, 0
		settings:AddButton({
			Name = "Probar notificación",
			Callback = function()
				idx = idx % #kinds + 1
				Library.Settings.Notifications = true
				Library:Notify({ Type = kinds[idx], Title = "Notificación de prueba", Content = "Tipo: " .. kinds[idx], Duration = 3.5 })
			end,
		})
	end

	if not IsMobile then
		settings:AddSection("Controles")
		settings:AddKeybind({
			Name = "Mostrar / ocultar", Default = Window._toggleKey,
			Changed = function(k) Window._toggleKey = k end,
		})
	end

	settings:AddSection("Configuración guardada")
	local cfgName = "default"
	settings:AddInput({ Name = "Nombre", Default = "default", Placeholder = "default", Callback = function(t) cfgName = (t ~= "" and t) or "default" end })
	settings:AddButton({
		Name = "Guardar configuración",
		Callback = function()
			local ok, err = Library:SaveConfig(cfgName)
			Library:Notify({ Type = ok and "success" or "error", Title = ok and "Guardado" or "No se pudo guardar", Content = ok and cfgName or tostring(err) })
		end,
	})
	settings:AddButton({
		Name = "Cargar configuración",
		Callback = function()
			local ok, err = Library:LoadConfig(cfgName)
			Library:Notify({ Type = ok and "success" or "error", Title = ok and "Cargado" or "No se pudo cargar", Content = ok and cfgName or tostring(err) })
		end,
	})

	settings:AddSection("Acerca de")
	settings:AddParagraph({
		Title = "M4teoUI v" .. Library.Version,
		Content = Library.Credit .. ". Librería de interfaz para Roblox con diseño 3D, animaciones y soporte móvil/PC.",
	})
	settings:AddButton({
		Name = "Destruir interfaz",
		Callback = function() Library:Destroy() end,
	})

	gearBtn.Activated:Connect(function()
		Library:PlaySound("Click")
		if Window.ActiveTab == settings then
			Window:SelectTab(Window._prevTab or Window.Tabs[1])
		else
			Window._prevTab = Window.ActiveTab
			Window:SelectTab(settings)
		end
	end)

	-- Abrir con animación de entrada
	task.defer(function() Window:Toggle(true) end)
	return Window
end

ENV.M4teoUI = Library
return Library
