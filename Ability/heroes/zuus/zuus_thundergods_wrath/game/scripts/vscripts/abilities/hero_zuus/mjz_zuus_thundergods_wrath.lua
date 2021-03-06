-- LinkLuaModifier("modifier_mjz_zuus_thundergods_wrath", "abilities/hero_zuus/mjz_zuus_thundergods_wrath.lua", LUA_MODIFIER_MOTION_NONE)

mjz_zuus_thundergods_wrath = class({})
local ability_class = mjz_zuus_thundergods_wrath

-- function ability_class:GetIntrinsicModifierName()
-- 	return "modifier_mjz_zuus_thundergods_wrath"
-- end

function ability_class:GetAOERadius()
	return self:GetSpecialValueFor('radius')
end

function ability_class:OnAbilityPhaseStart()
	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( self.nFXIndex, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true );
		ParticleManager:SetParticleControlEnt( self.nFXIndex, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true );
		EmitSoundOn( "Hero_Zuus.GodsWrath.PreCast", self:GetCaster() )
	end

	return true
end

function ability_class:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nFXIndex, true )
	end
end

function ability_class:OnSpellStart()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self

		-- local sight_radius = ability:GetSpecialValueFor("sight_radius")
		-- local sight_duration = ability:GetSpecialValueFor("sight_duration")
		
		EmitSoundOn("Hero_Zuus.GodsWrath.PreCast", caster)

		EmitSoundOn("Hero_Zuus.GodsWrath", caster)
		local p_name = "particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_bolt_parent.vpcf"
		local p_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(p_index, 1, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(p_index)

		-- AddFOWViewer(caster:GetTeam(), caster:GetAbsOrigin(), sight_radius, sight_duration, false)

		self:_ApplyDamage()
	end
end

if IsServer() then
	function ability_class:_ApplyDamage(target)
		local caster = self:GetCaster()
		local ability = self

		local radius = ability:GetSpecialValueFor('radius')
		local base_damage = ability:GetSpecialValueFor("base_damage")
		local intelligence_damage = GetTalentSpecialValueFor(ability, "intelligence_damage")
		local damage = base_damage + caster:GetIntellect() * (intelligence_damage / 100.0)

		local sound_name = "Hero_Zuus.GodsWrath.Target"
		
		local units = FindTargetEnemy(caster, caster:GetAbsOrigin(), radius)
		for _,unit in pairs(units) do
			ApplyEffect2(caster, unit)

			EmitSoundOn(sound_name, unit)

			ApplyDamage({
				attacker = caster,
				victim = unit,
				ability = ability,
				damage_type = ability:GetAbilityDamageType(),
				damage = damage
			})	
		end
	end

	function ApplyEffect(caster, target)
		local p_name = "particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf"

      	local p_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, target)
    	ParticleManager:SetParticleControl(p_index, 0, target:GetAbsOrigin())
      	ParticleManager:SetParticleControl(p_index, 1, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, 2000))
		ParticleManager:SetParticleControl(p_index, 2, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(p_index)
	end

	function ApplyEffect2(caster, target)
		local p_name = "particles/units/heroes/hero_zuus/zuus_thundergods_wrath.vpcf"
		local p_index = ParticleManager:CreateParticle(p_name, PATTACH_WORLDORIGIN, target)
		ParticleManager:SetParticleControl(p_index, 0, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
		ParticleManager:SetParticleControl(p_index, 1, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, 2000))
		ParticleManager:SetParticleControl(p_index, 2, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
		ParticleManager:ReleaseParticleIndex(p_index)
	end

end

-----------------------------------------------------------------------------------------

modifier_mjz_zuus_thundergods_wrath = class({})
local modifier_class = modifier_mjz_zuus_thundergods_wrath

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
	function modifier_class:OnCreated()
		local parent = self:GetParent()
		local ability = self:GetAbility()
	end

	function modifier_class:DeclareFunctions()
		return {
		}
	end

end

-----------------------------------------------------------------------------------------

-- True sight debuff
modifier_true_sight = class({})

function modifier_true_sight:IsHidden() return true end
function modifier_true_sight:IsPurgable() return false end
function modifier_true_sight:IsDebuff() return true end

function modifier_true_sight:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = false,
	}				   
	return state	
end

function modifier_true_sight:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end


-----------------------------------------------------------------------------------------
-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(caster, point, radius)
	local iTeamNumber = caster:GetTeamNumber()
	local vPosition = point					-- 搜索中心点
	local hCacheUnit = nil                  -- 通常值
	local flRadius = radius                 -- 搜索范围
	local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
	-- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
	local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE -- 忽视建筑物
	local iOrder = FIND_CLOSEST                         -- 寻找最近的
	iOrder = FIND_ANY_ORDER								-- 随机
	local bCanGrowCache = false             -- 通常值
	return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
		flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
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

