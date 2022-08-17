# Quest log class. Based on xLed's Jukebox Scene class and Reborn's Pulse Dex. 
class QuestLog_Scene
	attr_accessor :sprites
	#-----------------------------------------------------------------------------
	# * Object Initialization
	#     menu_index : command cursor's initial position
	#-----------------------------------------------------------------------------
	def initialize(menu_index = 0)
		@sprites={}
		@menu_index = menu_index
	end
  
	def pbUpdate
		pbUpdateSpriteHash(@sprites)
	end
	#-----------------------------------------------------------------------------
	# * Main Processing
	#-----------------------------------------------------------------------------
    def pbStartScene(commands)
		@commands = commands
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@sprites = {}
		@sprites["background"] = IconSprite.new(0,0,@viewport)
		@sprites["background"].setBitmap("Graphics/Pictures/questbg")
		@sprites["header"] = Window_UnformattedTextPokemon.newWithSize(
		   _INTL("Quest Log"),2,-18,256,64,@viewport)
		@sprites["header"].baseColor   = Color.new(248,248,248)
		@sprites["header"].shadowColor = Color.new(0,0,0)
		@sprites["header"].windowskin  = nil
		@sprites["commands"] = Window_CommandPokemon.newWithSize(@commands,
		   16,46,490,282,@viewport)
		@sprites["commands"].windowskin = nil
		@sprites["commands"].index = @menu_index
		pbFadeInAndShow(@sprites) { pbUpdate }
	  
	   if($game_variables[999])
		  @sprites["leftarrow"]=AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
		  @sprites["leftarrow"].play
		  @sprites["leftarrow"].x=-4
		  @sprites["leftarrow"].y=Graphics.height/2-20
		else
		  @sprites["rightarrow"]=AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
		  @sprites["rightarrow"].play
		  @sprites["rightarrow"].x=Graphics.width-38
		  @sprites["rightarrow"].y=Graphics.height/2-20
		end
	end
    def pbScene
		ret = -1
		loop do
			Graphics.update
			Input.update
			pbUpdate
			if Input.trigger?(Input::BACK)
				pbPlayCloseMenuSE
				break
			elsif Input.trigger?(Input::USE)
				ret = @sprites["commands"].index
				break
			end
			if Input.repeat?(Input::LEFT) || Input.repeat?(Input::RIGHT)
				$game_variables[999]= !$game_variables[999]
				if $game_variables[999]
					$game_variables[997]=@sprites["commands"].index
					$game_variables[998] ||= 0
					pbDisposeSprite(@sprites,"rightarrow")
					@sprites["leftarrow"]=AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
					@sprites["leftarrow"].play
					@sprites["leftarrow"].x=-4
					@sprites["leftarrow"].y=Graphics.height/2-20
					self.pbSetCommands(pbQuestSeen,$game_variables[998])
					
				else
					$game_variables[998]=@sprites["commands"].index
					$game_variables[997] ||= 0
					pbDisposeSprite(@sprites,"leftarrow")
					@sprites["rightarrow"]=AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
					@sprites["rightarrow"].play
					@sprites["rightarrow"].x=Graphics.width-38
					@sprites["rightarrow"].y=Graphics.height/2-20
					self.pbSetCommands(pbQuestSeen,$game_variables[997])
				end
				pbPlayCursorSE()
			end
		end
		return ret
	end

	def pbSetCommands(newcommands,newindex)
		@sprites["commands"].commands = (!newcommands) ? @commands : newcommands
		@sprites["commands"].index    = newindex
	end

	def pbEndScene
	pbFadeOutAndHide(@sprites) { pbUpdate }
	pbDisposeSpriteHash(@sprites)
	@viewport.dispose
	end
end    

class QuestLogScreen
	def initialize(scene)
		@scene = scene
	end

	def pbStartScreen
		commands = pbQuestSeen
		for i in 0..commands.length-1
			instance_variable_set("@cmd#{i}", -1)
			commands[i]= _INTL(commands[i])
		end
		@scene.pbStartScene(commands)
		loop do
			cmd = @scene.pbScene
			commands = pbQuestSeen
			if cmd<0
				pbPlayCloseMenuSE
				break
			elsif commands[cmd] != "Back" 
				####if the quest is called ??? we don't let the player access it
				if commands[cmd] != "???"
					if $game_variables[999]
						$game_variables[998]=commands.index(commands[cmd])
					else
						$game_variables[997]=commands.index(commands[cmd])
					end
					pbPlayDecisionSE
					pbFadeOutIn {
						scene = QuestInfo_Scene.new(commands.index(commands[cmd]))
						screen = QuestInfoScreen.new(scene)
						screen.pbStartScreen
					}
				end
		    else   # Exit
				pbPlayCloseMenuSE
				break
			end
		end
		@scene.pbEndScene
	end
end

#-----------------------------------------------------------------------------
# * Determines which Quests the trainer has knowledge about
#-----------------------------------------------------------------------------
def pbQuestSeen
	questSeen = []
	###we sort the quests based on their completion flag : first the  ongoing
	###quests, then those that are complete, and finally those that are 
	###undiscovered
	sort_order =["1","0","2"]
	$QuestLog= $QuestLog.sort_by {|a| a[sort_order.index(a[1].to_s)]}
	for i in 0..$QuestLog.length-1
		###if the quest is flagged as undiscovered we call it ???, otherwise
		###we show it's name, if it's completed we add "done" before it
		### either way we create an entry in the menu
	    if $QuestLog[i][2]==$game_variables[999].to_s
			if $QuestLog[i][1].to_i==0
				questSeen.push("???")
			elsif $QuestLog[i][1].to_i==1
				#'\\c[10]'+
				questSeen.push($QuestLog[i][0])
			else
				#"\c[3]"+
				questSeen.push("[DONE]"+$QuestLog[i][0])
			end
		end
	end
	### we add the return to previous menu button
	questSeen.push("Back")
	return questSeen
end

###quick class that plays a key role in handling the different pages of a quest.
###it will make more sense later on
class Screen_Values
	attr_accessor :l
	attr_accessor :current_index
	def initialize(l,index)
		@l=l
		@current_index=index
	end
end
