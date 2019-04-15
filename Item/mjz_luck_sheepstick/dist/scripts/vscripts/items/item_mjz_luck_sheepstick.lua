LinkLuaModifier("modifier_item_mjz_luck_sheepstick","items/item_mjz_luck_sheepstick.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mjz_luck_sheepstick_target","items/item_mjz_luck_sheepstick.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mjz_luck_sheepstick_model_change","items/item_mjz_luck_sheepstick.lua", LUA_MODIFIER_MOTION_NONE)

local DEFAULT_MODEL = "models/props_gameplay/frog.vmdl"
local MODEL_LIST = {
    "models/props_gameplay/frog.vmdl",
    "models/props_gameplay/chicken.vmdl",
    "models/props_gameplay/pig.vmdl",
    "models/items/hex/sheep_hex/sheep_hex.vmdl",
    "models/items/hex/sheep_hex/sheep_hex_gold.vmdl",
    "models/items/hex/fish_hex/fish_hex.vmdl",
}


----------------------------------------------------------------------------------------

item_mjz_luck_sheepstick = class({})
local item_class = item_mjz_luck_sheepstick

function item_class:GetAOERadius()
    return self:GetSpecialValueFor('cast_range')
end

function item_class:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor('cast_range')
end

function item_class:GetIntrinsicModifierName()
    return 'modifier_item_mjz_luck_sheepstick'
end

if IsServer() then

    function item_class:OnSpellStart()
        local ability = self
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        local modifier_target = "modifier_item_mjz_luck_sheepstick_target"
        local duration = ability:GetSpecialValueFor("sheep_duration")
        local sheep_chance = ability:GetSpecialValueFor("sheep_chance")
        local chance_scepter = ability:GetSpecialValueFor("chance_scepter")
        
        if caster:HasScepter() then     -- 有神杖时，增加成功几率
            sheep_chance = sheep_chance + chance_scepter
        end

        local ability_target = nil
        if RollPercentage(sheep_chance) then
            ability_target = target            
        else
            ability_target = caster
        end

        if ability_target:IsIllusion() then
            ability_target:ForceKill(true)
        else
            ability_target:AddNewModifier(caster, ability, modifier_target, {duration = duration})
        end

        -- EmitSoundOn("Hero_Lion.Voodoo", ability_target)
        EmitSoundOn("DOTA_Item.Sheepstick.Activate", ability_target)
        -- EmitSoundOn("Hero_Lion.Hex.Target", ability_target)
    end
    
end

----------------------------------------------------------------------------------------

modifier_item_mjz_luck_sheepstick = class({})
local modifier_class = modifier_item_mjz_luck_sheepstick

function modifier_class:IsHidden() return true end
function modifier_class:IsPurgable() return false end

function modifier_class:GetAttributes()
	return {
		MODIFIER_ATTRIBUTE_MULTIPLE,
	}
end

function modifier_class:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,		
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,	
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,		
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,		
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
	}
end

function modifier_class:GetModifierBonusStats_Strength( )
    return self:GetAbility():GetSpecialValueFor('bonus_strength')
end
function modifier_class:GetModifierBonusStats_Agility( )
    return self:GetAbility():GetSpecialValueFor('bonus_agility')
end
function modifier_class:GetModifierBonusStats_Intellect( )
    return self:GetAbility():GetSpecialValueFor('bonus_intellect')
end
function modifier_class:GetModifierConstantManaRegen( )
    return self:GetAbility():GetSpecialValueFor('bonus_mana_regen')
end
function modifier_class:GetModifierConstantHealthRegen( )
    return self:GetAbility():GetSpecialValueFor('bonus_health_regen')
end

----------------------------------------------------------------------------------------

modifier_item_mjz_luck_sheepstick_target = class({})
local modifier_target = modifier_item_mjz_luck_sheepstick_target

function modifier_target:IsHidden() return false end
function modifier_target:IsPurgable() return true end

function modifier_target:GetTexture()
    return 'item_mjz_luck_sheepstick'
end

function modifier_target:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_HEXED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_EVADE_DISABLED] = true,
        [MODIFIER_STATE_BLOCK_DISABLED] = true,
        [MODIFIER_STATE_SILENCED] = true,
    }
end

function modifier_target:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
end

function modifier_target:GetModifierMoveSpeed_Absolute( params )
    return self:GetAbility():GetSpecialValueFor('sheep_movement_speed')
end

function modifier_target:GetEffectName()
    return "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"
end
function modifier_target:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
    function modifier_target:OnCreated(table)
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local caster = self:GetCaster()

        self.modifier_name = 'modifier_item_mjz_luck_sheepstick_model_change'

        local model_index = math.random( #MODEL_LIST )

        parent:AddNewModifier(caster, ability, self.modifier_name, {model_index = model_index})
        -- parent:SetModifierStackCount(self.modifier_name, caster, model_index)

    end

    function modifier_target:OnDestroy()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        local caster = self:GetCaster()

        parent:RemoveModifierByName(self.modifier_name)
    end
end

----------------------------------------------------------------------------------------

modifier_item_mjz_luck_sheepstick_model_change = class({})
local modifier_model_change = modifier_item_mjz_luck_sheepstick_model_change

function modifier_model_change:IsHidden() return true end
function modifier_model_change:IsPurgable() return true end

function modifier_model_change:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_MODEL_CHANGE,
	}
end

function modifier_model_change:GetModifierModelChange()
    local model_index = self:GetStackCount()
    local model = MODEL_LIST[model_index]
    if model then
        return model
    else
        return DEFAULT_MODEL
    end
end

if IsServer() then
    function modifier_model_change:OnCreated(table)
        if table.model_index then
            self:SetStackCount(table.model_index)
        end
    end
end