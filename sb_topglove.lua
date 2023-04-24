local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local S_T = game:GetService("TeleportService")
local S_H = game:GetService("HttpService")

local File = pcall(function()
	AllIDs = S_H:JSONDecode(readfile("server-hop-temp.json"))
end)
if not File then
	table.insert(AllIDs, actualHour)
	pcall(function()
		writefile("server-hop-temp.json", S_H:JSONEncode(AllIDs))
	end)
end
local function TPReturner(placeId)
	local Site;
	if foundAnything == "" then
		Site = S_H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeId .. '/servers/Public?sortOrder=Asc&limit=100'))
	else
		Site = S_H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. placeId .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
	end
	local ID = ""
	if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
		foundAnything = Site.nextPageCursor
	end
	local num = 0;
	for i,v in pairs(Site.data) do
		local Possible = true
		ID = tostring(v.id)
		if tonumber(v.maxPlayers) > tonumber(v.playing) then
			for _,Existing in pairs(AllIDs) do
				if num ~= 0 then
					if ID == tostring(Existing) then
						Possible = false
					end
				else
					if tonumber(actualHour) ~= tonumber(Existing) then
						local delFile = pcall(function()
							delfile("server-hop-temp.json")
							AllIDs = {}
							table.insert(AllIDs, actualHour)
						end)
					end
				end
				num = num + 1
			end
			if Possible == true then
				table.insert(AllIDs, ID)
				wait()
				pcall(function()
					writefile("server-hop-temp.json", S_H:JSONEncode(AllIDs))
					wait()
					S_T:TeleportToPlaceInstance(placeId, ID, game.Players.LocalPlayer)
				end)
				wait(4)
			end
		end
	end
end

local gloves = {}


pcall(function()
	gloves = S_H:JSONDecode(readfile("popular_gloves.json"))
end)

for i,v in pairs(game.Players:GetPlayers()) do
    if v:FindFirstChild("leaderstats") and v.leaderstats:FindFirstChild("Glove") then
        gloves[v.leaderstats.Glove.Value] = (gloves[v.leaderstats.Glove.Value] or 0) + 1
    end
end

local qot = syn and syn.queue_on_teleport or queue_on_teleport
if qot then qot("loadstring(game:HttpGet('https://raw.githubusercontent.com/LeoKholYt/roblox/main/sb_topglove.lua'))()") end

function Teleport(placeId)
    writefile("popular_gloves.json", S_H:JSONEncode(gloves))
	while wait() do
		pcall(function()
			TPReturner(placeId)
			if foundAnything ~= "" then
				TPReturner(placeId)
			end
		end)
	end
end
Teleport(game.PlaceId)
