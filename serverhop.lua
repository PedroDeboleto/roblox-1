local File = pcall(function()
		AllIDs = S_H:JSONDecode(readfile("psx-server-hop-temp.json"))
	end)
	if not File then
		table.insert(AllIDs, actualHour)
		pcall(function()
			writefile("psx-server-hop-temp.json", S_H:JSONEncode(AllIDs))
		end)

	end
	local function TPReturner()
		local Site;
		if foundAnything == "" then
			Site = S_H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100'))
		else
			Site = S_H:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. game.PlaceId .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
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
						S_T:TeleportToPlaceInstance(game.PlaceId, ID, game.Players.LocalPlayer)
					end)
					wait(4)
				end
			end
		end
	end
local module = {}
	function module:Teleport()
		while wait() do
			pcall(function()
				TPReturner()
				if foundAnything ~= "" then
					TPReturner()
				end
			end)
		end
	end
return module
