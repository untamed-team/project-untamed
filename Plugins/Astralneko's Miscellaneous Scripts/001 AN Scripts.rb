class AstralnekoTemp
    # Player animations - stores the last direction the player was holding; everything else can be determined algorithmically
	attr_accessor :lastPlayerDirection
	
	def initialize
		@lastPlayerDirection = 2
	end
	
	def setLastPlayerDir(dir)
		@lastPlayerDirection = dir
    end
end
$Astralneko_Temp = AstralnekoTemp.new

class AstralnekoStorage
	# Time overrides
	attr_accessor :overrideTime
	attr_accessor :timeToOverride
	
	def initialize
		@overrideTime = false
		@timeToOverride = 0
	end
	
	def timeOverride?
		return @overrideTime
	end
	
	def setTimeOverride(time)
		@overrideTime = true
		@timeToOverride = time
	end
	
	def removeTimeOverride
		@overrideTime = false
	end
end
$Astralneko_Storage = AstralnekoStorage.new

# Saves the AstralnekoStorage global variable.
SaveData.register(:astralneko_storage) do
	load_in_bootup
    ensure_class :AstralnekoStorage
    save_value { $Astralneko_Storage }
    load_value { |value| $Astralneko_Storage = value }
    new_game_value { AstralnekoStorage.new }
end

alias pbGetTimeNow_astralneko pbGetTimeNow
def pbGetTimeNow
	if $Astralneko_Storage.timeOverride?
		return $Astralneko_Storage.timeToOverride
	else
		return pbGetTimeNow_astralneko
	end
end

def anTimeOverride(*args)
    if args.size == 2 || args.size == 3
		$Astralneko_Storage.setTimeOverride(Time.local(Time.now.year,Time.now.month,Time.now.day,args[0],args[1]))
	else
		if args[0].is_a?(Time)
			$Astralneko_Storage.setTimeOverride(args[0])
		else
		    $Astralneko_Storage.setTimeOverride(Time.local(Time.now.year,Time.now.month,Time.now.day,args[0],0,0))
		end
	end
end

def anRemoveTimeOverride
	$Astralneko_Storage.removeTimeOverride
end

# Play player animation
def anPlayPlayerAnimation(animname, length=1, frequency=2, vehicle=false)
    $Astralneko_Temp.setLastPlayerDir($game_player.direction)
	meta = GameData::Metadata.get_player($Trainer.character_ID)
	if meta
		charset = 1                                 # Regular graphic
		if vehicle
			if $PokemonGlobal.diving;     charset = 5   # Diving graphic
			elsif $PokemonGlobal.surfing; charset = 3   # Surfing graphic
			elsif $PokemonGlobal.bicycle; charset = 2   # Bicycle graphic
			end
		end
		newCharName = pbGetPlayerCharset(meta,charset,nil,true)
		animation = "" + newCharName + "_" + animname
		move_route = Array.new
		move_route.push(PBMoveRoute::Graphic,animation,0,2,0,PBMoveRoute::Wait,frequency) if length >= 1
		move_route.push(PBMoveRoute::Graphic,animation,0,2,1,PBMoveRoute::Wait,frequency) if length >= 2
		move_route.push(PBMoveRoute::Graphic,animation,0,2,2,PBMoveRoute::Wait,frequency) if length >= 3
		move_route.push(PBMoveRoute::Graphic,animation,0,2,3,PBMoveRoute::Wait,frequency) if length >= 4
		move_route.push(PBMoveRoute::Graphic,animation,0,4,0,PBMoveRoute::Wait,frequency) if length >= 5
		move_route.push(PBMoveRoute::Graphic,animation,0,4,1,PBMoveRoute::Wait,frequency) if length >= 6
		move_route.push(PBMoveRoute::Graphic,animation,0,4,2,PBMoveRoute::Wait,frequency) if length >= 7
		move_route.push(PBMoveRoute::Graphic,animation,0,4,3,PBMoveRoute::Wait,frequency) if length >= 8
		move_route.push(PBMoveRoute::Graphic,animation,0,6,0,PBMoveRoute::Wait,frequency) if length >= 9
		move_route.push(PBMoveRoute::Graphic,animation,0,6,1,PBMoveRoute::Wait,frequency) if length >= 10
		move_route.push(PBMoveRoute::Graphic,animation,0,6,2,PBMoveRoute::Wait,frequency) if length >= 11
		move_route.push(PBMoveRoute::Graphic,animation,0,6,3,PBMoveRoute::Wait,frequency) if length >= 12
		move_route.push(PBMoveRoute::Graphic,animation,0,8,0,PBMoveRoute::Wait,frequency) if length >= 13
		move_route.push(PBMoveRoute::Graphic,animation,0,8,1,PBMoveRoute::Wait,frequency) if length >= 14
		move_route.push(PBMoveRoute::Graphic,animation,0,8,2,PBMoveRoute::Wait,frequency) if length >= 15
		move_route.push(PBMoveRoute::Graphic,animation,0,8,3,PBMoveRoute::Wait,frequency) if length >= 16
		pbMoveRoute($game_player,move_route)
	end
