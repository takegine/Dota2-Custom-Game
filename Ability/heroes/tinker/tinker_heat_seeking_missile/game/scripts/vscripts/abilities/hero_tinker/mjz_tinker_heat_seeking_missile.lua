LinkLuaModifier("modifier_mjz_tinker_heat_seeking_missile_dud", "abilities/hero_tinker/mjz_tinker_heat_seeking_missile.lua", LUA_MODIFIER_MOTION_NONE)

mjz_tinker_heat_seeking_missile = class({})
local ability_class = mjz_tinker_heat_seeking_missile

function ability_class:GetIntrinsicModifierName()
	-- return "modifier_mjz_tinker_heat_seeking_missile"
end

function ability_class:GetAOERadius()
	local caster = self:GetCaster()
	local abiltiy = self
	local modifer_talent = ''
	local talent_value = 0
	local radius = abiltiy:GetSpecialValueFor('radius')
	local has_talent = caster:HasModifier(modifer_talent)
	if has_talent then
		radius = radius + talent_value
	end
	return radius
end

function ability_class:OnSpellStart( )
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self
		local radius = GetTalentSpecialValueFor(ability, "radius")
		local projectileSpeed = GetTalentSpecialValueFor(ability, "speed")
		local targets = GetTalentSpecialValueFor(ability, "targets")
		local targets_scepter = GetTalentSpecialValueFor(ability, "targets_scepter")
		local max_targets = value_if_scepter(caster, targets_scepter, targets)

		EmitSoundOn("Hero_Tinker.Heat-Seeking_Missile", caster)

		local particleName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"
		local modifierDudName = "modifier_mjz_tinker_heat_seeking_missile_dud"
		local targetTeam = ability:GetAbilityTargetTeam()
		local targetType = ability:GetAbilityTargetType()
		local targetFlag = ability:GetAbilityTargetFlags()
		local projectileDodgable = false
		local projectileProvidesVision = false
		
		-- pick up x nearest target heroes and create tracking projectile targeting the number of targets
		local units = FindUnitsInRadius(
			caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, targetTeam, targetType, targetFlag, FIND_CLOSEST, false
		)
		
		-- Seek out target
		local count = 0
		for k, v in pairs( units ) do
			if count < max_targets then
				local projTable = {
					Target = v,
					Source = caster,
					Ability = ability,
					EffectName = particleName,
					bDodgeable = projectileDodgable,
					bProvidesVision = projectileProvidesVision,
					iMoveSpeed = projectileSpeed, 
					vSpawnOrigin = caster:GetAbsOrigin()
				}
				ProjectileManager:CreateTrackingProjectile( projTable )
				count = count + 1
			else
				break
			end
		end
		
		-- If no unit is found, fire dud
		if count == 0 then
			-- ability:ApplyDataDrivenModifier( caster, caster, modifierDudName, {} )
			caster:AddNewModifier(caster, ability, modifierDudName, {Duration = 1.0})
		end

	end
end

if IsServer() then
	function ability_class:OnProjectileHit(target, location)
		local caster = self:GetCaster()
		local ability = self
		local base_damage = GetTalentSpecialValueFor(ability, "damage")
		local int_damage = GetTalentSpecialValueFor(ability, "intelligence_damage")
		local damage = base_damage + int_damage * caster:GetIntellect() / 100

		if target then
			
            ApplyDamage({
					attacker = caster,
					victim = target,
					damage = damage,
					damage_type = ability:GetAbilityDamageType(),
					ability = ability
			})
			
			create_popup_by_damage_type({
					target = target,
					value = damage,
					color = nil,
					type = "damage"
			}, ability) 
			
			local FX = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf", PATTACH_POINT, target)
			ParticleManager:ReleaseParticleIndex(FX)

			EmitSoundOn("Hero_Tinker.Heat-Seeking_Missile.Impact", target)
        end
    end
	
	function ability_class:OnProjectileHit_ExtraData(target, pos, keys)
	
	end
	
end

---------------------------------------------------------------------------------------

modifier_mjz_tinker_heat_seeking_missile_dud = class({})
local modifier_class_dud = modifier_mjz_tinker_heat_seeking_missile_dud

-- function modifier_class:IsPassive() return true end
function modifier_class_dud:IsHidden() return true end
function modifier_class_dud:IsPurgable() return false end

if IsServer() then	

	function modifier_class_dud:OnCreated( keys )
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local target = parent
		EmitSoundOn("Hero_Tinker.Heat-Seeking_Missile_Dud", target)

		local dud_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_missile_dud.vpcf", PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControlEnt(dud_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_attack3", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(dud_pfx)
	end

end



-----------------------------------------------------------------------------------------

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
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

