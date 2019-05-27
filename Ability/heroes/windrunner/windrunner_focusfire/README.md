# 集中火力

![](game/resource/flash3/images/spellicons/mjz_windrunner_focusfire.png)

![](game/resource/flash3/images/spellicons/mjz_windrunner_focusfire_red.png)

风行者受风的引领，攻击敌方单位或建筑的攻击速度增加450，但是攻击伤害降低。不过次级物品效果的附加伤害不会降低。持续20秒。

**施法动作**：0+0

**攻击速度加成**：450

**攻击力降低**：50%/40%/30% （神杖 30%/15%/0%）

**重击触发几率**：0 （天赋 +35%）

**重击时间**：0 （天赋 0.01）

**持续时间**：20

**冷却时间**：70 （神杖 15）

**魔法消耗**：75/100/125

**无视魔法免疫**：是

**能否被驱散**：否

*重击不无视技能免疫*



```
//=================================================================================================================
	"npc_dota_hero_windrunner"			// 风行者
	//=================================================================================================================
	{
		"override_hero"			"npc_dota_hero_windrunner"

		"Ability6"				"mjz_windrunner_focusfire"
		"Ability16"				"special_bonus_unique_mjz_windrunner_focusfire_ministun"
	}
```

