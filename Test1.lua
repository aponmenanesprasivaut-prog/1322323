--[[
	AXME Stress-Test Script
	Injection: Xeno (loadstring)
	Single file, no external dependencies
]]

-- ===== ALIASES =====
local _Inst = Instance
local _TweenS = game:GetService("TweenService")
local _UIS = game:GetService("UserInputService")
local _RunS = game:GetService("RunService")
local _Plrs = game:GetService("Players")
local _LP = _Plrs.LocalPlayer
local _Cam = workspace.CurrentCamera
local _Mouse = _LP:GetMouse()
local _WS = workspace
local _VIM = game:GetService("VirtualInputManager")
local _V3 = Vector3.new
local _V2 = Vector2.new
local _CF = CFrame.new
local _Ang = CFrame.Angles
local _clamp = math.clamp
local _rad = math.rad
local _cos = math.cos
local _sin = math.sin
local _acos = math.acos
local _floor = math.floor
local _tick = tick
local _pairs = pairs
local _ipairs = ipairs
local _pcall = pcall
local _type = type
local _tbl = table
local _C3 = Color3
local _UD2 = UDim2
local _TInfo = TweenInfo.new
local _HttpS = game:GetService("HttpService")

-- ===== COLOR HELPERS =====
local _COLORS = {
	Red = _C3.fromRGB(255, 0, 0),
	Blue = _C3.fromRGB(0, 0, 255),
	Green = _C3.fromRGB(0, 255, 0),
	Yellow = _C3.fromRGB(255, 255, 0),
	Purple = _C3.fromRGB(128, 0, 128),
	Cyan = _C3.fromRGB(0, 255, 255),
	White = _C3.fromRGB(255, 255, 255),
	Black = _C3.fromRGB(0, 0, 0)
}

local function _getColor(name)
	return _COLORS[name] or _C3.fromRGB(255, 255, 255)
end

local function _getName(color)
	for name, c in _pairs(_COLORS) do
		if c.R == color.R and c.G == color.G and c.B == color.B then
			return name
		end
	end
	return "White"
end

-- ===== CONFIG (_G["ov"]) =====
if not _G["ov"] then
	_G["ov"] = {
		esp = {
			enabled = false,
			chams = false,
			chamsColor = "White",
			chamsTrans = 0.5,
			boxes = false,
			boxColor = "White",
			boxThick = 1,
			health = false,
			healthBar = false,
			healthText = false,
			tracers = false,
			tracerColor = "White",
			tracerThick = 1,
			tracerOrigin = "Bottom",
			distance = false,
			fontSize = 13
		},
		aim = {
			enabled = false,
			hitbox = "Head",
			fov = 90,
			ignore = {},
			smooth = 0.5,
			visible = false,
			autoShoot = false,
			shootDelay = 100,
			teamCheck = false,
			silent = false,
			sound = false
		},
		move = {
			bhop = false,
			walkSpeed = 16,
			jumpPower = 50,
			airControl = false,
			antiAim = "Off",
			spinSpeed = 5
		},
		radar = {
			enabled = false,
			size = 150,
			zoom = 50
		},
		keys = {
			aim = Enum.KeyCode.F2,
			esp = Enum.KeyCode.F3,
			radar = Enum.KeyCode.F4,
			bhop = Enum.KeyCode.F5
		},
		profiles = { {}, {}, {} },
		ignoreList = {},
		menu = { trans = 0.6 }
	}
end
local C = _G["ov"]

-- ===== INSTANCE / TWEEN HELPERS =====
local function _mk(cls, props)
	local obj = _Inst.new(cls)
	for k, v in _pairs(props) do
		obj[k] = v
	end
	return obj
end

local function _tw(obj, props, dur, ...)
	local tween = _TweenS:Create(obj, _TInfo(dur or 0.3, ...), props)
	tween:Play()
	return tween
end

-- ===== TABLE STRINGIFY (for export) =====
local function _tblStr(t, indent)
	indent = indent or 0
	local pad = string.rep("  ", indent)
	local parts = {"{\n"}
	local first = true
	for k, v in _pairs(t) do
		if not first then
			table.insert(parts, ",\n")
		end
		first = false
		local kStr
		if _type(k) == "string" then
			kStr = "[\"" .. k .. "\"]"
		elseif _type(k) == "number" then
			kStr = "[" .. k .. "]"
		else
			kStr = "[" .. tostring(k) .. "]"
		end
		table.insert(parts, pad .. "  " .. kStr .. " = ")
		if _type(v) == "table" then
			table.insert(parts, _tblStr(v, indent + 1))
		elseif _type(v) == "string" then
			table.insert(parts, "\"" .. v .. "\"")
		elseif _type(v) == "boolean" then
			table.insert(parts, tostring(v))
		elseif _type(v) == "number" then
			table.insert(parts, tostring(v))
		else
			table.insert(parts, "\"" .. tostring(v) .. "\"")
		end
	end
	if not first then
		table.insert(parts, "\n")
	end
	table.insert(parts, pad .. "}")
	return _tbl.concat(parts, "")
end

-- ===== UI LIBRARY =====
local UI = {}

function UI:NewWindow()
	local gui = _mk("ScreenGui", {
		Name = "AXMEGui",
		ResetOnSpawn = false,
		Parent = _LP:WaitForChild("PlayerGui"),
		DisplayOrder = 999
	})
	local main = _mk("Frame", {
		Name = "Main",
		Parent = gui,
		Size = _UD2(0, 700, 0, 500),
		Position = _UD2(0.5, -350, 0.5, -250),
		BackgroundColor3 = _C3.fromRGB(25, 25, 25),
		BackgroundTransparency = C.menu.trans,
		BorderSizePixel = 0,
		Active = true,
		Draggable = true
	})
	-- Shadow
	_mk("Frame", {
		Name = "Shadow",
		Parent = main,
		Size = _UD2(1, 6, 1, 6),
		Position = _UD2(0, -3, 0, -3),
		BackgroundColor3 = _C3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = -1
	})
	-- Title bar
	local title = _mk("TextLabel", {
		Parent = main,
		Size = _UD2(1, 0, 0, 28),
		BackgroundColor3 = _C3.fromRGB(40, 40, 40),
		BackgroundTransparency = C.menu.trans,
		BorderSizePixel = 0,
		Text = "AXME v1.0  |  Stress-Test",
		TextColor3 = _C3.fromRGB(200, 200, 200),
		TextSize = 13,
		Font = Enum.Font.SourceSansBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextStrokeColor3 = _C3.fromRGB(0, 0, 0),
		TextStrokeTransparency = 0.75
	})
	_mk("UIListLayout", { Parent = title, Padding = _UD2(0, 8) })
	local closeBtn = _mk("TextButton", {
		Parent = title,
		Size = _UD2(0, 28, 0, 28),
		Position = _UD2(1, -28, 0, 0),
		BackgroundColor3 = _C3.fromRGB(55, 55, 55),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Text = "X",
		TextColor3 = _C3.fromRGB(255, 80, 80),
		TextSize = 14,
		Font = Enum.Font.SourceSansBold,
		AutoButtonColor = false
	})
	closeBtn.MouseButton1Click:Connect(function() guiRoot:Close() end)

	-- Tab bar
	local tabBar = _mk("Frame", {
		Parent = main,
		Size = _UD2(1, 0, 0, 30),
		Position = _UD2(0, 0, 0, 28),
		BackgroundColor3 = _C3.fromRGB(35, 35, 35),
		BackgroundTransparency = C.menu.trans,
		BorderSizePixel = 0
	})
	-- Content area
	local content = _mk("Frame", {
		Parent = main,
		Size = _UD2(1, 0, 1, -58),
		Position = _UD2(0, 0, 0, 58),
		BackgroundColor3 = _C3.fromRGB(18, 18, 18),
		BackgroundTransparency = C.menu.trans,
		BorderSizePixel = 0
	})
	self._gui = gui
	self._main = main
	self._tabBar = tabBar
	self._content = content
	self._tabButtons = {}
	self._tabContents = {}
	self._currentTab = 1
	self._allTabs = {}
	return main
