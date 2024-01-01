#===============================================================================
# Revamps miscellaneous Pokemon and battle-related code in base Essentials to 
# allow for plugin compatibility.
#===============================================================================


#-------------------------------------------------------------------------------
# Battler effects.
#-------------------------------------------------------------------------------
module PBEffects
  CriticalBoost    = 300  # General crit-boosting effect used by a variety of mechanics.
  EncoreRestore    = 301  # Used to restore Encore after using a battle mechanic that may temporarily ignore its effect.
  TransformPokemon = 302  # Used to get the correct sprite data while transformed in certain situations.
end


#-------------------------------------------------------------------------------
# Pokemon data.
#-------------------------------------------------------------------------------
class Pokemon
  def ace?; return @trainer_ace || false; end
  def ace=(value); @trainer_ace = value;  end
  
  
  alias dx_baseStats baseStats
  def baseStats
	base_stats = dx_baseStats
	form_stats = MultipleForms.call("baseStats", self)
	form_stats = celestial_data["BaseStats"] if celestial?
	return form_stats || base_stats
  end
  
  alias dx_initialize initialize  
  def initialize(*args)
    dx_initialize(*args)
    @trainer_ace = false
  end
  
  # Compatibility across multiple plugins.
  def dynamax?;   return false; end
  def gmax?;      return false; end
  def tera?;      return false; end
  def celestial?; return false; end
end


