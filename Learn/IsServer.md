# IsServer



需要被 `IsServer` 包裹的方面：

1. 给予伤害

   ```lua
   if IsServer() then
       ApplyDamage({
                   attacker = caster,
                   victim = target,
                   damage = damage,
                   damage_type = self:GetAbilityDamageType(),
                   ability = self
               })
   end
   ```

2. 添加物品