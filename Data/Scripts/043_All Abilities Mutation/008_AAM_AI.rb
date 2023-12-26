class Battle::AI
	#=============================================================================
	# Damage calculation
	#=============================================================================
	alias aam_pbRoughDamage pbRoughDamage
	def pbRoughDamage(move, user, target, skill, baseDmg)
		$aam_DamageCalcFromAlly=[]
		$aam_DamageCalcFromTargetAlly=[]
		aam_pbRoughDamage(move, user, target, skill, baseDmg)
	end
	alias aam_pbCalcAccuracyModifiers pbCalcAccuracyModifiers
	def pbCalcAccuracyModifiers(user, target, modifiers, move, type, skill)
		$aam_AccuracyCalcFromAlly=[]
		aam_pbCalcAccuracyModifiers(user, target, modifiers, move, type, skill)
	end  
end  