#-------------------------------------------------------------------------------
# Initializes battler effects.
#-------------------------------------------------------------------------------
class Battle::Battler
  attr_accessor :base_moves
  attr_accessor :power_trigger
  
  def ace?; return @pokemon&.ace?; end
  
  alias dx_pbInitEffects pbInitEffects  
  def pbInitEffects(batonPass)
    dx_pbInitEffects(batonPass)
    @base_moves = []
    @power_trigger = false
    @effects[PBEffects::CriticalBoost]    = 0 if !batonPass
    @effects[PBEffects::EncoreRestore]    = []
    @effects[PBEffects::TransformPokemon] = nil
  end
  
  #-----------------------------------------------------------------------------
  # Edited to reduce appropriate move PP when using certain plugin mechanics.
  #-----------------------------------------------------------------------------
  def pbReducePP(move)
    return true if usingMultiTurnAttack?
    return true if move.pp < 0
    return true if move.total_pp <= 0
    return false if move.pp == 0
    if move.pp > 0
      pbSetPP(move, move.pp - 1)
      if PluginManager.installed?("ZUD Mechanics") && move.powerMove?
        c = @power_index
        pbSetPP(@base_moves[c], @base_moves[c].pp - 1)
      end
      if PluginManager.installed?("PLA Battle Styles") && inStyle?
        pbSetPP(move, move.pp - 1) if move.pp > 0 && move.mastered?
      end
    end
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Reverts to base moves. Used by plugins that change moves mid-battle.
  #-----------------------------------------------------------------------------
  def display_base_moves
    return if @base_moves.empty?
    for i in 0...@moves.length
	  next if !@base_moves[i]
      if @base_moves[i].is_a?(Battle::Move)
        @moves[i] = @base_moves[i]
      else
        @moves[i] = Battle::Move.from_pokemon_move(@battle, @base_moves[i])
      end
    end
    @base_moves.clear
  end
  
  #-----------------------------------------------------------------------------
  # Checks for form changes upon changing the battler's held item.
  #-----------------------------------------------------------------------------
  def pbCheckFormOnHeldItemChange
    return if fainted? || @effects[PBEffects::Transform]
    #---------------------------------------------------------------------------
    # Dialga - holding Adamant Crystal
    if isSpecies?(:DIALGA)
      newForm = 0
      newForm = 1 if self.item == :ADAMANTCRYSTAL
      pbChangeForm(newForm, _INTL("{1} transformed!", pbThis))
    end
    #---------------------------------------------------------------------------
    # Palkia - holding Lustrous Globe
    if isSpecies?(:PALKIA)
      newForm = 0
      newForm = 1 if self.item == :LUSTROUSGLOBE
      pbChangeForm(newForm, _INTL("{1} transformed!", pbThis))
    end
    #---------------------------------------------------------------------------
    # Giratina - holding Griseous Orb/Core
    if isSpecies?(:GIRATINA)
      return if $game_map && GameData::MapMetadata.get($game_map.map_id)&.has_flag?("DistortionWorld")
      newForm = 0
      newForm = 1 if [:GRISEOUSORB, :GRISEOUSCORE].include?(self.item)
      pbChangeForm(newForm, _INTL("{1} transformed!", pbThis))
    end
    #---------------------------------------------------------------------------
    # Arceus - holding a Plate with Multi-Type
    if isSpecies?(:ARCEUS) && self.ability == :MULTITYPE
      newForm = 0
      type = GameData::Type.get(:NORMAL)
      if self.item
        typeArray = {
          1  => [:FIGHTING, [:FISTPLATE,   :FIGHTINIUMZ]],
          2  => [:FLYING,   [:SKYPLATE,    :FLYINIUMZ]],
          3  => [:POISON,   [:TOXICPLATE,  :POISONIUMZ]],
          4  => [:GROUND,   [:EARTHPLATE,  :GROUNDIUMZ]],
          5  => [:ROCK,     [:STONEPLATE,  :ROCKIUMZ]],
          6  => [:BUG,      [:INSECTPLATE, :BUGINIUMZ]],
          7  => [:GHOST,    [:SPOOKYPLATE, :GHOSTIUMZ]],
          8  => [:STEEL,    [:IRONPLATE,   :STEELIUMZ]],
          10 => [:FIRE,     [:FLAMEPLATE,  :FIRIUMZ]],
          11 => [:WATER,    [:SPLASHPLATE, :WATERIUMZ]],
          12 => [:GRASS,    [:MEADOWPLATE, :GRASSIUMZ]],
          13 => [:ELECTRIC, [:ZAPPLATE,    :ELECTRIUMZ]],
          14 => [:PSYCHIC,  [:MINDPLATE,   :PSYCHIUMZ]],
          15 => [:ICE,      [:ICICLEPLATE, :ICIUMZ]],
          16 => [:DRAGON,   [:DRACOPLATE,  :DRAGONIUMZ]],
          17 => [:DARK,     [:DREADPLATE,  :DARKINIUMZ]],
          18 => [:FAIRY,    [:PIXIEPLATE,  :FAIRIUMZ]]
        }
        typeArray.each do |form, data|
          next if !data.last.include?(self.item.id)
          type = GameData::Type.get(data.first)
          newForm = form
        end
      end
      pbChangeForm(newForm, _INTL("{1} transformed into the {2}-type!", pbThis, type.name))
    end
    #---------------------------------------------------------------------------
    # Genesect - holding a Drive
    if isSpecies?(:GENESECT)
      newForm = 0
      drives = [:SHOCKDRIVE, :BURNDRIVE, :CHILLDRIVE, :DOUSEDRIVE]
      drives.each_with_index do |drive, i|
        newForm = i + 1 if self.item == drive
      end
      pbChangeForm(newForm, nil)
    end
    #---------------------------------------------------------------------------
    # Silvally - holding a Memory with RKS System
    if isSpecies?(:SILVALLY) && self.ability == :RKSSYSTEM
      newForm = 0
      type = GameData::Type.get(:NORMAL)
      if self.item
        typeArray = {
          1  => [:FIGHTING, [:FIGHTINGMEMORY]],
          2  => [:FLYING,   [:FLYINGMEMORY]],
          3  => [:POISON,   [:POISONMEMORY]],
          4  => [:GROUND,   [:GROUNDMEMORY]],
          5  => [:ROCK,     [:ROCKMEMORY]],
          6  => [:BUG,      [:BUGMEMORY]],
          7  => [:GHOST,    [:GHOSTMEMORY]],
          8  => [:STEEL,    [:STEELMEMORY]],
          10 => [:FIRE,     [:FIREMEMORY]],
          11 => [:WATER,    [:WATERMEMORY]],
          12 => [:GRASS,    [:GRASSMEMORY]],
          13 => [:ELECTRIC, [:ELECTRICMEMORY]],
          14 => [:PSYCHIC,  [:PSYCHICMEMORY]],
          15 => [:ICE,      [:ICEMEMORY]],
          16 => [:DRAGON,   [:DRAGONMEMORY]],
          17 => [:DARK,     [:DARKMEMORY]],
          18 => [:FAIRY,    [:FAIRYMEMORY]]
        }
        typeArray.each do |form, data|
          next if !data.last.include?(self.item.id)
          type = GameData::Type.get(data.first)
          newForm = form
        end
      end
      pbChangeForm(newForm, _INTL("{1} transformed into the {2}-type!", pbThis, type.name))
    end
    #---------------------------------------------------------------------------
    # Zacian - holding Rusted Sword
    if isSpecies?(:ZACIAN)
      newForm = 0
      newForm = 1 if self.item == :RUSTEDSWORD
      moves = [:IRONHEAD, :BEHEMOTHBLADE]
      @moves.each_with_index do |m, i|
        next if m.id != moves[self.form]
        move = Pokemon::Move.new(moves.reverse[self.form])
        move.pp = m.pp
        @moves[i] = Battle::Move.from_pokemon_move(@battle, move)
      end
      pbChangeForm(newForm, _INTL("{1} transformed!", pbThis))
    end
    #---------------------------------------------------------------------------
    # Zamazenta - holding Rusted Shield
    if isSpecies?(:ZAMAZENTA)
      newForm = 0
      newForm = 1 if self.item == :RUSTEDSHIELD
      moves = [:IRONHEAD, :BEHEMOTHBASH]
      @moves.each_with_index do |m, i|
        next if m.id != moves[self.form]
        move = Pokemon::Move.new(moves.reverse[self.form])
        move.pp = m.pp
        @moves[i] = Battle::Move.from_pokemon_move(@battle, move)
      end
      pbChangeForm(newForm, _INTL("{1} transformed!", pbThis))
    end
  end
  
  #-----------------------------------------------------------------------------
  # Compatibility across multiple plugins.
  #-----------------------------------------------------------------------------
  def hasZMove?;       		return false; end
  def hasUltra?;       		return false; end
  def ultra?;          		return false; end
  def hasDynamax?;     		return false; end
  def hasDynamaxAvail?;		return false; end
  def dynamax?;        		return false; end
  def dynamax_able?;   		return false; end
  def hasGmax?;        		return false; end
  def gmax?;           		return false; end
  def gmax_factor?;    		return false; end
  def hasStyles?;      		return false; end
  def inStyle?;        		return false; end
  def tera?;           		return false; end
  def hasTera?;        		return false; end
  def hasZodiacPower?; 		return false; end
  def celestial?;      		return false; end
  def focus_meter;     		return 0;     end
