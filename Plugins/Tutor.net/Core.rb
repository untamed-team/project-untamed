#===============================================================================
#Tutor.net plugin by DemICE
#===============================================================================

#Sooooo DemICE's instructions are that we need to add moves and costs to the
#tutorlist array before opening Tutor.net
#I'm just gonna make a separate method that has predefined data so we don't have
#to painstakingly add each tutor move. Then we just call that script once and it
#replaces the entire array
#Script name is Tutor Moves and Costs
#-Gardenette

#===============================================================================
# Basic trainer class (use a child class rather than this one)
#===============================================================================
class Trainer
    attr_accessor(:tutorlist)
    attr_accessor(:tutornet)
  
    #=============================================================================
	alias tutornet_initialize initialize
    def initialize(name, trainer_type)
	  tutornet_initialize(name, trainer_type) 
      @tutorlist=[]
      @tutornet=false
    end
end


class PokemonTutorNet_Scene
    def pbUpdate
      pbUpdateSpriteHash(@sprites)
    end
  
    def pbStartScene(commands)
      @commands = commands
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @sprites = {}
      @sprites["background"] = IconSprite.new(0, 0, @viewport)
      if Settings::BIGGER_FRAME_STYLE 
        @sprites["background"].setBitmap("Graphics/Plugins/Tutor.net/tutornetbg_bigger_frame")
        @sprites["commands"] = Window_CommandPokemon.newWithSize(
          @commands, 22, -12, 424, 424, @viewport
        )
      else  
        @sprites["background"].setBitmap("Graphics/Plugins/Tutor.net/tutornetbg_default")
        @sprites["commands"] = Window_CommandPokemon.newWithSize(
          @commands, -8, -12, 424, 424, @viewport
        )
      end  
      @sprites["commands"].windowskin = nil
      pbFadeInAndShow(@sprites) { pbUpdate }
    end
  
    def pbScene
      ret = -1
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          break
        elsif Input.trigger?(Input::USE)
          ret = @sprites["commands"].index
          break
        end
      end
      return ret
    end
  
    def pbSetCommands(newcommands, newindex)
      @sprites["commands"].commands = (!newcommands) ? @commands : newcommands
      @sprites["commands"].index    = newindex
    end
  
    def pbEndScene
      pbFadeOutAndHide(@sprites) { pbUpdate }
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
    end
end
  
#===============================================================================

class PokemonTutorNetScreen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen(movelist=[])
      commands = []
      cmdTurnOff = -1
      moveDefault=0
	  realcommands = tutor_net_build_list(commands,moveDefault,movelist)
	  realcommands[cmdTurnOff = realcommands.length]              = _INTL("Exit")
      @scene.pbStartScene(realcommands)
      loop do
        cmd = @scene.pbScene
        if cmd < 0
          pbPlayCloseMenuSE
          break
        elsif cmdTurnOff >= 0 && cmd == cmdTurnOff
          pbPlayCloseMenuSE
          break
        elsif cmd<realcommands.length
          update=pbMoveTutorNetChoose(commands[cmd][0][0],false,false,false,commands[cmd][0][1],commands[cmd][0][2])
          if update
			@scene.pbEndScene
			commands = []
			realcommands = tutor_net_build_list(commands,moveDefault,movelist)
			realcommands[cmdTurnOff = realcommands.length]              = _INTL("Exit")
			@scene.pbStartScene(realcommands)
		  end	
        else   # Exit
          pbPlayCloseMenuSE
          break
        end
      end
      @scene.pbEndScene
    end
end
  
def tutor_net_build_list(commands,moveDefault,movelist)
	for i in 0...$Trainer.tutorlist.length
		if !$Trainer.tutorlist[i].is_a?(Array)
		makeit=[$Trainer.tutorlist[i],0]
		$Trainer.tutorlist[i]=makeit
		end
	end   
	for i in $Trainer.tutorlist
    if i[2]!="$"
      if i[1]>1
        currencyname=GameData::Item.get(i[2]).name_plural
      else
        currencyname=GameData::Item.get(i[2]).name
      end
      if Settings::USE_TUTOR_MOVE_ALIASES
        aliaslist=Settings::TUTOR_MOVE_ALIASES
        for j in aliaslist
          currencyname = j[1] if j[0] == i[2]
        end
      end
    end     
		if movelist.length>0
			next if !movelist.include?(i[0])
		end	
		name=GameData::Move.get(i[0]).name
		if i[1]>0
			if i[2] == "$"
				name+=" - "+"$"+i[1].to_s
			else	
				name+=" - "+i[1].to_s+" "+currencyname
			end	
		end  
		commands.push([i,name]) if name!=nil && name!=""
	end
	commands.sort! {|a,b| a[1]<=>b[1]}
	commands.each_with_index {|item,index|
	moveDefault=index if item[0]==0
	}
	realcommands=[]
	for command in commands
		realcommands.push(_ISPRINTF("{1:s}",command[1]))
	end
	return realcommands
