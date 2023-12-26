#===============================================================================
# Instances of this class are individual Pokémon.
# The player's party Pokémon are stored in the array $player.party.
#===============================================================================
class Pokemon
  attr_accessor :abilityMutation
	attr_accessor :pv

	################################################################################
	# All Abilities Mutation
	################################################################################ 
	# Enables All Abilities Mutation.
	@abilityMutation = false
	def enableAbilityMutation
		@abilityMutation = true
	end  
# Disables All Abilities Mutation.
	def disableAbilityMutation
		@abilityMutation = false
	end    

	# Toggles All Abilities Mutation.
	def toggleAbilityMutation
		if !@abilityMutation
			@abilityMutation = true
		else	
			@abilityMutation = false
		end	
	end 		
	
	def hasAbilityMutation?
		if @abilityMutation==true || Settings::GLOBAL_MUTATION==true
			return true 
		end	
	end
end