end


#-------------------------------------------------------------------------------
# Safari Zone compatibility
#-------------------------------------------------------------------------------
class Battle::FakeBattler
  attr_reader :effects
  
  alias zud_initialize initialize
  def initialize(*args)
    zud_initialize(*args)
    @effects = {}
  end
  
  #-----------------------------------------------------------------------------
  # Compatibility across multiple plugins.
  #-----------------------------------------------------------------------------
  def hasZMove?;            return false; end
  def hasUltra?;            return false; end
  def ultra?;               return false; end
  def hasDynamax?;          return false; end
  def hasDynamaxAvail?;     return false; end
  def dynamax?;             return false; end
  def gmax?;                return false; end
  def gmax_factor?;         return false; end
  def hasStyles?;           return false; end
  def inStyle?;             return false; end
  def hasTera?;             return false; end
  def tera?;                return false; end
  def birthsign;            return nil;   end
  def celestial?;           return false; end
  def blessed?;             return false; end
  def hasBirthsign?(arg);   return false; end
  def hasZodiacPower?;      return false; end
  def focus_meter;          return 0;     end
end


#-------------------------------------------------------------------------------
# Adds shortened move names; rewrites critical hit to include new effect.
#-------------------------------------------------------------------------------
class Battle::Move
  attr_accessor :short_name
  
  alias dx_initialize initialize
  def initialize(battle, move)
    dx_initialize(battle, move)
    @short_name = (Settings::SHORTEN_MOVES && @name.length > 16) ? @name[0..12] + "..." : @name
  end
  
  def pbIsCritical?(user, target)
    return false if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
    ratios = (Settings::NEW_CRITICAL_HIT_RATE_MECHANICS) ? [24, 8, 2, 1] : [16, 8, 4, 3, 2]
    c = 0
    if c >= 0 && user.abilityActive?
      c = Battle::AbilityEffects.triggerCriticalCalcFromUser(user.ability, user, target, c)
    end
    if c >= 0 && target.abilityActive? && !@battle.moldBreaker
      c = Battle::AbilityEffects.triggerCriticalCalcFromTarget(target.ability, user, target, c)
    end
    if c >= 0 && user.itemActive?
      c = Battle::ItemEffects.triggerCriticalCalcFromUser(user.item, user, target, c)
    end
    if c >= 0 && target.itemActive?
      c = Battle::ItemEffects.triggerCriticalCalcFromTarget(target.item, user, target, c)
    end
    return false if c < 0
    case pbCritialOverride(user, target)
    when 1  then return true
    when -1 then return false
    end
    return true if c > 50
    return true if user.effects[PBEffects::LaserFocus] > 0
    if highCriticalRate?
      c += (PluginManager.installed?("PLA Battle Styles") && user.strong_style?) ? 2 : 1
    end
    c += user.effects[PBEffects::FocusEnergy]
    c += user.effects[PBEffects::CriticalBoost]
    c += 1 if user.inHyperMode? && @type == :SHADOW
    c = ratios.length - 1 if c >= ratios.length
    return true if ratios[c] == 1
    r = @battle.pbRandom(ratios[c])
    return true if r == 0
    if r == 1 && Settings::AFFECTION_EFFECTS && @battle.internalBattle &&
       user.pbOwnedByPlayer? && user.affection_level == 5 && !target.mega?
      target.damageState.affection_critical = true
      return true
    end
    return false
  end
