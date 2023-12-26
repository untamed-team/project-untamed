
#DemICE make it so you cannot edit EVs during battle
class Battle
  alias mixed_ev_alloc_pbPartyScreen pbPartyScreen
  def pbPartyScreen(idxBattler, checkLaxOnly = false, canCancel = false, shouldRegister = false)
		$donteditEVs=true
    ret = mixed_ev_alloc_pbPartyScreen(idxBattler, checkLaxOnly, canCancel, shouldRegister)
		$donteditEVs=false
	return ret
  end	
end	

#DemICE implementing EV allocation system
class EVAllocationSprite < Sprite
	attr_reader :preselected
	attr_reader :index
	
	def initialize(viewport=nil,fifthmove=false)
		super(viewport)
		@EVsel=AnimatedBitmap.new("Graphics/Pictures/Level Based Mixed EV System and Allocator/EVsel")    
		@frame=0
		@index=0
		@fifthmove=fifthmove
		@preselected=false
		@updating=false
		@spriteVisible=true
		refresh
	end
	
	def dispose
		@EVsel.dispose
		super
	end
	
	def index=(value)
		@index=value
		refresh
	end
	
	def preselected=(value)
		@preselected=value
		refresh
	end
	
	def visible=(value)
		super
		@spriteVisible=value if !@updating
	end
	
	def refresh
		w=@EVsel.width
		h=@EVsel.height
		self.x=226
		self.y=76
		self.y=88+(self.index*32) if self.index>0
		self.bitmap=@EVsel.bitmap
		if self.preselected
			self.src_rect.set(0,h,w,h)
		else
			self.src_rect.set(0,0,w,h)
		end
	end
	
	def update
		@updating=true
		super
		@EVsel.update
		@updating=false
		refresh
	end
end


class EVAllocationSprite2 < Sprite
	attr_reader :preselected
	attr_reader :index
	
	def initialize(viewport=nil,fifthmove=false)
		$donteditEVs = true if $game_variables[MECHANICSVAR] >= 3 #by low
		super(viewport)
		if PluginManager.installed?("BW Summary Screen") 	
			@EVsel2=AnimatedBitmap.new("Graphics/Pictures/Level Based Mixed EV System and Allocator/EVsel2BW")
		elsif true#PluginManager.installed?("EVs and IVs in Summary v20") 	
			@EVsel2=AnimatedBitmap.new("Graphics/Pictures/Level Based Mixed EV System and Allocator/EVsel2evsivs")
		else	
			@EVsel2=AnimatedBitmap.new("Graphics/Pictures/Level Based Mixed EV System and Allocator/EVsel2") 
		end  
		@frame=0
		@index=0
		@fifthmove=fifthmove
		@preselected=false
		@updating=false
		@spriteVisible=true
		refresh
	end
	
	def dispose
		@EVsel2.dispose
		super
	end
	
	def index=(value)
		@index=value
		refresh
	end
	
	def preselected=(value)
		@preselected=value
		refresh
	end
	
	def visible=(value)
		super
		@spriteVisible=value if !@updating
	end
	
	def refresh
		w=@EVsel2.width
		h=@EVsel2.height
		self.x=219
		self.y=76
		self.y=88+(self.index*32) if self.index>0
		self.bitmap=@EVsel2.bitmap
		if self.preselected
			self.src_rect.set(0,h,w,h)
		else
			self.src_rect.set(0,0,w,h)
		end
	end
	
	def update
		@updating=true
		super
		@EVsel2.update
		@updating=false
		refresh
	end
end


