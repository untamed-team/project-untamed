
###class to define an individual subpage for a quest
class QuestInfo_Scene
	attr_accessor :offset
	attr_accessor :background
	attr_accessor :index
	attr_accessor :scrolling
	attr_accessor :screens
	attr_accessor :threshold
	attr_accessor :screen_index
	attr_accessor :viewport
	def initialize(index)
		@index      = index
		###by default (a quest fits on a single page) we don't scroll
		@scrolling=false
		@threshold=Graphics.height-32
		@screen_index=0
		@viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z=99999  
		@screens =[]
	end
  
  
  
	def pbStartScene(commands)
		fadein = true
		
		# Makes the text window
		@sprites={}
		@sprites["background"] = IconSprite.new(0,0,@viewport)
		@sprites["background"].setBitmap("Graphics/Pictures/questbg2")
		@sprites["background"].z=0
		@currentlog=$QuestLog.select{ |n| n[2]== $game_variables[999].to_s }
		###title of the quest
		@sprites["header"]=Window_UnformattedTextPokemon.newWithSize(_INTL(@currentlog[@index][0]),
		130,-8,512,64,@viewport)
		@sprites["header"].shadowColor=Color.new(0,0,0)
		@sprites["header"].windowskin=nil
		###depending of the completion state we adjust it's text color
		col = Color.new(248,248,248)
		if @currentlog[@index][1].to_i==2
		  var="clear"
		  col = Color.new(0,255,0)
		elsif  @currentlog[@index][1].to_i==1
		  var="inprogress"
		  col=Color.new(255,165,0)
		else
		  var="undiscovered"
		end
		@sprites["header"].baseColor=col
	end

	def pbScene
		@screen_index=0
		###we create the different subpages until we determine we reached the last
		@screens.push(Screen_Values.new(0,0))
		while @screen_index!=@screens.size
			createSprites
			@screen_index+=1
		end
		###we set ourselves back to the first page
		@screen_index=0
		createSprites
		# Execute transition
		Graphics.transition
		# Main loop
		ret = -1
		loop do
			Graphics.update
			Input.update
			pbUpdate
			if Input.trigger?(Input::BACK)
				pbPlayCloseMenuSE
				break
			end
		end
		return ret
	end
  
	def pbUpdate
		pbUpdateSpriteHash(@sprites)
		update_command
	end  

    def update_command
		##handling pressing left and right on the pages
		if Input.repeat?(Input::LEFT) && @scrolling==true
			if @screen_index>0
				@screen_index+=-1
			else
				@screen_index+=@screens.length-1
			end
			createSprites
			#pbFadeInAndShow(@sprites) { update }
			pbPlayCursorSE()
		end
		if Input.repeat?(Input::RIGHT) && @scrolling==true
			if(@screen_index< @screens.length-1)
				@screen_index+=1
			else
				@screen_index=0
			end
			createSprites
			#pbFadeInAndShow(@sprites) { update }
			pbPlayCursorSE()
		end
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
  
    ###this is the big function that creates the content of the subpages.
    ###basically we create a sprite object in which we put the content of one objective
    ###of the quest and color it according to it's status
    def createSprites()
		j=0
		timetostop=false
		###given the screen we currently are in, we fetch the corresponding entry in 
		### the little class we defined earlier
		s= @screens[@screen_index]
		###we duplicate l because we need it's original value at some point in the loop
		### but we also need to increment it
		l=s.l
		startpoint=l +s.current_index
		###rather than starting at zero, we start at the value of startpoint, which
		###should match to the value of the first objective not displayed on the
		###previous page
		pbDisposeSprite(@sprites,"rightarrow")
		pbDisposeSprite(@sprites,"leftarrow")
		for i in 0..@currentlog[@index][3].length-1
			###if we haven't reached the threshold value to stop creating sprites
			pbDisposeSprite(@sprites,"body "+i.to_s)
			if (i>=startpoint &&!timetostop)
				if @currentlog[@index][3][i][0].to_i==2
					var="done"
				elsif  @currentlog[@index][3][i][0].to_i==1
					var="inprogress"
				else
					var="undiscovered"
					##if we skip one message we decrease j by one to account for the offset
					##and increase l
					j=j-1
					l+=1
				end
				###if the objective is marked as undiscovered, we skip it. this allow us
				###to avoid having blanks in the quest log entry
				if var!="undiscovered"
					@sprites["body "+(i-l).to_s]=Window_UnformattedTextPokemon.newWithSize(
					_INTL(@currentlog[@index][3][i][1]),
					10,
					##we calculate the y coordinate based on the index (accounting for the
					##starting point) and the number of lines so far that have taken more 
					###than one line
					24+32*((i-startpoint)+j),
					512,
					64*((@currentlog[@index][3][i][1].length/48)+1),
					@viewport)
					##we increment j by the number of lines above it took to print this line
					j+=(@currentlog[@index][3][i][1].length/48)
					###same as the title, color depending of the objective's state
					if var=="done"
						@sprites["body "+(i-l).to_s].baseColor=Color.new(0,255,0)
					else
						@sprites["body "+(i-l).to_s].baseColor=Color.new(255,165,0)
					end
					@sprites["body "+(i-l).to_s].shadowColor=Color.new(0,0,0)
					@sprites["body "+(i-l).to_s].windowskin=nil
					###if there's less than 32 pixels of space after printing the current
					###objective, we stop printing sprites
					var = @sprites["body "+(i-l).to_s].y 
					var +=@sprites["body "+(i-l).to_s].height
					var +=32
					if var>@threshold && !timetostop
						###if we reached the bottom of the screen but still have stuff to do
						if i<@currentlog[@index][3].length-1
							@scrolling=true
						end
						timetostop=true
						##we push the relevant data about the page
						if(i< @currentlog[@index][3].length-1 && @screen_index==@screens.length-1)
							offset=l-s.l >0 ? 0 : s.l
							@screens.push(Screen_Values.new(offset,i+1))
						end
					end
				end
			end
		end
		###after all of that we create/recreate the arrows depending of what's needed
		if(@screen_index!=0)
			@sprites["leftarrow"]=AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
			@sprites["leftarrow"].play
			@sprites["leftarrow"].x=-4
			@sprites["leftarrow"].y=Graphics.height/2-20
		end
		if(@screen_index<@screens.length-1)
			@sprites["rightarrow"]=AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
			@sprites["rightarrow"].play
			@sprites["rightarrow"].x=Graphics.width-38
			@sprites["rightarrow"].y=Graphics.height/2-20
		end
    end