end


#-------------------------------------------------------------------------------
# Correctly records seen shadow Pokemon.
#-------------------------------------------------------------------------------
class Battle
  def pbSetSeen(battler)
    return if !battler || !@internalBattle
    if battler.is_a?(Battler)
      pbPlayer.pokedex.register(battler.displaySpecies, battler.displayGender,
                                battler.displayForm, battler.shiny?, 
                                true, battler.gmax?, battler.shadowPokemon?)
    else
      pbPlayer.pokedex.register(battler)
    end
  end
end


#-------------------------------------------------------------------------------
# Correctly records captured shadow Pokemon.
#-------------------------------------------------------------------------------
module Battle::CatchAndStoreMixin
  def pbRecordAndStoreCaughtPokemon
    @caughtPokemon.each do |pkmn|
      pbSetCaught(pkmn)
      pbSetSeen(pkmn)
      if !pbPlayer.owned?(pkmn.species)
        pbPlayer.pokedex.set_owned(pkmn.species)
        if $player.has_pokedex
          pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.", pkmn.name))
          pbPlayer.pokedex.register_last_seen(pkmn)
          @scene.pbShowPokedex(pkmn.species)
        end
      end
      pbPlayer.pokedex.set_shadow_pokemon_owned(pkmn.species_data.id) if pkmn.shadowPokemon?
      pbStorePokemon(pkmn)
    end
    @caughtPokemon.clear
  end
  
  alias dx_pbStorePokemon pbStorePokemon
  def pbStorePokemon(pkmn)
    pkmn.ace = false
    dx_pbStorePokemon(pkmn)
  end
end