LinkLuaModifier("modifier_mjz_clinkz_death_pact","abilities/hero_clinkz/mjz_clinkz_death_pact.lua", LUA_MODIFIER_MOTION_NONE)

mjz_clinkz_death_pact = class({})
local ability_class = mjz_clinkz_death_pact

-- function ability_class:GetIntrinsicModifierName()
-- 	return "modifier_mjz_clinkz_death_pact"
-- end

-- function ability_class:GetCooldown(iLevel)
--     -- return self:GetSpecialValueFor("cooldown")
--     return self.BaseClass.GetCooldown(self, iLevel)
-- end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local duration = ability:GetSpecialValueFor('duration')

		local modifier_name = 'modifier_mjz_clinkz_death_pact'

		local modifier = caster:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
			modifier:ForceRefresh()
		else
			caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
		end

		caster:EmitSound("Hero_Clinkz.DeathPact.Cast")
	end
end



---------------------------------------------------------------------------------------

modifier_mjz_clinkz_death_pact = class({})
local modifier_class = modifier_mjz_clinkz_death_pact

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,			-- 按百分比修改攻击力，负数降低攻击，正数提高攻击
		MODIFIER_PROPERTY_HEALTH_BONUS,							-- 修改目前血量
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,					-- 增加护甲
		MODIFIER_PROPERTY_MODEL_SCALE,							-- 设定模型大小
	}
	return funcs
end

function modifier_class:GetModifierDamageOutgoing_Percentage( )
	return self:GetAbility():GetSpecialValueFor('bonus_damage_pct')
end

function modifier_class:GetModifierHealthBonus( )
	return self:GetAbility():GetSpecialValueFor('bonus_health')
end

function modifier_class:GetModifierPhysicalArmorBonus( )
	return self:GetAbility():GetSpecialValueFor('armor_reduction')
end

function modifier_class:GetModifierModelScale( )
	return self:GetAbility():GetSpecialValueFor('model_scale')
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