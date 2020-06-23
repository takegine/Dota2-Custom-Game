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

if MainGame == nil then
	MainGame = class({})
end


require("lib/timers_v1_05")
require("utils/mjz_util")

require('systems/courier_system')

require("gm_custom_hero_level")
require("events")


local IS_TEST = IsInToolsMode()

local mCourierSystem = nil

function MainGame:InitGameMode()
	-- -- 设置自动开始前的等待时间。
	GameRules:SetCustomGameSetupAutoLaunchDelay(5)
	-- -- 设置选择英雄时间
	GameRules:SetHeroSelectionTime(60)
	-- -- 设置决策时间
	GameRules:SetStrategyTime(10)
	-- -- 设置展示时间
	GameRules:SetShowcaseTime(5)
	-- -- 设置游戏准备时间
	GameRules:SetPreGameTime(30)

	-- 设定游戏结束后在分数面板的停留时间
	-- GameRules:SetPostGameTime( 60.0 )
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
	GameRules:SetHeroRespawnEnabled( HERO_RESPAW_ENABLED )
	-- 第一滴血是否激活
	GameRules:SetFirstBloodActive(false)

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
	-- GameRules:SetStartingGold(600)	
	-- 设置每个时间间隔获得的金币
	GameRules:SetGoldPerTick(0)
	-- 设置获得金币的时间周期
	GameRules:SetGoldTickTime(0)
	-- 禁用死亡时损失金钱
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath( false )
	-- 允许/禁止英雄买活
	-- GameRules:GetGameModeEntity():SetBuybackEnabled( false ) 
	
    if IsInToolsMode() then
		-- 启用 (true)或禁用 (false) 自定义游戏的自动设置。
		-- GameRules:EnableCustomGameSetupAutoLaunch(true)
		-- -- 设置自动开始前的等待时间。
		GameRules:SetCustomGameSetupAutoLaunchDelay(0)
		-- -- 设置游戏的设置时间，0 = 立即开始 -1 = 等待直到设置完毕。
        -- -- GameRules:SetCustomGameSetupRemainingTime(0)

        -- -- 设置选择英雄时间
		-- GameRules:SetHeroSelectionTime(0)
		-- -- 设置决策时间
		GameRules:SetStrategyTime(0)
		-- -- 设置展示时间
		GameRules:SetShowcaseTime(0)
		-- -- 设置游戏准备时间
		GameRules:SetPreGameTime(0)
		
		GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,5)

        -- GameRules:GetGameModeEntity():SetMaximumAttackSpeed(1000)
	end
	
	

	
	-- 自定义英雄的最大等级
    --CustomHeroLevel()
    
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
	
	Convars:RegisterCommand( "mjz_hero_point", function(command) 
        print_all_hero_point()
    end, "mjz_hero_point", FCVAR_CHEAT )

    Convars:RegisterCommand( "mjz_hero_all_modifiers", function(command) 
        print_hero_all_modifiers()
    end, "mjz_hero_all_modifiers", FCVAR_CHEAT )

    Convars:RegisterCommand( "mjz_hero_base_attack_time", function(command) 
        print_hero_base_attack_time()
    end, "mjz_hero_base_attack_time", FCVAR_CHEAT )
    
    Convars:RegisterCommand( "mjz_clear_tree", function(command) 
        local point = PlayerInstanceFromIndex(1):GetAssignedHero():GetAbsOrigin()
        local radius = 1000
        GridNav:DestroyTreesAroundPoint( point, radius, false )        
    end, "mjz_clear_tree", FCVAR_CHEAT )

    Convars:RegisterCommand( "mjz_show_modifier", function(command, modifier_name) 
        local hero = PlayerInstanceFromIndex(1):GetAssignedHero()
        local modifier = hero:FindModifierByName(modifier_name)
        if modifier then
            print('Show Modifier: '..modifier_name)
            for k,v in pairs(modifier) do
                print("    ",k,v)
            end
        end
    end, "mjz_show_modifier", FCVAR_CHEAT )

    Convars:RegisterCommand( "mjz_show_ability", function(command, ability_name) 
        local hero = PlayerInstanceFromIndex(1):GetAssignedHero()
        local ability = hero:FindAbilityByName(ability_name)
        if ability then
            print('Show Ability: '..ability_name)
            for k,v in pairs(ability) do
                print("    ",k,v)
            end
        end
    end, "mjz_show_ability", FCVAR_CHEAT )
end


function MainGame:_ChatCommand(userid, text)
	if text == nil then return nil end
	if string.lower(text) == string.lower( "-DSkey") then
		ShowDSKey()
	end
end

function MainGame:_OnStartGame(  )
	CallAllHeroFunc(function(hero)
		if IsInToolsMode() then
			self:_Test_StartGame(hero)
		else
			local currentGold = hero:GetGold()
			local newGold = currentGold + HERO_START_GOLD
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
