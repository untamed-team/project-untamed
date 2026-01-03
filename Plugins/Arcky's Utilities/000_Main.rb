SaveData.register(:arckyglobal) do
  load_in_bootup
  ensure_class :ArckyGlobalData
  save_value { $ArckyGlobal }
  load_value { |value| $ArckyGlobal = value }
  new_game_value { ArckyGlobalData.new }
  reset_on_new_game
end

class ArckyGlobalData
  # Custom Trackers
  attr_accessor :globalCounter
  attr_accessor :itemTracker
  attr_accessor :trainerTracker
  attr_accessor :mapVisitTracker
  attr_accessor :pokeMartTracker

  # Custom Pokedex Trackers
  attr_accessor :seenSpeciesCount
  attr_accessor :seenSpeciesCountMap
  attr_accessor :caughtSpeciesCount
  attr_accessor :caughtSpeciesCountMap
  attr_accessor :defeatedSpeciesCount
  attr_accessor :defeatedSpeciesCountMap
  attr_accessor :lastSeenSpeciesForm
  attr_accessor :lastSeenSpeciesFormMap
  attr_accessor :lastCaughtSpeciesForm

  def initialize
    # Custom Trackers
    @globalCounter              = {} # ok
    @itemTracker                = {} # ok
    @trainerTracker             = {} # ok
    @mapVisitTracker            = {} # ok
    @pokeMartTracker            = {} # ok

    # Custom Pokedex Trackers
    @seenSpeciesCount           = {}
    @seenSpeciesCountMap        = {}
    @caughtSpeciesCount         = {}
    @caughtSpeciesCountMap      = {}
    @defeatedSpeciesCount       = {}
    @defeatedSpeciesCountMap    = {}
    @lastSeenSpeciesForm        = {}
    @lastSeenSpeciesFormMap     = {}
    @lastCaughtSpeciesForm      = {}
  end
end

SEEN     = :seen
CAUGHT   = :caught
DEFEATED = :defeated
GENDER   = :gender
FORM     = :form
SHINY    = :shiny

# Utilities
def getDistrictName(mapPos, mapData = nil)
  regionName = "Unknown"
  mapPos = mapPos.town_map_position if !mapPos.nil? && !mapPos.is_a?(Array)
  if mapPos.nil?
    Console.echoln_li _INTL("The current map has no MapPosition defined in the map_metadata.txt PBS file.")
    return regionName
  end
  mapData = pbLoadTownMapData if mapData.nil? && Essentials::VERSION.include?("20")
  mapData = GameData::TownMap.get(mapPos[0]) if mapData.nil?
  regionName = Essentials::VERSION.include?("20") ? MessageTypes::RegionNames : MessageTypes::REGION_NAMES
  if ARMSettings::USE_REGION_DISTRICTS_NAMES
    ARMSettings::REGION_DISTRICTS.each do |region, rangeX, rangeY, districtName|
      if mapPos[0] == region && mapPos[1].between?(rangeX[0], rangeX[1]) && mapPos[2].between?(rangeY[0], rangeY[1])
        scripts = Essentials::VERSION.include?("20") ? MessageTypes::ScriptTexts : MessageTypes::SCRIPT_TEXTS
        return pbGetMessageFromHash(scripts, districtName)
      end
    end
  end
  return pbGetMessage(regionName, mapPos[0]) if Essentials::VERSION.include?("20")
  return pbGetMessageFromHash(regionName, mapData.name.to_s) if Essentials::VERSION.include?("21")
end

def convertIntegerOrFloat(number)
  return 0 unless number.is_a?(Integer) || number.is_a?(Float)
  number = number.to_i if number.to_i == number
  return number
end

def convertOpacity(input)
  return (([0, [100, (input / 5.0).round * 5].min].max) * 2.55).round
end

def toNumber(value)
  return 0 if value.nil?
  value.to_i.to_s == value ? value.to_i : 0
end

def getSpeciesDexNumber(pokemon, region)
  num = pbGetRegionalNumber(region, pokemon)
  if num <= 0
    region = -1
    nationalDex = [:NONE]
    GameData::Species.each_species { |s| nationalDex.push(s.species) }
    dexnum = nationalDex.index(pokemon) || 9999
  else
    dexnum = num
    speciesData = GameData::Species.get(pokemon)
    if speciesData.form > 0
      dexnum += (speciesData.form.to_f / 10)
    end
  end
  dexnum -= 1 if Settings::DEXES_WITH_OFFSETS.include?(region)
  return dexnum
end

def getValidMapPositions(map)
  return if map.nil?
  mapSize = map.town_map_size
  mapPosArray = []
  if mapSize && mapSize[0] && mapSize[0] > 0
    sqwidth  = mapSize[0]
    sqheight = (mapSize[1].length.to_f / mapSize[0]).ceil
    mapPos = map.town_map_position
    for i in 0...sqwidth
      for j in 0...sqheight
        mapPosArray << [mapPos[0], mapPos[1] + i, mapPos[2] + j]
      end
    end
  else
    mapPosArray = [map.town_map_position]
  end
  return mapPosArray
