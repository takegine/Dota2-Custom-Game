# 过载

![](game/resource/flash3/images/spellicons/mjz_io_overcharge.png)



艾欧获得攻击速度加成并降低受到的伤害，代价是每秒流失一定百分比的当前生命值。如果艾欧和一个友军连接，该单位也会获得增益效果。

Io gains bonus attack speed and damage reduction, at the cost of draining a percentage of its current health. If Io is tethered to an ally, that unit also gains the bonuses.

**施法动作**：0+0

**每秒当前生命消耗**：6%

**攻击速度加成**：40/60/80/100

**伤害减免**：5%/10%/15%/20%

**冷却时间**：2

**能否被驱散**：否





```lua
//=================================================================================================================
	"npc_dota_hero_wisp"			// 小精灵
	//=================================================================================================================
	{
		"override_hero"			"npc_dota_hero_wisp"

		"Ability3"				"mjz_io_overcharge"
		"Ability11"				"special_bonus_unique_wisp_4"
		"Ability17"				"special_bonus_attack_damage_120"
	}
```

