



**Dummy**

```lua
-- Dummy
		local dummy_name = 'npc_dota_invisible_vision_source' -- npc_dummy_unit
		local dummy = CreateUnitByName(dummy_name, target_point, false, caster, caster, caster:GetTeam())
		dummy:AddNewModifier(caster, nil, "modifier_phased", {})
		dummy:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
		dummy:AddNewModifier(caster, ability, "modifier_item_gem_of_true_sight", {duration = duration})
```



**Thinker**

```lua
	local thinker = CreateModifierThinker(caster, ability, 'MODIFIER_DUMMY_THINKER', {duration = 60.0}, pos, caster:GetTeamNumber(), false)

```

**FindUnits**

```lua
local enemy_list = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, 
			ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false )

		for _,enemy in pairs(enemy_list) do
			enemy:AddNewModifier(caster, ability, 'modifier_silence', {duration = silence_duration})
			ApplyDamage({ 
				victim = caster, attacker = enemy, 
				damage = damage, damage_type = ability:GetAbilityDamageType() 
			})
		end
```

