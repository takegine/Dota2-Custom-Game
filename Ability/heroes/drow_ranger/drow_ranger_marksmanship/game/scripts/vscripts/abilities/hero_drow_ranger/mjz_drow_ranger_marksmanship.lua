
local MODIFIER_INIT_NAME = 'modifier_mjz_drow_ranger_marksmanship'
local MODIFIER_THINKER_NAME = 'modifier_mjz_drow_ranger_marksmanship_thinker'

LinkLuaModifier(MODIFIER_INIT_NAME,"abilities/hero_drow_ranger/mjz_drow_ranger_marksmanship.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_THINKER_NAME,"modifiers/hero_drow_ranger/modifier_mjz_drow_ranger_marksmanship_thinker.lua", LUA_MODIFIER_MOTION_NONE)

---------------------------------------------------------------------------------------

mjz_drow_ranger_marksmanship = class({})
local ability_class = mjz_drow_ranger_marksmanship

function ability_class:GetIntrinsicModifierName()
	return MODIFIER_INIT_NAME
end

if IsServer() then
    function ability_class:OnProjectileHit(target, location)
		if target and target:IsAlive() then
            local caster = self:GetCaster()
			if caster:HasScepter() and caster:IsRangedAttacker() then
				local damage_reduction = self:GetSpecialValueFor("damage_reduction_scepter")
				local damage = caster:GetAverageTrueAttackDamage(target) * (damage_reduction / 100.0)

				ApplyDamage({
					ability = self,
					attacker = caster,
					victim = target,				
					damage = damage,
					damage_type = DAMAGE_TYPE_PHYSICAL,
				})
			end
        end

        return true
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_drow_ranger_marksmanship = class({})
local modifier_class = modifier_mjz_drow_ranger_marksmanship

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_EVENT_ON_ATTACK,			
	}
	return funcs
end

function modifier_class:GetModifierBonusStats_Agility( )
	return self:GetAbility():GetSpecialValueFor('bonus_agility')
end

function modifier_class:OnAttack(keys)
	if IsServer() then
		self:_OnAttack(keys)
	end
end

if IsServer() then
	function modifier_class:OnCreated(table)
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local parent = self:GetParent()
		parent:AddNewModifier(caster, ability, MODIFIER_THINKER_NAME, {})
	end
	
	function modifier_class:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveModifierByName(MODIFIER_THINKER_NAME)
	end
	
	function modifier_class:_OnAttack(keys)
		if keys.attacker ~= self:GetParent() then return nil end
		if keys.target:IsBuilding() then return nil end
		if not self:GetParent():HasScepter() then return nil end
		if not self:GetParent():IsRangedAttacker() then return nil end
		if self:GetParent():PassivesDisabled() then return nil end
		if TargetIsFriendly(self:GetParent(), keys.target) then return nil end

        local attacker = keys.attacker
		local target = keys.target
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local arrow_speed = ability:GetSpecialValueFor('arrow_speed_scepter')
		local split_count = ability:GetSpecialValueFor('split_count_scepter')
		local split_range = ability:GetSpecialValueFor('split_range_scepter')
		

		local projectile_name = "particles/units/heroes/hero_drow/drow_base_attack.vpcf"
		local max_targets = split_count
		local enemy_list = FindTargetEnemy(caster, target:GetAbsOrigin(), split_range)
		
		for _,enemy in pairs(enemy_list) do
			if enemy ~= target then
				local projectile_info = {
					EffectName = projectile_name,
					Ability = ability,
					vSpawnOrigin = caster:GetAbsOrigin(),
					Target = enemy,
					Source = caster,
					bHasFrontalCone = false,
					iMoveSpeed = arrow_speed,
					bReplaceExisting = false,
					bProvidesVision = false
				}
				ProjectileManager:CreateTrackingProjectile(projectile_info)
				max_targets = max_targets - 1
			end
			if max_targets == 0 then break end
		end

	end	

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

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(caster, point, radius)
    local iTeamNumber = caster:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
	local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
	-- 仅针对可见的单位、忽视建筑物、支持魔法免疫
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE   
	local iOrder = FIND_CLOSEST                         -- 寻找最近的
	iOrder = FIND_ANY_ORDER								-- 随机寻找
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end

function TargetIsFriendly(caster, target )
	local nTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY 	-- ability:GetAbilityTargetTeam()
	local nTargetType = DOTA_UNIT_TARGET_ALL 			-- ability:GetAbilityTargetType()
	local nTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE		-- ability:GetAbilityTargetFlags()
	local nTeam = caster:GetTeamNumber()
	local ufResult = UnitFilter(target, nTargetTeam, nTargetType, nTargetFlags, nTeam)
	return ufResult == UF_SUCCESS
end