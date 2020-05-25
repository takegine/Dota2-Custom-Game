# Overhead Alerts



```lua
SendOverheadEventMessage(handle player, int overhead_alert_index, handle target_entity, int int value, handle source_player)
```

![overhead-alerts](D:\Projects\Game\Dota2 Custom Game\Learn\img\overhead-alerts.png)



### Indexes

- 0 OVERHEAD_ALERT_GOLD (has a sound effect)
- 1 OVERHEAD_ALERT_DENY
- 2 OVERHEAD_ALERT_CRITICAL
- 3 OVERHEAD_ALERT_XP
- 4 OVERHEAD_ALERT_BONUS_SPELL_DAMAGE
- 5 OVERHEAD_ALERT_MISS
- 6 OVERHEAD_ALERT_DAMAGE
- 7 OVERHEAD_ALERT_EVADE
- 7 PATTACH_OVERHEAD_FOLLOW
- 8 OVERHEAD_ALERT_BLOCK
- 9 OVERHEAD_ALERT_BONUS_POISON_DAMAGE
- 10 OVERHEAD_ALERT_HEAL
- 11 OVERHEAD_ALERT_MANA_ADD
- 12 OVERHEAD_ALERT_MANA_LOSS
- 13 OVERHEAD_ALERT_LAST_HIT_EARLY
- 14 OVERHEAD_ALERT_LAST_HIT_CLOSE
- 15 OVERHEAD_ALERT_LAST_HIT_MISS
- 16 OVERHEAD_ALERT_MAGICAL_BLOCK



### Example

```lua
ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( GhostGameMode, "OnItemPickUp"), self )
...
...

function GhostGameMode:OnItemPickUp( event )
    local item = EntIndexToHScript( event.ItemEntityIndex )
    local player = EntIndexToHScript( event.HeroEntityIndex )
    value = 15
    if event.itemname == "item_bag_of_gold" then
        SendOverheadEventMessage( player, OVERHEAD_ALERT_MANA_ADD , player, value, nil )
        player:GiveMana(value)
    end
end
```