end

def updateQuestLog(start=0)
	tempLog =$QuestLog.clone
	$QuestLog=load_data("Data/quests.dat")
	if start>$QuestLog.length-1
		start =$QuestLog.length-1
	end
	if start>0
		$QuestLog=$QuestLog.drop(start)
	end
	for i in 0..$QuestLog.length-1
		quest= tempLog.detect { |q| q[0] ==$QuestLog[i][0] }
		if quest!=nil
			$QuestLog[i][1]=quest[1]
			for j in 0..quest[3].length-1
				if $QuestLog[i][3][j][0]!=quest[3][j][0] 
					$QuestLog[i][3][j][0]= quest[3][j][0]
				end
			end
		end
	end
end

#===============================================================================
#
#===============================================================================
class QuestInfoScreen
    def initialize(scene)
		@scene = scene
    end

	def pbStartScreen
		commands = []
		@scene.pbStartScene(commands)
		loop do
			cmd = @scene.pbScene
			if Input.trigger?(Input::BACK)
				break
			end
		end
		@scene.pbEndScene
	end
end

def pbSetQuestGoal(title,goal,newstate,shouldrevealnextgoal=false,shouldcomplete=false)
	quest= $QuestLog.detect { |q| q[0].downcase == title.downcase }
	if !goal.is_a? Integer
		goal = quest[3].detect{ |r|  r[1].downcase.include?(goal.downcase)}

		goal[0]=newstate
	else
		quest[3][goal][0]=newstate
	end
	status = "in progress."
	allstates=[]
	quest[3].each do |goal|
		allstates << goal[0]
	end
	
	if shouldrevealnextgoal
		if (goal.is_a? Integer) && (goal+1)<quest[3].length
			quest[3][goal+1][0]=1
		elsif quest[3].index(goal)<quest[3].length-1
			quest[3][quest[3].index(goal)+1][0]=1 
		end
	end
	if (allstates.uniq.size <= 1 && allstates[0]==2)|| shouldcomplete
		quest[1]="2"
		status ="completed!"
	end
	
	if quest[1]=="0"
		quest[1]="1"
		status = "added!"
	end
	
	$scene.spriteset.addUserSprite(LocationWindow.new(_INTL("Quest Log updated : " + title +" : " +status)))
end

def getQuestState(title,goal)
	state=nil
	quest= $QuestLog.detect { |q| q[0].downcase == title.downcase }
	if !goal.is_a? Integer
		goal = quest[3].detect{ |r|  r[1].downcase.include?(goal.downcase)}

		state=goal[0]
	else
		state=quest[3][goal][0]
	end
	return state
end