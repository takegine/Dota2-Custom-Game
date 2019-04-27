
LinkLuaModifier("modifier_black_king_bar_faster", "items/item_black_king_bar_faster.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_black_king_bar_faster_ability", "items/item_black_king_bar_faster.lua", LUA_MODIFIER_MOTION_NONE)

------------------------------------------------------------------------

item_black_king_bar_faster = class({})

function item_black_king_bar_faster:GetIntrinsicModifierName()
	if IsServer() then
		self:OnEquip()
	end
	return 'modifier_black_king_bar_faster'
end

if IsServer() then
	function item_black_king_bar_faster:OnEquip()
		local caster = self:GetCaster()
		local ability = self
		local duration = ability:GetSpecialValueFor("duration")
		local max_level = ability:GetSpecialValueFor("max_level")
	
		RefreshLevel(caster, ability, max_level)
	end

	function item_black_king_bar_faster:OnSpellStart()
		local caster = self:GetCaster()
		local ability = self
		local duration = ability:GetSpecialValueFor("duration")
		local max_level = ability:GetSpecialValueFor("max_level")

		caster:AddNewModifier(caster, ability, "modifier_black_king_bar_faster_ability", {Duration = duration})

		UpdateLevel(caster, ability, max_level)

		caster:Purge(false, true, false, true, false)

		EmitSoundOn("DOTA_Item.BlackKingBar.Activate", caster)
	end
end


function UpdateLevel(caster, ability, max_level)
	local item_name = ability:GetName()
	local current_level = caster.BKBLevel or ability:GetLevel()

	if current_level + 1 <= max_level then
		ability:SetLevel(current_level + 1)
		caster.BKBLevel = current_level + 1  --BKB's level is tied to the player, not the item, so store it here.
		
		RefreshLevel(caster, ability, max_level)
	end
end

function RefreshLevel(caster, ability, max_level)
	local item_name = ability:GetName()
    local bkb_level = caster.BKBLevel or ability:GetLevel()
		
	for i=0, 11, 1 do  --Level up any other BKBs in the player's inventory or stash to match the new level.
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then
            if current_item:GetName() == item_name and current_item:GetLevel() ~= bkb_level then
				current_item:SetLevel(bkb_level)
			end
		end
	end
end

------------------------------------------------------------------------


modifier_black_king_bar_faster = class({})

function modifier_black_king_bar_faster:IsHidden() return true end
function modifier_black_king_bar_faster:IsPurgable() return false end

function modifier_black_king_bar_faster:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_black_king_bar_faster:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor('bonus_strength')
end

function modifier_black_king_bar_faster:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor('bonus_damage')
end


------------------------------------------------------------------------


modifier_black_king_bar_faster_ability = class({})

function modifier_black_king_bar_faster_ability:IsHidden() return false end
function modifier_black_king_bar_faster_ability:IsPurgable() return false end

function modifier_black_king_bar_faster_ability:GetTexture()
    -- return self:GetAbility():GetAbilityTextureName()
    return 'item_black_king_bar_faster'
end

function modifier_black_king_bar_faster_ability:CheckState()
	local state = {
	  [MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
	return state
end

function modifier_black_king_bar_faster_ability:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
end

function modifier_black_king_bar_faster_ability:GetModifierModelScale()
	return self:GetAbility():GetSpecialValueFor("model_scale")
end

function modifier_black_king_bar_faster_ability:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function modifier_black_king_bar_faster_ability:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_black_king_bar_faster_ability:GetStatusEffectName()
	return "particles/status_fx/status_effect_avatar.vpcf"
end
function modifier_black_king_bar_faster_ability:StatusEffectPriority()
	return 10
end


-----------------------------------------------------------------------


function scaleModel(caster, PercentageOverModelScale, Duration)
	if not Timers then return end

    local final_model_scale = (PercentageOverModelScale / 100) + 1  --This will be something like 1.3.
	local model_scale_increase_per_interval = 100 / (final_model_scale - 1)

	--Scale the model up over time.
	for i=1,100 do
		Timers:CreateTimer(i/75, 
		function()
			caster:SetModelScale(1 + i/model_scale_increase_per_interval)
		end)
	end

	--Scale the model back down around the time the duration ends.
	for i=1,100 do
		Timers:CreateTimer(Duration - 1 + (i/50),
		function()
			caster:SetModelScale(final_model_scale - i/model_scale_increase_per_interval)
		end)
	end
end