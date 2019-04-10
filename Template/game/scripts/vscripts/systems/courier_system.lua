
-- Courier Spawner and maybe future handler


-- Taken from bb template
if CourierSystem == nil then
--   Debug.EnabledModules['CourierSystem:*'] = true
  print( 'creating new Courier object' )
  CourierSystem = class({})
end

function CourierSystem:constructor ()
    CourierSystem.hasCourier = {}
    CourierSystem.hasCourier[DOTA_TEAM_BADGUYS] = false
    CourierSystem.hasCourier[DOTA_TEAM_GOODGUYS] = false
end

function CourierSystem:SpawnCourier (hero)
  if hero:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
    return
  end
  if self.hasCourier[hero:GetTeamNumber()] then
    return
  end

  self.hasCourier[hero:GetTeamNumber()] = true

  Timers:CreateTimer(1, function ()

    print("Creating Courier for Team " .. hero:GetTeamNumber())

    -- Check if there is an item blocking slot 1, if so sell it
    local slot1Item = hero:GetItemInSlot(0)
    if slot1Item then
      hero:TakeItem(slot1Item)
    end

    -- Create couriers and then cast them straight away
    local courier = hero:AddItemByName('item_courier')
    if courier then
        hero:CastAbilityImmediately(courier, hero:GetPlayerID())
    end
    local courierUnit = PlayerResource:GetNthCourierForTeam(0, hero:GetTeamNumber())
    if courierUnit then
      courierUnit:UpgradeToFlyingCourier()
    end

    if slot1Item then
      Timers:CreateTimer(0.5, function ()
        hero:AddItem(slot1Item)
      end)
    end
  end)
end