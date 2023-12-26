
module PBEffects
  #===========================================================================
  # These effects apply to a battler
  #===========================================================================
  #IMPORTANT: Set Trace to an unused Effect ID in your game.
  ############################################################################
  Trace  = 1000
end   
  

class Battle::Battler
  attr_accessor :abilityMutationList
  
  def hasAbilityMutation?
    return (@pokemon) ? @pokemon.hasAbilityMutation? : false
  end
  
  # Gen 9 Pack Compatibility
  def affectedByMoldBreaker?
    return @battle.moldBreaker && !hasActiveItem?(:ABILITYSHIELD)
  end
  
  def ability=(value)
    new_ability = GameData::Ability.try_get(value)
    @ability_id = (new_ability) ? new_ability.id : nil
    if @ability_id 
      if self.hasAbilityMutation?
        @abilityMutationList.unshift(@ability_id)
        @abilityMutationList=@abilityMutationList|[]
      else  
        @abilityMutationList[0]=@ability_id 
      end  
    end  
  end
	
  alias abilityMutations_pbInitPokemon pbInitPokemon 
   def pbInitPokemon(pkmn, idxParty)
    abilityMutations_pbInitPokemon(pkmn, idxParty)
    # DemICE AAM edits
    abilist=[@ability_id]
    if pkmn.hasAbilityMutation?
        if pkmn&.mega?
          pkmn.makeUnmega
          for i in pkmn.getAbilityList
            abilist.push(i[0])
          end 
          pkmn.makeMega
        end  
        for i in pkmn.getAbilityList
          abilist.push(i[0])
        end 
    end	
    @abilityMutationList= abilist|[]
    #print @abilityMutationList
    #DemICE end
  end
  
  
  alias abilityMutations_pbInitEffects pbInitEffects
  def pbInitEffects(batonPass)
    abilityMutations_pbInitEffects(batonPass)
	  @effects[PBEffects::Trace] = false   #DemICE   AAM edit
  end
  
  #=============================================================================
  # Refreshing a battler's properties
  #=============================================================================
  alias abilityMutations_pbUpdate pbUpdate
  def pbUpdate(fullChange = false)
    return if !@pokemon
    abilityMutations_pbUpdate(fullChange)
    if !@effects[PBEffects::Transform] && fullChange
      if !@abilityMutationList.include?(@ability_id)
        if self.hasAbilityMutation?
          @abilityMutationList.unshift(@ability_id)
          @abilityMutationList=@abilityMutationList|[]
        else
          @abilityMutationList[0]=@ability_id
        end  
        #print @abilityMutationList
      end
    end
  end

  def hasActiveAbility?(check_ability, ignore_fainted = false, mold_broken = false) # updated to keep in mind the better AI #by low
		return false if mold_broken
    return false if !abilityActive?(ignore_fainted, check_ability)
    if self.hasAbilityMutation?	
      if check_ability.is_a?(Array)
        for i in check_ability
          $aamName2=GameData::Ability.get(i).name
          return @abilityMutationList.include?(i)	
        end	
      else	
        $aamName2=GameData::Ability.get(check_ability).name
        return @abilityMutationList.include?(check_ability)	
      end 
    end	
    return check_ability.include?(@ability_id) if check_ability.is_a?(Array)
	  $aamName2=GameData::Ability.get(check_ability).name
    return self.ability == check_ability
  end
  alias hasWorkingAbility hasActiveAbility?  
  
  # Called when a Pokémon (self) enters battle, at the end of each move used,
  # and at the end of each round.
  def pbContinualAbilityChecks(onSwitchIn = false)
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    # Trace
    if hasActiveAbility?(:TRACE) && (self.effects[PBEffects::Trace] || onSwitchIn)
      # NOTE: In Gen 5 only, Trace only triggers upon the Trace bearer switching
      #       in and not at any later times, even if a traceable ability turns
      #       up later. Essentials ignores this, and allows Trace to trigger
      #       whenever it can even in Gen 5 battle mechanics.
      choices = @battle.allOtherSideBattlers(@index).select { |b|
        next !b.ungainableAbility? &&
             ![:POWEROFALCHEMY, :RECEIVER, :TRACE].include?(b.ability_id) && 
			 !self.abilityMutationList.include?(b.ability_id)
      }
      if choices.length==0
        effects[PBEffects::Trace]=true	  
      else
        choice = choices[@battle.pbRandom(choices.length)]
        $aamName="Trace"
        @battle.pbShowAbilitySplash(self,true)
        if self.hasAbilityMutation?
          self.abilityMutationList.push(choice.ability.id)							
        else
          self.ability = choice.ability
        end
        $aamName=choice.abilityName
        battle.pbReplaceAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!", pbThis, choice.pbThis(true), choice.abilityName))
        @battle.pbHideAbilitySplash(self)
        if !onSwitchIn && (unstoppableAbility? || abilityActive?)
          Battle::AbilityEffects.triggerOnSwitchIn(self.ability, self, @battle)
        end
        self.effects[PBEffects::Trace]=false
      end
      #print self.abilityMutationList
    end
  end	

  alias aam_pbCanInflictStatus? pbCanInflictStatus?
  def pbCanInflictStatus?(newStatus, user, showMessages, move = nil, ignoreStatus = false)
    $aam_StatusImmunityFromAlly=[]
    aam_pbCanInflictStatus?(newStatus, user, showMessages, move, ignoreStatus)
  end
  
