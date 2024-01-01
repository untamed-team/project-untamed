
class Battle::Move
  
  alias aam_pbCalcDamageMultipliers pbCalcDamageMultipliers
  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    $aam_DamageCalcFromAlly=[]
    $aam_DamageCalcFromTargetAlly=[]
    aam_pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
  end

  alias aam_pbCalcAccuracyModifiers pbCalcAccuracyModifiers
  def pbCalcAccuracyModifiers(user, target, modifiers)
    $aam_AccuracyCalcFromAlly=[]
    aam_pbCalcAccuracyModifiers(user, target, modifiers)
  end

end  