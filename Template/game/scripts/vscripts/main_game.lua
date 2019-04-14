--[[
From
Holdout Example

	Underscore prefix such as "_function()" denotes a local function and is used to improve readability
	
	Variable Prefix Examples
		"fl"	Float
		"n"		Int
		"v"		Table
		"b"		Boolean
]]

require("lib.timers")
require("utils/mjz_util")

require('systems/courier_system')

require("gm_custom_hero_level")

if MainGame == nil then
	MainGame = class({})
end

local IS_TEST = IsInToolsMode()
local START_GOLD = 2000
local MIN_RESPAWN_TIME = 5
local MAX_RESPAWN_TIME = 60

local mCourierSystem = nil

function MainGame:InitGameMode()

    if IsInToolsMode() then
		-- 启用 (true)或禁用 (false) 自定义游戏的自动设置。
		GameRules:EnableCustomGameSetupAutoLaunch(true)
		-- 设置自动开始前的等待时间。
		GameRules:SetCustomGameSetupAutoLaunchDelay(0)
		-- 设置游戏的设置时间，0 = 立即开始 -1 = 等待直到设置完毕。
        -- GameRules:SetCustomGameSetupRemainingTime(0)

        -- 设置选择英雄时间
		GameRules:SetHeroSelectionTime(0)
		-- 设置决策时间
		GameRules:SetStrategyTime(0)
		-- 设置展示时间
		GameRules:SetShowcaseTime(0)
		-- 设置游戏准备时间
        GameRules:SetPreGameTime(0)

        -- GameRules:GetGameModeEntity():SetMaximumAttackSpeed(1000)
    else
        -- 设置选择英雄时间
		GameRules:SetHeroSelectionTime(60)
	end
	
	-- 设定游戏结束后在分数面板的停留时间
	GameRules:SetPostGameTime( 60.0 )
	-- 任何一家商店都可以购买全部物品，不用到野外商店购买
    GameRules:SetUseUniversalShopMode(true)
    -- 树木再生时间
    GameRules:SetTreeRegrowTime( 60.0 )
	-- 设置小地图图标大小
	GameRules:SetHeroMinimapIconScale( 0.7 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	-- 设置玩家人数为： 天辉4人，夜魇0人（不可选）
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,5)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,0)
	-- 不能自动重生，死亡墓碑上显示玩家名字
	-- GameRules:SetHeroRespawnEnabled( false )

	-- 是否关闭战争迷雾 
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
	-- 是否启用未探索地形战争迷雾
    GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled(true)
    -- 设置神符刷新时间（秒）
	-- GameRules:GetGameModeEntity():SetRuneSpawnTime(2 * 60)
	-- 不刷新幻象神符
	-- GameRules:GetGameModeEntity():SetRuneEnabled(DOTA_RUNE_ILLUSION, false)
	-- 幻象死亡时立即消失，而不是延迟数秒
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	-- 设置初始金钱
	-- GameRules:GetGameModeEntity():SetStartingGold(600)	
	-- 禁用死亡时损失金钱
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	-- 允许/禁止英雄买活
	-- GameRules:GetGameModeEntity():SetBuybackEnabled( false ) 
	-- 自定义英雄的最大等级
    CustomHeroLevel()
    
    self:_RegisterCommand()

    self:_ListenToGameEvent()
	
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end

function MainGame:CreateSystems()
	if ( not mCourierSystem ) then
		mCourierSystem = CourierSystem()
	end 
end

-- Evaluate the state of the game
function MainGame:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function MainGame:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
        print("DOTA_GAMERULES_STATE_PRE_GAME")
        -- ShowGenericPopup( "#holdout_instructions_title", "#holdout_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
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

---------------------------------------------------------

function MainGame:_ListenToGameEvent()
    -- 官方参考：https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Engine_Events

    --监听游戏进度
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(MainGame,"OnGameRulesStateChange"), self)
    
    ----------  Player events  -------------------------------
    -- 玩家满员
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(MainGame, 'OnConnectFull'), self)
    -- 玩家连接
	ListenToGameEvent('player_connect', Dynamic_Wrap(MainGame, 'OnPlayerConnect'), self)
    -- 玩家失去连接
    ListenToGameEvent('player_disconnect', Dynamic_Wrap(MainGame, 'OnPlayerDisconnect'), self)
    -- 玩家重新连接
    ListenToGameEvent("player_reconnected", Dynamic_Wrap(MainGame, 'OnPlayerReconnect'), self)
    -- 玩家聊天信息
    ListenToGameEvent("player_chat", Dynamic_Wrap(MainGame, 'OnPlayerChat'), self)
     -- 玩家选中英雄
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(MainGame, 'OnPlayerPickHero'), self)
    -- 玩家升级
    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(MainGame, 'OnPlayerLevelUp'), self)
    -- 玩家学习技能
    ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(MainGame, 'OnPlayerLearnedAbility'), self)
    -- 玩家使用技能
    ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(MainGame, 'OnPlayerUsedAbility'), self)
    -- 当使用技能时，但单位不是玩家
	ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(MainGame, 'OnNonPlayerUsedAbility'), self)
    -- 当一个玩家破坏了一座防御塔
    ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(MainGame, 'OnPlayerTakeTowerDamage'), self)
        
    -- 单位被杀
    ListenToGameEvent( "entity_killed", Dynamic_Wrap(MainGame, 'OnEntityKilled' ), self)
    -- 单位诞生
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(MainGame, 'OnNPCSpawn'), self)
    -- 单位受到伤害
	ListenToGameEvent('entity_hurt', Dynamic_Wrap(MainGame, 'OnEntityHurt'), self)
    -- 树被砍掉
	ListenToGameEvent('tree_cut', Dynamic_Wrap(MainGame, 'OnTreeCut'), self)
    -- 当购买物品
    ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(MainGame, 'OnItemPurchased'), self)
    -- 当物品被捡起
    ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(MainGame, 'OnItemPickedUp'), self)
    
    -- 最近的攻击
    -- ListenToGameEvent('last_hit', Dynamic_Wrap(MainGame, 'OnLastHit'), self)
    -- 当激活神符
    --ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(MainGame, 'OnRuneActivated'), self)
    -- 当一个玩家在团战中杀了一个玩家
	-- ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(MainGame, 'OnTeamKillCredit'), self)
  
end

function MainGame:_RegisterCommand( )
    -- Custom console commands
    Convars:RegisterCommand( "test_func", function(...) return print( ... ) end, "Test Function.", FCVAR_CHEAT )
end

function MainGame:_OnStartGame(  )
	CallAllHeroFunc(function(hero)
		if IsInToolsMode() then
			self:_Test_StartGame(hero)
		else
			local currentGold = hero:GetGold()
			local newGold = currentGold + START_GOLD
			hero:SetGold(newGold, false)	

			if hero:HasAnyAvailableInventorySpace() then
				hero:AddItemByName("item_blink")
				hero:AddItemByName("item_boots")
			end	
		end
	end)
end


function MainGame:_Test_StartGame( unit )
	unit:SetGold(99999, false)	
    unit:AddExperience (112000, DOTA_ModifyGold_HeroKill, false, false)
    
    local item_list = {
        "item_blink",                   -- 跳刀
        "item_heart",				    -- 龙芯
        "item_satanic",				    -- 撒旦
        "item_travel_boots_2",          -- 飞行鞋
        "item_ultimate_scepter",		-- 神杖
    }

    for k,v in pairs(item_list) do
        if unit:HasAnyAvailableInventorySpace() then
            unit:AddItemByName(v)
        end	
    end

	mCourierSystem:SpawnCourier(unit)
end
