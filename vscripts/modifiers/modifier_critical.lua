--[[
	暴击效果
]]
modifier_critical = class({})

function modifier_critical:IsHidden() return true end
function modifier_critical:IsPurgable() return false end

if IsServer() then
    function modifier_critical:DeclareFunctions()
        local func = {
            MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        }
        return func
    end

    function modifier_critical:GetModifierPreAttack_CriticalStrike()
        local crit_chance = self:GetAbility():GetSpecialValueFor("crit_chance")
        local crit_bonus = self:GetAbility():GetSpecialValueFor("crit_bonus")
        if RollPercentage(crit_chance) then
            return crit_bonus
        end
    end
end