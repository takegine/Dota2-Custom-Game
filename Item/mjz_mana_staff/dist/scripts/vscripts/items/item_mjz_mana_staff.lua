-- require("lib/my")



function on_attack(keys)
    local caster = keys.caster
    local ability = keys.ability
    local damage = keys.damage

    local mana_steal_pct = ability:GetSpecialValueFor("mana_steal")

    local mana_gain = damage * mana_steal_pct * 0.01

    local particle = ParticleManager:CreateParticle("particles/custom/manasteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particle)

    caster:GiveMana(mana_gain)
end
