LinkLuaModifier("modifier_mjz_morphling_replicate","abilities/hero_morphling/mjz_morphling_replicate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_morphling_replicate_strength","abilities/hero_morphling/mjz_morphling_replicate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_morphling_replicate_agility","abilities/hero_morphling/mjz_morphling_replicate.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_morphling_replicate_intellect","abilities/hero_morphling/mjz_morphling_replicate.lua", LUA_MODIFIER_MOTION_NONE)

mjz_morphling_replicate = class({})
local ability_class = mjz_morphling_replicate

-- function ability_class:GetIntrinsicModifierName()
-- 	return "modifier_mjz_morphling_replicate"
-- end

-- function ability_class:GetCooldown(iLevel)
--     -- return self:GetSpecialValueFor("cooldown")
--     return self.BaseClass.GetCooldown(self, iLevel)
-- end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local duration = GetTalentSpecialValueFor(ability, 'duration')
		local bonus_stats_pct = GetTalentSpecialValueFor(ability, 'bonus_stats_pct')


		local modifier_name = 'modifier_mjz_morphling_replicate'
		local modifier_name_strength = 'modifier_mjz_morphling_replicate_strength'
		local modifier_name_agility = 'modifier_mjz_morphling_replicate_agility'
		local modifier_name_intellect = 'modifier_mjz_morphling_replicate_intellect'

		self:_AddModifier(modifier_name, duration)
		self:_AddModifier(modifier_name_strength, duration)
		self:_AddModifier(modifier_name_agility, duration)
		self:_AddModifier(modifier_name_intellect, duration)

		--------------------------------------------------------------------------
		local iCount = 0
		local modifier_strength = caster:FindModifierByName(modifier_name_strength)
		if modifier_strength then
			modifier_strength:SetStackCount(0)
			iCount = target:GetStrength() * (bonus_stats_pct / 100.0)
			modifier_strength:SetStackCount(iCount)
		end

		local modifier_agility = caster:FindModifierByName(modifier_name_agility)
		if modifier_agility then
			modifier_agility:SetStackCount(0)
			iCount = target:GetAgility() * (bonus_stats_pct / 100.0)
			modifier_agility:SetStackCount(iCount)
		end

		local modifier_intellect = caster:FindModifierByName(modifier_name_intellect)
		if modifier_intellect then
			modifier_intellect:SetStackCount(0)
			iCount = target:GetIntellect() * (bonus_stats_pct / 100.0)
			modifier_intellect:SetStackCount(iCount)
		end
		--------------------------------------------------------------------------


		caster:EmitSound("Hero_Morphling.Replicate")
	end

	function ability_class:_AddModifier(modifier_name, duration)
		local ability = self
		local caster = self:GetCaster()

		local modifier = caster:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
			modifier:ForceRefresh()
		else
			caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
		end
	end
end



---------------------------------------------------------------------------------------

modifier_mjz_morphling_replicate = class({})
local modifier_class = modifier_mjz_morphling_replicate

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE,							-- 设定模型大小
	}
	return funcs
end
function modifier_class:GetModifierAttackRangeBonus( )
	return self:GetAbility():GetSpecialValueFor('bonus_attack_range')
end
function modifier_class:GetModifierModelScale( )
	return self:GetAbility():GetSpecialValueFor('model_scale')
end

if IsServer() then
	function modifier_class:OnDestroy( )
		local parent = self:GetParent()
		parent:EmitSound("Hero_Morphling.ReplicateEnd")		
	end
end



modifier_mjz_morphling_replicate_strength = class({})
local modifier_strength = modifier_mjz_morphling_replicate_strength
function modifier_strength:IsHidden() return true end
function modifier_strength:IsPurgable() return false end
function modifier_strength:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end
function modifier_strength:GetModifierBonusStats_Strength( )
	return self:GetStackCount()
end

modifier_mjz_morphling_replicate_agility = class({})
local modifier_agility = modifier_mjz_morphling_replicate_agility
function modifier_agility:IsHidden() return true end
function modifier_agility:IsPurgable() return false end
function modifier_agility:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end
function modifier_agility:GetModifierBonusStats_Agility( )
	return self:GetStackCount()
end

modifier_mjz_morphling_replicate_intellect = class({})
local modifier_intellect = modifier_mjz_morphling_replicate_intellect
function modifier_intellect:IsHidden() return true end
function modifier_intellect:IsPurgable() return false end
function modifier_intellect:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end
function modifier_intellect:GetModifierBonusStats_Intellect( )
	return self:GetStackCount()
end

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