

function MainGame:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
        print("DOTA_GAMERULES_STATE_PRE_GAME")
        -- ShowGenericPopup( "#holdout_instructions_title", "#holdout_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	elseif nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        -- 玩家没选择的英雄，就随机一个英雄给他
		for i=0, DOTA_MAX_TEAM_PLAYERS do
			if PlayerResource:HasSelectedHero(i) == false then
	            local player = PlayerResource:GetPlayer(i)
	            if player then
	            	print("Randoming hero for player ", i)
	            	player:MakeRandomHeroSelection()
	            end
	        end
	    end
    elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        print("DOTA_GAMERULES_STATE_HERO_SELECTION")
        if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
            -- HeroSelection:Start()
        end
    elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
        print("Entered DOTA_GAMERULES_STATE_PRE_GAME")
        self:OnPreGameState()
    elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then	 -- 游戏开始
        print("Entered DOTA_GAMERULES_STATE_GAME_IN_PROGRESS")
        self:OnGameInProgress()
    elseif newState == DOTA_GAME_UI_STATE_LOADING_SCREEN then
        print("Entered DOTA_GAME_UI_STATE_LOADING_SCREEN")
    elseif newState == DOTA_GAME_UI_DOTA_INGAME then
        print("Entered DOTA_GAME_UI_DOTA_INGAME")
    elseif newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        print("Entered DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP")
	end
end

function MainGame:OnNPCSpawn(data)
    local unit = EntIndexToHScript(data.entindex)
    local player = unit:GetPlayerOwner()

    if player ~= nil then
		if player:GetTeam() == DOTA_TEAM_GOODGUYS or player:GetTeam() == DOTA_TEAM_BADGUYS then
			if unit:IsRealHero() then
				self:OnHeroInGameFirstTime(unit)
			end
		end
	end
end

function MainGame:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if not killedUnit then return end
	
	if killedUnit and killedUnit:IsRealHero() then
        if HERO_RESSURECTION_TOMBSTONE then
		    CreateRessurectionTombstone(killedUnit)
        end
		if killedUnit:IsReincarnating() == false and HERO_RESPAW_ENABLED then
            --print("Setting time for respawn")
            if HERO_MIN_RESPAWN_TIME ~= nil and HERO_MAX_RESPAWN_TIME ~= nil then
                local respawn_time = killedUnit:GetLevel() * 2
                if respawn_time < HERO_MIN_RESPAWN_TIME then
                    respawn_time = HERO_MIN_RESPAWN_TIME
                elseif respawn_time > HERO_MAX_RESPAWN_TIME then
                    respawn_time = HERO_MAX_RESPAWN_TIME
                end
                killedUnit:SetTimeUntilRespawn(respawn_time)
            end
        end
	end

    if killedUnit:IsRealHero() then

    else
        
	end
end

function MainGame:OnPreGameState( )
    print('OnPreGameState')
end

function MainGame:OnGameInProgress( )
    if not self._Inited_IN_PROGRESS then
        self._Inited_IN_PROGRESS = true

	    self:CreateSystems()

		Timers:CreateTimer(5, function( )
			self:_OnStartGame()
		end)
	end
end

function MainGame:OnHeroInGameFirstTime( hero )
    --print("OnHeroInGameFirstTime")

    if not hero.next_spawn then
        hero.next_spawn = true;
		HeroAbilitySetBaseLevel(hero)
    end
end

function MainGame:OnTreeCut(keys)
	--print ('OnTreeCut')
	--PrintTable(keys)
	--[[local treeX = keys.tree_x
	local treeY = keys.tree_y]]--
end

function MainGame:OnEntityHurt(keys)
	--print("Entity Hurt")
	--PrintTable(keys)
	--local attacker = EntIndexToHScript(keys.entindex_attacker)
	--local victim = EntIndexToHScript(keys.entindex_killed)
end

function MainGame:OnConnectFull(keys)
	print ('OnConnectFull')
	--PrintTable(keys)
	MainGame:OnFirstPlayerLoaded()

	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)

	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()

	local playerName = PlayerResource:GetPlayerName(playerID)

	-- Update the user ID table with this user
	-- self.vUserIds[keys.userid] = ply

	-- Update the Steam ID table
	-- self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply

	-- If the player is a broadcaster flag it in the Broadcasters table
	if PlayerResource:IsBroadcaster(playerID) then
		-- self.vBroadcasters[keys.userid] = 1
		return
	end
end

function MainGame:OnFirstPlayerLoaded()
    print('OnFirstPlayerLoaded')
end

function MainGame:OnPlayerConnect(keys)
	--print('PlayerConnect')
	--PrintTable(keys)
	if keys.bot == 1 then
        -- This user is a Bot, so add it to the bots table
        if not self.vBots then
            self.vBots = {}
        end
		self.vBots[keys.userid] = 1
	end
end

