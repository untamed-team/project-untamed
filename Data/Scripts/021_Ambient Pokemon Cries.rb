#===============================================================================
# * Ambient Pokémon Cries - by Vendily
# Modified by SpaceWestern
#===============================================================================
# This script plays random cries of pokémon that can be encountered on the map
#  for ambiance. It does not activate for maps that don't have pokemon,
#  and optionally only when a switch is active.
# To ensure you get no errors, this script must be under PField_Field. It can
#  be anywhere but it must be under that section. (It's because it uses the
#  Events Module, which is defined in PField_Field)
#===============================================================================
# * The time between cries in seconds (arbitrarily default 60)
# * The variance in time for cries in seconds (arbitrarily default +/-rand(5))
# * The Global Switch that is checked to see if ambiance should be used, set
#      to -1 to always play ambiance if possible
# * The volume to play the cry at (default 65)
# * If the game should play roamer cries, which are the only cries that play
#    should one be found on the current map (default true)
#===============================================================================
#TIME_BETWEEN_CRIES  = 60
if $GameSpeed > 0
TIME_BETWEEN_CRIES  = (45 * UnrealTime::PROPORTION) * $GameSpeed
else
TIME_BETWEEN_CRIES  = (45 * UnrealTime::PROPORTION)
end
RANDOM_TIME_FACTOR  = 5
AMBIANCE_SWITCH     = 71
CRY_VOLUME          = 50
CRY_ROAMERS         = true

class PokemonEncounters
  def pbAllValidEncounterTypes(mapID)
    @data = GameData::Encounter.get(mapID, $PokemonGlobal.encounter_version)
    data = GameData::Encounter.get(mapID, $PokemonGlobal.encounter_version)
    enclist= Marshal.load(Marshal.dump(data.types))
    ret=[]
    enclist.each{|enclist| 
      ret.push(enclist)
    }
    return ret
  end
end

#class PokemonTemp
class Game_Temp
  attr_accessor :lastCryTime
end

def pbPlayAmbiance
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  return false if !map_metadata
  if $game_switches[AMBIANCE_SWITCH]
    roam=[]
    if CRY_ROAMERS
      for i in 0...Settings::ROAMING_SPECIES.length
        poke=Settings::ROAMING_SPECIES[i]
        species=getID(GameData::Species,poke[0])
        next if !species || species<=0
        if $game_switches[poke[2]] && $Overworld_RoamingPokemon.roamPokemon[i]!=true
          currentArea=$Overworld_RoamingPokemon.roamPosition[i]
          if !currentArea
            $Overworld_RoamingPokemon.roamPosition[i]=keys[rand(keys.length)]
            currentArea=$Overworld_RoamingPokemon.roamPosition[i]
          end
          roamermeta=pbGetMetadata(currentArea,MetadataMapPosition)
          possiblemaps=[]
          mapinfos=$RPGVX ? load_data("Data/MapInfos.rvdata") : load_data("Data/MapInfos.rxdata")
          for j in 1...mapinfos.length
            jmeta=pbGetMetadata(j,MetadataMapPosition)
            if mapinfos[j] && mapinfos[j].name==$game_map.name &&
              roamermeta && jmeta && roamermeta[0]==jmeta[0]
              possiblemaps.push(j)   # Any map with same name as roamer's current map
            end
          end
          if possiblemaps.include?(currentArea) && pbRoamingMethodAllowed(poke[3])
            # Change encounter to species and level, with BGM on end
            roam.push(species)
          end
        end
      end
    end
    
    if roam.length>0
      #play a random roaming cry
      Pokemon.play_cry(roam[rand(roam.length)], 0, CRY_VOLUME, 100)
    else
      # enctypes will be the full set of lists of all encounters listed by type
      # the first index within each index (ie. enctypes[x][0] will be the actual
      # type of encounter (Land, Water, OldRod, etc.)
      enctypes=$PokemonEncounters.pbAllValidEncounterTypes($game_map.map_id) rescue []
      
      if enctypes && enctypes.length>0
        invalenc=true        
        while invalenc
          # This grabs one of the encounter types from the available options
          enc=enctypes[rand(enctypes.length)]
          
          # This checks to make sure that if it grabbed night it is night, and 
          # the same for morning and day
          if (enc[0]=="LandNight" && !PBDayNight.isNight?) ||
             (enc[0]=="LandDay" && !PBDayNight.isDay?) ||
             (enc[0]=="LandMorning" && !PBDayNight.isMorning?)
          else
            invalenc=false 
          end
        end
        # This grabs an individual cry from the chosen encounter type list
        crypoke = enc[1][rand(enc[1].length)][1]
      end
      if crypoke
        Pokemon.play_cry(crypoke, 0, CRY_VOLUME, 100)
      end
    end
  end
end

#Events.onMapUpdate+=proc {|sender,e|   # Ambiance check
EventHandlers.add(:on_frame_update, :ambient_cry,
  proc {
  now=pbGetTimeNow
  
  # This makes sure that the timer doesn't get confused when you load a save
  # Without this, it will always cry when you load in
  #if $PokemonTemp.lastCryTime==nil
  if $game_temp.lastCryTime==nil
    #$PokemonTemp.lastCryTime = now
    $game_temp.lastCryTime = now
  end
  
  #last=$PokemonTemp.lastCryTime
  last=$game_temp.lastCryTime
  if !last || (now-last>(TIME_BETWEEN_CRIES+((rand(2)==0 ? -1 : 1)*rand(RANDOM_TIME_FACTOR))))
    pbPlayAmbiance
    #$PokemonTemp.lastCryTime=now
    $game_temp.lastCryTime=now
  end
  }
)