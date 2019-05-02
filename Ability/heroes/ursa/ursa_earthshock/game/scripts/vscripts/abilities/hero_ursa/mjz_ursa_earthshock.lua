LinkLuaModifier("modifier_mjz_ursa_earthshock","abilities/hero_ursa/mjz_ursa_earthshock.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_ursa_earthshock_talent_radius","abilities/hero_ursa/mjz_ursa_earthshock.lua", LUA_MODIFIER_MOTION_NONE)

mjz_ursa_earthshock = class({})
local ability_class = mjz_ursa_earthshock

function ability_class:GetAOERadius()
	local ability = self
	local caster = self:GetCaster()
	local base_radius = self:GetSpecialValueFor('shock_radius')
	local modifier_talent_name = 'modifier_mjz_ursa_earthshock_talent_radius'
	local talent_value = 600

	if caster:HasModifier(modifier_talent_name) then
		return base_radius + talent_value
	end
	return base_radius
end


if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local duration = ability:GetSpecialValueFor('duration')
		local radius = GetTalentSpecialValueFor(ability, "shock_radius")
		local base_damage = ability:GetSpecialValueFor("damage")
		local str_damage_pct = ability:GetSpecialValueFor("str_damage_pct")

		local modifier_debuff_name = 'modifier_mjz_ursa_earthshock'

		local damage = base_damage + caster:GetStrength() * (str_damage_pct / 100.0)

		local enemy_list = FindUnitsInRadius(
			caster:GetTeam(), 
			caster:GetAbsOrigin(), 
			nil, radius, 
			ability:GetAbilityTargetTeam(), 
			ability:GetAbilityTargetType(), 
			ability:GetAbilityTargetFlags(), 
			FIND_ANY_ORDER, false
		)

		for _,enemy in pairs(enemy_list) do
			local postDmg = ApplyDamage({
				victim = enemy, 
				attacker = caster, 
				damage = damage, 
				damage_type = ability:GetAbilityDamageType()
			})

			enemy:AddNewModifier(caster, ability, modifier_debuff_name, {duration = duration})
		end


		self:_PlayEffect()
		self:_CheckTalent()
	end


	function ability_class:_PlayEffect( )
		local ability = self
		local caster = self:GetCaster()

		local particle_cast = "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf"

		-- get data
		local slow_radius = GetTalentSpecialValueFor(ability, "shock_radius")

		-- play particles
		local nFXIndex = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, caster:GetOrigin() )
		ParticleManager:SetParticleControlForward( nFXIndex, 0, caster:GetForwardVector() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector(slow_radius/2, slow_radius/2, slow_radius/2) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		EmitSoundOn("Hero_Ursa.Earthshock", caster)
	end

	function ability_class:_CheckTalent( )
		local ability = self
		local caster = self:GetCaster()
		local base_radius = self:GetSpecialValueFor('shock_radius')
		local modifier_talent_name = 'modifier_mjz_ursa_earthshock_talent_radius'
		local talent_value = 600
	
		if not caster:HasModifier(modifier_talent_name) then
			local radius = GetTalentSpecialValueFor(ability, "shock_radius")
			if radius > base_radius then
				caster:AddNewModifier(caster, ability, modifier_talent_name, {})
			end
		end
	end
end



---------------------------------------------------------------------------------------

modifier_mjz_ursa_earthshock = class({})
local modifier_class = modifier_mjz_ursa_earthshock

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return true end
function modifier_class:IsDebuff() return true end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
	return funcs
end

function modifier_class:GetModifierMoveSpeedBonus_Percentage( )
	return self:GetAbility():GetSpecialValueFor('movement_slow')
end

-----------------------------------------------------------------------------------------


modifier_mjz_ursa_earthshock_talent_radius = class({})
function modifier_mjz_ursa_earthshock_talent_radius:IsHidden() return true end
function modifier_mjz_ursa_earthshock_talent_radius:IsPurgable() return false end

-----------------------------------------------------------------------------------------

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