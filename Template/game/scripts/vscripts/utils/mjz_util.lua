

-----------------------------------------------------------------------------------
--  Dev Command
Convars:RegisterCommand( "mjz_dummy_target", function(...) 
    local unit = PlayerInstanceFromIndex(1):GetAssignedHero()	
    local vLocation = unit:GetAbsOrigin()
    CreateUnit_DummyTarget(vLocation, DOTA_GC_TEAM_BAD_GUYS, unit:GetPlayerID())
end, "dummy_target", FCVAR_CHEAT )

Convars:RegisterCommand( "mjz_hero_all_modifiers", function(...) 
    print_hero_all_modifiers()
end, "print_hero_all_modifiers", FCVAR_CHEAT )

-----------------------------------------------------------------------------------


function print_all_hero_point( )
    CallAllHeroFunc(function(hero)
        local p_id = hero:GetPlayerID()
        local p = hero:GetAbsOrigin()
        local s = string.format( "Player - %d : X(%f) Y(%f) Z(%f)", p_id, p.x, p.y, p.z )
        print(s)
    end)
end

function print_hero_all_modifiers( )
    CallAllHeroFunc(function(hero)
        local p_id = hero:GetPlayerID()
        local ms = hero:FindAllModifiers()
        print("Player - " .. p_id)
        for _, modifier in pairs(ms) do
            print("    " .. modifier:GetName())
            local statck_count = hero:GetModifierStackCount(modifier:GetName(), nil)
            local duration = modifier:GetDuration()
            local s = string.format( "Statck(%d) Duration(%d)", statck_count, duration)
            print("    " .. s)
        end
    end)
end

function print_hero_base_attack_time( )
  CallAllHeroFunc(function(hero)
    local p_id = hero:GetPlayerID()
    print("Player - " .. p_id)
    print('    base_attack_time: ', hero:GetBaseAttackTime())
  end)
end


-- BUG
function CallAllHeroFunc_bug( func )
    local player_list = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    for i = 1, player_list do
        local player = PlayerInstanceFromIndex(i)
        if player ~= nil then 
            local hero = PlayerInstanceFromIndex(i):GetAssignedHero()
            if hero ~= nil then 
                if type(func) == 'function' then
                    func(hero)
                end
            end
        end
    end
end
function CallAllHeroFunc( func )
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:HasSelectedHero( nPlayerID ) then
            -- PlayerResource:ModifyGold( nPlayerID, nTowersStandingGoldReward, true, DOTA_ModifyGold_Unspecified )
            local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
            if hero ~= nil then 
                if type(func) == 'function' then
                    func(hero)
                end
            end
        end
    end
end


function PrintTable(t, indent, done)
    --print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end
  
    done = done or {}
    done[t] = true
    indent = indent or 0
  
    local l = {}
    for k, v in pairs(t) do
      table.insert(l, k)
    end
  
    table.sort(l)
    for k, v in ipairs(l) do
      -- Ignore FDesc
      if v ~= 'FDesc' then
        local value = t[v]
  
        if type(value) == "table" and not done[value] then
          done [value] = true
          print(string.rep ("\t", indent)..tostring(v)..":")
          PrintTable (value, indent + 2, done)
        elseif type(value) == "userdata" and not done[value] then
          done [value] = true
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
          PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
        else
          if t.FDesc and t.FDesc[v] then
            print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
          else
            print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
          end
        end
      end
    end
end


-- 创建傀儡目标
function CreateUnit_DummyTarget(point, team, playerID)

  local hDummy = CreateUnitByName( "npc_dota_hero_target_dummy", point, true, nil, nil, team )
  hDummy:SetAbilityPoints( 0 )
  if playerID then
    hDummy:SetControllableByPlayer( playerID, false )
  end
  hDummy:Hold()
  hDummy:SetIdleAcquire( false )
  hDummy:SetAcquisitionRange( 0 )

  return hDummy
end



function TargetIsFriendly(caster, target )
	local nTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY 	-- ability:GetAbilityTargetTeam()
	local nTargetType = DOTA_UNIT_TARGET_ALL 			-- ability:GetAbilityTargetType()
	local nTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE		-- ability:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end

function TargetIsEnemy(caster, target )
	local nTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY 	-- ability:GetAbilityTargetTeam()
	local nTargetType = DOTA_UNIT_TARGET_ALL 			-- ability:GetAbilityTargetType()
	local nTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE		-- ability:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end


