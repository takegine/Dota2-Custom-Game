LinkLuaModifier("modifier_mjz_doom_bringer_devour","modifiers/hero_doom_bringer/modifier_mjz_doom_bringer_devour.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_doom_bringer_devour_regen","modifiers/hero_doom_bringer/modifier_mjz_doom_bringer_devour.lua", LUA_MODIFIER_MOTION_NONE)

mjz_doom_bringer_devour = class({})
local ability_class = mjz_doom_bringer_devour


function ability_class:GetIntrinsicModifierName()
    return "modifier_mjz_doom_bringer_devour"
end

if IsServer() then
	function ability_class:OnSpellStart()
		local ability = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local devour_time = ability:GetSpecialValueFor("devour_time")
		local bonus_strength = GetTalentSpecialValueFor(ability, "bonus_strength")
		if target then
			EmitSoundOn("Hero_DoomBringer.DevourCast", caster)

			local p_name = "particles/units/heroes/hero_doom_bringer/doom_bringer_devour.vpcf"
			local pfx = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster)
    		ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_origin", target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx)
			
			EmitSoundOn("Hero_DoomBringer.Devour", target)

			local modifier = caster:FindModifierByName('modifier_mjz_doom_bringer_devour')
			modifier:SetStackCount(modifier:GetStackCount() + bonus_strength)

			caster:AddNewModifier(caster, ability, 'modifier_mjz_doom_bringer_devour_regen', {duration = devour_time})
		end
	end
end

-----------------------------------------------------------------------------



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