
local THIS_LUA = "abilities/hero_windrunner/mjz_windrunner_focusfire.lua"
local MODIFIER_CASTER_NAME = 'modifier_mjz_windrunner_focusfire' 
local MODIFIER_BUFF_NAME = 'modifier_mjz_windrunner_focusfire_attackspeed_buff' 
local MODIFIER_DEBUFF_NAME = 'modifier_mjz_windrunner_focusfire_damage_debuff' 

LinkLuaModifier(MODIFIER_CASTER_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_BUFF_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier(MODIFIER_DEBUFF_NAME, THIS_LUA, LUA_MODIFIER_MOTION_NONE)


mjz_windrunner_focusfire = class({})
local ability_class = mjz_windrunner_focusfire

function ability_class:GetCastRange(vLocation, hTarget)
	-- return self.BaseClass.GetCastRange(self, vLocation, hTarget) 
	return self:GetCaster():Script_GetAttackRange()
end


function ability_class:GetCooldown(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor('cooldown_scepter')
	end
    return self.BaseClass.GetCooldown(self, iLevel)
end

if IsServer() then
	function ability_class:OnSpellStart( )
		local ability = self
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local duration = ability:GetSpecialValueFor('duration')

		ability.focusfire_target = target

		local modifier_name = MODIFIER_CASTER_NAME
		local modifier = caster:FindModifierByName(modifier_name)
		if modifier then
			modifier:SetDuration(duration, true)
			modifier:ForceRefresh()
		else
			caster:AddNewModifier(caster, ability, modifier_name, {duration = duration})
		end

		local order = {
			UnitIndex = caster:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = target:entindex()
		}
		ExecuteOrderFromTable( order )

		EmitSoundOn("Ability.Focusfire", caster)
	end
end



---------------------------------------------------------------------------------------

modifier_mjz_windrunner_focusfire = class({})
local modifier_class = modifier_mjz_windrunner_focusfire

function modifier_class:IsPassive() return false end
function modifier_class:IsHidden() return false end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:DeclareFunctions() 
        return {
            MODIFIER_EVENT_ON_ATTACK_START,
            -- MODIFIER_EVENT_ON_ATTACK,
            MODIFIER_EVENT_ON_ATTACK_LANDED,
        } 
    end

    function modifier_class:OnAttackStart(keys)
        if keys.attacker ~= self:GetParent() then return nil end

		local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker
		local target = keys.target
		
		self.last_attack_target = target
		self.last_attack_time = GameRules:GetGameTime()

		self:_OnAttackTarget(target)
    end

    function modifier_class:OnAttack(keys)
        if keys.attacker ~= self:GetParent() then return nil end
        local attacker = keys.attacker
        local target = keys.target
        -- local damage = keys.damage
        local parent = self:GetParent()
		local ability = self:GetAbility()
		
    end
    
    function modifier_class:OnAttackLanded(keys)
        if keys.attacker ~= self:GetParent() then return nil end
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker
		local target = keys.target
		
		self:_OnAttackTarget(target)
		self:_MiniStunTarget(target)
	end

	function modifier_class:OnCreated(  )
		self.last_attack_target = nil
		self.last_attack_time = 0
		self.on_PerformAttack = false
		self:StartIntervalThink(0.05)
	end

	function modifier_class:OnRefresh(table)
		local parent = self:GetParent()
		ForceRefreshModifier(parent, MODIFIER_BUFF_NAME)
		ForceRefreshModifier(parent, MODIFIER_DEBUFF_NAME)
	end

	function modifier_class:OnIntervalThink()
        local parent = self:GetParent()
		local ability = self:GetAbility()
		local target = ability.focusfire_target
		local can_PerformAttack = false
		-- local target_in_nearby = self:_TargetInNearby()

		if self.on_PerformAttack then
			if self.last_attack_target ~= ability.focusfire_target then
				can_PerformAttack = false
			end
		else
			if (GameRules:GetGameTime() - self.last_attack_time) > 0.25 then
				can_PerformAttack = self:_TargetInNearby()
			end
		end

		if can_PerformAttack then
			self.on_PerformAttack = true
			parent:PerformAttack (
				target,     			-- handle hTarget 
				true,       			-- bool bProcessProcs,		
				true,     				-- bool bUseCastAttackOrb, 	是否使用攻击法球、特效
				false,       			-- bool bSkipCooldown		是否跳过攻击间隔
				true,      				-- bool bIgnoreInvis		是否忽略隐形单位
				true,      				-- bool bUseProjectile		是否使用攻击投射物
				false,      			-- bool bFakeAttack			
				false      				-- bool bNeverMiss			是否不会Miss
			)
		else
			self.on_PerformAttack = false
		end
		
	end
	
	function modifier_class:OnDestroy()
		local caster = self:GetCaster()
        local parent = self:GetParent()
		local ability = self:GetAbility()
		parent:RemoveModifierByName(MODIFIER_BUFF_NAME)
		parent:RemoveModifierByName(MODIFIER_DEBUFF_NAME)
	end

	function modifier_class:_OnAttackTarget( target )
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		
		if target ~= ability.focusfire_target then
			RemoveModifierByName(parent, MODIFIER_BUFF_NAME)
			RemoveModifierByName(parent, MODIFIER_DEBUFF_NAME)
		else
			if not parent:HasModifier(MODIFIER_BUFF_NAME) then
				parent:AddNewModifier(caster, ability, MODIFIER_BUFF_NAME, {})
			end
			if not parent:HasModifier(MODIFIER_DEBUFF_NAME) then
				parent:AddNewModifier(caster, ability, MODIFIER_DEBUFF_NAME, {})
			end
		end
	end

	function modifier_class:_MiniStunTarget( target )
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local ministun_chance = GetTalentSpecialValueFor(ability, 'ministun_chance')
		local ministun_duration = GetTalentSpecialValueFor(ability, 'ministun_duration')
		
		if target == ability.focusfire_target then
			if RollPercentage(ministun_chance) then
				-- Add stun modifier (system)
				target:AddNewModifier(parent, ability, "modifier_stunned", {duration = ministun_duration})
			end
		end
	end

	function modifier_class:_TargetInNearby( )
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local target = ability.focusfire_target

		local radius = parent:Script_GetAttackRange()
		local enemies = FindUnitsInRadius(
			parent:GetTeamNumber(),
			parent:GetAbsOrigin(),
			nil, radius,
			ability:GetAbilityTargetTeam(),
			ability:GetAbilityTargetType(),
			ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false
		)
		for _,enemy in pairs(enemies) do
			if enemy == target then
				return true
			end
		end
		return false
	end
end


---------------------------------------------------------------------------------------

modifier_mjz_windrunner_focusfire_attackspeed_buff = class({})
local modifier_buff = modifier_mjz_windrunner_focusfire_attackspeed_buff

function modifier_buff:IsHidden() return true end
function modifier_buff:IsPurgable() return false end

function modifier_buff:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	} 
end

function modifier_buff:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetStackCount()
end

if IsServer() then
	function modifier_buff:OnCreated(table)
		self:OnRefresh(table)
	end
	function modifier_buff:OnRefresh(table)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local bonus_attack_speed = ability:GetSpecialValueFor('bonus_attack_speed')
		self:SetStackCount(bonus_attack_speed)
	end
end

---------------------------------------------------------------------------------------

modifier_mjz_windrunner_focusfire_damage_debuff = class({})
local modifier_debuff = modifier_mjz_windrunner_focusfire_damage_debuff

function modifier_debuff:IsHidden() return true end
function modifier_debuff:IsPurgable() return false end

function modifier_debuff:DeclareFunctions() 
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	} 
end

function modifier_debuff:GetModifierDamageOutgoing_Percentage(  )
	return self:GetStackCount()
end

if IsServer() then
	function modifier_debuff:OnCreated(table)
		self:OnRefresh(table)
	end

	function modifier_debuff:OnRefresh(table)
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage_reduction = ability:GetSpecialValueFor('damage_reduction')
		local damage_reduction_scepter = ability:GetSpecialValueFor('damage_reduction_scepter')
		if caster:HasScepter() then
			self:SetStackCount(damage_reduction_scepter)
		else
			self:SetStackCount(damage_reduction)
		end
	end
end


-----------------------------------------------------------------------------------------

function ForceRefreshModifier( unit, modifier_name )
	if unit then
		local m = unit:FindModifierByName(modifier_name)
		if m then m:ForceRefresh() end
	end
end

function NewModifierByName(unit, modifier_name )
	if unit and IsValidEntity(unit) then
		if unit:HasModifier(modifier_name) then
			unit:RemoveModifierByName(modifier_name)
		end
	end
end

function RemoveModifierByName(unit, modifier_name )
	if unit and IsValidEntity(unit) then
		if unit:HasModifier(modifier_name) then
			unit:RemoveModifierByName(modifier_name)
		end
	end
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