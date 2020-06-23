-- LinkLuaModifier( "modifier_item_mjz_chinese_gold", "items/modifier_item_mjz_chinese_gold", LUA_MODIFIER_MOTION_NONE )

---------------------------------------------------------------------------------------

function item_mjz_chinese_gold_CastTarget( item, target )
    if target and IsValidEntity(target) and target:IsRealHero() then
        local caster = item:GetCaster()
        local newItemName = item:GetName() .. "_sell"

        caster:RemoveItem(item)

        local sameItem = nil
        local hasInventory = false
        for i=0,8, 1 do
            local current_item = caster:GetItemInSlot(i)
            if current_item == nil then
                hasInventory = true
            else
                if current_item:GetName() == newItemName then
                    sameItem = current_item
                end
            end
        end

        if sameItem then
            local charges = sameItem:GetCurrentCharges()
            if charges == 0 then
                charges = 1
            end
            sameItem:SetCurrentCharges( charges + 1)
        else
            local newItem = CreateItem(newItemName, caster, caster)
            newItem:SetPurchaseTime(0)
            if hasInventory then
                target:AddItem(newItem)
            else
			    local drop = CreateItemOnPositionSync( target:GetAbsOrigin(), newItem )
            end
        end
        
    end
end

function item_mjz_chinese_gold_Sell( item, target )
    if target and IsValidEntity(target) and target:IsRealHero() then
        local itemCost = item:GetCost()
        local charges = item:GetCurrentCharges()
        if charges == 0 then
            charges = 1
        end
        local totalCost = itemCost * charges
        target:RemoveItem(item)
        target:ModifyGold(totalCost, true, 0)

        EmitSoundOnClient("DOTA_Item.Hand_Of_Midas", PlayerResource:GetPlayer(target:GetPlayerID()))
        PopupAlchemistGold(target, totalCost, target:GetPlayerOwner())
        local pn = "particles/econ/items/alchemist/alchemist_midas_knuckles/alch_knuckles_lasthit_coins.vpcf"
        local coins = ParticleManager:CreateParticle(pn, PATTACH_CUSTOMORIGIN, target)
        ParticleManager:SetParticleControl(coins, 1, target:GetAbsOrigin())
    end
end

---------------------------------------------------------------------------------------

item_mjz_chinese_gold_1 = class({})

-- function item_mjz_chinese_gold_1:GetIntrinsicModifierName()
-- 	return "modifier_item_mjz_chinese_gold"
-- end

function item_mjz_chinese_gold_1:OnSpellStart()
    if IsServer() then
        item_mjz_chinese_gold_CastTarget(self, self:GetCursorTarget())
    end
end

---------------------------------------------------------------------------------------

item_mjz_chinese_gold_2 = class({})

-- function item_mjz_chinese_gold_2:GetIntrinsicModifierName()
-- 	return "modifier_item_mjz_chinese_gold"
-- end

function item_mjz_chinese_gold_2:OnSpellStart()
    if IsServer() then
        item_mjz_chinese_gold_CastTarget(self, self:GetCursorTarget())
    end
end

---------------------------------------------------------------------------------------

item_mjz_chinese_gold_3 = class({})

-- function item_mjz_chinese_gold_3:GetIntrinsicModifierName()
-- 	return "modifier_item_mjz_chinese_gold"
-- end

function item_mjz_chinese_gold_3:OnSpellStart()
    if IsServer() then
        item_mjz_chinese_gold_CastTarget(self, self:GetCursorTarget())
    end
end

---------------------------------------------------------------------------------------

item_mjz_chinese_gold_4 = class({})

-- function item_mjz_chinese_gold_4:GetIntrinsicModifierName()
-- 	return "modifier_item_mjz_chinese_gold"
-- end

function item_mjz_chinese_gold_4:OnSpellStart()
    if IsServer() then
        item_mjz_chinese_gold_CastTarget(self, self:GetCursorTarget())
    end
end

---------------------------------------------------------------------------------------

item_mjz_chinese_gold_5 = class({})

-- function item_mjz_chinese_gold_5:GetIntrinsicModifierName()
-- 	return "modifier_item_mjz_chinese_gold"
-- end

function item_mjz_chinese_gold_5:OnSpellStart()
    if IsServer() then
        item_mjz_chinese_gold_CastTarget(self, self:GetCursorTarget())
    end
end

---------------------------------------------------------------------------------------

item_mjz_chinese_gold_1_sell = class({})

function item_mjz_chinese_gold_1_sell:OnSpellStart()
	if IsServer() then
        item_mjz_chinese_gold_Sell(self, self:GetParent())
    end
end

---------------------------------------------------------------------------------------

item_mjz_chinese_gold_2_sell = class({})

function item_mjz_chinese_gold_2_sell:OnSpellStart()
	if IsServer() then
        item_mjz_chinese_gold_Sell(self, self:GetParent())
    end
end
---------------------------------------------------------------------------------------

item_mjz_chinese_gold_3_sell = class({})

function item_mjz_chinese_gold_3_sell:OnSpellStart()
	if IsServer() then
        item_mjz_chinese_gold_Sell(self, self:GetParent())
    end
end
---------------------------------------------------------------------------------------

item_mjz_chinese_gold_4_sell = class({})

function item_mjz_chinese_gold_4_sell:OnSpellStart()
	if IsServer() then
        item_mjz_chinese_gold_Sell(self, self:GetParent())
    end
end
---------------------------------------------------------------------------------------

item_mjz_chinese_gold_5_sell = class({})

function item_mjz_chinese_gold_5_sell:OnSpellStart()
	if IsServer() then
        item_mjz_chinese_gold_Sell(self, self:GetParent())
    end
end


---------------------------------------------------------------------------------------

modifier_item_mjz_chinese_gold = class({})

function modifier_item_mjz_chinese_gold:IsHidden() return true end

function modifier_item_mjz_chinese_gold:IsPurgable() return false end

-- modifier 叠加
function modifier_item_mjz_chinese_gold:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