function MainGame:OnPlayerDisconnect(keys)
	print('Player Disconnected ' .. tostring(keys.userid))
	--PrintTable(keys)
	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid
end

function MainGame:OnPlayerReconnect(keys)
	print ( 'OnPlayerReconnect' )
	-- PrintTable(keys)
	local plyID = keys.PlayerID
	local ply = PlayerResource:GetPlayer(plyID)
	print("P" .. plyID .. " reconnected.")
	local plyhero = PlayerResource:GetPlayer(plyID):GetAssignedHero()
	ply.disconnected = false
end

function MainGame:OnPlayerChat( keys )
    --if keys then DeepPrintTable(keys) end
    local teamonly = keys.teamonly  -- 是否是团队聊天
    local userid = keys.userid      -- 玩家id
	local text = keys.text          -- 内容
	if self._ChatCommand then
        self:_ChatCommand(userid, text)
    end
end

function MainGame:OnPlayerPickHero(keys)
	--print ('OnPlayerPickHero')
	--PrintTable(keys)
	--[[local heroClass = keys.hero
	local heroEntity = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)]]--
end

function MainGame:OnPlayerLevelUp(keys)
	--print ('OnPlayerLevelUp')
	--PrintTable(keys)
	--[[local player = EntIndexToHScript(keys.player)
	local level = keys.level]]--
end

function MainGame:OnPlayerLearnedAbility( keys)
	--print ('OnPlayerLearnedAbility')
	--PrintTable(keys)
	--[[local player = EntIndexToHScript(keys.player)
	local abilityname = keys.abilityname]]--
end

function MainGame:OnPlayerUsedAbility(keys)
end

function MainGame:OnNonPlayerUsedAbility(keys)
	--print('OnNonPlayerUsedAbility')
	--PrintTable(keys)

	--local abilityname=  keys.abilityname
end

function MainGame:OnPlayerTakeTowerDamage(keys)
	--print ('OnPlayerTakeTowerDamage')
	--PrintTable(keys)

	--[[local player = PlayerResource:GetPlayer(keys.PlayerID)
	local damage = keys.damage]]--
end

function MainGame:OnTeamKillCredit(keys)
	--print ('OnTeamKillCredit')
	--PrintTable(keys)

	--[[local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
	local numKills = keys.herokills
	local killerTeamNumber = keys.teamnumber]]--
end

function MainGame:OnLastHit(keys)
	--print ('OnLastHit')
	--PrintTable(keys)

	--[[local isFirstBlood = keys.FirstBlood == 1
	local isHeroKill = keys.HeroKill == 1
	local isTowerKill = keys.TowerKill == 1
	local player = PlayerResource:GetPlayer(keys.PlayerID)]]--
end

function MainGame:OnItemPickedUp(keys)
	-- print ( 'OnItemPickedUp' )
	--PrintTable(keys)

	--[[local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local itemname = keys.itemname]]--
end

function MainGame:OnItemPurchased( keys )
	--print ( 'OnItemPurchased' )
	--PrintTable(keys)

	-- The playerID of the hero who is buying something
	--[[local plyID = keys.PlayerID
	if not plyID then return end

	-- The name of the item purchased
	local itemName = keys.itemname

	-- The cost of the item purchased
	local itemcost = keys.itemcost
	]]--
end

function MainGame:OnRuneActivated (keys)
	--print ('OnRuneActivated')
	--PrintTable(keys)
	
	--[[local player = PlayerResource:GetPlayer(keys.PlayerID)
	local rune = keys.rune]]--

	--[[ Rune Can be one of the following types
	DOTA_RUNE_DOUBLEDAMAGE
	DOTA_RUNE_HASTE
	DOTA_RUNE_HAUNTED
	DOTA_RUNE_ILLUSION
	DOTA_RUNE_INVISIBILITY
	DOTA_RUNE_MYSTERY
	DOTA_RUNE_RAPIER
	DOTA_RUNE_REGENERATION
	DOTA_RUNE_SPOOKY
	DOTA_RUNE_TURBO
	]]
end

----------------------------------------------------------------------------------

--[[
	当英雄出生时，设置他的技能的基础等级。相当于默认技能
	技能需要定义 BaseLevel 键，值为基础等级
]]
function HeroAbilitySetBaseLevel( hero )
	local ability_count = hero:GetAbilityCount()
	for i=0, (ability_count - 1) do
		local ability = hero:GetAbilityByIndex(i)
		if ability ~= nil then
			local ability_max_level = ability:GetMaxLevel()
			local ability_kv = ability:GetAbilityKeyValues()
			for k,v in pairs(ability_kv) do 
				if k == "BaseLevel" then
					local base_level = tonumber(v) or 0
					if base_level > 0 and base_level <= ability_max_level then
						if ability:GetLevel() < base_level then
							ability:SetLevel(base_level)
						end
					end
					break
				end
			end
		end
	end
end