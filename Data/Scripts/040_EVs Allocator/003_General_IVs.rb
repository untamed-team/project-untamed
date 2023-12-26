#This plugin makes every pokemon able to randomly have any hidden power type regardless of its IVs

class Battle
  attr_accessor :hptype 
  attr_accessor :hptypeflag 
end

class Battle::Battler
  def hptype;         		 return @pokemon ? @pokemon.hptype : 0;				           end  	
  def hptypeflag;          return @pokemon ? @pokemon.hptypeflag : false;          end  	
end

def pbHiddenPower(pkmn)
  return [pkmn.hptype, 60]
end 


#===============================================================================
# Instances of this class are individual Pokémon.
# The player's party Pokémon are stored in the array $player.party.
#===============================================================================
class Pokemon
  attr_writer :hptype
  # The hidden power type is now a separate attribute of the Pokemon.
  def hptype
    if !@hptype
      types = []
      GameData::Type.each do |t|
        types.push(t.id) if !t.pseudo_type && ![:FAIRY, :SHADOW].include?(t.id)
      end
    @hptype=types.sample
    end
    return @hptype
  end
  
  # The flag that indicates a Pokemon has had its hidden power type altered.
  def hptypeflag
    if !@hptypeflag
      @hptypeflag = false
    end
    return @hptypeflag
  end  
  
  # Set the flag that indicates a Pokemon has had its hidden power type altered.
  def sethptypeflag
    @hptypeflag=true
  end  
end

#-----------------------
#The item that is used to change the hidden power type can be set to any item you desire.
#If you don't want to have an item that changes hidden power type you can simply don't edit the code below
#...unless you have an item in your game with id :ANYITEM  lol

#Unrestricted Hidden Power changing.
ItemHandlers::UseOnPokemon.add(:OLDGATEAU, proc { |item, qty, pokemon, scene, screen, msg|
	commands = []
	types = []
	GameData::Type.each do |t|
		if !t.pseudo_type && ![:FAIRY, :SHADOW].include?(t.id)
			commands.push(t.name)
			types.push(t.id) 
	 end
	end
	commands.push(_INTL("Cancel"))
	cmd = types.index(pokemon.hptype) || 0
	cmd = pbMessage(_INTL("Choose the type of {1}'s Hidden Power.",pokemon.name), commands, -1, nil, cmd)
	if cmd >=0 && cmd<types.length && pokemon.hptype != types[cmd]
		pokemon.hptype = types[cmd]
		scene.pbDisplay(_INTL("{1}'s Hidden Power has been set to {2}.",pokemon.name, pokemon.hptype))
	else
		# canceled
	end
})