end

# Play player animation from a certain frame
def anPlayPlayerAnimationFromFrame(start_frame, animname, length=1, frequency=2, vehicle=false)
    $Astralneko_Temp.setLastPlayerDir($game_player.direction)
	meta = GameData::Metadata.get_player($Trainer.character_ID)
	if meta
		charset = 1                                 # Regular graphic
		if vehicle
			if $PokemonGlobal.diving;     charset = 5   # Diving graphic
			elsif $PokemonGlobal.surfing; charset = 3   # Surfing graphic
			elsif $PokemonGlobal.bicycle; charset = 2   # Bicycle graphic
			end
		end
		newCharName = pbGetPlayerCharset(meta,charset,nil,true)
		animation = "" + newCharName + "_" + animname
		move_route = Array.new
		move_route.push(PBMoveRoute::Graphic,animation,0,2,0,PBMoveRoute::Wait,frequency) if length >= 1 && start_frame <= 1
		move_route.push(PBMoveRoute::Graphic,animation,0,2,1,PBMoveRoute::Wait,frequency) if length >= 2 && start_frame <= 2
		move_route.push(PBMoveRoute::Graphic,animation,0,2,2,PBMoveRoute::Wait,frequency) if length >= 3 && start_frame <= 3
		move_route.push(PBMoveRoute::Graphic,animation,0,2,3,PBMoveRoute::Wait,frequency) if length >= 4 && start_frame <= 4
		move_route.push(PBMoveRoute::Graphic,animation,0,4,0,PBMoveRoute::Wait,frequency) if length >= 5 && start_frame <= 5
		move_route.push(PBMoveRoute::Graphic,animation,0,4,1,PBMoveRoute::Wait,frequency) if length >= 6 && start_frame <= 6
		move_route.push(PBMoveRoute::Graphic,animation,0,4,2,PBMoveRoute::Wait,frequency) if length >= 7 && start_frame <= 7
		move_route.push(PBMoveRoute::Graphic,animation,0,4,3,PBMoveRoute::Wait,frequency) if length >= 8 && start_frame <= 8
		move_route.push(PBMoveRoute::Graphic,animation,0,6,0,PBMoveRoute::Wait,frequency) if length >= 9 && start_frame <= 9
		move_route.push(PBMoveRoute::Graphic,animation,0,6,1,PBMoveRoute::Wait,frequency) if length >= 10 && start_frame <= 10
		move_route.push(PBMoveRoute::Graphic,animation,0,6,2,PBMoveRoute::Wait,frequency) if length >= 11 && start_frame <= 11
		move_route.push(PBMoveRoute::Graphic,animation,0,6,3,PBMoveRoute::Wait,frequency) if length >= 12 && start_frame <= 12
		move_route.push(PBMoveRoute::Graphic,animation,0,8,0,PBMoveRoute::Wait,frequency) if length >= 13 && start_frame <= 13
		move_route.push(PBMoveRoute::Graphic,animation,0,8,1,PBMoveRoute::Wait,frequency) if length >= 14 && start_frame <= 14
		move_route.push(PBMoveRoute::Graphic,animation,0,8,2,PBMoveRoute::Wait,frequency) if length >= 15 && start_frame <= 15
		move_route.push(PBMoveRoute::Graphic,animation,0,8,3,PBMoveRoute::Wait,frequency) if length >= 16 && start_frame <= 16
		pbMoveRoute($game_player,move_route)
	end
