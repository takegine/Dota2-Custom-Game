LinkLuaModifier("modifier_mjz_night_stalker_hunter_in_the_night","abilities/hero_night_stalker/mjz_night_stalker_hunter_in_the_night.lua", LUA_MODIFIER_MOTION_NONE)

mjz_night_stalker_hunter_in_the_night = class({})
local ability_class = mjz_night_stalker_hunter_in_the_night

function ability_class:GetIntrinsicModifierName()
	return "modifier_mjz_night_stalker_hunter_in_the_night"
end


---------------------------------------------------------------------------------------

modifier_mjz_night_stalker_hunter_in_the_night = class({})
local modifier_class = modifier_mjz_night_stalker_hunter_in_the_night

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,	
	}
	return funcs
end

function modifier_class:GetModifierMoveSpeedBonus_Percentage( )
	return self:GetAbility():GetSpecialValueFor('bonus_movement_speed_pct')
end

function modifier_class:GetModifierAttackSpeedBonus_Constant( )
	-- return self:GetAbility():GetSpecialValueFor('bonus_attack_speed')
	if IsServer() then
		local statck_count = GetTalentSpecialValueFor(self:GetAbility(), 'bonus_attack_speed')
		if self:GetStackCount() ~= statck_count then
			self:SetStackCount(statck_count)
		end
	end
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