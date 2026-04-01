local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

local URL = "https://your-app.up.railway.app/ai"

-- COLORS
local BG = Color3.fromRGB(15, 23, 42)
local PANEL = Color3.fromRGB(17, 24, 39)
local INPUT = Color3.fromRGB(31, 41, 55)
local BUTTON = Color3.fromRGB(37, 99, 235)
local TEXT = Color3.fromRGB(229, 231, 235)

-- LOAD SAVED KEY
local API_KEY = ""
pcall(function()
	if readfile and isfile and isfile("groq_key.txt") then
		API_KEY = readfile("groq_key.txt")
	end
end)

-- MEMORY
local messages = {
	{role = "system", content = "You are a smart AI inside Roblox. Be helpful and fast."}
}

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 400)
main.Position = UDim2.new(0.5, -250, 0.5, -200)
main.BackgroundColor3 = PANEL

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.Text = "Groq Agent ULTRA"
title.TextColor3 = TEXT
title.BackgroundTransparency = 1
title.TextSize = 22

local settingsBtn = Instance.new("TextButton", main)
settingsBtn.Size = UDim2.new(0,40,0,40)
settingsBtn.Position = UDim2.new(1,-45,0,0)
settingsBtn.Text = "⚙"

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1,-20,1,-120)
scroll.Position = UDim2.new(0,10,0,40)
scroll.BackgroundColor3 = BG

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

local input = Instance.new("TextBox", main)
input.Size = UDim2.new(1,-120,0,40)
input.Position = UDim2.new(0,10,1,-50)
input.BackgroundColor3 = INPUT
input.TextColor3 = TEXT
input.PlaceholderText = "Ask anything..."

local send = Instance.new("TextButton", main)
send.Size = UDim2.new(0,90,0,40)
send.Position = UDim2.new(1,-100,1,-50)
send.Text = "Send"
send.BackgroundColor3 = BUTTON
send.TextColor3 = TEXT

-- SETTINGS
local settings = Instance.new("Frame", gui)
settings.Size = UDim2.new(0,300,0,150)
settings.Position = UDim2.new(0.5,-150,0.5,-75)
settings.BackgroundColor3 = PANEL
settings.Visible = false

local apiBox = Instance.new("TextBox", settings)
apiBox.Size = UDim2.new(1,-20,0,40)
apiBox.Position = UDim2.new(0,10,0,20)
apiBox.PlaceholderText = "Enter Groq API Key"
apiBox.Text = API_KEY

local save = Instance.new("TextButton", settings)
save.Size = UDim2.new(0,100,0,30)
save.Position = UDim2.new(0.5,-50,1,-40)
save.Text = "Save"

settingsBtn.MouseButton1Click:Connect(function()
	settings.Visible = not settings.Visible
end)

save.MouseButton1Click:Connect(function()
	API_KEY = apiBox.Text
	
	-- SAVE LOCALLY
	pcall(function()
		if writefile then
			writefile("groq_key.txt", API_KEY)
		end
	end)
	
	settings.Visible = false
end)

-- ADD MESSAGE
local function addMessage(text, isUser)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,-10,0,0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.TextWrapped = true
	label.Text = text
	label.BackgroundColor3 = isUser and BUTTON or INPUT
	label.TextColor3 = TEXT
	label.Parent = scroll
end

-- TYPING EFFECT
local function typeText(label, fullText)
	label.Text = ""
	for i = 1, #fullText do
		label.Text = string.sub(fullText, 1, i)
		task.wait(0.01)
	end
end

-- REQUEST
local function askAI()
	for i=1,3 do
		local success, response = pcall(function()
			return HttpService:PostAsync(
				URL,
				HttpService:JSONEncode({
					messages = messages,
					apiKey = API_KEY
				}),
				Enum.HttpContentType.ApplicationJson
			)
		end)

		if success then
			local data = HttpService:JSONDecode(response)
			return data.choices[1].message.content
		end
		
		task.wait(2)
	end
	
	return "Server error"
end

-- SEND
send.MouseButton1Click:Connect(function()
	if input.Text == "" or API_KEY == "" then return end
	
	local userText = input.Text
	addMessage("You: "..userText, true)
	
	table.insert(messages, {role="user", content=userText})
	input.Text = ""

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,-10,0,0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.TextWrapped = true
	label.BackgroundColor3 = INPUT
	label.TextColor3 = TEXT
	label.Parent = scroll
	
	local reply = askAI()
	
	typeText(label, "AI: "..reply)
	
	table.insert(messages, {role="assistant", content=reply})
end)