class PokemonSummary_Scene

  alias mixed_ev_alloc_pbStartScene pbStartScene
  def pbStartScene(party, partyindex, inbattle = false)
	mixed_ev_alloc_pbStartScene(party, partyindex, inbattle)
	#DemICE implementing EV allocation system
	@sprites["EVsel"]=EVAllocationSprite.new(@viewport)
	@sprites["EVsel"].visible=false     
	@sprites["EVsel2"]=EVAllocationSprite2.new(@viewport)
	@sprites["EVsel2"].visible=false         
	@sprites["EVsel3"]=EVAllocationSprite2.new(@viewport)
	@sprites["EVsel3"].visible=false 
	$evalloc=false
	#DemICE end
  end
  
  #>>DemICE - Implementing the EV allocation system.
  	#DemICE>>  
	def pbEVAllocation
		return if $donteditEVs
		$evalloc=true
		@sprites["EVsel"].visible=true
		@sprites["EVsel2"].visible=true
		@sprites["EVsel"].index=0
		@sprites["EVsel2"].index=0
		selEV=0
		editev=0
		evpool=80+@pokemon.level*8
		evpool=(evpool.div(4))*4      
		evpool=512 if evpool>512    
		evcap=40+@pokemon.level*4
		evcap=(evcap.div(4))*4
		evcap=252 if evcap>252
		evsum=@pokemon.ev[:HP]+@pokemon.ev[:ATTACK]+@pokemon.ev[:DEFENSE]+@pokemon.ev[:SPECIAL_DEFENSE]+@pokemon.ev[:SPEED]
		evsum+=@pokemon.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE
		drawPage(3) 
		loop do
			evpool=80+@pokemon.level*8
			evpool=(evpool.div(4))*4      
			evpool=512 if evpool>512    
			evcap=40+@pokemon.level*4
			evcap=(evcap.div(4))*4
			evcap=252 if evcap>252
			evsum=@pokemon.ev[:HP]+@pokemon.ev[:ATTACK]+@pokemon.ev[:DEFENSE]+@pokemon.ev[:SPECIAL_DEFENSE]+@pokemon.ev[:SPEED]   
			evsum+=@pokemon.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE    
			Graphics.update
			Input.update
			pbUpdate
			if Settings::PURIST_MODE
				case selEV
				when 0
					editev=@pokemon.ev[:HP]
				when 1
					editev=@pokemon.ev[:ATTACK]
				when 2
					editev=@pokemon.ev[:DEFENSE]
				when 3
					editev=@pokemon.ev[:SPECIAL_ATTACK]
				when 4
					editev=@pokemon.ev[:SPECIAL_DEFENSE]
				when 5
					editev=@pokemon.ev[:SPEED]
				end  
			else
				case selEV
				when 0
					editev=@pokemon.ev[:HP]
				when 1
					editev=@pokemon.ev[:ATTACK]
				when 2
					editev=@pokemon.ev[:DEFENSE]
				when 3
					editev=@pokemon.ev[:SPECIAL_DEFENSE]
				when 4
					editev=@pokemon.ev[:SPEED]
				end 
			end	  	
			if Input.trigger?(Input::B)
				@sprites["EVsel"].visible=false
				@sprites["EVsel2"].visible=false
				@sprites["EVsel3"].visible=false
				break
			end
			if Input.trigger?(Input::Y)
				# for i in 0...6
				# 	@pokemon.ev[i]=0
				# end
				@pokemon.ev[:HP]=0
				@pokemon.ev[:ATTACK]=0
				@pokemon.ev[:DEFENSE]=0
				@pokemon.ev[:SPECIAL_ATTACK]=0
				@pokemon.ev[:SPECIAL_DEFENSE]=0
				@pokemon.ev[:SPEED]=0
				@pokemon.calc_stats
				Graphics.update
				Input.update
				pbUpdate  
				drawPage(3)
			end
			if Input.trigger?(Input::DOWN)
				selEV+=1
				selEV=0 if selEV>5
				selEV=5 if selEV<0
				@sprites["EVsel"].index=selEV
				@sprites["EVsel2"].index=selEV
				if !Settings::PURIST_MODE
					if selEV==1
						@sprites["EVsel3"].visible=true
						@sprites["EVsel3"].index=3
					elsif selEV==3
						@sprites["EVsel3"].visible=true
						@sprites["EVsel3"].index=1
					else
						@sprites["EVsel3"].visible=false
					end 
				end	
				pbPlayCursorSE()
			end
			if Input.trigger?(Input::UP)
				selEV-=1
				selEV=0 if selEV>5
				selEV=5 if selEV<0
				@sprites["EVsel"].index=selEV
				@sprites["EVsel2"].index=selEV
				if !Settings::PURIST_MODE
					if selEV==1
						@sprites["EVsel3"].visible=true
						@sprites["EVsel3"].index=3
					elsif selEV==3
						@sprites["EVsel3"].visible=true
						@sprites["EVsel3"].index=1
					else
						@sprites["EVsel3"].visible=false
					end 
				end	
				pbPlayCursorSE( )
			end
			if Input.trigger?(Input::LEFT)
				case selEV
				when 0
					@pokemon.ev[:HP]-=4
					if @pokemon.ev[:HP]<0
						@pokemon.ev[:HP]=0
						if (evpool-evsum)>evcap
							@pokemon.ev[:HP]=evcap
						else
							@pokemon.ev[:HP]=evpool-evsum
						end
						@pokemon.ev[:HP]=(@pokemon.ev[:HP].div(4))*4
					end
					@pokemon.calc_stats
				when 1
					@pokemon.ev[:ATTACK]-=4
					if @pokemon.ev[:ATTACK]<0
						@pokemon.ev[:ATTACK]=0
						if (evpool-evsum)>evcap
							@pokemon.ev[:ATTACK]=evcap
						else
							@pokemon.ev[:ATTACK]=evpool-evsum
						end
						@pokemon.ev[:ATTACK]=(@pokemon.ev[:ATTACK].div(4))*4
					end
					@pokemon.calc_stats
				when 2
					@pokemon.ev[:DEFENSE]-=4
					if @pokemon.ev[:DEFENSE]<0
						@pokemon.ev[:DEFENSE]=0
						if (evpool-evsum)>evcap
							@pokemon.ev[:DEFENSE]=evcap
						else
							@pokemon.ev[:DEFENSE]=evpool-evsum
						end
						@pokemon.ev[:DEFENSE]=(@pokemon.ev[:DEFENSE].div(4))*4
					end
					@pokemon.calc_stats
				when 3
					if Settings::PURIST_MODE	
						@pokemon.ev[:SPECIAL_ATTACK]-=4
						if @pokemon.ev[:SPECIAL_ATTACK]<0
							@pokemon.ev[:SPECIAL_ATTACK]=0
							if (evpool-evsum)>evcap
								@pokemon.ev[:SPECIAL_ATTACK]=evcap
							else
								@pokemon.ev[:SPECIAL_ATTACK]=evpool-evsum
							end
							@pokemon.ev[:SPECIAL_ATTACK]=(@pokemon.ev[:SPECIAL_ATTACK].div(4))*4
						end
					else		
						@pokemon.ev[:ATTACK]-=4
						if @pokemon.ev[:ATTACK]<0
							@pokemon.ev[:ATTACK]=0
							if (evpool-evsum)>evcap
								@pokemon.ev[:ATTACK]=evcap
							else
								@pokemon.ev[:ATTACK]=evpool-evsum
							end
							@pokemon.ev[:ATTACK]=(@pokemon.ev[:ATTACK].div(4))*4
						end
					end	
					@pokemon.calc_stats
				when 4
					@pokemon.ev[:SPECIAL_DEFENSE]-=4
					if @pokemon.ev[:SPECIAL_DEFENSE]<0
						@pokemon.ev[:SPECIAL_DEFENSE]=0
						if (evpool-evsum)>evcap
							@pokemon.ev[:SPECIAL_DEFENSE]=evcap
						else
							@pokemon.ev[:SPECIAL_DEFENSE]=evpool-evsum
						end
						@pokemon.ev[:SPECIAL_DEFENSE]=(@pokemon.ev[:SPECIAL_DEFENSE].div(4))*4
					end
					@pokemon.calc_stats
				when 5
					@pokemon.ev[:SPEED]-=4
					if @pokemon.ev[:SPEED]<0
						@pokemon.ev[:SPEED]=0
						if (evpool-evsum)>evcap
							@pokemon.ev[:SPEED]=evcap
						else
							@pokemon.ev[:SPEED]=evpool-evsum
						end
						@pokemon.ev[:SPEED]=(@pokemon.ev[:SPEED].div(4))*4
					end
					@pokemon.calc_stats
				end  
				@pokemon.calc_stats
				Graphics.update
				Input.update
				pbUpdate    
				dorefresh=true
				drawPage(3)            
			end
			if Input.trigger?(Input::RIGHT)
				case selEV
				when 0
					@pokemon.ev[:HP]+=4
					@pokemon.ev[:HP]=0 if @pokemon.ev[:HP]>evcap || evsum>=evpool
				when 1
					@pokemon.ev[:ATTACK]+=4
					@pokemon.ev[:ATTACK]=0 if @pokemon.ev[:ATTACK]>evcap || evsum>=evpool
				when 2
					@pokemon.ev[:DEFENSE]+=4
					@pokemon.ev[:DEFENSE]=0 if @pokemon.ev[:DEFENSE]>evcap || evsum>=evpool
				when 3
					if Settings::PURIST_MODE
						@pokemon.ev[:SPECIAL_ATTACK]+=4
						@pokemon.ev[:SPECIAL_ATTACK]=0 if @pokemon.ev[:SPECIAL_ATTACK]>evcap || evsum>=evpool
					else	
						@pokemon.ev[:ATTACK]+=4
						@pokemon.ev[:ATTACK]=0 if @pokemon.ev[:ATTACK]>evcap || evsum>=evpool
					end
				when 4
					@pokemon.ev[:SPECIAL_DEFENSE]+=4
					@pokemon.ev[:SPECIAL_DEFENSE]=0 if @pokemon.ev[:SPECIAL_DEFENSE]>evcap || evsum>=evpool
				when 5
					@pokemon.ev[:SPEED]+=4
					@pokemon.ev[:SPEED]=0 if @pokemon.ev[:SPEED]>evcap || evsum>=evpool
					@pokemon.ev[:SPEED]=(@pokemon.ev[:SPEED].div(4))*4
				end  
				@pokemon.calc_stats
				Graphics.update
				Input.update
				pbUpdate    
				dorefresh=true
				drawPage(3)           
			end      
		end 
		$evalloc=false
		@sprites["EVsel"].visible=false
		@sprites["EVsel2"].visible=false
	end 
	
	def drawPageThree #overhauled #by low
		overlay = @sprites["overlay"].bitmap
		base   = Color.new(248, 248, 248)
		shadow = Color.new(104, 104, 104)
		# Determine which stats are boosted and lowered by the Pokémon's nature
		statshadows = {}
		GameData::Stat.each_main { |s| statshadows[s.id] = shadow }
		if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
			@pokemon.nature_for_stats.stat_changes.each do |change|
			statshadows[change[0]] = Color.new(255, 0, 0) if change[1] > 0
			statshadows[change[0]] = Color.new(0, 148, 255) if change[1] < 0
			end
		end
    base_stats = @pokemon.baseStats
    stats = {}
    GameData::Stat.each_main do |s|
      stats[s.id] = base_stats[s.id]
    end
		# Write various bits of text		
		if Settings::PURIST_MODE
			spatk=:SPECIAL_ATTACK
		else
			spatk=:ATTACK
		end
    # Write various bits of text
    textpos = [
      [_INTL("HP"), 250, 82, 2, base, statshadows[:HP]],
      [sprintf("%d/%d", @pokemon.hp, @pokemon.totalhp), 442, 82, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:HP]), 496, 83, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Attack"), 238, 126, 0, base, statshadows[:ATTACK]],
      [sprintf("%d", @pokemon.attack), 436, 126, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:ATTACK]), 496, 127, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Defense"), 238, 158, 0, base, statshadows[:DEFENSE]],
      [sprintf("%d", @pokemon.defense),436, 158, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:DEFENSE]), 496, 159, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Sp. Atk"), 238, 190, 0, base, statshadows[:SPECIAL_ATTACK]],
      [sprintf("%d", @pokemon.spatk), 436, 190, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:SPECIAL_ATTACK]), 496, 191, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Sp. Def"), 238, 222, 0, base, statshadows[:SPECIAL_DEFENSE]],
      [sprintf("%d", @pokemon.spdef), 436, 222, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:SPECIAL_DEFENSE]), 496, 223, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Speed"), 238, 254, 0, base, statshadows[:SPEED]],
      [sprintf("%d", @pokemon.speed), 436, 254, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
			[sprintf("%d", stats[:SPEED]), 496, 255, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)]
    ]
		#DemICE adding the unused EVs
		totalevs=80+@pokemon.level*8
		totalevs=(totalevs.div(4))*4      
		totalevs=512 if totalevs>512        
		evpool=totalevs-@pokemon.ev[:HP]-@pokemon.ev[:ATTACK]-@pokemon.ev[:DEFENSE]-@pokemon.ev[:SPECIAL_DEFENSE]-@pokemon.ev[:SPEED]
		evpool-=@pokemon.ev[:SPECIAL_ATTACK] if Settings::PURIST_MODE  
		
		#DemICE adding ev allocation instructions
		if $evalloc
			textpos.push(
				[sprintf("%d", @pokemon.ev[:HP]), 348, 82, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
				[sprintf("%d", @pokemon.ev[:ATTACK]), 374, 127, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
				[sprintf("%d", @pokemon.ev[:DEFENSE]), 374, 159, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
				[sprintf("%d", @pokemon.ev[spatk]), 374, 191, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
				[sprintf("%d", @pokemon.ev[:SPECIAL_DEFENSE]), 374, 223, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
				[sprintf("%d", @pokemon.ev[:SPEED]), 374, 255, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)]
			)
			textpos.push(["EV Pool:",224,290,0,base, shadow])
			textpos.push([sprintf("%d", evpool), 344, 290, 1, base, shadow])
			textpos.push(["[S] resets EVs",362,290,0,Color.new(64,64,64),Color.new(176,176,176)])
			drawTextEx(overlay,224,322,282,2,"When EV is 0:     [<-] to max.  When EV is max: [->] to 0.",Color.new(64,64,64),Color.new(176,176,176))
		else
			# Draw ability name and description
			textpos.push([_INTL("Ability"), 224, 290, 0, base, shadow])
			ability = @pokemon.ability
			if ability
				textpos.push([ability.name, 362, 290, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
				#abilitydesc = _INTL("Press {1} to view ability description.",$PokemonSystem.game_controls.find{|c| c.control_action=="Registered Item"}.key_name)
				abilitydesc = @pokemon.ability.description
        drawTextEx(overlay,224,320,282+12,2,abilitydesc,Color.new(64,64,64),Color.new(176,176,176))
			end
		end	
		
		# Draw all text
		pbDrawTextPositions(overlay, textpos)
		# Draw HP bar
		if @pokemon.hp > 0	
			w = @pokemon.hp * 96 / @pokemon.totalhp.to_f	
			w = 1 if w < 1	
			w = ((w / 2).round) * 2	
			hpzone = 0	
			hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor	
			hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor	
			imagepos = [["Graphics/Pictures/Summary/overlay_hp", 339, 111, 0, hpzone * 6, w, 6]]	
			pbDrawImagePositions(overlay, imagepos)
		end
	end

  def pbScene
    @pokemon.play_cry
    loop do
      Graphics.update
      Input.update
      pbUpdate
      dorefresh = false
      if Input.trigger?(Input::ACTION)
        pbSEStop
        @pokemon.play_cry
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        if @page == 3 && !$donteditEVs
          pbPlayDecisionSE
		  pbEVAllocation
          dorefresh = true
        elsif @page == 4
          pbPlayDecisionSE
          pbMoveSelection
          dorefresh = true
        elsif @page == 5
          pbPlayDecisionSE
          pbRibbonSelection
          dorefresh = true
        elsif !@inbattle
          pbPlayDecisionSE
          dorefresh = pbOptions
        end
      elsif Input.trigger?(Input::UP) && @partyindex > 0
        oldindex = @partyindex
        pbGoToPrevious
        if @partyindex != oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::DOWN) && @partyindex < @party.length - 1
        oldindex = @partyindex
        pbGoToNext
        if @partyindex != oldindex
          pbChangePokemon
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage = @page
        @page -= 1
        @page = 1 if @page < 1
        @page = 5 if @page > 5
        if @page != oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage = @page
        @page += 1
        @page = 1 if @page < 1
        @page = 5 if @page > 5
        if @page != oldpage   # Move to next page
          pbSEPlay("GUI summary change page")
          @ribbonOffset = 0
          dorefresh = true
        end
      #which button to press has been edited by Gardenette for keybinding purposes
			#elsif Input.trigger?(Input::SPECIAL) && !@pokemon.egg? && @page == 3 # extra long ability desc #by low
			#	pbMessage(_INTL("{1}: {2}",@pokemon.ability.name,@pokemon.ability.description))
      end
      if dorefresh
        drawPage(@page)
      end
    end
    return @partyindex
  end    
  
end