end

def anReversePlayerAnimation(animname, length=1, frequency=2, vehicle=false)
    $Astralneko_Temp.setLastPlayerDir($game_player.direction)
	meta = GameData::Metadata.get_player($Trainer.character_ID)
	if meta
		charset = 1                                 # Regular graphic
		if vehicle
			if $PokemonGlobal.diving;     charset = 5   # Diving graphic
			elsif $PokemonGlobal.surfing; charset = 3   # Surfing graphic
			elsif $PokemonGlobal.bicycle; charset = 2   # Bicycle graphic
			end
		end
		newCharName = pbGetPlayerCharset(meta,charset,nil,true)
		animation = "" + newCharName + "_" + animname
		move_route = Array.new
		move_route.push(PBMoveRoute::Graphic,animation,0,8,3,PBMoveRoute::Wait,frequency) if length >= 16
		move_route.push(PBMoveRoute::Graphic,animation,0,8,2,PBMoveRoute::Wait,frequency) if length >= 15
		move_route.push(PBMoveRoute::Graphic,animation,0,8,1,PBMoveRoute::Wait,frequency) if length >= 14
		move_route.push(PBMoveRoute::Graphic,animation,0,8,0,PBMoveRoute::Wait,frequency) if length >= 13
		move_route.push(PBMoveRoute::Graphic,animation,0,6,3,PBMoveRoute::Wait,frequency) if length >= 12
		move_route.push(PBMoveRoute::Graphic,animation,0,6,2,PBMoveRoute::Wait,frequency) if length >= 11
		move_route.push(PBMoveRoute::Graphic,animation,0,6,1,PBMoveRoute::Wait,frequency) if length >= 10
		move_route.push(PBMoveRoute::Graphic,animation,0,6,0,PBMoveRoute::Wait,frequency) if length >= 9
		move_route.push(PBMoveRoute::Graphic,animation,0,4,3,PBMoveRoute::Wait,frequency) if length >= 8
		move_route.push(PBMoveRoute::Graphic,animation,0,4,2,PBMoveRoute::Wait,frequency) if length >= 7
		move_route.push(PBMoveRoute::Graphic,animation,0,4,1,PBMoveRoute::Wait,frequency) if length >= 6
		move_route.push(PBMoveRoute::Graphic,animation,0,4,0,PBMoveRoute::Wait,frequency) if length >= 5
		move_route.push(PBMoveRoute::Graphic,animation,0,2,3,PBMoveRoute::Wait,frequency) if length >= 4
		move_route.push(PBMoveRoute::Graphic,animation,0,2,2,PBMoveRoute::Wait,frequency) if length >= 3
		move_route.push(PBMoveRoute::Graphic,animation,0,2,1,PBMoveRoute::Wait,frequency) if length >= 2
		move_route.push(PBMoveRoute::Graphic,animation,0,2,0,PBMoveRoute::Wait,frequency) if length >= 1
		pbMoveRoute($game_player,move_route)
	end
end

