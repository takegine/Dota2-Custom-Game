
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

function CallAllHeroFunc( func )
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

