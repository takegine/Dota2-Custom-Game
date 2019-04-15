--[[
    名字：流血
    效果：拥有此 Modifier 的单位攻击目标时，会令目标身上的龙芯或特定物品进入冷却时间。
]]

modifier_bleed_of_heart = class({})
local modifier_class = modifier_bleed_of_heart

function modifier_class:IsHidden() return true end
function modifier_class:RemoveOnDeath() return true end
function modifier_class:IsPurgable() return false end
function modifier_class:IsPurgeException() return false end

if IsServer() then
    function modifier_class:DeclareFunctions()
        return {
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
    end

    function modifier_class:OnAttackLanded(data)
        if data.attacker == self:GetParent() and data.target:IsAlive() then
            local hTarget = data.target
            
            -- 龙芯
            local modifier_item_heart_list = hTarget:FindAllModifiersByName('modifier_item_heart')
            for _,m in pairs(modifier_item_heart_list) do
                local item_heart = m:GetAbility()
                item_heart:StartCooldown(item_heart:GetCooldown(1))    
            end
    
            -- 额外的物品
            local heart_list = {}     --{"item_heart"}
            for k,v in pairs(heart_list) do
                self:_StartCooldown(hTarget, v)
            end
        end
    end

    function modifier_class:_StartCooldown(hTarget, item_name )
        local hItem = nil
        if hTarget:HasItemInInventory(item_name) then
            for i = 0, 5 do
                hItem = hTarget:GetItemInSlot(i)
                if hItem ~= nil then
                    if hItem:GetAbilityName() == item_name then
                        hItem:StartCooldown(hItem:GetCooldown(1))               
                    end
                end
            end
        end
    end
end