--[[
    A quick function to create popups.
    Example:
    create_popup({
        target = target,
        value = value,
        color = Vector(255, 20, 147),
        type = "spell_custom"
	}) 
	伤害类型的颜色：
		物理：Vector(174, 47, 40)
		魔法：Vector(91, 147, 209)
		纯粹：Vector(216, 174, 83)
	spell_custom: 
		block | crit | damage | evade | gold | heal | mana_add | mana_loss | miss | poison | spell | xp
	Color:	
		red 	={255,0,0},
		orange	={255,127,0},
		yellow	={255,255,0},
		green 	={0,255,0},
		blue 	={0,0,255},
		indigo 	={0,255,255},
		purple 	={255,0,255},
]]
function create_popup(data)
    local target = data.target
    local value = math.floor(data.value)

    local type = data.type or "miss"
    local color = data.color or Vector(255, 255, 255)
    local duration = data.duration or 1.0

    local size = string.len(value)

    local pre = data.pre or nil
    if pre ~= nil then
        size = size + 1
    end

    local pos = data.pos or nil
    if pos ~= nil then
        size = size + 1
    end

    local particle_path = "particles/msg_fx/msg_" .. type .. ".vpcf"
    local particle = ParticleManager:CreateParticle(particle_path, PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 1, Vector(pre, value, pos))
    ParticleManager:SetParticleControl(particle, 2, Vector(duration, size, 0))
    ParticleManager:SetParticleControl(particle, 3, color)
	ParticleManager:ReleaseParticleIndex(particle)
end

function create_popup_by_damage_type(data, ability)
    local damage_type = ability:GetAbilityDamageType()
    if damage_type == DAMAGE_TYPE_PHYSICAL then
        data.color = Vector(174, 47, 40)
    elseif damage_type == DAMAGE_TYPE_MAGICAL then
        data.color = Vector(91, 147, 209)
    elseif damage_type == DAMAGE_TYPE_PURE then
        data.color = Vector(216, 174, 83)
    else
        data.color = Vector(255, 255, 255)
    end
    create_popup(data)
end


-- 是否学习了指定天赋技能
function HasTalent(unit, talentName)
    if unit:HasAbility(talentName) then
        if unit:FindAbilityByName(talentName):GetLevel() > 0 then return true end
    end
    return false
end
 
-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end


function KillTreesInRadius(caster, center, radius)
    local particles = {
        "particles/newplayer_fx/npx_tree_break.vpcf",
        "particles/newplayer_fx/npx_tree_break_b.vpcf",
    }
    local particle = particles[math.random(1, #particles)]

    local trees = GridNav:GetAllTreesAroundPoint(center, radius, true)
    for _,tree in pairs(trees) do
        local particle_fx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_fx, 0, tree:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle_fx)
    end
    GridNav:DestroyTreesAroundPoint(center, radius, false)
end


function TeleportToPoint( unit, point )
    local playerID = unit:GetPlayerOwnerID()
    FindClearSpaceForUnit(unit, point, false)
    PlayerResource:SetCameraTarget(playerID, unit)
    Timers:CreateTimer(0.2, function()
        PlayerResource:SetCameraTarget(playerID, nil)
    end)
end

function StrSplit (inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

-- 显示地图秘钥
function ShowDSKey()
	local ply = PlayerResource:GetPlayer(0)
	if ply then
		local playerID = ply:GetPlayerID()
		local steamID = PlayerResource:GetSteamAccountID(playerID)
		if steamID == 333664846 then	-- or 76561198293930574
			local dsKey = GetDedicatedServerKeyV2("1")
			print("dsKey: " .. tostring(dsKey))
			GameRules:SendCustomMessage("dsKey: " .. tostring(dsKey), 0, 0)
		end
	end
end

-- 死亡后生成复活墓碑
function CreateRessurectionTombstone( killedUnit )
	local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )
	newItem:SetPurchaseTime( 0 )
	newItem:SetPurchaser( killedUnit )
	local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
	tombstone:SetContainedItem( newItem )
	tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
	FindClearSpaceForUnit( tombstone, killedUnit:GetAbsOrigin(), true )	
end

function PopupAlchemistGold(target, number, player)
    local symbol = 0 -- "+" presymbol
    local color = Vector(255, 200, 33) -- Gold
    local lifetime = 3
    local digits = string.len(number) + 1
    local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
    local particle = ParticleManager:CreateParticleForPlayer(particleName, PATTACH_CUSTOMORIGIN, target, player or target:GetPlayerOwner())
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(symbol, number, symbol))
    ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(particle, 3, color)
end
-- 添加金钱，带特效
function PlayerModifyGold(hero, gold) 
	hero:ModifyGold(gold, true, 0)
	EmitSoundOnClient("DOTA_Item.Hand_Of_Midas", PlayerResource:GetPlayer(hero:GetPlayerID()))
	PopupAlchemistGold(hero, gold, hero:GetPlayerOwner())
	local pn = "particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf"
	local coins = ParticleManager:CreateParticle(pn, PATTACH_CUSTOMORIGIN, hero)
	ParticleManager:SetParticleControl(coins, 1, hero:GetAbsOrigin())
end

