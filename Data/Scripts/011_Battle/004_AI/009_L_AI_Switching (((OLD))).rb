# this is a fuckin mess
=begin
class Battle::AI
	def pbShouldSwitch?(index)    
		#return false if !@opponent || $game_switches[318]		
		switchscore = 0
		noswitchscore = 0
		monarray = []
		currentmon = @battle.battlers[index]
		opponent1 = @battle.battlers[0] #currentmon.pbDirectOpposing
		if !opponent1.allAllies.empty? # double battle
			opponent2 = @battle.battlers[2]
		else
			opponent2 = @battle.battlers[0].clone
			#~ opponent2.hp = 0
		end
		party = @battle.pbParty(index)
		partyroles = []
		if @battle.wildBattle? 
			skill = 0
		else
			skill = @battle.pbGetOwnerFromBattlerIndex(index).skill_level
		end
		count = @battle.pbAbleNonActiveCount(currentmon.idxOwnSide)
		return false if count==1
		return false if count==2
		count = 0
		for i in 0..(party.length-1)
			next if !@battle.pbCanSwitchLax?(index,i)
			count+=1
		end
		return false if count==0
		count = -1        
		for i in party      
			count+=1
			next if i.nil? || i.fainted?
			next if count == index
			dummyarr1 = pbGetPokemonRole(i,opponent1,count,party)
			(partyroles << dummyarr1).flatten!
			dummyarr2 = pbGetPokemonRole(i,opponent2,count,party)
			(partyroles << dummyarr2).flatten!
		end  
		#~ print "wawa the first"
		partyroles.uniq!
		currentroles = pbGetPokemonRole(currentmon,opponent1)
		# Statuses
		Console.echoln "Initial switchscore building: Statuses #{switchscore}" #if $INTERNAL
		if currentmon.effects[PBEffects::Curse]
			switchscore+=80
		end
		if currentmon.effects[PBEffects::LeechSeed]>=0
			switchscore+=60
		end
		if currentmon.effects[PBEffects::Attract]>=0
			switchscore+=60
		end    
		if currentmon.effects[PBEffects::Confusion]>0
			switchscore+=80
		end    
		if currentmon.effects[PBEffects::PerishSong]==2
			switchscore+=40
		elsif currentmon.effects[PBEffects::PerishSong]==1
			switchscore+=200
		end    
		if currentmon.effects[PBEffects::Toxic]>0
			switchscore+= (currentmon.effects[PBEffects::Toxic]*15)
		end   
		if currentmon.hasActiveAbility?(:NATURALCURE) && currentmon.pbHasAnyStatus?
			switchscore+=50
		end
		if partyroles.include?("Cleric") && currentmon.pbHasAnyStatus?
			switchscore+=60
		end
		if currentmon.asleep?
			for m in opponent1.moves
				if m.id == :DREAMEATER
					switchscore+=170
				end
			end   
		end   
		if currentmon.effects[PBEffects::Yawn]>0 && !currentmon.asleep?
			switchscore+=95
		end  
		# Stat Stages
		Console.echoln "Initial switchscore building: Stat Stages #{switchscore}" #if $INTERNAL
		specialmove = false
		physmove = false
		for i in currentmon.moves
			specialmove = true if i.specialMove?(i.type)
			physmove = true if i.physicalMove?(i.type)
		end    
		if currentroles.include?("Sweeper")
			switchscore+= (-30)*currentmon.stages[:ATTACK] if currentmon.stages[:ATTACK]<0 && physmove
			switchscore+= (-30)*currentmon.stages[:SPECIAL_ATTACK] if currentmon.stages[:SPECIAL_ATTACK]<0 && specialmove
			switchscore+= (-30)*currentmon.stages[:SPEED] if currentmon.stages[:SPEED]<0
			switchscore+= (-30)*currentmon.stages[:ACCURACY] if currentmon.stages[:ACCURACY]<0
		else
			switchscore+= (-15)*currentmon.stages[:ATTACK] if currentmon.stages[:ATTACK]<0 && physmove
			switchscore+= (-15)*currentmon.stages[:SPECIAL_ATTACK] if currentmon.stages[:SPECIAL_ATTACK]<0 && specialmove
			switchscore+= (-15)*currentmon.stages[:SPEED] if currentmon.stages[:SPEED]<0      
			switchscore+= (-15)*currentmon.stages[:ACCURACY] if currentmon.stages[:ACCURACY]<0      
		end    
		if currentroles.include?("Physical Wall")
			switchscore+= (-30)*currentmon.stages[:DEFENSE] if currentmon.stages[:DEFENSE]<0      
		else
			switchscore+= (-15)*currentmon.stages[:DEFENSE] if currentmon.stages[:DEFENSE]<0      
		end  
		if currentroles.include?("Special Wall")
			switchscore+= (-30)*currentmon.stages[:SPECIAL_DEFENSE] if currentmon.stages[:SPECIAL_DEFENSE]<0      
		else
			switchscore+= (-15)*currentmon.stages[:SPECIAL_DEFENSE] if currentmon.stages[:SPECIAL_DEFENSE]<0      
		end  
		# Healing
		Console.echoln "Initial switchscore building: Healing" #if $INTERNAL
		if currentmon.hp/currentmon.totalhp<(2/3) && currentmon.hasActiveAbility?(:REGENERATOR)
			switchscore+=30
		end
		if currentmon.effects[PBEffects::Wish]>0
			lowhp = false
			for i in party
				next if i.nil?
				if 0.3<(i.hp/i.totalhp) && (i.hp/i.totalhp)<0.6
					lowhp = true
				end
			end
			switchscore+40 if lowhp
		end    
		# fsteak
		Console.echoln "Initial switchscore building: fsteak #{switchscore}" #if $INTERNAL
		finalmod = 0
		opp1Types = opponent1.pbTypes(true)
		opp2Types = opponent2.pbTypes(true)
		for i in currentmon.moves
			mod1 = pbCalcTypeMod(i.pbCalcType(currentmon), currentmon, opponent1)
			mod2 = pbCalcTypeMod(i.pbCalcType(currentmon), currentmon, opponent2)
			mod1 = 4 if opponent1.hp==0
			mod2 = 4 if opponent2.hp==0
			if opponent1.hasActiveAbility?(:WONDERGUARD) && mod1<=4
				mod1=0
			end
			if opponent2.hasActiveAbility?(:WONDERGUARD) && mod2<=4
				mod2=0
			end
			finalmod += mod1*mod2
		end
		switchscore+=140 if finalmod==0
		totalpp=0
		for i in currentmon.moves
			totalpp+= i.pp
		end
		switchscore+=200 if totalpp==0
		if currentmon.effects[PBEffects::Encore]>0
			encoremoove=GameData::Move.get(opponent1.effects[PBEffects::EncoreMove])
			dmgValue = pbRoughDamage(encoremoove, user, opponent1, skill, encoremoove.baseDamage)
			if encoremoove.baseDamage!=0
				dmgPercent = (dmgValue*100)/(opponent1.hp)
				dmgPercent = 110 if dmgPercent > 110
			else
				dmgPercent = pbStatusDamage(encoremoove.baseDamage)
			end
			encoreScore = pbGetMoveScore(encoremoove, currentmon, opponent1, skill, dmgPercent)
			if encoreScore <= 30
				switchscore+=120
			end    
		end  
		if skill<PBTrainerAI.highSkill
			switchscore/=2.0
		end
		# Specific Switches
		Console.echoln "Initial switchscore building: Specific Switches #{switchscore}" #if $INTERNAL
		if opponent1.effects[PBEffects::TwoTurnAttack]
			twoturnmove = GameData::Move.get(opponent1.effects[PBEffects::TwoTurnAttack])
			#~ twoturnmove = :SOLARBLADE
			twoturntype = twoturnmove.type
			breakvar = false
			savedmod = -1
			indexsave = -1
			count = -1  
			for i in party
				count+=1
				next if i.nil?
				next if count == index
				for zzz in i.moves
					totalmod=pbCalcTypeMod(zzz.pbCalcType(i), currentmon, opponent1)
					if totalmod<4
						switchscore+=80 unless breakvar
						breakvar = true
						if savedmod<0
							indexsave = count
							savedmod = totalmod
						else
							if savedmod>totalmod
								indexsave = count
								savedmod = totalmod
							end
						end
					end
				end
			end
			monarray.push(indexsave) if indexsave > -1
		end 
		if pbRoughStat(currentmon,:SPEED,skill) < pbRoughStat(opponent1,:SPEED,skill)
			movedamages = []
			for m in opponent1.moves
				movedamages.push(pbRoughDamage(m, currentmon, opponent1, skill, m.baseDamage))
			end   
			if movedamages.length > 0
				bestmoveindex = movedamages.index(movedamages.max)
				bestmove = movedamages[bestmoveindex]  #checklater
				if (currentmon.hp) < movedamages[bestmoveindex]
					count = -1
					breakvar = false
					immunevar = false
					savedmod = -1
					indexsave = -1     
					for i in party
						count+=1
						next if i.nil?
						next if count == index
						totalmod = pbCalcTypeMod(zzz.pbCalcType(i), currentmon, opponent1)
						if totalmod<4
							switchscore+=80 unless breakvar
							breakvar = true
							if totalmod == 0
								switchscore+=20 unless immunevar
								immunevar = true
							end     
							if savedmod<0
								indexsave = count
								savedmod = totalmod
							else
								if savedmod>totalmod
									indexsave = count
									savedmod = totalmod
								end
							end
						end        
					end
					if immunevar
						monarray.push(indexsave) if indexsave > -1
					else
						if indexsave > -1
							if party[indexsave].speed > pbRoughStat(opponent1,:SPEED,skill)
								monarray.push(indexsave)
							end
						end
					end            
				end
			end
		end
		fakeout = false
		for i in opponent1.moves
			if i.id==:FAKEOUT
				fakeout = true
			end
		end  
		if fakeout && opponent1.turnCount == 1
			count = -1       
			for i in party
				count+=1
				next if i.nil?
				next if count == index   
				if i.ability == :STEADFAST
					monarray.push(count)
					switchscore+=90
					break
				end
			end
		end
		if opponent1.ability == :SKILLLINK
			probablycinccino = false
			for i in opponent1.moves
				if i.function=="HitTwoToFiveTimes" && i.contactMove?
					probablycinccino = true
				end
			end  
			if probablycinccino
				count = -1             
				maxpain = 0
				storedmon = -1
				for i in party
					count+=1
					next if i.nil?
					paincount = 0
					next if count == index   
					if i.ability == :ROUGHSKIN || i.ability == :IRONBARBS
						paincount+=1
					end
					if i.item_id == :ROCKYHELMET
						paincount+=1
					end            
					if paincount>0 && paincount>maxpain
						maxpain=paincount
						storedmon = count
						switchscore+=70
					end            
				end
				if storedmon>-1
					monarray.push(storedmon)
				end          
			end
		end      
		count = -1             
		storedmon = -1
		storedhp = -1
		for i in party
			count+=1
			next if i.nil?
			next if i.totalhp==0
			next if count == index
			next if !@battle.pbCanSwitchLax?(index,count)
			if storedhp < 0
				storedhp = i.hp/i.totalhp.to_f
				storedmon = i #count
				storedcount = count
			else
				if storedhp > i.hp/i.totalhp.to_f
					storedhp = i.hp/i.totalhp.to_f
					storedmon = i #count
					storedcount = count
				end
			end
		end
		if storedhp < 0.20 && storedhp > 0
			if (storedmon.speed < pbRoughStat(opponent1,:SPEED,skill)) || 
				 (storedmon.speed < pbRoughStat(opponent2,:SPEED,skill)) || 
				@battle.sides[1].effects[PBEffects::Spikes]>0 || 
				@battle.sides[1].effects[PBEffects::StealthRock]
				speedcheck = false
				for i in party
					next if i.nil?
					next if i==storedmon
					if i.speed > pbRoughStat(opponent1,:SPEED,skill)
						speedcheck = true
					end
				end
				if speedcheck
					monarray.push(storedcount)
					switchscore+=20
				end
			end      
		end
		maxlevel = -1
		for i in party
			next if i.nil?
			if maxlevel < 0
				maxlevel = i.level
			else
				if maxlevel < i.level
					maxlevel = i.level
				end
			end
		end
		Console.echoln "Party maxlevel: #{maxlevel}" #if $INTERNAL
		if maxlevel>(opponent1.level+10)
			switchscore-=100
			if maxlevel>(opponent1.level+20)
				switchscore-=1000
			end
		end    
		Console.echoln "#{@battle.battlers[index].name}: initial switchscore: #{switchscore}" #if $INTERNAL
		Console.echoln " " #if $INTERNAL
		# Stat Stages
		Console.echoln "Initial noswitchscore building: Stat Stages #{noswitchscore}" #if $INTERNAL
		specialmove = false
		physmove = false
		for i in currentmon.moves
			specialmove = true if i.specialMove?(i.type)
			physmove = true if i.physicalMove?(i.type)
		end      
		if currentroles.include?("Sweeper")
			noswitchscore+= (30)*currentmon.stages[:ATTACK] if currentmon.stages[:ATTACK]>0 && physmove
			noswitchscore+= (30)*currentmon.stages[:SPECIAL_ATTACK] if currentmon.stages[:SPECIAL_ATTACK]>0 && specialmove
			noswitchscore+= (30)*currentmon.stages[:SPEED] if currentmon.stages[:SPEED]>0 unless (currentroles.include?("Physical Wall") || currentroles.include?("Special Wall") || currentroles.include?("Tank"))   
		else
			noswitchscore+= (15)*currentmon.stages[:ATTACK] if currentmon.stages[:ATTACK]>0 && physmove
			noswitchscore+= (15)*currentmon.stages[:SPECIAL_ATTACK] if currentmon.stages[:SPECIAL_ATTACK]>0 && specialmove
			noswitchscore+= (15)*currentmon.stages[:SPEED] if currentmon.stages[:SPEED]>0 unless (currentroles.include?("Physical Wall") || currentroles.include?("Special Wall") || currentroles.include?("Tank"))
		end    
		if currentroles.include?("Physical Wall")
			noswitchscore+= (30)*currentmon.stages[:DEFENSE] if currentmon.stages[:DEFENSE]<0      
		else
			noswitchscore+= (15)*currentmon.stages[:DEFENSE] if currentmon.stages[:DEFENSE]<0      
		end  
		if currentroles.include?("Special Wall")
			noswitchscore+= (30)*currentmon.stages[:SPECIAL_DEFENSE] if currentmon.stages[:SPECIAL_DEFENSE]<0      
		else
			noswitchscore+= (15)*currentmon.stages[:SPECIAL_DEFENSE] if currentmon.stages[:SPECIAL_DEFENSE]<0      
		end  
		# Entry Hazards
		Console.echoln "Initial noswitchscore building: Entry Hazards #{noswitchscore}" #if $INTERNAL
		noswitchscore+= (15)*@battle.sides[1].effects[PBEffects::Spikes]
		noswitchscore+= (15)*@battle.sides[1].effects[PBEffects::ToxicSpikes]
		noswitchscore+= (15) if @battle.sides[1].effects[PBEffects::StealthRock]
		noswitchscore+= (15) if @battle.sides[1].effects[PBEffects::StickyWeb]>0
		noswitchscore+= (15) if (@battle.sides[1].effects[PBEffects::StickyWeb]>0 && currentroles.include?("Sweeper"))    
		airmon = currentmon.airborne?
		currentTypes = currentmon.pbTypes(true)
		hazarddam = totalHazardDamage(@battle.sides[1],currentmon,airmon,skill)
		if (currentmon.hp/currentmon.totalhp) < hazarddam
			noswitchscore+= 100
		end
		temppartyko = true
		for i in party
			count+=1
			next if i.nil?
			next if count == index
			temproles = pbGetPokemonRole(i,opponent1,count,party)
			next if temproles.include?("Ace")
			airborne=false
			if i.hasType?(:FLYING) || i.ability == :LEVITATE || i.item_id == :AIRBALLOON
				airborne=true
			end
			tempdam = totalHazardDamage(@battle.sides[1],currentmon,airborne,skill)
			if (i.hp/i.totalhp) > tempdam
				temppartyko = false
			end      
		end  
		if temppartyko
			noswitchscore+= 200
		end  
		# Better Switching Options
		Console.echoln "Initial noswitchscore building: Better Switching Options #{noswitchscore}" #if $INTERNAL
		if pbRoughStat(currentmon,:SPEED,skill) > pbRoughStat(opponent1,:SPEED,skill)
			if currentmon.pbHasMove?(:VOLTSWITCH) || currentmon.pbHasMove?(:UTURN)
				noswitchscore+=90
			end
		end
		if currentmon.effects[PBEffects::PerishSong]==0 && currentmon.pbHasMove?(:BATONPASS)
			noswitchscore+=90
		end
		# Second Wind Situations
		Console.echoln "Initial noswitchscore building: Second Wind Situations #{noswitchscore}" #if $INTERNAL
		privar = false
		for i in opponent1.moves
			privar=true if i.priority>0
		end
		if !privar
			if pbRoughStat(currentmon,:SPEED,skill) > pbRoughStat(opponent1,:SPEED,skill)
				maxdam = 0
				for i in currentmon.moves
					if opponent1.hp>0
						tempdam = (pbRoughDamage(i,opponent1,currentmon,skill,i.baseDamage)*100/opponent1.hp)
					else
						tempdam=0
					end        
					if tempdam > maxdam
						maxdam = tempdam
					end
				end      
				if maxdam > 100 
					noswitchscore+=130
				end
			end
			if pbRoughStat(currentmon,:SPEED,skill) > pbRoughStat(opponent2,:SPEED,skill)
				maxdam = 0
				for i in currentmon.moves
					if opponent2.hp>0
						tempdam = (pbRoughDamage(i,opponent2,currentmon,skill,i.baseDamage)*100/opponent2.hp)
					else
						tempdam=0
					end        
					if tempdam > maxdam
						maxdam = tempdam
					end
				end
				if maxdam > 100 
					noswitchscore+=130
				end
			end 
			maxdam = 0
			for i in currentmon.moves
				next if i.priority < 1
				if opponent1.hp>0
					tempdam = (pbRoughDamage(i,opponent1,currentmon,skill,i.baseDamage)*100/opponent1.hp)
				else
					tempdam=0
				end      
				if tempdam > maxdam
					maxdam = tempdam
				end
			end
			if maxdam > 100 
				noswitchscore+=130
			end 
			maxdam = 0
			for i in currentmon.moves
				next if i.priority < 1
				if opponent2.hp>0
					tempdam = (pbRoughDamage(i,opponent2,currentmon,skill,i.baseDamage)*100/opponent2.hp)
				else
					tempdam=0
				end      
				if tempdam > maxdam
					maxdam = tempdam
				end
			end
			if maxdam > 100 
				noswitchscore+=130
			end 
		end
		finalcrit = 0
		for i in currentmon.moves
			critrate1 = pbAICritRate(currentmon,opponent1,i)
			critrate2 = pbAICritRate(currentmon,opponent2,i)
			maxcrit = [critrate1,critrate2].max
			if finalcrit < maxcrit
				finalcrit = maxcrit
			end
		end
		if finalcrit == 1
			noswitchscore += 25
		elsif finalcrit == 2
			noswitchscore += 50
		elsif finalcrit == 3
			noswitchscore += 100
		end  
		if currentmon.asleep? && currentmon.statusCount<3
			noswitchscore+=100
		end
		monturn = (100 - (currentmon.turnCount*25))
		if currentroles.include?("Lead")
			monturn /= 2
		end
		if monturn > 0
			noswitchscore+=monturn
		end
		Console.echoln "#{@battle.battlers[index].name}: initial noswitchscore: #{noswitchscore}" #if $INTERNAL
		Console.echoln " " #if $INTERNAL
		finalscore = switchscore - noswitchscore
		if skill<PBTrainerAI.highSkill
			finalscore/=2.0
		end
		if skill<PBTrainerAI.mediumSkill
			finalscore-=100
		end  
		highscore = 0 
		movecount = -1
		for i in currentmon.moves   
			movecount+=1
			next if i.id==0
			next if !@battle.pbCanChooseMove?(index,movecount,false)
			if !opponent1.allAllies.empty?
				dmgValue1 = pbRoughDamage(i,currentmon,opponent1,skill,i.baseDamage)
				if i.baseDamage!=0
					if opponent1.hp==0
						dmgPercent1=0
					else              
						dmgPercent1 = (dmgValue1*100)/(opponent1.hp)
						dmgPercent1 = 110 if dmgPercent1 > 110
					end
				else
					dmgPercent1 = pbStatusDamage(i)
				end   
				dmgValue2 = pbRoughDamage(i,currentmon,opponent2,skill,i.baseDamage)
				if i.baseDamage!=0
					if opponent2.hp==0
						dmgPercent2=0
					else 
						dmgPercent2 = (dmgValue2*100)/(opponent2.hp)
						dmgPercent2 = 110 if dmgPercent2 > 110
					end          
				else
					dmgPercent2 = pbStatusDamage(i)
				end  
				if opponent1.hp!=0 && opponent2.hp!=0
					tempscore = [pbGetMoveScore(i,currentmon,opponent1,skill,dmgPercent1), pbGetMoveScore(i,currentmon,opponent2,skill,dmgPercent2)].max
				elsif opponent1.hp!=0
					tempscore = pbGetMoveScore(i,currentmon,opponent1,skill,dmgPercent1)
				elsif opponent2.hp!=0
					tempscore = pbGetMoveScore(i,currentmon,opponent2,skill,dmgPercent2)
				end                  
			else
				dmgValue = pbRoughDamage(i,currentmon,opponent1,skill,i.baseDamage)
				if i.baseDamage!=0
					dmgPercent = (dmgValue*100)/(opponent1.hp)
					dmgPercent = 110 if dmgPercent > 110
				else
					dmgPercent = pbStatusDamage(i)
				end 
				tempscore = pbGetMoveScore(i,currentmon,opponent1,skill,dmgPercent)
			end      
			if tempscore > highscore
				highscore = tempscore
			end
		end
		#~ print "wawa one"
		Console.echoln " " #if $INTERNAL
		Console.echoln "#{@battle.battlers[index].name}: highest move score: #{highscore}" #if $INTERNAL
		Console.echoln "#{@battle.battlers[index].name}: final switching score: #{highscore}" #if $INTERNAL
		if finalscore > highscore
			Console.echoln "#{highscore} < #{finalscore}, will switch" #if $INTERNAL
			Console.echoln " " #if $INTERNAL
			willswitch = true
		else
			Console.echoln "#{highscore} > #{finalscore}, will not switch" #if $INTERNAL
			Console.echoln " " #if $INTERNAL
			willswitch = false
		end 
		if currentmon.hasActiveItem?(:CUSTAPBERRY) && (currentmon.hp/currentmon.totalhp)<=0.25
			willswitch = false
		end
		#~ print "testwawa"
		#~ monarray.push(1) #if indexsave > -1
		if willswitch
			memmons = monarray.length
			if memmons>0
				counts = Hash.new(0)
				monarray.each do |mon|
					counts[mon] += 1
				end
				storedswitch = -1
				storednumber = -1
				tievar = false
				for i in counts.keys
					if counts[i] > storednumber
						storedswitch = i
						storednumber = counts[i]
						tievar = true
					elsif counts[i] == storednumber
						tievar=true
					end          
				end
				if !tievar
					if @battle.pbRegisterSwitch(index,storedswitch)
						Console.echoln "[AI] #{currentmon.pbThis} (#{index}) will switch with #{@battle.pbParty(index)[storedswitch].name} (#{storedswitch.index})"
						return true
					end
				else
					wallmon = -1
					wallindex = -1
					chosenindex = -1
					wallvar = false
					for i in counts.keys
						temparr = pbGetPokemonRole(party[i],opponent1,count,party)            
						if temparr.include?("Physical Wall") || temparr.include?("Special Wall")
							wallvar = true
							wallmon = i
						end 
					end
					if wallvar
						if @battle.pbRegisterSwitch(index, wallmon)
							Console.echoln "[AI1] #{currentmon.pbThis} (#{index}) will switch with #{@battle.pbParty(index)[wallmon].name} (#{wallmon})"
							return true
						end
					else
						maxhpvar = -1
						chosenmon = -1
						chosenindex = -1
						for i in counts.keys
							temphp = party[i].hp
							if temphp > maxhpvar
								maxhpvar = temphp
								chosenmon = i
							end
						end
						if @battle.pbRegisterSwitch(index, chosenmon)
							Console.echoln "[AI2] #{currentmon.pbThis} (#{index}) will switch with #{@battle.pbParty(index)[chosenmon].name} (#{chosenmon})"
							return true
						end
					end
				end
			else
				switchindex = pbSwitchTo(currentmon,party,100,false,index)
				return false if switchindex==-1
				if @battle.pbRegisterSwitch(index, switchindex)
					Console.echoln "[AI3] #{currentmon.pbThis} (#{index}) will switch with #{@battle.pbParty(index)[switchindex].name} (#{switchindex})"
					return true
				end
			end
		end
		return false
	end
	
	def totalHazardDamage(side,currentmon,airborne,skill)
		percentdamage = 0
		if side.effects[PBEffects::Spikes]>0 && (!airborne || @field.effects[PBEffects::Gravity]>0)
			spikesdiv=[8,8,6,4][side.effects[PBEffects::Spikes]]
			percentdamage += (100/spikesdiv)
		end
		if side.effects[PBEffects::StealthRock]
			airdamage = (airborne) ? 4 : 8
			percentdamage += (100/airdamage)
		end
		percentdamage = 0 if i.ability == :TILEWORKER
		return percentdamage
	end
	
	def pbTypeModifierAINonBattler(moveType, user, target)
		# user is *probably* a Pokemon
    return Effectiveness::NORMAL_EFFECTIVE if !moveType
    return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
                                              target.pbHasType?(:FLYING) && # target is a Battle::Battler
                                              target.item == :IRONBALL
    # Determine types
    tTypes = target.pbTypes(true)
    # Get effectivenesses
    typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
    if moveType == :SHADOW
      if target.shadowPokemon?
        typeMods[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
      else
        typeMods[0] = Effectiveness::SUPER_EFFECTIVE_ONE
      end
    else
      tTypes.each_with_index do |defType, i|
				typeMods[i] = Effectiveness.calculate_one(moveType, defType)
				if Effectiveness.ineffective_type?(moveType, defType)
					# Ring Target
					typeMods[i] = Effectiveness::NORMAL_EFFECTIVE_ONE if target.hasActiveItem?(:RINGTARGET)
					# Scrappy
					typeMods[i] = Effectiveness::NORMAL_EFFECTIVE_ONE if (user.ability == :SCRAPPY || user.ability == :NORMALIZE) && defType == :GHOST
					# Corrosion
					typeMods[i] = Effectiveness::NORMAL_EFFECTIVE_ONE if user.ability == :CORROSION && defType == :STEEL
					# Enigmize
					typeMods[i] = Effectiveness::NORMAL_EFFECTIVE_ONE if user.ability == :ENIGMIZE
					# Gravity
					typeMods[i] = Effectiveness::NORMAL_EFFECTIVE_ONE if @battle.field.effects[PBEffects::Gravity]>0 && defType == :FLYING
				elsif Effectiveness.super_effective_type?(moveType, defType)
					# Delta Stream's weather
					typeMods[i] = Effectiveness::NORMAL_EFFECTIVE_ONE if target.effectiveWeather == :StrongWinds && defType == :FLYING
				elsif !Effectiveness.super_effective_type?(moveType, defType)
					# Mass Extinction #by low
					typeMods[i] = Effectiveness::SUPER_EFFECTIVE_ONE if user.ability == :MASSEXTINCTION && defType == :DRAGON
				end
				# Grounded Flying-type Pokémon become susceptible to Ground moves
				typeMods[i] = Effectiveness::NORMAL_EFFECTIVE_ONE if !target.airborne? && defType == :FLYING && moveType == :GROUND
				if moveType == :NORMAL
					if [:AERILATE, :GALVANIZE, :PIXILATE, :REFRIGERATE].include?(user.ability)
						typeMods[i] = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :GHOST
					end
					if user.ability == :ENIGMIZE
						typeMods[i] = Effectiveness::NORMAL_EFFECTIVE_ONE if [:STEEL, :GHOST, :GROUND, :FAIRY, :FLYING, :NORMAL, :DARK].include?(defType)
					end
					if user.ability == :NORMALIZE
						typeMods[i] = Effectiveness::NOT_VERY_EFFECTIVE_ONE if defType == :STEEL
						typeMods[i] = Effectiveness::NORMAL_EFFECTIVE_ONE if [:GROUND, :FAIRY, :FLYING, :NORMAL, :DARK].include?(defType)
						typeMods[i] = Effectiveness::INEFFECTIVE if defType == :GHOST
					end
				end
      end
    end
    # Multiply all effectivenesses together
    ret = 1
    typeMods.each { |m| ret *= m }
    ret *= 2 if target.effects[PBEffects::TarShot] && moveType == :FIRE
		# Inverse Battle Switch #by low
		# 8x = ret 64
		# 4x = ret 32
		if $game_switches[INVERSEBATTLESWITCH]
			if ret == 0
				ret = 16
			elsif ret >= 64
				ret = 0
			else
				ret = (64 / ret)
			end
		end
		ret = 14 if ret > 14 && !target.pbOwnedByPlayer? && $game_variables[MASTERMODEVARS][28]==true
    return ret
	end
	
	#~ def pbDefaultChooseNewEnemy(idxBattler, party) # a replacement for the older one
		#~ return pbSwitchTo(idxBattler, party, 100, true)
	#~ end
	
	def pbSwitchTo(currentmon,party,skill,forced = false, index)
		#~ skill=0 if $game_switches[318] && currentmon==@battle.battlers[2]
		#~ print true if $game_switches[318] && currentmon==@battle.battlers[2]
		if currentmon == 1
			currentmonparty = @battle.pbParty(@battle.sides[1].effects[PBEffects::LastRoundFaintedPokemon][0])
			currentmonpkmn = currentmonparty[@battle.sides[1].effects[PBEffects::LastRoundFaintedPokemon][1]]
			if currentmonpkmn&.able?
				currentmon = Battle::Battler.new(self, @battle.sides[1].effects[PBEffects::LastRoundFaintedPokemon][0], false)
				currentmon.pbInitDummyPokemon(currentmonpkmn, @battle.sides[1].effects[PBEffects::LastRoundFaintedPokemon][1])
			end
		end
		#~ print currentmon
		opponent1 = @battle.battlers[0] #currentmon.pbDirectOpposing
		if !opponent1.allAllies.empty? # double battle
			opponent2 = @battle.battlers[2]
		else
			opponent2 = @battle.battlers[0].clone
			#~ opponent2.hp = 0
		end
		opp1roles = pbGetPokemonRole(opponent1,currentmon)
		opp2roles = pbGetPokemonRole(opponent2,currentmon)
		scorearray = []
		supercount=-1
		for i in party            
			supercount+=1
			if i.nil?
				scorearray.push(-10000000)
				next
			end      
			Console.echoln "Scoring for #{currentmon.species} switching to: #{i.species}" #if $INTERNAL
			if !@battle.pbCanSwitchLax?(index,supercount)
				scorearray.push(-10000000)
				Console.echoln "Score: -10000000" #if $INTERNAL
				Console.echoln " " #if $INTERNAL
				next
			end   
			# print pbCanSwitchLax?(index,supercount,false)
			theseRoles = pbGetPokemonRole(i,opponent1,supercount,party) 
			if theseRoles.include?("Physical Wall") || theseRoles.include?("Special Wall")
				wallvar = true
			else
				wallvar = false
			end
			monscore = 0
			#Don't switch to already inplay mon
			if index == scorearray.length
				scorearray.push(-10000000)
				Console.echoln "Score: -10000000" #if $INTERNAL
				Console.echoln " " #if $INTERNAL
				next
			end   
			if i.hp <= 0
				scorearray.push(-10000000)
				Console.echoln "Score: -10000000" #if $INTERNAL
				Console.echoln " " #if $INTERNAL
				next
			end   
			sedamagevar = 0
			#Defensive
			for j in opponent1.moves
				totalmod = pbTypeModifierAINonBattler(j.type, i, opponent1)
				if totalmod > 4
					sedamagevar = j.baseDamage if j.baseDamage>sedamagevar
					if totalmod >= 16
						sedamagevar*=2
					end
					opp1Types = opponent1.pbTypes(true)
					if j.type == opp1Types[0] || j.type == opp1Types[1] || j.type == opp1Types[2]
						sedamagevar*=1.5
					end
				end          
			end  
			monscore-=(sedamagevar-50)
			immunevar = 0
			resistvar = 0
			bestresist = false
			bestimmune = false
			count = 0
			movedamages = []
			bestmoveindex = -1
			for j in opponent1.moves
				movedamages.push(j.baseDamage)
			end   
			if movedamages.length > 0
				bestmoveindex = movedamages.index(movedamages.max)
			end        
			for j in opponent1.moves
				totalmod = pbTypeModifierAINonBattler(j.type, i, opponent1)
				if bestmoveindex > -1
					if count == bestmoveindex
						if totalmod == 0
							bestimmune = true
						elsif totalmod == 1 || totalmod == 2
							bestresist = true
						end              
					end
				end           
				if totalmod == 0
					immunevar+=1
				elsif totalmod == 1 || totalmod == 2
					resistvar+=1
				end          
				count+=1
			end  
			if immunevar == 4
				if wallvar
					monscore+=150
				else
					monscore+=100
				end
			end
			if immunevar+resistvar == 4 && immunevar!=4
				if wallvar
					monscore+=150
				else
					monscore+=100
				end
			elsif bestresist 
				if wallvar
					monscore+=45
				else
					monscore+=30
				end 
			end
			opp1Types = opponent1.pbTypes(true)
			otype11 = opp1Types[0]
			otype12 = opp1Types[1]
			otype13 = opp1Types[2]	
			opp2Types = opponent2.pbTypes(true)
			otype21 = opp2Types[0]
			otype22 = opp2Types[1]
			otype23 = opp2Types[2]
			atype1 = i.types[0]
			atype2 = i.types[1]
			atype3 = i.types[2]
			atype1 = :QMARKS if atype1.nil?
			atype2 = :QMARKS if atype2.nil?
			atype3 = :QMARKS if atype3.nil?
			stabresist11a = Effectiveness.calculate_one(otype11, atype1)
			if atype1!=atype2
				stabresist11b = Effectiveness.calculate_one(otype11, atype2) 
			else
				stabresist11b = 2
			end				
			stabresist12a = Effectiveness.calculate_one(otype12, atype1)
			if atype1!=atype2
				stabresist12b = Effectiveness.calculate_one(otype12, atype2)
			else
				stabresist12b = 2
			end			 
			stabresist13a = 2
			stabresist13a = Effectiveness.calculate_one(otype13, atype1) if !otype13.nil?
			if (atype3!=nil || atype3!=atype2 || atype3!=atype1) || !otype13.nil?
				stabresist13b = Effectiveness.calculate_one(otype13, atype3)
			else
				stabresist13b = 2
			end	     
			stabresist21a = Effectiveness.calculate_one(otype21, atype1)
			if atype1!=atype2
				stabresist21b = Effectiveness.calculate_one(otype21, atype2)
			else
				stabresist21b = 2
			end  
			stabresist22a = Effectiveness.calculate_one(otype22, atype1)
			if atype1!=atype2
				stabresist22b = Effectiveness.calculate_one(otype22, atype2)
			else
				stabresist22b = 2
			end  
			stabresist23a = 2
			stabresist23a = Effectiveness.calculate_one(otype23, atype1) if !otype13.nil?
			if (atype3!=nil && atype3!=atype2 && atype3!=atype1) || !otype23.nil?
				stabresist23b = Effectiveness.calculate_one(otype23, atype3)
			else
				stabresist23b = 2
			end				
			if stabresist11a*stabresist11b<4 || stabresist12a*stabresist12b<4 || stabresist13a*stabresist13b<4
				monscore+=40
				if otype11==otype12
					monscore+=30
				else
					if (stabresist11a*stabresist11b<4 && stabresist12a*stabresist12b<4) || (stabresist11a*stabresist11b<4 && stabresist13a*stabresist13b<4) || (stabresist13a*stabresist13b<4 && stabresist12a*stabresist12b<4)
						monscore+=60
					end
				end
			end
			if stabresist21a*stabresist21b<4 || 
				 stabresist22a*stabresist22b<4 || 
				 stabresist23a*stabresist23b<4
				monscore+=40
				if otype21==otype22
					monscore+=30
				else
					if (stabresist21a*stabresist21b<4 && stabresist22a*stabresist22b<4) || 
						 (stabresist21a*stabresist21b<4 && stabresist23a*stabresist23b<4) || 
						 (stabresist23a*stabresist23b<4 && stabresist22a*stabresist22b<4)
						monscore+=60
					end
				end
			end
			Console.echoln "Defensive: #{monscore}" #if $INTERNAL
			#Offensive
			maxbasedam = -1
			bestmove = -1
			for k in i.moves
				#~ wawa = Pokemon::Move.new(k)
				j = Battle::Move.from_pokemon_move(@battle, k)
				basedam = j.baseDamage
				targetTypes = opponent1.pbTypes(true)
				Effectiveness.calculate(:ELECTRIC, targetTypes[0], targetTypes[1], targetTypes[2])
				if (pbTypeModifierAINonBattler(j.type,i,opponent1)>4) || ((pbTypeModifierAINonBattler(j.type,i,opponent2)>4) && opponent2.totalhp !=0)
					basedam*=2
					if (pbTypeModifierAINonBattler(j.type,i,opponent1)==16) || ((pbTypeModifierAINonBattler(j.type,i,opponent2)==16) && opponent2.totalhp !=0)
						basedam*=2
					end
				end
				if (pbTypeModifierAINonBattler(j.type,i,opponent1)<4) || ((pbTypeModifierAINonBattler(j.type,i,opponent2)<4) && opponent2.totalhp !=0)
					basedam/=2.0 
					if (pbTypeModifierAINonBattler(j.type,i,opponent1)==1) || ((pbTypeModifierAINonBattler(j.type,i,opponent2)==1) && opponent2.totalhp !=0)
						basedam/=2.0
					end    
				end    
				if (pbTypeModifierAINonBattler(j.type,i,opponent1)==0) || 
					 ((pbTypeModifierAINonBattler(j.type,i,opponent2)==0) && opponent2.totalhp !=0)
					basedam=0
				end
				if (pbTypeModifierAINonBattler(j.type,i,opponent1)<=4 && opponent1.hasActiveAbility?(:WONDERGUARD)) || 
					 ((pbTypeModifierAINonBattler(j.type,i,opponent2)<=4 && opponent2.hasActiveAbility?(:WONDERGUARD)) && opponent2.totalhp !=0)
					basedam=0
				end 
				if pbTypeModifierAINonBattler(k.type,i,opponent1) ||
					 pbTypeModifierAINonBattler(k.type,i,opponent2)
					basedam=0
				end   
				if j.physicalMove?(j.type) && i.status == :BURN
					basedam/=2.0
				end
				if skill>=PBTrainerAI.highSkill
					if i.hasType?(j.type)
						basedam*=1.5
					end
				end
				if j.accuracy!=0
					basedam*=(j.accuracy/100.0)
				end
				if basedam>maxbasedam
					maxbasedam = basedam 
					bestmove = j
				end
			end
			if bestmove!=-1
				if bestmove.priority>0
					maxbasedam*=1.5
				end
			end
			if i.speed<pbRoughStat(opponent1,:SPEED,skill) || i.speed<pbRoughStat(opponent2,:SPEED,skill)
				maxbasedam*=0.75
			else
				maxbasedam*=1.25
			end
			if maxbasedam==0
				monscore-=80
			else
				monscore+=maxbasedam
				ministat=0
				if i.attack > i.spatk
					ministat = [(opponent1.stages[:SPECIAL_DEFENSE] - opponent1.stages[:DEFENSE]),(opponent2.stages[:SPECIAL_DEFENSE] - opponent2.stages[:DEFENSE])].max
				else
					ministat = [(opponent1.stages[:DEFENSE] - opponent1.stages[:SPECIAL_DEFENSE]),(opponent1.stages[:DEFENSE] - opponent1.stages[:SPECIAL_DEFENSE])].max
				end
				ministat*=20
				monscore+=ministat
			end              
			Console.echoln "Offensive: #{monscore}" #if $INTERNAL
			#Roles
			if skill>=PBTrainerAI.highSkill
				if theseRoles.include?("Sweeper")
					if party.length<4
						monscore+=80
					else
						monscore-=50
					end
					if i.attack >= i.spatk
						if (opponent1.defense<opponent1.spdef) || (opponent2.defense<opponent2.spdef)
							monscore+=30
						end
					end
					if i.spatk >= i.attack
						if (opponent1.spdef<opponent1.defense) || (opponent2.spdef<opponent2.defense)
							monscore+=30
						end
					end  
					monscore+= (-10)*opponent1.stages[:ATTACK] if opponent1.stages[:ATTACK]<0
					monscore+= (-10)*opponent2.stages[:ATTACK] if opponent2.stages[:ATTACK]<0
					monscore+= (-10)*opponent1.stages[:DEFENSE] if opponent1.stages[:DEFENSE]<0
					monscore+= (-10)*opponent2.stages[:DEFENSE] if opponent2.stages[:DEFENSE]<0
					monscore+= (-10)*opponent1.stages[:SPECIAL_ATTACK] if opponent1.stages[:SPECIAL_ATTACK]<0
					monscore+= (-10)*opponent2.stages[:SPECIAL_ATTACK] if opponent2.stages[:SPECIAL_ATTACK]<0
					monscore+= (-10)*opponent1.stages[:SPECIAL_DEFENSE] if opponent1.stages[:SPECIAL_DEFENSE]<0
					monscore+= (-10)*opponent2.stages[:SPECIAL_DEFENSE] if opponent2.stages[:SPECIAL_DEFENSE]<0
					monscore+= (-10)*opponent1.stages[:SPEED] if opponent1.stages[:SPEED]<0
					monscore+= (-10)*opponent2.stages[:SPEED] if opponent2.stages[:SPEED]<0
					monscore+= (-10)*opponent1.stages[:ACCURACY] if opponent1.stages[:ACCURACY]<0
					monscore+= (-10)*opponent2.stages[:ACCURACY] if opponent2.stages[:ACCURACY]<0
					if ((i.speed > opponent1.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
						monscore*=1.3
					else
						monscore*=0.7
					end
					if opponent1.asleep?
						monscore+=50
					end
				end
				if wallvar
					if theseRoles.include?("Physical Wall") && (opponent1.spatk>opponent1.attack || opponent2.spatk>opponent2.attack)
						monscore+=30
					end
					if theseRoles.include?("Special Wall") && (opponent1.spatk<opponent1.attack || opponent2.spatk<opponent2.attack)
						monscore+=30
					end          
					if opponent1.status == :BURN || opponent1.status == :POISON || opponent1.effects[PBEffects::LeechSeed]>0
						monscore+=30
					end
					if opponent2.status == :BURN || opponent2.status == :POISON || opponent2.effects[PBEffects::LeechSeed]>0
						monscore+=30
					end      
				end
				if theseRoles.include?("Tank")
					if opponent1.paralyzed? || opponent1.effects[PBEffects::LeechSeed]>0          
						monscore+=40
					end
					if opponent2.paralyzed? || opponent2.effects[PBEffects::LeechSeed]>0          
						monscore+=40
					end  
					if @battle.sides[1].effects[PBEffects::Tailwind]>0
						monscore+=30
					end          
				end
				if theseRoles.include?("Lead")        
					monscore+=40
				end        
				if theseRoles.include?("Cleric")        
					partystatus = false
					partymidhp = false
					for k in party
						next if k.nil?
						next if k==i
						if k.pbHasAnyStatus?
							partystatus=true
						end
						if 0.3<(k.hp/k.totalhp) && (k.hp/k.totalhp)<0.6
							partymidhp = true
						end            
					end
					if partystatus
						monscore+=50
					end
					if partymidhp
						monscore+=50
					end          
				end   
				if theseRoles.include?("Screener")        
					monscore+=60
				end   
				if theseRoles.include?("Revenge Killer")
					if opponent2.totalhp!=0 && opponent1.totalhp!=0
						if (opponent1.hp/opponent1.totalhp)<0.3 || (opponent2.hp/opponent2.totalhp)<0.3
							monscore+=100
						end     
					elsif opponent1.totalhp!=0
						if (opponent1.hp/opponent1.totalhp)<0.3
							monscore+=100
						end    
					elsif opponent2.totalhp!=0
						if (opponent2.hp/opponent2.totalhp)<0.3
							monscore+=100
						end 
					end          
				end  
				if theseRoles.include?("Spinner")        
					if !opponent1.pbHasType?(:GHOST) && (opponent2.hp==0 || !opponent2.pbHasType?(:GHOST))
						monscore+=20*@battle.sides[1].effects[PBEffects::Spikes]
						monscore+=20*@battle.sides[1].effects[PBEffects::ToxicSpikes]
						monscore+=30 if @battle.sides[1].effects[PBEffects::StickyWeb]>0
						monscore+=30 if @battle.sides[1].effects[PBEffects::StealthRock]
					end          
				end
				if theseRoles.include?("Pivot")        
					monscore+=40
				end   
				if theseRoles.include?("Baton Passer")        
					monscore+=50
				end  
				if theseRoles.include?("Stallbreaker")    
					healer = false
					for zzz in opponent1.moves
						healer=true if j.healingMove?
					end
					for zzz in opponent2.moves
						healer=true if j.healingMove?
					end
					monscore+=80 if healer
				end  
				if theseRoles.include?("Stallbreaker")    
					healer = false
					for zzz in opponent1.moves
						healer=true if j.healingMove?
					end
					for zzz in opponent2.moves
						healer=true if j.healingMove?
					end
					monscore+=80 if healer
				end         
				if theseRoles.include?("Status Absorber")    
					statusmove = false
					for j in opponent1.moves
						statusmove=true if (j.id==:THUNDERWAVE ||  
																j.id==:TOXIC ||  j.id==:SPORE ||  
																j.id==:SING ||  j.id==:POISONPOWDER ||  
																j.id==:STUNSPORE ||  j.id==:SLEEPPOWDER ||  
																j.id==:NUZZLE ||  j.id==:WILLOWISP ||  
																j.id==:HYPNOSIS ||  j.id==:GLARE ||  
																j.id==:DARKVOID ||  j.id==:GRASSWHISTLE ||  
																j.id==:LOVELYKISS ||  j.id==:POISONGAS)
					end
					monscore+=70 if statusmove
				end   
				if theseRoles.include?("Trapper")
					if ((i.speed>opponent1.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
						if opponent1.hp/opponent1.totalhp<0.6
							monscore+=100
						end
					end          
				end    
				if theseRoles.include?("Weather Setter")
					if i.ability == :DROUGHT || i.hasMove?(:SUNNYDAY) ||
					  (i.species == :ZARCOIL && i.item == :ZARCOILITE)
						if @battle.field.weather != :Sun
							monscore+=60
						end	
						if @battle.field.weather == :Rain
							monscore+=60
							if theseRoles.include?("Ace") || theseRoles.include?("Second")
								monscore*=10
							end	
						end
						if !(@battle.battlers[1].isFainted? || @battle.battlers[3].isFainted?)
							monscore*=0.1
						end	
					elsif i.ability == :DRIZZLE || i.hasMove?(:RAINDANCE) ||
					  (i.species == :ZOLUPINE && i.item == :ZOLUPINEITE)
						if @battle.field.weather != :Rain
							monscore+=60
						elsif @battle.field.weather == :Sun
							monscore+=60
							if theseRoles.include?("Ace") || theseRoles.include?("Second")
								monscore*=10
							end														
						end
					elsif i.ability == :SANDSTREAM || i.hasMove?(:SANDSTORM) ||
					  (i.species == :CACTURNE && i.item == :CACTURNITE)
						if @battle.field.weather != :Sandstorm
							monscore+=60
						end 
					elsif i.ability == :SNOWWARNING || i.hasMove?(:HAIL) ||
					  (i.species == :FRIZZARD && i.item == :FRIZZARDITE)
						if @battle.field.weather != :Hail
							monscore+=60
						end
					elsif i.ability == :PRIMORDIALSEA || i.ability == :DESOLATELAND || i.ability == :DELTASTREAM
						monscore+=60
					end
				end
			end   
			Console.echoln "Roles: #{monscore}" #if $INTERNAL
			# Weather
			case @battle.field.weather
			when :Sun
				monscore-=40 if i.ability == :DRYSKIN
				monscore+=50 if i.ability == :SOLARPOWER
				monscore+=80 if i.ability == :CHLOROPHYLL 
			when :Rain
				monscore+=50 if i.ability == :DRYSKIN || i.ability == :HYDRATION || i.ability == :RAINDISH
				monscore+=80 if i.ability == :SWIFTSWIM
			when :Sandstorm
				monscore+=25 if i.ability == :MAGICGUARD || i.ability == :OVERCOAT || i.hasType?(:ROCK) || i.hasType?(:GROUND) || i.hasType?(:STEEL)
				monscore+=50 if i.ability == :SANDVEIL || i.ability == :SANDFORCE
				monscore+=80 if i.ability == :SANDRUSH     
			when :Hail
				monscore+=25 if i.ability == :MAGICGUARD || i.ability == :OVERCOAT || i.hasType?(:ICE)
				monscore+=50 if i.ability == :SNOWCLOAK || i.ability == :ICEBODY
				monscore+=80 if i.ability == :SLUSHRUSH   
			end  
			if @battle.field.effects[PBEffects::TrickRoom]>0
				if i.speed<opponent1.pbSpeed
					monscore+=30
				else
					monscore-=30
				end
				if i.speed<opponent2.pbSpeed
					monscore+=30
				else
					monscore-=30
				end   
			end
			Console.echoln "Weather: #{monscore}" #if $INTERNAL
			#Moves 
			if skill>=PBTrainerAI.highSkill
				if @battle.sides[1].effects[PBEffects::ToxicSpikes] && (i.hasType?(:POISON) || i.hasType?(:FLYING))
					monscore+=50
				end
				if i.hasMove?(:CLEARSMOG) || i.hasMove?(:HAZE)
					monscore+= (10)*opponent1.stages[:ATTACK] if opponent1.stages[:ATTACK]>0
					monscore+= (10)*opponent2.stages[:ATTACK] if opponent2.stages[:ATTACK]>0
					monscore+= (10)*opponent1.stages[:DEFENSE] if opponent1.stages[:DEFENSE]>0
					monscore+= (10)*opponent2.stages[:DEFENSE] if opponent2.stages[:DEFENSE]>0
					monscore+= (10)*opponent1.stages[:SPECIAL_ATTACK] if opponent1.stages[:SPECIAL_ATTACK]>0
					monscore+= (10)*opponent2.stages[:SPECIAL_ATTACK] if opponent2.stages[:SPECIAL_ATTACK]>0
					monscore+= (10)*opponent1.stages[:SPECIAL_DEFENSE] if opponent1.stages[:SPECIAL_DEFENSE]>0
					monscore+= (10)*opponent2.stages[:SPECIAL_DEFENSE] if opponent2.stages[:SPECIAL_DEFENSE]>0
					monscore+= (10)*opponent1.stages[:SPEED] if opponent1.stages[:SPEED]>0
					monscore+= (10)*opponent2.stages[:SPEED] if opponent2.stages[:SPEED]>0
					monscore+= (10)*opponent1.stages[:ACCURACY] if opponent1.stages[:ACCURACY]>0
					monscore+= (10)*opponent2.stages[:ACCURACY] if opponent2.stages[:ACCURACY]>0
					monscore+= (10)*opponent1.stages[:EVASION] if opponent1.stages[:EVASION]>0
					monscore+= (10)*opponent2.stages[:EVASION] if opponent2.stages[:EVASION]>0
				end
				if i.hasMove?(:FAKEOUT)
					monscore+=25
				end
				if i.hasMove?(:RETALIATE) && 
					(@battle.sides[1].effects[PBEffects::LastRoundFainted] == (@battle.turnCount - 1)) # Retaliate
					monscore+=30
				end
			end
			Console.echoln "Moves: #{monscore}" #if $INTERNAL
			#Abilities
			if skill>=PBTrainerAI.highSkill
				thereselec=false
				theresgrass=false
				theresmisty=false
#~ =begin
				#~ for j in @battle.battlers
					#~ if (isConst?(j.species,PBSpecies,:AMPHAROS) && j.item == :AMPHAROSITE && j.willmega)
						#~ thereselec=true
					#~ end
				#~ end	
				#~ for j in @battle.battlers
					#~ if (isConst?(j.species,PBSpecies,:WHIMSICOTT) && j.item == :WHIMSICOTTITE && j.willmega)
						#~ theresgrass=true
					#~ end
				#~ end
				#~ for j in @battle.battlers
					#~ if (isConst?(j.species,PBSpecies,:KIRICORN) && j.item == :KIRICORNITE && j.willmega)
						#~ theresmisty=true
					#~ end
				#~ end
#~ =end
				if i.ability == :UNAWARE
					monscore+= (10)*opponent1.stages[:ATTACK] if opponent1.stages[:ATTACK]>0
					monscore+= (10)*opponent2.stages[:ATTACK] if opponent2.stages[:ATTACK]>0
					monscore+= (10)*opponent1.stages[:DEFENSE] if opponent1.stages[:DEFENSE]>0
					monscore+= (10)*opponent2.stages[:DEFENSE] if opponent2.stages[:DEFENSE]>0
					monscore+= (10)*opponent1.stages[:SPECIAL_ATTACK] if opponent1.stages[:SPECIAL_ATTACK]>0
					monscore+= (10)*opponent2.stages[:SPECIAL_ATTACK] if opponent2.stages[:SPECIAL_ATTACK]>0
					monscore+= (10)*opponent1.stages[:SPECIAL_DEFENSE] if opponent1.stages[:SPECIAL_DEFENSE]>0
					monscore+= (10)*opponent2.stages[:SPECIAL_DEFENSE] if opponent2.stages[:SPECIAL_DEFENSE]>0
					monscore+= (10)*opponent1.stages[:SPEED] if opponent1.stages[:SPEED]>0
					monscore+= (10)*opponent2.stages[:SPEED] if opponent2.stages[:SPEED]>0
					monscore+= (10)*opponent1.stages[:ACCURACY] if opponent1.stages[:ACCURACY]>0
					monscore+= (10)*opponent2.stages[:ACCURACY] if opponent2.stages[:ACCURACY]>0
					monscore+= (10)*opponent1.stages[:EVASION] if opponent1.stages[:EVASION]>0
					monscore+= (10)*opponent2.stages[:EVASION] if opponent2.stages[:EVASION]>0
				end
				if i.ability == :DROUGHT || i.ability == :DESOLATELAND || (i.species == :ZARCOIL && i.item == :ZARCOILITE)
					monscore+=40 if opponent1.pbHasType?(:WATER)
					monscore+=40 if opponent2.pbHasType?(:WATER)
					typecheck=false
					for j in opponent1.moves
						if j.type == :WATER
							typecheck=true
						end
					end
					monscore+=15 if typecheck
					typecheck=false
					for j in opponent2.moves
						if j.type == :WATER
							typecheck=true
						end
					end
					monscore+=15 if typecheck
				end
				if (i.species == :BEAKRAFT && i.item == :BEAKRAFTITE) || i.ability == :ELECTRICSURGE
					 (i.species == :MILOTIC  && i.item == :MILOTITE) || i.ability == :MISTYSURGE
					slepmove=false
					for j in opponent1.moves
						if [:SPORE,:SLEEPPOWDER,:HYPNOSIS,:DARKVOID,:GRASSWHISTLE,:LOVELYKISS,:SING].include?(j.id)
							slepmove=true
						end                
					end
					for j in opponent2.moves
						if [:SPORE,:SLEEPPOWDER,:HYPNOSIS,:DARKVOID,:GRASSWHISTLE,:LOVELYKISS,:SING].include?(j.id)
							slepmove=true
						end                
					end
					monscore+=20 if slepmove
				end	  
				if i.ability == :DRIZZLE || i.ability == :PRIMORDIALSEA || (i.species == :ZOLUPINE && i.item == :ZOLUPINEITE)
					monscore+=40 if opponent1.pbHasType?(:FIRE)
					monscore+=40 if opponent2.pbHasType?(:FIRE)
					typecheck=false
					for j in opponent1.moves
						if j.type == :FIRE
							typecheck=true
						end
					end
					monscore+=15 if typecheck
					typecheck=false
					for j in opponent2.moves
						if j.type == :FIRE
							typecheck=true
						end
					end
					monscore+=15 if typecheck  
				end        
				if i.ability == :LIMBER
					paracheck=false
					for j in opponent1.moves
						if [:THUNDERWAVE,:STUNSPORE,:GLARE].include?(j.id)
							paracheck=true
						end
					end
					monscore+=15 if paracheck
					paracheck=false
					for j in opponent2.moves
						if [:THUNDERWAVE,:STUNSPORE,:GLARE].include?(j.id)
							paracheck=true
						end                
					end
					monscore+=15 if paracheck
				end
				if i.ability == :OBLIVIOUS
					monscore+=20 if opponent1.ability == :CUTECHARM || opponent2.ability == :CUTECHARM
					paracheck=false
					for j in opponent1.moves
						if [:ATTRACT].include?(j.id)
							paracheck=true
						end                
					end
					for j in opponent2.moves
						if [:ATTRACT].include?(j.id)
							paracheck=true
						end                
					end
					monscore+=20 if paracheck
				end    
				if i.ability == :COMPOUNDEYES
					if opponent1.item == :LAXINCENSE || opponent1.item == :BRIGHTPOWDER || opponent1.stages[:EVASION]>0
						monscore+=25
					end
					if opponent2.item == :LAXINCENSE || opponent2.item == :BRIGHTPOWDER || opponent2.stages[:EVASION]>0
						monscore+=25
					end   
				end
				if i.ability == :NEUTRALIZINGGAS
					if opponent1.ability == :CONTRARY || opponent2.ability == :CONTRARY || 
						opponent1.ability == :HEATPROOF || opponent2.ability == :HEATPROOF || 
						opponent1.ability == :SERENEGRACE || opponent2.ability == :SERENEGRACE || 
						opponent1.ability == :TOUGHCLAWS || opponent2.ability == :TOUGHCLAWS || 
						opponent1.ability == :STRONGJAW || opponent2.ability == :STRONGJAW || 
						opponent1.ability == :SHEERFORCE || opponent2.ability == :SHEERFORCE
						monscore+=40 
					elsif opponent1.ability == :STURDY || opponent2.ability == :STURDY || 
						opponent1.ability == :LEADSKIN || opponent2.ability == :LEADSKIN || 
						(opponent1.ability == :GUTS && opponent1.pbHasAnyStatus?) || 
						(opponent2.ability == :GUTS	 && opponent2.pbHasAnyStatus?) || 
						opponent1.ability == :HUSTLE || opponent2.ability == :HUSTLE	
						monscore+=80 			
					end	
				end				
				if i.ability == :INSOMNIA || i.ability == :VITALSPIRIT
					slepmove=false
					for j in opponent1.moves
						if [:SPORE,:SLEEPPOWDER,:HYPNOSIS,:DARKVOID,:GRASSWHISTLE,:LOVELYKISS,:SING].include?(j.id)
							slepmove=true
						end                
					end
					monscore+=20 if slepmove
					slepmove=false
					for j in opponent2.moves
						if [:SPORE,:SLEEPPOWDER,:HYPNOSIS,:DARKVOID,:GRASSWHISTLE,:LOVELYKISS,:SING].include?(j.id)
							slepmove=true
						end                
					end
					monscore+=20 if slepmove
				end         
				if i.ability == :POISONHEAL || i.ability == :TOXICBOOST || i.ability == :IMMUNITY
					poismove=false
					for j in opponent1.moves
						if [:POISONGAS,:POISONPOWDER,:TOXIC].include?(j.id)
							poismove=true
						end                
					end
					monscore+=20 if poismove
					poismove=false
					for j in opponent2.moves
						if [:POISONGAS,:POISONPOWDER,:TOXIC].include?(j.id)
							poismove=true
						end                
					end
					monscore+=20 if poismove
				end               
				if i.ability == :MAGICGUARD
					leechmove=false
					burnmove=false
					poismove=false
					for j in opponent1.moves
						leechmove=true if j.id == :LEECHSEED
						burnmove=true if  j.id == :WILLOWISP    
						poismove=true if [:POISONGAS,:POISONPOWDER,:TOXIC].include?(j.id)
					end  
					monscore+=20 if leechmove
					monscore+=20 if burnmove
					monscore+=20 if poismove   
					###############################
					leechmove=false
					burnmove=false
					poismove=false
					for j in opponent2.moves
						leechmove=true if j.id == :LEECHSEED
						burnmove=true if  j.id == :WILLOWISP    
						poismove=true if [:POISONGAS,:POISONPOWDER,:TOXIC].include?(j.id)
					end  
					monscore+=20 if leechmove
					monscore+=20 if burnmove
					monscore+=20 if poismove
				end        
				if i.ability == :WATERVEIL || i.ability == :FLAREBOOST
					burnmove=false
					for j in opponent1.moves
						burnmove=true if  j.id == :WILLOWISP    
						if burnmove
							monscore+=10
							if i.ability == :FLAREBOOST
								monscore+=10
							end
						end
					end
					for j in opponent2.moves
						burnmove=true if  j.id == :WILLOWISP    
						if burnmove
							monscore+=10
							if i.ability == :FLAREBOOST
								monscore+=10
							end
						end
					end
				end               
				if i.ability == :OWNTEMPO
					confumove=false
					for j in opponent1.moves
						if [:CONFUSERAY,:SUPERSONIC,:FLATTER,:SWAGGER,:SWEETKISS,:TEETERDANCE].include?(j.id)
							confumove=true
						end                
					end
					monscore+=20 if confumove
					confumove=false
					for j in opponent2.moves
						if [:CONFUSERAY,:SUPERSONIC,:FLATTER,:SWAGGER,:SWEETKISS,:TEETERDANCE].include?(j.id)
							confumove=true
						end                
					end
					monscore+=20 if confumove
				end
				if i.ability == :INTIMIDATE && i.ability == :FURCOAT || i.ability == :STAMINA
					if opponent1.attack>opponent1.spatk
						monscore+=40
					end
					if opponent2.attack>opponent2.spatk
						monscore+=40
					end          
				end
				if i.ability == :GRIMTEARS
					if opponent1.attack<opponent1.spatk
						monscore+=40
					end
					if opponent2.attack<opponent2.spatk
						monscore+=40
					end          
				end
				if i.ability == :WONDERGUARD
					dievar = false
					instantdievar=false
					for j in opponent1.moves
						dievar=true if [:FIRE,:GHOST,:DARK,:ROCK,:FLYING].include?(j.type)
					end
					for j in opponent2.moves
						dievar=true if [:FIRE,:GHOST,:DARK,:ROCK,:FLYING].include?(j.type)
					end
					if @battle.field.weather == :Hail ||
						 @battle.field.weather == :Sandstorm
						dievar=true
						instantdievar=true
					end
					if i.status == :BURN || i.status == :POISON || i.frozen?
						dievar=true
						instantdievar=true
					end
					if @battle.sides[1].effects[PBEffects::StealthRock] || @battle.sides[1].effects[PBEffects::Spikes]>0 || 
						 @battle.sides[1].effects[PBEffects::ToxicSpikes]>0
						dievar=true
						instantdievar=true
					end
					if opponent1.ability == :MOLDBREAKER || (opponent1.species==:GYARADOS && opponent1.item == :GYARADOSITE && opponent1.willmega) || 
						 opponent1.ability == :TURBOBLAZE || opponent1.ability == :TERAVOLT
						dievar=true
					end
					if opponent2.ability == :MOLDBREAKER || (opponent2.species==:GYARADOS && opponent2.item == :GYARADOSITE && opponent2.willmega) || 
						 opponent2.ability == :TURBOBLAZE || opponent2.ability == :TERAVOLT
						dievar=true
					end          
					monscore+=90 if !dievar
					monscore-=90 if instantdievar
				end        
				if i.ability == :EFFECTSPORE || i.ability == :STATIC || i.ability == :POISONPOINT || 
					 i.ability == :ROUGHSKIN || i.ability == :IRONBARBS || i.ability == :FLAMEBODY || 
					 i.ability == :CUTECHARM || i.ability == :MUMMY || i.ability == :AFTERMATH || i.ability == :GOOEY
					biggestpower=0
					biggestcontact=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.contactMove?
								biggestcontact=true 
							else
								biggestcontact=false
							end                  
						end
					end
					monscore+=30 if biggestcontact
					biggestpower=0
					biggestcontact=false
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.contactMove?
								biggestcontact=true 
							else
								biggestcontact=false
							end                  
						end
					end
					monscore+=30 if biggestcontact
				end        
				if i.ability == :TRACE
					if opponent1.ability == :WATERABSORB || 
						 opponent1.ability == :VOLTABSORB || 
						 opponent1.ability == :STORMDRAIN || 
						 opponent1.ability == :MOTORDRIVE || 
						 opponent1.ability == :FLASHFIRE || 
						 opponent1.ability == :LEVITATE || 
						 opponent1.ability == :LIGHTNINGROD || 
						 opponent1.ability == :SAPSIPPER || 
						 opponent1.ability == :DRYSKIN || 
						 opponent1.ability == :SLUSHRUSH || 
						 opponent1.ability == :SANDRUSH || 
						 opponent1.ability == :SWIFTSWIM || 
						 opponent1.ability == :CHLOROPHYLL || 
						 opponent1.ability == :SPEEDBOOST || 
						 opponent1.ability == :WONDERGUARD || 
						 opponent1.ability == :PRANKSTER || 
						 (i.speed>opponent1.pbSpeed && (opponent1.ability == :ADAPTABILITY || opponent1.ability == :DOWNLOAD || opponent1.ability == :PROTEAN)) || 
						 (opponent1.attack>opponent1.spatk && opponent1.ability == :INTIMIDATE) || opponent1.ability == :UNAWARE
						 (i.hp==i.totalhp && (opponent1.ability == :MULTISCALE || opponent1.ability == :SHADOWSHIELD))
						monscore+=60
					end          
				end
				if i.ability == :MAGMAARMOR
					typecheck=false
					for j in opponent1.moves
						if j.type == :ICE || j.id == :BITINGCOLD
							typecheck=true
						end
					end
					monscore+=20 if typecheck
					typecheck=false
					for j in opponent2.moves
						if j.type == :ICE || j.id == :BITINGCOLD
							typecheck=true
						end
					end
					monscore+=20 if typecheck
				end  
				if i.ability == :SOUNDPROOF
					biggestpower=0
					biggestcontact=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.soundMove?
								biggestcontact=true 
							else
								biggestcontact=false
							end                  
						end
					end
					monscore+=60 if biggestcontact
					biggestpower=0
					biggestcontact=false
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.soundMove?
								biggestcontact=true 
							else
								biggestcontact=false
							end                  
						end
					end
					monscore+=60 if biggestcontact
				end       
				if i.ability == :THICKFAT
					biggestpower=0
					typecheck=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :ICE || j.type == :FIRE
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					monscore+=30 if typecheck
					biggestpower=0
					typecheck=false
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :ICE || j.type == :FIRE
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					monscore+=30 if typecheck
				end           
				if i.ability == :LIQUIDOOZE
					typecheck=false
					for j in opponent1.moves
						if j.healingMove? || j.id == :LEECHSEED
							typecheck=true
						end
					end
					monscore+=40 if typecheck
					typecheck=false
					for j in opponent2.moves
						if j.healingMove? || j.id == :LEECHSEED
							typecheck=true
						end
					end
					monscore+=40 if typecheck
				end        
				if i.ability == :RIVALRY
					if i.gender==opponent1.gender
						monscore+=30
					end
					if i.gender==opponent2.gender
						monscore+=30
					end   
				end
				if i.ability == :SCRAPPY || i.ability == :NORMALIZE || i.ability == :ENIGMIZE
					if opponent1.pbHasType?(:GHOST)
						monscore+=30
					end
					if opponent2.pbHasType?(:GHOST)
						monscore+=30
					end   
				end
				if i.ability == :LIGHTMETAL
					typecheck=false
					for j in opponent1.moves
						if j.id == :GRASSKNOT || j.id == :LOWKICK 
							typecheck=true
						end
					end
					monscore+=10 if typecheck
					typecheck=false
					for j in opponent2.moves
						if j.id == :GRASSKNOT || j.id == :LOWKICK 
							typecheck=true
						end
					end
					monscore+=10 if typecheck
				end  
				if i.ability == :ANALYTIC
					if ((i.speed<opponent1.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
						monscore+=30
					end
					if ((i.speed<opponent2.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
						monscore+=30
					end   
				end    
				if i.ability == :ILLUSION
					monscore+=40
				end
				#~ if i.ability == :IMPOSTER)
				#~ monscore+= (20)*opponent1.stages[:ATTACK] 
				#~ monscore+= (20)*opponent1.stages[:SPECIAL_ATTACK]
				#~ monscore+=50 if opponent1.ability == :PUREPOWER) || opponent1.ability == :HUGEPOWER) || opponent1.ability == :MOXIE) || opponent1.ability == :SPEEDBOOST) || opponent1.ability == :BEASTBOOST) || opponent1.ability == :SOULHEART) || opponent1.ability == :WONDERGUARD) || opponent1.ability == :PROTEAN) || SilvallyCheck(opponent1, "fire")
				#~ monscore+=30 if (opponent1.level>i.level) || opp1roles.include?("Sweeper")
				#~ end        
				if i.ability == :MOXIE
					monscore+=40 if ((i.speed>opponent1.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) && (opponent1.hp/opponent1.totalhp<0.5)
					if !opponent1.allAllies.empty?
						monscore+=40 if ((i.speed>opponent2.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) && (opponent2.hp/opponent2.totalhp<0.5)
					end
				end  
				if i.ability == :SPEEDBOOST
					monscore+=25 if (i.speed>opponent1.pbSpeed) && (opponent1.hp/opponent1.totalhp<0.3)
					if !opponent1.allAllies.empty?
						monscore+=25 if (i.speed>opponent2.pbSpeed) && (opponent2.hp/opponent2.totalhp<0.3)
					end
				end
				if i.ability == :JUSTIFIED
					biggestpower=0
					typecheck=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :DARK
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :DARK
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					monscore+=30 if typecheck
				end  
				if i.ability == :RATTLED
					biggestpower=0
					typecheck=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :DARK || j.type == :GHOST || j.type == :BUG
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :DARK || j.type == :GHOST || j.type == :BUG
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					monscore+=15 if typecheck
				end
				if i.ability == :IRONBARBS || i.ability == :ROUGHSKIN
					monscore+=30 if opponent1.ability == :SKILLLINK
					monscore+=30 if opponent2.ability == :SKILLLINK
				end
				if i.ability == :PRANKSTER
					monscore+=50 if ((opponent1.pbSpeed>i.speed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
					monscore+=50 if ((opponent2.pbSpeed>i.speed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
				end
				if i.ability == :GALEWINGS
					monscore+=50 if ((opponent1.pbSpeed>i.speed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
					monscore+=50 if ((opponent2.pbSpeed>i.speed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
				end
				if i.ability == :HEATPROOF
					biggestpower=0
					typecheck=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :FIRE
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :FIRE
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					monscore+=60 if typecheck
				end  
				if i.ability == :LEVITATE
					biggestpower=0
					typecheck=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :GROUND
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :GROUND
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					monscore+=60 if typecheck
				end
				if i.ability == :AURABREAK
					monscore+=50 if opponent1.ability == :FAIRYAURA || opponent1.ability == :DARKAURA || opponent1.ability == :SPOOPERAURA
					monscore+=50 if opponent2.ability == :FAIRYAURA || opponent2.ability == :DARKAURA || opponent2.ability == :SPOOPERAURA
				end
				if i.ability == :PROTEAN
					monscore+=40 if ((i.speed>opponent1.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0)) || 
													((i.speed>opponent2.pbSpeed) ^ (@battle.field.effects[PBEffects::TrickRoom]!=0))
				end
				if i.ability == :SANDSTREAM || i.ability == :SNOWWARNING
					monscore+=70 if opponent1.ability == :WONDERGUARD
					monscore+=70 if opponent2.ability == :WONDERGUARD
				end
				if i.ability == :STURDY && i.hp == i.totalhp 
					if currentmon.hp != 0 # hard switch 
						monscore -= 80 
					end
				end
				if i.ability == :DAZZLING || i.ability == :QUEENLYMAJESTY
					for j in opponent1.moves
						monscore+=20 if j.priority>0
					end
					for j in opponent2.moves
						monscore+=20 if j.priority>0
					end  
				end 				
			end
			Console.echoln "Abilities: #{monscore}" #if $INTERNAL
			#Items
			if skill>=PBTrainerAI.highSkill
				if i.item == :ROCKYHELMET
					monscore+=30 if opponent1.ability == :SKILLLINK
					monscore+=30 if opponent2.ability == :SKILLLINK
					biggestpower=0
					biggestcontact=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.contactMove?
								biggestcontact=true 
							else
								biggestcontact=false
							end                  
						end
					end
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.contactMove?
								biggestcontact=true 
							else
								biggestcontact=false
							end                  
						end
					end
					monscore+=30 if biggestcontact
				end
				if i.item == :AIRBALLOON
					biggestpower=0
					typecheck=false
					allground=true
					for j in opponent1.moves
						if j.type != :GROUND
							allground=false
						end
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :GROUND
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					for j in opponent2.moves
						if j.type != :GROUND
							allground=false
						end
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :GROUND
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					monscore+=60 if typecheck
					monscore+=100 if allground
				end
				if i.item == :FLOATSTONE
					typecheck=false
					for j in opponent1.moves
						if j.id == :GRASSKNOT || j.id == :LOWKICK 
							typecheck=true
						end
					end
					monscore+=10 if typecheck
					typecheck=false
					for j in opponent2.moves
						if j.id == :GRASSKNOT || j.id == :LOWKICK 
							typecheck=true
						end
					end
					monscore+=10 if typecheck
				end
				if i.item == :DESTINYKNOT
					monscore+=20 if opponent1.ability == :CUTECHARM || opponent2.ability == :CUTECHARM
					paracheck=false
					for j in opponent1.moves
						if [:ATTRACT].include?(j.id)
							paracheck=true
						end                
					end
					for j in opponent2.moves
						if [:ATTRACT].include?(j.id)
							paracheck=true
						end                
					end
					monscore+=20 if paracheck
				end
				if i.item == :ABSORBBULB
					biggestpower=0
					typecheck=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :WATER
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :WATER
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					monscore+=25 if typecheck
				end
				if i.item == :CELLBATTERY
					biggestpower=0
					typecheck=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :ELECTRIC
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :ELECTRIC
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					monscore+=25 if typecheck
				end
				if i.item == :FOCUSSASH || i.ability == :STURDY
					if @battle.field.weather == :SANDSTORM || @battle.field.weather == :HAIL || 
						 @battle.sides[1].effects[PBEffects::StealthRock] || 
						 @battle.sides[1].effects[PBEffects::Spikes]>0 || 
						 @battle.sides[1].effects[PBEffects::ToxicSpikes]>0
						monscore-=30
					end
				end
				if i.item == :SNOWBALL
					biggestpower=0
					typecheck=false
					for j in opponent1.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :ICE
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					for j in opponent2.moves
						if j.baseDamage>biggestpower
							biggestpower=j.baseDamage
							if j.type == :ICE
								typecheck=true 
							else
								typecheck=false
							end                  
						end
					end
					monscore+=25 if typecheck
				end
				if i.item == :PROTECTIVEPADS
					if i.ability == :EFFECTSPORE || i.ability == :STATIC || i.ability == :POISONPOINT || 
						 i.ability == :ROUGHSKIN || i.ability == :IRONBARBS || i.ability == :FLAMEBODY || 
						 i.ability == :CUTECHARM || i.ability == :MUMMY || i.ability == :AFTERMATH || 
						 i.ability == :GOOEY || opponent1.item == :ROCKYHELMET
						monscore+=25
					end
				end
			end
			Console.echoln "Items: #{monscore}" #if $INTERNAL
			if @battle.sides[1].effects[PBEffects::StealthRock] || 
				 @battle.sides[1].effects[PBEffects::Spikes]>0 
				monscore*= (i.hp/i.totalhp)
			end
			airboom=false
			if i.hasType?(:FLYING) || i.item == :AIRBALLOON || (i.ability == :LEVITATE && !@battle.moldBreaker)
				airboom=true
			end
			if i.item == :IRONBALL || @battle.field.effects[PBEffects::Gravity] > 0
				airboom=false
			end
			hazpercent = totalHazardDamage(@battle.sides[1],i,airboom,skill)
			if hazpercent>(i.hp/i.totalhp)*100
				monscore=1
			end
			if theseRoles.include?("Ace") #&& skill>=PBTrainerAI.bestSkill
				monscore*= 0.1
			end 
			if theseRoles.include?("Second") && !opponent1.allAllies.empty? #&& skill>=PBTrainerAI.bestSkill
				monscore*= 0.2
			end 			 
			Console.echoln "Score: #{monscore}" #if $INTERNAL
			Console.echoln " " #if $INTERNAL
			scorearray.push(monscore)
		end
		# weirdly, due to how the replacement code is made, the AI will most likely 
		# throw the worst possible *replacement* if all other options are bad
		count=-1
		bestcount=-1
		highscore=-1000000000000000000000000
		for score in scorearray
			count+=1
			next if party[count].nil?
			if score>highscore
				highscore=score
				bestcount=count
			elsif score==highscore
				if party[count].hp>party[bestcount].hp
					bestcount=count
				end
			end
		end
		highscore=-1 if highscore<-1 && !forced
		Console.echoln "Best score: #{highscore}" #if $INTERNAL
		if !@battle.pbCanSwitchLax?(index,bestcount)
			return -1
		else
			if highscore!=-1
				return bestcount
			else
				return -1
			end
		end
	end
end
=end