end	

#===============================================================================

def pbTutorNetTutor(movelist)
	pbFadeOutIn {
		scene = PokemonTutorNet_Scene.new
		screen = PokemonTutorNetScreen.new(scene)
		screen.pbStartScreen(movelist)
	  }	
end	

def pbMoveTutorNetChoose(move, movelist = nil, bymachine = false, oneusemachine = false ,cost=0, currency="$")
    ret = false
    move = GameData::Move.get(move).id
    movelist=nil
    if movelist.is_a?(Array)
      movelist.map! { |m| GameData::Move.get(m).id }
    end
    pbFadeOutIn {
      movename = GameData::Move.get(move).name
      annot = pbMoveTutorAnnotations(move, movelist)
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene, $player.party)
      screen.pbStartScene(_INTL("Teach which Pokémon?"), false, annot)
      loop do
        chosen = screen.pbChoosePokemon
        break if chosen < 0
        pokemon = $player.party[chosen]
        if pokemon.egg?
          pbMessage(_INTL("Eggs can't be taught any moves.")) { screen.pbUpdate }
        elsif pokemon.shadowPokemon?
          pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
        elsif movelist && movelist.none? { |j| j == pokemon.species }
          pbMessage(_INTL("{1} can't learn {2}.", pokemon.name, movename)) { screen.pbUpdate }
        elsif !pokemon.compatible_with_move?(move)
          pbMessage(_INTL("{1} can't learn {2}.", pokemon.name, movename)) { screen.pbUpdate }
        else
            if cost>0
			  if currency == "$"
				purchase_msg = _INTL("Purchase this move for {1}{2}?",currency,cost)
			  else
				purchase_msg = _INTL("Purchase this move for {1} {2}?",cost,GameData::Item.get(currency).name_plural)
			  end	
              if Kernel.pbConfirmMessage(purchase_msg)
                case currency
					#######################################
					# MONEY SECTION
					#######################################
					when "$"
					  if $Trainer.money>=cost
						for i in 0...$Trainer.tutorlist.length
						  if $Trainer.tutorlist[i][0]==move         
							  if pbLearnMove(pokemon,move,false,false) { screen.pbUpdate }
								  pbSEPlay("Slots coin",volume=80,pitch=80)
								  $Trainer.money-=cost
								  if Settings::PERMANENT_TUTOR_MOVE_UNLOCK 
									  cost=0
									  $Trainer.tutorlist[i][1]=0   
								  end	
								ret=true
								break
							  end
						  end
						end
					  else
						Kernel.pbMessage(_INTL("You don't have enough money."))
					  end
				  else
                    if $bag.quantity(currency)>=cost
                      for i in 0...$Trainer.tutorlist.length
                        if $Trainer.tutorlist[i][0]==move       
                            if pbLearnMove(pokemon,move,false,false) { screen.pbUpdate }
								pbSEPlay("Slots coin",volume=80,pitch=80)
								$bag.remove(currency,cost)
								if Settings::PERMANENT_TUTOR_MOVE_UNLOCK 
									cost=0
									$Trainer.tutorlist[i][1]=0   
								end	
                              ret=true
                              break
                            end
                        end
                      end
                    else
                      Kernel.pbMessage(_INTL("You don't have enough {1}.",GameData::Item.get(currency).name_plural))
                    end					 
                end
              end
            else            
               if  pbLearnMove(pokemon, move, false, bymachine) { screen.pbUpdate }
                    $stats.moves_taught_by_item += 1 if bymachine
                    $stats.moves_taught_by_tutor += 1 if !bymachine
                    pokemon.add_first_move(move) if oneusemachine
                    ret = true
                    break
               end
            end
        end
      end
      screen.pbEndScene
    }
    return ret   # Returns whether the move was learned by a Pokemon