end

def getEncChances(enc, encType)
  data = {}
  total = enc.map { |chance| chance[0] }.sum
  enc.each do |chance, species, min, max|
    speciesData = GameData::Species.get(species)
    entry = {
      :chance => ((chance.to_f / total) * 100).round(1),
      :level => { :min => min, :max => max || min },
    }
    if data.key?(species)
      data[species][:entries] << entry
    else
      data[species] = {
        :type => getSpeciesTypes(speciesData),
        :catchRate => "#{convertIntegerOrFloat(((speciesData.catch_rate.to_f / 255) * 100).round(1))}%",
        :entries => [entry]
      }
    end
  end
  return data
end

def getSpeciesTypes(speciesData)
  type = speciesData.types
  typeNames = type.map { |type| GameData::Type.try_get(type).name }
  if typeNames.size > 1
    textType = typeNames.join("/")
  else
    textType = typeNames.first
  end
  return textType
end

def textToLines(widths, text, extra, maxWidth = 460)
  currSum = 0
  newLines = []
  widths.each_with_index do |width, index|
    currSum += width
    currSum += extra if index != widths.length - 1
    if currSum > maxWidth
      newLines << index
      currSum = width
    end
  end
  newLines.each do |index|
    text[index] = "\n#{text[index]}"
  end
  return text
end

def getBitmapWidth(input)
  return Bitmap.new(input).width
end

def getBitmapHeight(input)
  return Bitmap.new(input).height
end

def getDistrictProgress
  return if $ArckyGlobal.globalCounter.empty?
  array = {}
  $ArckyGlobal.globalCounter[:districts].each do |district, progress|
    array[district] = ((progress[:progress].to_f / progress[:total]) * 100).round(1)
  end
  return array
end

def convertToRegularHash(obj)
  case obj
  when Hash
    regular_hash = {}
    obj.each do |key, value|
      regular_hash[key] = convertToRegularHash(value)
    end
    regular_hash
  when Array
    obj.map { |e| convertToRegularHash(e) }
  else
    obj
  end
end

def switchesForDistricts
  return if !ARMSettings::ProgressCounter
  hash = getDistrictProgress
  return if hash.nil?
  hash.each do |district, progress|
    next if (switch = ARMSettings::PROGRESS_SWITCHES[district]).nil?
    $game_switches[switch] = progress.to_i == 100
  end
end

def mergeArrayToString(array)
  if array.length > 1
    return array[0..-2].join(", ") + " and " + array[-1]
  else
    return array[0]
  end
end

def getDateFromString(date)
  dateArray = date.split('-')
  return Time.local(dateArray[0], dateArray[1], dateArray[2])
end

# Tracker Methods
def registerSpeciesSeen(species, gender, form, shiny)
  registerSpecies(SEEN, species, gender, form, shiny)
end

def registerSpeciesCaught(species, gender, form, shiny)
  registerSpecies(CAUGHT, species, gender, form, shiny)
end

def registerSpeciesDefeated(species, gender, form, shiny)
  registerSpecies(DEFEATED, species, gender, form, shiny)
end

def registerSpecies(type, species, gender, form, shiny)
  speciesID, gender, shiny = validateSpecies(species, gender, shiny)
  mapID = $game_map.map_id
  return if [speciesID, gender, shiny].all?(&:nil?)
  spCounter, spMapCounter, lastSpCounter, lastSpMapCounter = getCounters(type, mapID)
  spCounter[speciesID] ||= [[[], []], [[], []]]
  spCounter[speciesID][gender][shiny][form] ||= 0
  spCounter[speciesID][gender][shiny][form] += 1
  if type == SEEN
    shin = shiny == 1
    if MultipleForms.hasFunction?(species, "getFormOnCreation")
      lastSpCounter[species] = [gender, shin, form]
    else
      lastSpCounter[species] ||= {}
      lastSpCounter[species][form] = [gender, shin]
    end
  end
  spMapCounter[mapID] ||= {}
  spMapCounter[mapID][speciesID] ||= [[[], []], [[], []]]
  spMapCounter[mapID][speciesID][gender][shiny][form] ||= 0
  spMapCounter[mapID][speciesID][gender][shiny][form] += 1
  if type == SEEN
    lastSpMapCounter[mapID] ||= {}
    lastSpMapCounter[mapID][speciesID] = [gender, shiny, form]
  end
end


def validateSpecies(species, gender, shiny)
  speciesData = GameData::Species.try_get(species)
  speciesID = speciesData&.species
  unless speciesID.nil?
    gender = 0 if !gender.nil? && gender >= 2
    shiny = shiny ? 1 : 0
  end
  return speciesID, gender, shiny
end

