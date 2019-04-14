LinkLuaModifier("modifier_generic_orb_effect_lua", "modifiers/hero_templar_assassin/modifier_generic_orb_effect_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_templar_assassin_proficiency_debuff", "modifiers/hero_templar_assassin/modifier_mjz_templar_assassin_proficiency_debuff.lua", LUA_MODIFIER_MOTION_NONE)

mjz_templar_assassin_proficiency = class({})
local ability_class = mjz_templar_assassin_proficiency

function ability_class:IsRefreshable() return true end
function ability_class:IsStealable() return false end	-- 是否可以被法术偷取。

--[[
	function ability_class:GetAOERadius() return 600 end
	function ability_class:GetCastRange(vLocation, hTarget)
		-- return self.BaseClass.GetCastRange(self, vLocation, hTarget) end 
		return 600
	end
]]

function ability_class:GetIntrinsicModifierName()
    return "modifier_generic_orb_effect_lua"
end

function ability_class:OnAbilityPhaseStart()
	if IsServer() then
		local target = self:GetCursorTarget()
		if target then
			-- self.overrideAutocast = true
			-- self:GetCaster():MoveToTargetToAttack(target)
		end
	end
end

--------------------------------------------------------------------------------
-- Orb Effects
function ability_class:GetProjectileName()
	return "particles/units/heroes/hero_templar_assassin/templar_assassin_meld_attack.vpcf"
end

function ability_class:OnOrbFire( params )
	local ability = self
	local caster = self:GetCaster()
	local target = params.target
	-- play effects
	-- EmitSoundOn('Hero_TemplarAssassin.Meld.Attack', target)
end

function ability_class:OnOrbImpact( params )
	local ability = self
	local caster = self:GetCaster()
	local target = params.target

	local armor_reduction_duration = ability:GetSpecialValueFor("armor_reduction_duration")
	local armor_reduction_percent = ability:GetSpecialValueFor("armor_reduction_percent")
	local modifier_name = "modifier_mjz_templar_assassin_proficiency_debuff"
	
	local modifier = target:FindModifierByName(modifier_name)
	if modifier then 
		modifier:SetDuration(armor_reduction_duration, true)
		modifier:ForceRefresh()
	else
		local modifier_table = { 
			duration = armor_reduction_duration,
			armor_reduction_percent = armor_reduction_percent,
		} 
		target:AddNewModifier(caster, ability, modifier_name, modifier_table)
	end
	
end
