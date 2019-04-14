
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