end

# Safari Zone Fix
class Battle::FakeBattler
  attr_accessor :abilityMutationList
  
  alias aam_initialize initialize
  def initialize(*args)
    aam_initialize(*args)
    @abilityMutationList=[]
  end

  def hasAbilityMutation?
    return (@pokemon) ? @pokemon.hasAbilityMutation? : false
  end
end  

class Battle::Scene::AbilitySplashBar < Sprite

  def refresh
    self.bitmap.clear
    return if !@battler
    textPos = []
    textX = (@side == 0) ? 10 : self.bitmap.width - 8
    # Draw Pokémon's name
    textPos.push([_INTL("{1}'s", @battler.name), textX, 8, @side == 1,
                  TEXT_BASE_COLOR, TEXT_SHADOW_COLOR, true])
    # Draw Pokémon's ability
    abilitytext=@battler.abilityName
    if @battler.hasAbilityMutation?
      aamNames=[]
      for i in @battler.abilityMutationList
        aamNames.push(GameData::Ability.get(i).name)
      end	
      abilitytext=$aamName2 if aamNames.include?($aamName2)
      abilitytext=$aamName if aamNames.include?($aamName)
    end	
    textPos.push([abilitytext, textX, 38, @side == 1,
                  TEXT_BASE_COLOR, TEXT_SHADOW_COLOR, true])
    pbDrawTextPositions(self.bitmap, textPos)
  end  

end

################################################################################
################################################################################
################################################################################
################################################################################


class Battle

  alias aam_pbCanSwitch? pbCanSwitch?
  def pbCanSwitch?(idxBattler, idxParty = -1, partyScene = nil)
    $aam_trapping=false

    aam_switch =  aam_pbCanSwitch?(idxBattler, idxParty, partyScene)

    $aam_trapping=true
    battler = @battlers[idxBattler]
    # Trapping abilities for All Abilities Mutation
    allOtherSideBattlers(idxBattler).each do |b|
      next if !b.abilityActive?
      if Battle::AbilityEffects.triggerTrappingByTarget(b.ability, battler, b, self)
        partyScene&.pbDisplay(_INTL("{1}'s {2} prevents switching!",
                                    b.pbThis, $aamName))
        return false
      end
    end
    return aam_switch
  end

  alias aam_pbCanRun? pbCanRun?
  def pbCanRun?(idxBattler)
    $aam_trapping=true
    return aam_pbCanRun?(idxBattler)
  end  
  
end  