# 鱼人碎击

![](game/resource/flash3/images/spellicons/mjz_slardar_slithereen_crush.png)

![](game/resource/flash3/images/spellicons/mjz_slardar_slithereen_crush_immortal.png)

![](game/resource/flash3/images/spellicons/mjz_slardar_slithereen_crush_immortal_gold.png)

猛击地面，对附近地面单位造成伤害并眩晕。眩晕结束后还会受到减速。

```
斯拉达每次施放鱼人碎击都会产生一滩水洼，提供与河道相同的移动速度及其他加成。在水洼或河道中获得额外生命恢复、护甲和状态抗性。
```



**施法动作**：0.35+0.6

**范围**：350

**基础伤害**：80/140/200/260

**额外力量伤害**：60%/120%/180%/240%（天赋 +60%）

**移动速度减缓**：20%/25%/30%/35%

**攻击速度降低**：20/25/30/35

**眩晕时间**：1

**减速时间**：3/4/5/6

**河道生命恢复加成**：0 （神杖+35）

**河道护甲加成**：0（神杖+12）

**河道状态抗性加成**：0%（神杖+40%）

**冷却时间**：8

**魔法消耗**：80/95/105/115

**无视魔法免疫**：否

**能否被驱散**：是



```lua
//=================================================================================================================
	"npc_dota_hero_slardar"			//  大鱼人
	//=================================================================================================================
	{
		"override_hero"			"npc_dota_hero_slardar"

		"Ability2"				"mjz_slardar_slithereen_crush"
		"Ability16"				"special_bonus_unique_mjz_slardar_slithereen_crush_strength"
	}
```