def anEndPlayerAnimation
	meta = GameData::Metadata.get_player($Trainer.character_ID)
	if meta
		charset = 1                                 # Regular graphic
		if $PokemonGlobal.diving;     charset = 5   # Diving graphic
		elsif $PokemonGlobal.surfing; charset = 3   # Surfing graphic
		elsif $PokemonGlobal.bicycle; charset = 2   # Bicycle graphic
		end
		newCharName = pbGetPlayerCharset(meta,charset,nil,true)
		case $Astralneko_Temp.lastPlayerDirection
		when 2
		pbMoveRoute($game_player,[
			PBMoveRoute::TurnDown,
			PBMoveRoute::Graphic,newCharName, 
			  0, 2, 0
		])
		when 4
		pbMoveRoute($game_player,[
			PBMoveRoute::TurnDown,
			PBMoveRoute::Graphic,newCharName, 
			  0, 4, 0
		])
		when 6
		pbMoveRoute($game_player,[
			PBMoveRoute::TurnDown,
			PBMoveRoute::Graphic,newCharName, 
			  0, 6, 0
		])
		when 8
		pbMoveRoute($game_player,[
			PBMoveRoute::TurnDown,
			PBMoveRoute::Graphic,newCharName, 
			  0, 8, 0
		])
		end
	end
end

def anMart(itemlist)
    badges = $Trainer.badge_count
	
	buyableItems = []
	for i in 0...itemlist.length
		if itemlist[i+1].is_a?(Integer)
			if badges >= itemlist[i+1]
				buyableItems.push(itemlist[i])
			end
		end
	end
	pbPokemonMart(buyableItems)
end

def anStackBitmapsSingle(baseBitmap, addBitmap)
	return nil if !baseBitmap || !addBitmap
	
	# Ensure the new bitmap can fit the larger of the two widths
	if addBitmap.width > baseBitmap.width
		width = addBitmap.width
	else
		width = baseBitmap.width
	end
	# Ensure the new bitmap can fit the larger of the two heights
	if addBitmap.height > baseBitmap.height
		height = addBitmap.height
	else
		height = baseBitmap.height
	end
	
	# blt the two bitmaps together on a new bitmap
	result = Bitmap.new(width,height)
	result.blt(0,0,baseBitmap,Rect.new(0,0,baseBitmap.width,baseBitmap.height))
	result.blt(0,0,addBitmap,Rect.new(0,0,addBitmap.width,addBitmap.height))
	return result
end

# The above function, but generalized to any amount of Bitmap objects instead of two
def anStackBitmaps(*args)
	result = Bitmap.new(10,10)
	for i in args.size
		if args[i].is_a?(Bitmap)
			result = anStackBitmapsSingle(result,args[i])
		else # Assume filename string if not a Bitmap
			if pbResolveBitmap("Graphics/"+args[i])
				bitmap = Bitmap.new(args[i])
				result = anStackBitmapsSingle(result,bitmap)
			else
				return nil
			end
		end
	end
	return result
end

# Generate a new random name from a list
def anRandomName
  names = Astralneko_Config::RANDOM_NAME_LIST
  return names[rand(names.size)] # could be rand(612) but this future proofs it
end

# Generates a random gender, based loosely on the name of the character.
def anRandomGender(name="X")
  guess = defined?(Trainer.nonbinary?) ? rand(3) : rand(2) # 0 = male, 1 = female, 2 = nonbinary (if defined)
  # To maintain the guess, the following checks must not succeed:
  # Name ends in L/O/N/S, 1/2 chance
  guess = 0 if name[/[l|o|n|s]$/] != "" && rand(2) == 0
  # Name ends in O/E/R, 1/4 chance
  guess = 0 if name[/[o|e|r]$/] != "" && rand(4) == 0
  # Name ends in A/IE, 1/2 chance
  guess = 1 if name[/[a|ie]$/] != "" && rand(2) == 0
  # Name ends in A/D/Z/Y, 1/4 chance
  guess = 1 if name[/[a|d|z|y]$/] != "" && rand(4) == 0
  # Whatever guess now is, return it
  return guess
end