def getCounters(type, mapID)
  case type
  when SEEN
    return [$ArckyGlobal.seenSpeciesCount, $ArckyGlobal.seenSpeciesCountMap,
            $ArckyGlobal.lastSeenSpeciesForm, $ArckyGlobal.lastSeenSpeciesFormMap]
  when CAUGHT
    return [$ArckyGlobal.caughtSpeciesCount, $ArckyGlobal.caughtSpeciesCountMap,
            $ArckyGlobal.lastCaughtSpeciesForm]
  when DEFEATED
    return [$ArckyGlobal.defeatedSpeciesCount, $ArckyGlobal.defeatedSpeciesCountMap]
  end
end

def countSeenSpecies(species, gender = nil, form = nil, shiny = false)
  getCounterSpecies(SEEN, species, gender, form, shiny)
end

def countSeenSpeciesMap(map = nil, species = nil, gender = nil, form = nil, shiny = false)
  map = $game_map.map_id if map.nil?
  getCounterSpecies(SEEN, species, gender, form, shiny, map)
end

def countSeenSpeciesForms(species, gender = nil, form = nil, shiny = false)
  getCounterSpecies(SEEN, species, gender, form, shiny, nil, true)
end

def countCaughtSpecies(species, gender = nil, form = nil, shiny = false)
  getCounterSpecies(CAUGHT, species, gender, form, shiny)
end

def countCaughtSpeciesMap(map = nil, species = nil, gender = nil, form = nil, shiny = false)
  map = $game_map.map_id if map.nil?
  getCounterSpecies(CAUGHT, species, gender, form, shiny, map)
end

def countCaughtSpeciesForms(species, gender = nil, form = nil, shiny = false)
  getCounterSpecies(CAUGHT, species, gender, form, shiny, nil, true)
end

def countDefeatedSpecies(species, gender = nil, form = nil, shiny = false)
  getCounterSpecies(DEFEATED, species, gender, form, shiny)
end

def countDefeatedSpeciesMap(map = nil, species = nil, gender = nil, form = nil, shiny = false)
  map = $game_map.map_id if map.nil?
  getCounterSpecies(DEFEATED, species, gender, form, shiny, map)
end

def countDefeatedSpeciesForms(species, gender = nil, form = nil, shiny = false)
  getCounterSpecies(DEFEATED, species, gender, form, shiny, nil, true)
end

def countSpeciesForms(counter)
  return 0 if counter.nil?
  array = counter.map { |sar| sar.map { |ssar| ssar.compact } }.flatten(1) # removes all nil and flattens the arrays 1 level.
  maxLength = array.map(&:length).max # get the max array length.
  sums = Array.new(maxLength, 0) # creates array of wanted length.
  array.each { |sarr| sarr.each_with_index { |value, index| sums[index] += value } } # merges all sub arrays and saves it.
  return sums.length # return output length.
end

def getCounterSpecies(type, species, gender, form, shiny, map = nil, allForms = false)
  speciesID, gender, shiny = validateSpecies(species, gender, shiny)
  spCounter, spMapCounter = getCounters(type, map)
  return 0 if spCounter.nil? || spMapCounter.nil?
  counter = map.nil? ? spCounter : spMapCounter[map]
  return countSpeciesForms(counter[speciesID]) if allForms
  return 0 if speciesID.nil? && counter.nil? || (counter.nil? || counter[speciesID].nil?)
  if gender && form && shiny # returns total amount of Species by given Gender, Form and Shininess.

    return counter[speciesID][gender][shiny][form] || 0
  elsif gender && form # returns total amount of Species by given Gender and Form.
    array = counter[speciesID][gender].map { |shinArr| shinArr[form] } || 0
  elsif gender # returns total amount of Species by given Gender.
    array = counter[speciesID][gender].flatten || 0
  elsif form # returns total amount of Species by given Form.
    array = counter[speciesID].map { |genArr| genArr.map { |shinArr| shinArr[form] } } || 0
  else # returns total amount of Species.
    array = counter[speciesID].flatten || 0
  end
  return array.flatten.compact.sum
end

if Essentials::VERSION.include?("20")
  module SaveData
    class Value
      def initialize(id, &block)
        validate id => Symbol, block => Proc
        @id = id
        @loaded = false
        @load_in_bootup = false
        @reset_on_new_game = false
        instance_eval(&block)
        raise "No save_value defined for save value #{id.inspect}" if @save_proc.nil?
        raise "No load_value defined for save value #{id.inspect}" if @load_proc.nil?
      end

      def reset_on_new_game
        @reset_on_new_game = true
      end

      def reset_on_new_game?
        return @reset_on_new_game
      end

      # Marks all values that aren't loaded on bootup as unloaded.
      def self.mark_values_as_unloaded
        @values.each do |value|
          value.mark_as_unloaded if !value.load_in_bootup? || value.reset_on_new_game?
        end
      end

      # Loads each {Value}'s new game value, if one is defined. Done when starting a
      # new game.
      def self.load_new_game_values
        @values.each do |value|
          value.load_new_game_value if value.has_new_game_proc? && (!value.loaded? || value.reset_on_new_game?)
        end
      end
    end
  end
end