end
  
  
def pbTutorNetAdd(move,cost=0,currency="$")
if !($Trainer.tutorlist)
  $Trainer.tutorlist=[]
end
if !$Trainer.tutornet
  Kernel.pbMessage(_INTL("By the way are you aware of Tutor.net? It's a PokéGear app we tutors have set up to make our services more accessible. Here, let me help you make an account."))
  pbSEPlay("Voltorb flip gain coins",volume=80,pitch=80)
  Kernel.pbMessage(_INTL("All done! Just boot up the Tutor.net app from your PokéGear app at any time now!"))
  !$Trainer.tutornet=true
end
for i in 0...$Trainer.tutorlist.length  
  if !$Trainer.tutorlist[i].is_a?(Array)
	makeit=[$Trainer.tutorlist[i],0,"$"]
	$Trainer.tutorlist[i]=makeit
  end
end
found=false
for i in 0...$Trainer.tutorlist.length
  if $Trainer.tutorlist[i][0]==move	
	found=true
	if ($Trainer.tutorlist[i][1]!=cost || $Trainer.tutorlist[i][2]!=currency) && $Trainer.tutorlist[i][1]>0 
		if cost ==0
			Kernel.pbMessage(_INTL("{1} is now free on your Tutor.net account!",GameData::Move.get(move).name))
			$Trainer.tutorlist[i][1]=cost
			$Trainer.tutorlist[i][2]=currency
		elsif $Trainer.tutorlist[i][1]>0
			Kernel.pbMessage(_INTL("{1} is already registered on your Tutor.net account with a different cost!",GameData::Move.get(move).name))
      current_cost = ""
      new_cost = ""
			if $Trainer.tutorlist[i][2]=="$"
				current_cost = _INTL("Current cost: ${1}",$Trainer.tutorlist[i][1])
			else
				current_cost = _INTL("Current cost: {1} {2}",$Trainer.tutorlist[i][1],GameData::Item.get($Trainer.tutorlist[i][2]).name_plural)
			end	
			if currency=="$"
				new_cost = _INTL("New cost: ${1}",cost)
			else
				new_cost = _INTL("New cost: {1} {2}",cost,GameData::Item.get(currency).name_plural)
			end
      cost_swap_msg = current_cost+"\n"+new_cost	
      Kernel.pbMessage(cost_swap_msg)		
			if Kernel.pbConfirmMessage(_INTL("Swap costs?"))
				$Trainer.tutorlist[i][1]=cost      
				$Trainer.tutorlist[i][2]=currency 
				Kernel.pbMessage(_INTL("The cost for {1} has been successfully changed!",GameData::Move.get(move).name))
			else	
				Kernel.pbMessage(_INTL("You decided to keep the old cost."))
			end
		end	
	end	
  end
end 
unlock_message = "Purchase"
unlock_message = "Permanently unlock" if Settings::PERMANENT_TUTOR_MOVE_UNLOCK       
if !found
	$Trainer.tutorlist.push([move,cost,currency])
	 if cost==0
	   Kernel.pbMessage(_INTL("{1} is now available on your Tutor.net account!",GameData::Move.get(move).name))
	 else  
	   Kernel.pbMessage(_INTL("{1} has been added to your Tutor.net wishlist!",GameData::Move.get(move).name))
	 end  
	return true             
end
return false
end

#Change the cost and the currency of said cost of a registered move in Tutor.net
def pbTutorNetChangeMoveCost(move,cost=0,currency="$")
  for i in 0...$Trainer.tutorlist.length
	if $Trainer.tutorlist[i][0]==move       
		$Trainer.tutorlist[i][1]=cost      
		$Trainer.tutorlist[i][2]=currency 
	end
  end
end

#-------------------------------------------------------------------------------
# Entry for Tutor.net in Voltseon's Pause Menu
#-------------------------------------------------------------------------------
class MenuEntryTutorNet < MenuEntry
  def initialize
    @icon = "menuPokegear"
    @name = "Tutor.net"
  end

  def selected(menu)
    pbFadeOutIn {
      scene = PokemonTutorNet_Scene.new
      screen = PokemonTutorNetScreen.new(scene)
      screen.pbStartScreen
    }
	end

  def selectable?
    #return ($player.party_count > 0)
    #added by Gardenette for camping menu
    return ($player.party_count > 0 && !$game_switches[83] && $game_switches[93])
  end
end