end

function UI:AddTab(name)
	local idx = #self._allTabs + 1
	local tabBtn = _mk("TextButton", {
		Parent = self._tabBar,
		Size = _UD2(0, 700 / 5, 0, 30),
		Position = _UD2(0, (700 / 5) * (idx - 1), 0, 0),
		BackgroundColor3 = _C3.fromRGB(40, 40, 40),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = _C3.fromRGB(180, 180, 180),
		TextSize = 13,
		Font = Enum.Font.SourceSansSemibold,
		AutoButtonColor = false
	})
	local tabContent = _mk("ScrollingFrame", {
		Parent = self._content,
		Size = _UD2(1, -10, 1, -10),
		Position = _UD2(0, 5, 0, 5),
		BackgroundColor3 = _C3.fromRGB(18, 18, 18),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = _C3.fromRGB(60, 60, 60),
		Visible = idx == 1,
		CanvasSize = _UD2(0, 0)
	})
	local listLayout = _mk("UIListLayout", {
		Parent = tabContent,
		Padding = _UD2(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	_mk("UIPadding", {
		Parent = tabContent,
		PaddingLeft = _UD2(0, 6),
		PaddingRight = _UD2(0, 6),
		PaddingTop = _UD2(0, 6),
		PaddingBottom = _UD2(0, 6)
	})
	tabBtn.MouseButton1Click:Connect(function()
		UI:SwitchTab(idx)
	end)
	self._tabButtons[idx] = tabBtn
	self._tabContents[idx] = tabContent
	self._allTabs[idx] = { button = tabBtn, content = tabContent, name = name, layout = listLayout }
	-- Update canvas size when children change
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabContent.CanvasSize = _UD2(0, listLayout.AbsoluteContentSize.Y + 12)
	end)
	-- Trigger initial canvas
	task.spawn(function() tabContent.CanvasSize = _UD2(0, listLayout.AbsoluteContentSize.Y + 12) end)

	-- Style active tab
	self:SwitchTab(self._currentTab)
	return tabContent
end

function UI:SwitchTab(idx)
	for i, tab in _ipairs(self._allTabs) do
		tab.content.Visible = (i == idx)
		tab.button.BackgroundColor3 = (i == idx) and _C3.fromRGB(55, 55, 55) or _C3.fromRGB(40, 40, 40)
		tab.button.TextColor3 = (i == idx) and _C3.fromRGB(255, 255, 255) or _C3.fromRGB(180, 180, 180)
	end
	self._currentTab = idx
end

function UI:Open()
	self._main.Visible = true
end

function UI:Close()
	self._main.Visible = false
end

function UI:Toggle()
	self._main.Visible = not self._main.Visible
end

-- Helper: section header
local function _addSection(parent, text)
	local lbl = _mk("TextLabel", {
		Parent = parent,
		Size = _UD2(1, -12, 0, 22),
		BackgroundColor3 = _C3.fromRGB(40, 50, 60),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Text = "  " .. text,
		TextColor3 = _C3.fromRGB(80, 180, 255),
		TextSize = 12,
		Font = Enum.Font.SourceSansBold,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return lbl
end

-- Helper: category sub-header
local function _addCategory(parent, text)
	local lbl = _mk("TextLabel", {
		Parent = parent,
		Size = _UD2(1, -12, 0, 18),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "  " .. text,
		TextColor3 = _C3.fromRGB(140, 140, 140),
		TextSize = 11,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return lbl
end

-- AddToggle(parent, name, getter, setter)
function UI:AddToggle(parent, name, getter, setter)
	local frame = _mk("Frame", {
		Parent = parent,
		Size = _UD2(1, -12, 0, 26),
		BackgroundColor3 = _C3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0
	})
	local lbl = _mk("TextLabel", {
		Parent = frame,
		Size = _UD2(0.8, -6, 1, 0),
		Position = _UD2(0, 6, 0, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = _C3.fromRGB(200, 200, 200),
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local btn = _mk("TextButton", {
		Parent = frame,
		Size = _UD2(0, 20, 0, 20),
		Position = _UD2(1, -26, 0.5, -10),
		BackgroundColor3 = getter() and _C3.fromRGB(60, 200, 60) or _C3.fromRGB(60, 60, 60),
		BorderSizePixel = 0,
		Text = getter() and "✓" or "",
		TextColor3 = _C3.fromRGB(255, 255, 255),
		TextSize = 12,
		Font = Enum.Font.SourceSansBold,
		AutoButtonColor = false
	})
	btn.MouseButton1Click:Connect(function()
		local new = not getter()
		setter(new)
		btn.BackgroundColor3 = new and _C3.fromRGB(60, 200, 60) or _C3.fromRGB(60, 60, 60)
		btn.Text = new and "✓" or ""
	end)
	return frame
end

-- AddSlider(parent, name, min, max, default, suffix, callback)
function UI:AddSlider(parent, name, min, max, default, suffix, callback)
	local frame = _mk("Frame", {
		Parent = parent,
		Size = _UD2(1, -12, 0, 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	local lbl = _mk("TextLabel", {
		Parent = frame,
		Size = _UD2(0.5, -6, 0, 14),
		Position = _UD2(0, 6, 0, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = _C3.fromRGB(200, 200, 200),
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local valLabel = _mk("TextLabel", {
		Parent = frame,
		Size = _UD2(0, 40, 0, 14),
		Position = _UD2(1, -46, 0, 0),
		BackgroundTransparency = 1,
		Text = tostring(default) .. (suffix or ""),
		TextColor3 = _C3.fromRGB(80, 180, 255),
		TextSize = 11,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Right
	})
	local barBg = _mk("Frame", {
		Parent = frame,
		Size = _UD2(0.5, -6, 0, 4),
		Position = _UD2(0, 6, 1, -8),
		BackgroundColor3 = _C3.fromRGB(50, 50, 50),
		BorderSizePixel = 0
	})
	local barFill = _mk("Frame", {
		Parent = barBg,
		Size = _UD2((default - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = _C3.fromRGB(80, 180, 255),
		BorderSizePixel = 0
	})
	local thumb = _mk("TextButton", {
		Parent = barBg,
		Size = _UD2(0, 8, 0, 8),
		Position = _UD2((default - min) / (max - min), -4, 0.5, -4),
		BackgroundColor3 = _C3.fromRGB(200, 200, 200),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false
	})
	local function updateSlider(val)
		val = _clamp(val, min, max)
		local frac = (val - min) / (max - min)
		barFill.Size = _UD2(frac, 0, 1, 0)
		thumb.Position = _UD2(frac, -4, 0.5, -4)
		if _type(default) == "number" and _floor(default) == default then
			valLabel.Text = tostring(_floor(val)) .. (suffix or "")
		else
			valLabel.Text = string.format("%.1f", val) .. (suffix or "")
		end
		callback(val)
	end
	local dragging = false
	thumb.MouseButton1Down:Connect(function()
		dragging = true
	end)
	_UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	_UIS.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			local pos = _UIS:GetMouseLocation()
			local absPos = barBg.AbsolutePosition
			local absSize = barBg.AbsoluteSize.X
			local frac = (pos.X - absPos.X) / absSize
			frac = _clamp(frac, 0, 1)
			local val = min + frac * (max - min)
			updateSlider(val)
		end
	end)
	-- Click on bar to jump
	barBg.MouseButton1Click:Connect(function()
		local pos = _UIS:GetMouseLocation()
		local absPos = barBg.AbsolutePosition
		local absSize = barBg.AbsoluteSize.X
		local frac = (pos.X - absPos.X) / absSize
		frac = _clamp(frac, 0, 1)
		local val = min + frac * (max - min)
		updateSlider(val)
	end)
	return frame
end

-- AddDropdown(parent, name, options, default, callback)
-- Uses overlay frame (not resizing parent) to avoid layout shifting
function UI:AddDropdown(parent, name, options, default, callback)
	local frame = _mk("Frame", {
		Parent = parent,
		Size = _UD2(1, -12, 0, 26),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	_Inst.new("UICorner", { CornerRadius = _UD2(0, 3), Parent = frame })
	local lbl = _mk("TextLabel", {
		Parent = frame,
		Size = _UD2(0.4, -6, 1, 0),
		Position = _UD2(0, 6, 0, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = _C3.fromRGB(200, 200, 200),
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local btn = _mk("TextButton", {
		Parent = frame,
		Size = _UD2(0.6, -6, 0, 22),
		Position = _UD2(0.4, 6, 0.5, -11),
		BackgroundColor3 = _C3.fromRGB(35, 35, 35),
		BorderSizePixel = 0,
		Text = tostring(default),
		TextColor3 = _C3.fromRGB(80, 180, 255),
		TextSize = 12,
		Font = Enum.Font.SourceSansSemibold,
		AutoButtonColor = false
	})
	-- Overlay dropdown: parent is the ScreenGui so it overlays everything
	local dropFrameParent = nil
	local function getDropParent()
		if not dropFrameParent then
			dropFrameParent = _mk("Frame", {
				Parent = _LP:WaitForChild("PlayerGui"),
				Size = _UD2(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 9999
			})
			-- Close on click outside
			local closeBtn = _mk("TextButton", {
				Parent = dropFrameParent,
				Size = _UD2(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 9998
			})
			closeBtn.MouseButton1Click:Connect(function()
				if open then
					open = false
					dropFrameParent.Visible = false
				end
			end)
		end
		return dropFrameParent
	end

	local dropFrame = _mk("ScrollingFrame", {
		Size = _UD2(0, 0, 0, 0),
		BackgroundColor3 = _C3.fromRGB(25, 25, 30),
		BorderSizePixel = 0,
		Visible = false,
		ScrollBarThickness = 3,
		CanvasSize = _UD2(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 10000
	})
	_Inst.new("UIListLayout", { Parent = dropFrame, Padding = _UD2(0, 1) })
	_Inst.new("UICorner", { CornerRadius = _UD2(0, 3), Parent = dropFrame })

	local open = false
	local function positionDrop()
		local absPos = btn.AbsolutePosition
		local absSize = btn.AbsoluteSize
		local w = absSize.X
		local h = _clamp(#options * 22, 22, 180)
		dropFrame.Size = _UD2(0, w, 0, h)
		dropFrame.Position = _UD2(0, absPos.X, 0, absPos.Y + absSize.Y)
	end

	btn.MouseButton1Click:Connect(function()
		open = not open
		if open then
			local p = getDropParent()
			dropFrame.Parent = p
			p.Visible = true
			positionDrop()
		end
		dropFrame.Visible = open
	end)

	for _, opt in _ipairs(options) do
		local optBtn = _mk("TextButton", {
			Size = _UD2(1, 0, 0, 20),
			BackgroundColor3 = _C3.fromRGB(40, 40, 40),
			BorderSizePixel = 0,
			Text = tostring(opt),
			TextColor3 = _C3.fromRGB(180, 180, 180),
			TextSize = 11,
			Font = Enum.Font.SourceSans,
			AutoButtonColor = false,
			Parent = dropFrame,
			ZIndex = 10001
		})
		optBtn.MouseButton1Click:Connect(function()
			btn.Text = tostring(opt)
			callback(opt)
			open = false
			dropFrame.Visible = false
			local p = getDropParent()
			p.Visible = false
		end)
	end
	return frame
end

-- AddButton(parent, name, callback)
function UI:AddButton(parent, name, callback)
	local frame = _mk("Frame", {
		Parent = parent,
		Size = _UD2(1, -12, 0, 28),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	local btn = _mk("TextButton", {
		Parent = frame,
		Size = _UD2(1, -12, 1, -4),
		Position = _UD2(0, 6, 0, 2),
		BackgroundColor3 = _C3.fromRGB(35, 45, 55),
		BorderSizePixel = 0,
		Text = name,
		TextColor3 = _C3.fromRGB(80, 180, 255),
		TextSize = 12,
		Font = Enum.Font.SourceSansSemibold,
		AutoButtonColor = false
	})
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- AddLabel(parent, name)  -- returns a TextLabel for later updating
function UI:AddLabel(parent, name)
	local lbl = _mk("TextLabel", {
		Parent = parent,
		Size = _UD2(1, -12, 0, 18),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = _C3.fromRGB(160, 160, 160),
		TextSize = 11,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return lbl
end

-- AddTextBox(parent, name, default, callback)
function UI:AddTextBox(parent, name, default, callback)
	local frame = _mk("Frame", {
		Parent = parent,
		Size = _UD2(1, -12, 0, 28),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	local lbl = _mk("TextLabel", {
		Parent = frame,
		Size = _UD2(0.35, -6, 1, 0),
		Position = _UD2(0, 6, 0, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = _C3.fromRGB(200, 200, 200),
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local box = _mk("TextBox", {
		Parent = frame,
		Size = _UD2(0.65, -12, 0, 22),
		Position = _UD2(0.35, 6, 0.5, -11),
		BackgroundColor3 = _C3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		Text = tostring(default or ""),
		TextColor3 = _C3.fromRGB(200, 200, 200),
		TextSize = 11,
		Font = Enum.Font.SourceSans,
		PlaceholderText = name,
		PlaceholderColor3 = _C3.fromRGB(100, 100, 100),
		ClearTextOnFocus = false
	})
	box.FocusLost:Connect(function()
		callback(box.Text)
	end)
	return box
end

-- ===== BUILD UI =====
local guiRoot = UI:NewWindow()

-- Interactive keybinder
local _waitingForKey = false
local _waitingForField = nil

function UI:AddKeybinder(parent, name, keyRef)
	local row = _mk("Frame", {
		Parent = parent,
		Size = _UD2(1, -12, 0, 26),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	local lbl = _mk("TextLabel", {
		Parent = row,
		Size = _UD2(0.5, -6, 1, 0),
		Position = _UD2(0, 6, 0, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = _C3.fromRGB(200, 200, 200),
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local btn = _mk("TextButton", {
		Parent = row,
		Size = _UD2(0, 100, 0, 22),
		Position = _UD2(1, -106, 0.5, -11),
		BackgroundColor3 = _C3.fromRGB(35, 35, 35),
		BorderSizePixel = 0,
		Text = tostring(C.keys[keyRef]):gsub("Enum.KeyCode.", ""),
		TextColor3 = _C3.fromRGB(80, 180, 255),
		TextSize = 11,
		Font = Enum.Font.SourceSansSemibold,
		AutoButtonColor = false
	})
	local listeningConn
	btn.MouseButton1Click:Connect(function()
		if _waitingForKey then
			if _waitingForField then
				_waitingForField.Text = tostring(C.keys[_waitingForField._keyRef]):gsub("Enum.KeyCode.", "")
			end
		end
		btn.Text = "... press a key"
		_waitingForKey = true
		_waitingForField = btn
		btn._keyRef = keyRef
		if listeningConn then listeningConn:Disconnect() end
		listeningConn = _UIS.InputBegan:Connect(function(input, gp)
			if not _waitingForKey or _waitingForField ~= btn then
				if listeningConn then listeningConn:Disconnect() end
				return
			end
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				_waitingForKey = false
				C.keys[keyRef] = input.KeyCode
				btn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
				if listeningConn then listeningConn:Disconnect() end
			end
		end)
	end)
	return row
end

-- ===== TAB 1: ESP =====
do
	local tab = UI:AddTab("ESP")
	_addSection(tab, "Visuals")
	UI:AddToggle(tab, "Enabled", function() return C.esp.enabled end, function(v) C.esp.enabled = v end)
	_addCategory(tab, "Chams")
	UI:AddToggle(tab, "Chams", function() return C.esp.chams end, function(v) C.esp.chams = v end)
	UI:AddDropdown(tab, "Chams Color", {"Red","Blue","Green","Yellow","Purple","Cyan","White","Black"}, C.esp.chamsColor, function(v) C.esp.chamsColor = v end)
	UI:AddSlider(tab, "Chams Transp.", 0, 1, C.esp.chamsTrans, "", function(v) C.esp.chamsTrans = v end)
	_addCategory(tab, "Boxes")
	UI:AddToggle(tab, "Boxes", function() return C.esp.boxes end, function(v) C.esp.boxes = v end)
	UI:AddDropdown(tab, "Box Color", {"Red","Blue","Green","Yellow","Purple","Cyan","White","Black"}, C.esp.boxColor, function(v) C.esp.boxColor = v end)
	UI:AddSlider(tab, "Box Thickness", 1, 5, C.esp.boxThick, "", function(v) C.esp.boxThick = _floor(v) end)
	_addCategory(tab, "Health")
	UI:AddToggle(tab, "Health Bar", function() return C.esp.healthBar end, function(v) C.esp.healthBar = v end)
	UI:AddToggle(tab, "Health Text", function() return C.esp.healthText end, function(v) C.esp.healthText = v end)
	_addCategory(tab, "Tracers")
	UI:AddToggle(tab, "Tracers", function() return C.esp.tracers end, function(v) C.esp.tracers = v end)
	UI:AddDropdown(tab, "Tracer Color", {"Red","Blue","Green","Yellow","Purple","Cyan","White","Black"}, C.esp.tracerColor, function(v) C.esp.tracerColor = v end)
	UI:AddSlider(tab, "Tracer Thickness", 1, 5, C.esp.tracerThick, "", function(v) C.esp.tracerThick = _floor(v) end)
	UI:AddDropdown(tab, "Tracer Origin", {"Bottom","Middle","Top"}, C.esp.tracerOrigin, function(v) C.esp.tracerOrigin = v end)
	_addCategory(tab, "Info")
	UI:AddToggle(tab, "Distance", function() return C.esp.distance end, function(v) C.esp.distance = v end)
	UI:AddSlider(tab, "Font Size", 10, 20, C.esp.fontSize, "", function(v) C.esp.fontSize = _floor(v) end)
end

-- ===== TAB 2: AIMBOT =====
do
	local tab = UI:AddTab("Aimbot")
	_addSection(tab, "Aimbot Settings")
	UI:AddToggle(tab, "Enabled", function() return C.aim.enabled end, function(v) C.aim.enabled = v end)
	UI:AddDropdown(tab, "Hitbox", {"Head","UpperTorso","LowerTorso","HumanoidRootPart","LeftFoot","RightFoot"}, C.aim.hitbox, function(v) C.aim.hitbox = v end)
	UI:AddSlider(tab, "FOV", 0, 360, C.aim.fov, "°", function(v) C.aim.fov = v end)
	UI:AddSlider(tab, "Smooth", 0, 1, C.aim.smooth, "", function(v) C.aim.smooth = v end)
	UI:AddToggle(tab, "Visible Check", function() return C.aim.visible end, function(v) C.aim.visible = v end)
	UI:AddToggle(tab, "Team Check", function() return C.aim.teamCheck end, function(v) C.aim.teamCheck = v end)
	UI:AddToggle(tab, "Silent Aim", function() return C.aim.silent end, function(v) C.aim.silent = v; print("Silent Aim toggled (simulation)") end)
	UI:AddToggle(tab, "Auto Shoot", function() return C.aim.autoShoot end, function(v) C.aim.autoShoot = v end)
	UI:AddSlider(tab, "Shoot Delay", 0, 1000, C.aim.shootDelay, "ms", function(v) C.aim.shootDelay = _floor(v) end)
	UI:AddToggle(tab, "Sound", function() return C.aim.sound end, function(v) C.aim.sound = v end)
	_addSection(tab, "Ignore List")
	UI:AddTextBox(tab, "Ignore Names", _tbl.concat(C.aim.ignore, ","), function(text)
		local names = {}
		for n in text:gmatch("[^,%s]+") do
			_tbl.insert(names, n)
		end
		C.aim.ignore = names
	end)
	_addSection(tab, "Keybinds")
	UI:AddKeybinder(tab, "Aimbot", "aim")
	UI:AddKeybinder(tab, "ESP", "esp")
	UI:AddKeybinder(tab, "Radar", "radar")
	UI:AddKeybinder(tab, "BHop", "bhop")
end

-- ===== TAB 3: MOVEMENT =====
do
	local tab = UI:AddTab("Movement")
	_addSection(tab, "Movement")
	UI:AddToggle(tab, "Bunny Hop", function() return C.move.bhop end, function(v) C.move.bhop = v end)
	UI:AddSlider(tab, "WalkSpeed", 16, 200, C.move.walkSpeed, "", function(v) C.move.walkSpeed = _floor(v) end)
	UI:AddSlider(tab, "JumpPower", 50, 200, C.move.jumpPower, "", function(v) C.move.jumpPower = _floor(v) end)
	UI:AddToggle(tab, "Air Control", function() return C.move.airControl end, function(v) C.move.airControl = v end)
	_addSection(tab, "Anti-Aim")
	UI:AddDropdown(tab, "Anti-Aim", {"Off","Jitter","Spin","Fake"}, C.move.antiAim, function(v) C.move.antiAim = v end)
	UI:AddSlider(tab, "Spin Speed", 1, 10, C.move.spinSpeed, "", function(v) C.move.spinSpeed = v end)
end

-- ===== TAB 4: RADAR =====
do
	local tab = UI:AddTab("Radar")
	_addSection(tab, "Radar Settings")
	UI:AddToggle(tab, "Enabled", function() return C.radar.enabled end, function(v) C.radar.enabled = v end)
	UI:AddSlider(tab, "Size", 50, 300, C.radar.size, "", function(v) C.radar.size = _floor(v) end)
	UI:AddSlider(tab, "Zoom", 10, 200, C.radar.zoom, "", function(v) C.radar.zoom = v end)
end

-- ===== TAB 5: CONFIG =====
do
	local tab = UI:AddTab("Config")
	_addSection(tab, "Menu Settings")
	UI:AddSlider(tab, "Menu Transp.", 0, 1, C.menu.trans, "", function(v)
		C.menu.trans = v
		-- Update all UI frames with transparency
		local function updateTrans(obj, trans)
			if obj:IsA("Frame") or obj:IsA("TextButton") then
				if obj:FindFirstChild("_origTrans") then
					-- Only update if it's a background frame we set
					pcall(function()
						if obj.BackgroundTransparency > 0.5 then
							obj.BackgroundTransparency = trans
						end
					end)
				end
			end
		end
	end)
	_addSection(tab, "Profiles")
	for i = 1, 3 do
		_addCategory(tab, "Profile " .. i)
		local row = _mk("Frame", {
			Parent = tab,
			Size = _UD2(1, -12, 0, 28),
			BackgroundTransparency = 1,
			BorderSizePixel = 0
		})
		_mk("UIListLayout", { Parent = row, FillDirection = Enum.FillDirection.Horizontal, Padding = _UD2(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center })
		local saveBtn = _mk("TextButton", {
			Parent = row,
			Size = _UD2(0, 100, 0, 24),
			BackgroundColor3 = _C3.fromRGB(35, 45, 55),
			BorderSizePixel = 0,
			Text = "Save P" .. i,
			TextColor3 = _C3.fromRGB(80, 200, 80),
			TextSize = 11,
			Font = Enum.Font.SourceSansSemibold,
			AutoButtonColor = false
		})
		saveBtn.MouseButton1Click:Connect(function()
			-- Deep-copy the full config, converting enums to their numeric values
			local raw = _HttpS:JSONDecode(_HttpS:JSONEncode(C))
			raw._meta = "saved"
			raw._keys = {}
			for k, v in _pairs(C.keys) do
				raw._keys[k] = v.Value
			end
			C.profiles[i] = raw
			print("Saved profile " .. i)
		end)
		local loadBtn = _mk("TextButton", {
			Parent = row,
			Size = _UD2(0, 100, 0, 24),
			BackgroundColor3 = _C3.fromRGB(35, 45, 55),
			BorderSizePixel = 0,
			Text = "Load P" .. i,
			TextColor3 = _C3.fromRGB(255, 180, 80),
			TextSize = 11,
			Font = Enum.Font.SourceSansSemibold,
			AutoButtonColor = false
		})
		loadBtn.MouseButton1Click:Connect(function()
			if C.profiles[i] and C.profiles[i]._meta == "saved" then
				local loaded = _HttpS:JSONDecode(_HttpS:JSONEncode(C.profiles[i]))
				C.esp = loaded.esp
				C.aim = loaded.aim
				C.move = loaded.move
				C.radar = loaded.radar
				C.menu = loaded.menu
				C.ignoreList = loaded.ignoreList
				if loaded._keys then
					for k, v in _pairs(loaded._keys) do
						local found = false
						for _, enumItem in _pairs(Enum.KeyCode:GetEnumItems()) do
							if enumItem.Value == v then
								C.keys[k] = enumItem
								found = true
								break
							end
						end
					end
				end
				print("Loaded profile " .. i .. ". Restart script to refresh UI.")
			else
				print("Profile " .. i .. " is empty")
			end
		end)
	end
	_addSection(tab, "UI")
	UI:AddButton(tab, "Refresh UI (reload)", function()
		print("Reloading script...")
		_pcall(function()
			for _, v in _ipairs(_LP:WaitForChild("PlayerGui"):GetChildren()) do
				if v.Name == "AXMEGui" or v.Name == "AXMERadar" or v.Name == "AXMEStatus" or v.Name == "_tracerParent" then
					v:Destroy()
				end
			end
		end)
		_pcall(function()
			for _, v in _ipairs(_LP.PlayerScripts:GetChildren()) do
				if v.Name == "AXME_Loader" then v:Destroy() end
			end
		end)
		loadstring(game:HttpGet("https://pastebin.com/raw/..."))()
	end)
	_addSection(tab, "Import / Export")
	UI:AddButton(tab, "Export Config", function()
		local export = _HttpS:JSONEncode({
			esp = C.esp,
			aim = C.aim,
			move = C.move,
			radar = C.radar,
			menu = C.menu,
			ignoreList = C.ignoreList,
			keys = { aim = C.keys.aim.Value, esp = C.keys.esp.Value, radar = C.keys.radar.Value, bhop = C.keys.bhop.Value }
		})
		print("-- AXME CONFIG EXPORT --")
		print(export)
		print("-- END EXPORT --")
	end)
	UI:AddTextBox(tab, "Import Config", "", function(text)
		local ok, data = _pcall(function() return _HttpS:JSONDecode(text) end)
		if ok and _type(data) == "table" then
			if data.esp then C.esp = data.esp end
			if data.aim then C.aim = data.aim end
			if data.move then C.move = data.move end
			if data.radar then C.radar = data.radar end
			if data.menu then C.menu = data.menu end
			if data.ignoreList then C.ignoreList = data.ignoreList end
			if data.keys then
				for k, v in _pairs(data.keys) do
					local keyEnum = Enum.KeyCode:GetEnumItems()[v]
					if keyEnum then C.keys[k] = keyEnum end
				end
			end
			print("Config imported successfully")
		else
			warn("Failed to import config: invalid JSON")
		end
	end)
end

-- ===== TRACER FRAME PARENT =====
local _tracerParent = _mk("Frame", {
	Name = "_tracerParent",
	Parent = _LP:WaitForChild("PlayerGui"),
	Size = _UD2(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = 1000
})

-- ===== ESP MODULE =====
local _espObjs = {}
local _espConn = nil

local function _clearEsp()
	for _, obj in _ipairs(_espObjs) do
		_pcall(function() obj:Destroy() end)
	end
	_espObjs = {}
end

local function _addEspObj(obj)
	_tbl.insert(_espObjs, obj)
end

local function _isValidTarget(ch)
	return ch and ch:FindFirstChild("Humanoid") and ch:FindFirstChild("HumanoidRootPart")
end

local function _drawEsp()
	if not C.esp.enabled then return end
	local myChar = _LP.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
	local myPos = myChar.HumanoidRootPart.Position
	local screenSize = _Cam.ViewportSize

	for _, plr in _ipairs(_Plrs:GetPlayers()) do
		if plr == _LP then continue end
		local ch = plr.Character
		if not _isValidTarget(ch) then continue end
		local hum = ch:FindFirstChild("Humanoid")
		local root = ch:FindFirstChild("HumanoidRootPart")
		if not hum or not root then continue end

		-- Check if in ignore list
		local ignored = false
		for _, name in _ipairs(C.ignoreList) do
			if plr.Name:lower():find(name:lower()) then ignored = true; break end
		end
		if ignored then continue end

		local dist = (root.Position - myPos).Magnitude

		-- Get screen position
		local headPos = ch:FindFirstChild("Head") and ch.Head.Position or root.Position + _V3(0, 2, 0)
		local footPos = root.Position - _V3(0, 3, 0)
		local headScreen, onScreen = _Cam:WorldToViewportPoint(headPos)
		local footScreen, _ = _Cam:WorldToViewportPoint(footPos)

		if not onScreen then continue end

		local boxHeight = (headScreen - footScreen).Y
		local boxWidth = boxHeight * 0.6
		local centerX = headScreen.X
		local topY = headScreen.Y

		-- BillboardGui parent
		local bill = _mk("BillboardGui", {
			Adornee = root,
			Size = _UD2(0, boxWidth + 10, 0, boxHeight + 10),
			StudsOffset = _V3(0, 0, 0),
			AlwaysOnTop = true,
			MaxDistance = 2000,
			Enabled = true,
			ResetOnSpawn = false,
			ClipsDescendants = false
		})
		_addEspObj(bill)

		-- === CHAMS (Highlight) ===
		if C.esp.chams then
			local hl = _mk("Highlight", {
				Adornee = ch,
				FillColor = _getColor(C.esp.chamsColor),
				FillTransparency = C.esp.chamsTrans,
				OutlineTransparency = 0.5
			})
			_addEspObj(hl)
		end

		-- === BOXES ===
		if C.esp.boxes then
			local boxColor = _getColor(C.esp.boxColor)
			local thick = C.esp.boxThick
			-- Top border
			local top = _mk("Frame", {
				Parent = bill,
				Size = _UD2(1, 0, 0, thick),
				Position = _UD2(0, -5, 0, -5),
				BackgroundColor3 = boxColor,
				BorderSizePixel = 0
			})
			_addEspObj(top)
			-- Bottom border
			local btm = _mk("Frame", {
				Parent = bill,
				Size = _UD2(1, 0, 0, thick),
				Position = _UD2(0, -5, 1, -5 + thick),
				BackgroundColor3 = boxColor,
				BorderSizePixel = 0
			})
			_addEspObj(btm)
			-- Left border
			local left = _mk("Frame", {
				Parent = bill,
				Size = _UD2(0, thick, 1, 0),
				Position = _UD2(0, -5, 0, -5),
				BackgroundColor3 = boxColor,
				BorderSizePixel = 0
			})
			_addEspObj(left)
			-- Right border
			local right = _mk("Frame", {
				Parent = bill,
				Size = _UD2(0, thick, 1, 0),
				Position = _UD2(1, -5 + thick, 0, -5),
				BackgroundColor3 = boxColor,
				BorderSizePixel = 0
			})
			_addEspObj(right)
		end

		-- === HEALTH BAR ===
		if C.esp.healthBar then
			local hp = hum.Health / hum.MaxHealth
			local barBg = _mk("Frame", {
				Parent = bill,
				Size = _UD2(0, 4, 1, 0),
				Position = _UD2(0, -10, 0, -5),
				BackgroundColor3 = _C3.fromRGB(40, 40, 40),
				BorderSizePixel = 0
			})
			_addEspObj(barBg)
			local barFill = _mk("Frame", {
				Parent = barBg,
				Size = _UD2(1, 0, hp, 0),
				Position = _UD2(0, 0, 1 - hp, 0),
				BackgroundColor3 = _C3.fromRGB(255 * (1 - hp), 255 * hp, 0),
				BorderSizePixel = 0
			})
			_addEspObj(barFill)
		end

		-- === HEALTH TEXT ===
		if C.esp.healthText then
			local hp = hum.Health
			local hpLbl = _mk("TextLabel", {
				Parent = bill,
				Size = _UD2(1, 0, 0, 16),
				Position = _UD2(0, -5, 1, -5 + (C.esp.healthBar and 6 or 0)),
				BackgroundTransparency = 1,
				Text = _floor(hp),
				TextColor3 = _C3.fromRGB(255, 255, 255),
				TextSize = C.esp.fontSize,
				Font = Enum.Font.SourceSansBold,
				TextStrokeColor3 = _C3.fromRGB(0, 0, 0),
				TextStrokeTransparency = 0.5
			})
			_addEspObj(hpLbl)
		end

		-- === DISTANCE ===
		if C.esp.distance then
			local distLbl = _mk("TextLabel", {
				Parent = bill,
				Size = _UD2(1, 0, 0, 16),
				Position = _UD2(0, -5, 1, (C.esp.healthText or C.esp.healthBar) and -21 or -5),
				BackgroundTransparency = 1,
				Text = _floor(dist) .. " studs",
				TextColor3 = _C3.fromRGB(200, 200, 200),
				TextSize = C.esp.fontSize,
				Font = Enum.Font.SourceSans,
				TextStrokeColor3 = _C3.fromRGB(0, 0, 0),
				TextStrokeTransparency = 0.5
			})
			_addEspObj(distLbl)
		end

		-- === TRACERS ===
		if C.esp.tracers then
			local tracerColor = _getColor(C.esp.tracerColor)
			local thick = C.esp.tracerThick
			local origin
			if C.esp.tracerOrigin == "Bottom" then
				origin = _V2(screenSize.X / 2, screenSize.Y)
			elseif C.esp.tracerOrigin == "Middle" then
				origin = _V2(screenSize.X / 2, screenSize.Y / 2)
			else -- Top
				origin = _V2(screenSize.X / 2, 0)
			end
			local targetScreen, vis = _Cam:WorldToViewportPoint(root.Position)
			if vis then
				-- Use a screen-space frame line
				local dx = targetScreen.X - origin.X
				local dy = targetScreen.Y - origin.Y
				local len = _V2(dx, dy).Magnitude
				if len > 0 then
					local angle = math.atan2(dy, dx)
					local line = _mk("Frame", {
						Parent = _tracerParent,
						Size = _UD2(0, len, 0, thick),
						Position = _UD2(0, origin.X, 0, origin.Y),
						Rotation = math.deg(angle),
						BackgroundColor3 = tracerColor,
						BorderSizePixel = 0,
						AnchorPoint = _V2(0, 0.5)
					})
					_addEspObj(line)
				end
			end
		end
	end
end

-- ===== AIMBOT MODULE =====
local AimBot = {
	target = nil,
	lastTarget = nil,
	lastShootTime = 0
}

local function _isTargetValid(ch)
	if not ch or not ch:FindFirstChild(C.aim.hitbox) then return false end
	if not ch:FindFirstChild("Humanoid") or ch.Humanoid.Health <= 0 then return false end
	-- Check ignore list (exact match via lookup table)
	local ignoreMap = {}
	for _, n in _ipairs(C.aim.ignore) do ignoreMap[n] = true end
	local pName = _Plrs:GetPlayerFromCharacter(ch)
	if pName and ignoreMap[pName.Name] then return false end
	-- Team check
	if C.aim.teamCheck then
		if ch:FindFirstChild("Humanoid") then
			local myTeam = _LP.Team
			local targetTeam = _Plrs:GetPlayerFromCharacter(ch)
			if myTeam and targetTeam and targetTeam.Team == myTeam then return false end
		end
	end
	return true
end

local function _getTargetPart(ch)
	if not ch then return nil end
	local part = ch:FindFirstChild(C.aim.hitbox)
	if part then return part end
	-- Fallback to HumanoidRootPart
	return ch:FindFirstChild("HumanoidRootPart")
end

local function _isVisible(targetPart)
	if not C.aim.visible then return true end
	local myChar = _LP.Character
	if not myChar then return false end
	local origin = _Cam.CFrame.Position
	local dir = (targetPart.Position - origin)
	local dist = dir.Magnitude
	dir = dir.Unit

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignoreList = {_Cam}
	if myChar then
		for _, part in _ipairs(myChar:GetDescendants()) do
			if part:IsA("BasePart") then
				_tbl.insert(ignoreList, part)
			end
		end
		-- Add tool/weapon parts so they don't block visibility
		for _, tool in _ipairs(myChar:GetChildren()) do
			if tool:IsA("Tool") then
				for _, p in _ipairs(tool:GetDescendants()) do
					if p:IsA("BasePart") then
						_tbl.insert(ignoreList, p)
					end
				end
			end
		end
	end
	params.FilterDescendantsInstances = ignoreList

	local result = _WS:Raycast(origin, dir * (dist + 5), params)
	if result then
		local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
		if hitModel then
			return hitModel == targetPart:FindFirstAncestorOfClass("Model")
		end
		return false
	end
	return true
end

function AimBot:Update()
	if not C.aim.enabled then
		self.target = nil
		self.lastTarget = nil
		return
	end

	local myChar = _LP.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
		self.target = nil
		return
	end

	local myPos = _Cam.CFrame.Position
	local camDir = _Cam.CFrame.LookVector
	local bestTarget = nil
	local bestFov = C.aim.fov
	local bestPart = nil

	for _, plr in _ipairs(_Plrs:GetPlayers()) do
		if plr == _LP then continue end
		local ch = plr.Character
		if not _isTargetValid(ch) then continue end
		local part = _getTargetPart(ch)
		if not part then continue end

		local targetPos = part.Position
		local dir = (targetPos - myPos).Unit
		local angle = _acos(_clamp(camDir:Dot(dir), -1, 1))
		local fovDeg = math.deg(angle)

		if fovDeg <= bestFov then
			if not C.aim.visible or _isVisible(part) then
				bestFov = fovDeg
				bestTarget = plr
				bestPart = part
			end
		end
	end

	if bestTarget and bestPart then
		self.target = bestTarget
		self.targetPart = bestPart
		-- Sound notification on new target
		if C.aim.sound and (not self.lastTarget or self.lastTarget ~= bestTarget) then
			_pcall(function()
				local snd = _Inst("Sound")
				snd.SoundId = "rbxassetid://9120383495"
				snd.Volume = 0.5
				snd.Parent = _Cam
				snd:Play()
				task.delay(0.3, function() _pcall(function() snd:Destroy() end) end)
			end)
		end
		self.lastTarget = bestTarget

		-- Aim
		local targetPos = bestPart.Position
		local look = _CF(myPos, targetPos)
		local s = C.aim.smooth

		if s > 0 then
			_Cam.CFrame = _Cam.CFrame:Lerp(look, 1 - s * 0.95)
		else
			_Cam.CFrame = look
		end

		-- Auto Shoot
		if C.aim.autoShoot then
			local now = _tick()
			if now - self.lastShootTime >= C.aim.shootDelay / 1000 then
				-- Check if player has a weapon
				local hasWeapon = false
				local char = _LP.Character
				if char then
					for _, t in _ipairs(char:GetChildren()) do
						if t:IsA("Tool") and t:FindFirstChild("Handle") then
							hasWeapon = true
							break
						end
					end
				end
				if hasWeapon then
					_VIM:SendMouseButtonEvent(0, 0, 0, true, _Cam, false)
					task.wait(0.05)
					_VIM:SendMouseButtonEvent(0, 0, 0, false, _Cam, false)
					self.lastShootTime = now
				end
			end
		end
	else
		self.target = nil
		self.targetPart = nil
	end
end

function AimBot:GetTarget()
	return self.target, self.targetPart
end

-- ===== MOVEMENT MODULE =====
local Movement = {}

function Movement:BunnyHop()
	if not C.move.bhop then return end
	local ch = _LP.Character
	if not ch then return end
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	if _UIS:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial ~= Enum.Material.Air then
		hum.Jump = true
	end
end

function Movement:ApplySpeed()
	local ch = _LP.Character
	if not ch then return end
	local hum = ch:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	if hum.WalkSpeed ~= C.move.walkSpeed then
		hum.WalkSpeed = C.move.walkSpeed
	end
	if hum.JumpPower ~= C.move.jumpPower then
		hum.JumpPower = C.move.jumpPower
	end
end

function Movement:AirControl()
	if not C.move.airControl then return end
	local ch = _LP.Character
	if not ch then return end
	local hum = ch:FindFirstChildOfClass("Humanoid")
	local root = ch:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end
	-- Only apply when in air
	if hum:GetState() ~= Enum.HumanoidStateType.Freefall and hum:GetState() ~= Enum.HumanoidStateType.Jumping then return end

	local moveVec = _V3(
		(_UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (_UIS:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
		0,
		(_UIS:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (_UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
	)
	if moveVec.Magnitude > 0 then
		moveVec = moveVec.Unit
		local camRight = _Cam.CFrame.RightVector
		local camLook = _V3(_Cam.CFrame.LookVector.X, 0, _Cam.CFrame.LookVector.Z).Unit
		local targetVel = (camRight * moveVec.X + camLook * moveVec.Z) * hum.WalkSpeed
		root.Velocity = _V3(targetVel.X, root.Velocity.Y, targetVel.Z)
	end
end

function Movement:AntiAim()
	if C.move.antiAim == "Off" then return end
	local ch = _LP.Character
	if not ch then return end
	local root = ch:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local t = _tick()
	if C.move.antiAim == "Jitter" then
		local angle = _sin(t * 10) * 30
		root.CFrame = _CF(root.Position) * _Ang(0, _rad(angle), 0)
	elseif C.move.antiAim == "Spin" then
		local angle = (t * C.move.spinSpeed * 50) % 360
		root.CFrame = _CF(root.Position) * _Ang(0, _rad(angle), 0)
	elseif C.move.antiAim == "Fake" then
		local angle = _cos(t * 8) * 45 + _sin(t * 5) * 20
		root.CFrame = _CF(root.Position) * _Ang(0, _rad(angle), 0)
	end
end

-- ===== RADAR =====
local _radarFrame = nil
local _radarDots = {}
local _radarPlayerArrow = nil
local _radarSize = 0
local _radarZoom = 0

local function _createRadar()
	if _radarFrame and (_radarSize ~= C.radar.size or _radarZoom ~= C.radar.zoom) then
		_pcall(function() _radarFrame:Destroy() end)
		_radarFrame = nil
	end
	if _radarFrame then return end
	if not C.radar.enabled then return end

	local size = C.radar.size
	_radarSize = size
	_radarZoom = C.radar.zoom
	_radarFrame = _mk("Frame", {
		Parent = _LP:WaitForChild("PlayerGui"),
		Name = "AXMERadar",
		Size = _UD2(0, size, 0, size),
		Position = _UD2(0, 10, 0.5, -size / 2),
		BackgroundColor3 = _C3.fromRGB(20, 20, 20),
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0
	})

	-- Radar border
	_mk("Frame", {
		Parent = _radarFrame,
		Size = _UD2(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 1,
		BorderColor3 = _C3.fromRGB(60, 200, 60)
	})

	-- Center dot (player)
	_radarPlayerArrow = _mk("TextLabel", {
		Parent = _radarFrame,
		Size = _UD2(0, 10, 0, 10),
		Position = _UD2(0.5, -5, 0.5, -5),
		BackgroundTransparency = 1,
		Text = "^",
		TextColor3 = _C3.fromRGB(60, 200, 60),
		TextSize = 10,
		Font = Enum.Font.SourceSansBold
	})
end

local function _drawRadar()
	if not C.radar.enabled then
		if _radarFrame then
			_pcall(function() _radarFrame:Destroy() end)
			_radarFrame = nil
		end
		return
	end

	-- Recreate if size changed or doesn't exist
	if not _radarFrame or _radarSize ~= C.radar.size then
		_radarSize = C.radar.size
		_createRadar()
	end
	if not _radarFrame then return end

	-- Clear old dots
	for _, dot in _ipairs(_radarDots) do
		_pcall(function() dot:Destroy() end)
	end
	_radarDots = {}

	local myChar = _LP.Character
	if not myChar then return end
	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local myPos = myRoot.Position
	local myRot = myRoot.Orientation.Y
	local halfSize = C.radar.size / 2
	local zoom = C.radar.zoom

	-- Update player arrow rotation
	if _radarPlayerArrow then
		_radarPlayerArrow.Rotation = -myRot
	end

	for _, plr in _ipairs(_Plrs:GetPlayers()) do
		if plr == _LP then continue end
		local ch = plr.Character
		if not ch or not ch:FindFirstChild("HumanoidRootPart") then continue end
		local hum = ch:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		local targetRoot = ch:FindFirstChild("HumanoidRootPart")
		local relPos = targetRoot.Position - myPos

		-- Rotate relative position by player rot
		local radRot = _rad(-myRot)
		local rotX = relPos.X * _cos(radRot) - relPos.Z * _sin(radRot)
		local rotZ = relPos.X * _sin(radRot) + relPos.Z * _cos(radRot)

		-- Scale
		local scale = zoom / 100
		local dotX = rotX * scale
		local dotZ = rotZ * scale

		-- Clamp to radar bounds
		if math.abs(dotX) > halfSize or math.abs(dotZ) > halfSize then continue end

		-- Determine color
		local isTeam = C.aim.teamCheck and plr.Team and plr.Team == _LP.Team
		local dotColor = isTeam and _C3.fromRGB(60, 200, 60) or _C3.fromRGB(200, 60, 60)

		local dot = _mk("Frame", {
			Parent = _radarFrame,
			Size = _UD2(0, 4, 0, 4),
			Position = _UD2(0.5, dotX - 2, 0.5, dotZ - 2),
			BackgroundColor3 = dotColor,
			BorderSizePixel = 0
		})
		_tbl.insert(_radarDots, dot)
	end
end

-- ===== STATUS INDICATOR =====
local _statusFrame = nil
local _statusLabels = {}

local function _createStatus()
	if _statusFrame then
		_pcall(function() _statusFrame:Destroy() end)
		_statusFrame = nil
	end
	_statusFrame = _mk("Frame", {
		Parent = _LP:WaitForChild("PlayerGui"),
		Name = "AXMEStatus",
		Size = _UD2(0, 200, 0, 120),
		Position = _UD2(1, -210, 0, 10),
		BackgroundColor3 = _C3.fromRGB(10, 10, 10),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0
	})
	_mk("UIListLayout", { Parent = _statusFrame, Padding = _UD2(0, 2) })
	_mk("UIPadding", { Parent = _statusFrame, PaddingLeft = _UD2(0, 6), PaddingTop = _UD2(0, 4) })

	-- Title
	local title = _mk("TextLabel", {
		Parent = _statusFrame,
		Size = _UD2(1, -12, 0, 16),
		BackgroundTransparency = 1,
		Text = "AXME Status",
		TextColor3 = _C3.fromRGB(80, 200, 255),
		TextSize = 12,
		Font = Enum.Font.SourceSansBold,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	_tbl.insert(_statusLabels, title)

	-- Active features
	local featLbl = _mk("TextLabel", {
		Parent = _statusFrame,
		Size = _UD2(1, -12, 0, 14),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = _C3.fromRGB(200, 200, 200),
		TextSize = 10,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true
	})
	_tbl.insert(_statusLabels, featLbl)

	-- Target info
	local targetLbl = _mk("TextLabel", {
		Parent = _statusFrame,
		Size = _UD2(1, -12, 0, 14),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = _C3.fromRGB(200, 200, 200),
		TextSize = 10,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	_tbl.insert(_statusLabels, targetLbl)

	-- FPS
	local fpsLbl = _mk("TextLabel", {
		Parent = _statusFrame,
		Size = _UD2(1, -12, 0, 14),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = _C3.fromRGB(80, 200, 80),
		TextSize = 10,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	_tbl.insert(_statusLabels, fpsLbl)
end

local function _updateStatus()
	if not _statusFrame then _createStatus() end
	if #_statusLabels < 4 then return end

	-- Active features
	local parts = {}
	if C.esp.enabled then _tbl.insert(parts, "ESP") end
	if C.aim.enabled then _tbl.insert(parts, "Aim") end
	if C.move.bhop then _tbl.insert(parts, "BHop") end
	if C.radar.enabled then _tbl.insert(parts, "Radar") end
	if C.move.antiAim ~= "Off" then _tbl.insert(parts, C.move.antiAim) end
	_statusLabels[2].Text = "Active: " .. (#parts > 0 and _tbl.concat(parts, ", ") or "None")

	-- Target
	if C.aim.enabled and AimBot.target and AimBot.targetPart then
		local dist = (AimBot.targetPart.Position - _Cam.CFrame.Position).Magnitude
		_statusLabels[3].Text = "Target: " .. AimBot.target.Name .. " [" .. _floor(dist) .. "m]"
	else
		_statusLabels[3].Text = ""
	end

	-- FPS
	local stats = _RunS:GetStatistics()
	local fps = stats.FPS
	_statusLabels[4].Text = "FPS: " .. _floor(fps)
end

-- ===== KEYBINDS =====
_UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		guiRoot:Toggle()
	end
	if input.KeyCode == C.keys.aim then
		C.aim.enabled = not C.aim.enabled
	end
	if input.KeyCode == C.keys.esp then
		C.esp.enabled = not C.esp.enabled
	end
	if input.KeyCode == C.keys.radar then
		C.radar.enabled = not C.radar.enabled
		if not C.radar.enabled and _radarFrame then
			_pcall(function() _radarFrame:Destroy() end)
			_radarFrame = nil
		end
	end
	if input.KeyCode == C.keys.bhop then
		C.move.bhop = not C.move.bhop
	end
end)

-- ===== MAIN LOOP =====
_RunS.RenderStepped:Connect(function(dt)
	_clearEsp()

	-- ESP
	_drawEsp()

	-- Aimbot
	AimBot:Update()

	-- Movement
	Movement:BunnyHop()
	Movement:ApplySpeed()
	Movement:AirControl()
	Movement:AntiAim()

	-- Radar
	_drawRadar()

	-- Status
	_updateStatus()
end)

-- Auto-open menu after short delay
local _autoOpenConn = _RunS.Heartbeat:Connect(function()
	local pg = _LP:FindFirstChild("PlayerGui")
	if pg and pg:FindFirstChild("AXMEGui") then
		_autoOpenConn:Disconnect()
		task.wait(0.3)
		guiRoot:Open()
		print("Menu opened. Press Insert to toggle.")
	end
end)

-- Clean up orphaned objects from previous runs
_pcall(function()
	local pg = _LP:FindFirstChild("PlayerGui")
	if pg then
		for _, v in _ipairs(pg:GetChildren()) do
			if v.Name == "AXMERadar" or v.Name == "AXMEStatus" or v.Name == "_tracerParent" then
				v:Destroy()
			end
		end
	end
end)

-- ===== INITIALIZATION =====
print("AXME Stress-Test Script Loaded")
print("Press Insert to toggle menu")

-- On-screen notification
_pcall(function()
	local notif = _mk("TextLabel", {
		Parent = _LP:WaitForChild("PlayerGui"),
		Size = _UD2(0, 300, 0, 30),
		Position = _UD2(0.5, -150, 0, 50),
		BackgroundColor3 = _C3.new(0,0,0),
		BackgroundTransparency = 0.3,
		Text = "AXME Loaded | Press Insert",
		TextColor3 = _C3.fromRGB(0, 255, 200),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		BorderSizePixel = 0,
		ZIndex = 10001
	})
	task.spawn(function()
		task.wait(5)
		_tw(notif, { BackgroundTransparency = 1, TextTransparency = 1 }, 0.5)
		task.wait(0.5)
		notif:Destroy()
	end)
end)
