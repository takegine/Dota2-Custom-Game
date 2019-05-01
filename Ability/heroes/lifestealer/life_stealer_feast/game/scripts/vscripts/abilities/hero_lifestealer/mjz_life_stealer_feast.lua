LinkLuaModifier("modifier_mjz_life_stealer_feast", "abilities/hero_lifestealer/mjz_life_stealer_feast.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_life_stealer_feast_damage", "abilities/hero_lifestealer/mjz_life_stealer_feast.lua", LUA_MODIFIER_MOTION_NONE)

mjz_life_stealer_feast = class({})
local ability_class = mjz_life_stealer_feast

function ability_class:GetIntrinsicModifierName()
    return "modifier_mjz_life_stealer_feast"
end

---------------------------------------------------------------------------------------

modifier_mjz_life_stealer_feast = class({})
local modifier_class = modifier_mjz_life_stealer_feast

function modifier_class:IsPassive() return true end
function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

if IsServer() then
    function modifier_class:DeclareFunctions() 
        return {
            MODIFIER_EVENT_ON_ATTACK_START,
            MODIFIER_EVENT_ON_ATTACK,
            -- MODIFIER_EVENT_ON_ATTACK_LANDED,
        } 
    end

    function modifier_class:OnAttackStart(keys)
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target
        local m_name = 'modifier_mjz_life_stealer_feast_damage'

        if parent:HasModifier(m_name) then
            parent:RemoveModifierByName(m_name)           
        end

        if attacker ~= parent or attacker:PassivesDisabled() or attacker:IsIllusion() then return end
        if target:IsBuilding() then return nil end
        if target:GetTeam() == attacker:GetTeam() then return nil end

        parent:AddNewModifier(caster, ability, m_name, {})
    end

    function modifier_class:OnAttack(keys)
        local attacker = keys.attacker
        local target = keys.target
        -- local damage = keys.damage
        local parent = self:GetParent()
        local ability = self:GetAbility()

        if attacker ~= parent or attacker:PassivesDisabled() or attacker:IsIllusion() then return end
        if target:IsBuilding() then return nil end
        if target:GetTeam() == attacker:GetTeam() then return nil end

        local str_damage_pct = GetTalentSpecialValueFor(ability, "str_damage_pct")
        local damage = parent:GetStrength() * (str_damage_pct / 100.0)
        attacker:Heal(damage, ability)

        local p_name = "particles/generic_gameplay/generic_lifesteal.vpcf"
        local p_index = ParticleManager:CreateParticle(p_name, PATTACH_ABSORIGIN_FOLLOW, attacker)
        ParticleManager:ReleaseParticleIndex(p_index)
    end
    
    function modifier_class:OnAttackLanded(keys)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local attacker = keys.attacker
        local target = keys.target
    end
end

---------------------------------------------------------------------------------------

modifier_mjz_life_stealer_feast_damage = class({})
local modifier_damage = modifier_mjz_life_stealer_feast_damage

function modifier_damage:IsHidden() return true end
function modifier_damage:IsPurgable() return false end
function modifier_damage:IsBuff() return true end

function modifier_damage:DeclareFunctions() 
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    } 
end
function modifier_damage:GetModifierPreAttack_BonusDamage() 
    
    return self:GetStackCount()
end

function modifier_damage:OnAttackLanded(keys)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    self:Destroy()
end

if IsServer() then
    function modifier_damage:OnCreated(table)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local str_damage_pct = GetTalentSpecialValueFor(ability, "str_damage_pct")

        local damage = parent:GetStrength() * (str_damage_pct / 100.0)
        self:SetStackCount(damage)
    end
end

---------------------------------------------------------------------------------------

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