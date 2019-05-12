# 热血战魂

![](game/resource/flash3/images/spellicons/mjz_troll_warlord_fervor.png)

当巨魔战将持续攻击同一个目标时，他会攻击得越来越快。如果改变目标，则额外的攻速加成减半。

With each continuous blow on the same target, Troll gains increased attack speed. If Troll changes targets, the stacks drop to half.

**最大叠加层数**：12（天赋 +3）

**每层攻击速度加成**：15/20/25/30



```lua
//=================================================================================================================
	"npc_dota_hero_troll_warlord"			//  巨魔战将
	//=================================================================================================================
	{
		"override_hero"			"npc_dota_hero_troll_warlord"

		"Ability4"				"mjz_troll_warlord_fervor"
		"Ability12"				"special_bonus_unique_mjz_troll_warlord_fervor_stacks"
	}
```

