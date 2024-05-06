def timeMachineCheckSaves
  location = File.join(ENV['APPDATA'],"project-untamed")
  return false unless File.directory?(location)
  #find eligible save files
  eligibleSaveFiles = []
  #replace "\" with "/"
  location.gsub!("\\", "\/")
  #Dir.each_child('/path/to/dir') do |filename|
  #Dir.glob("#{location}/*.rxdata") do |rxdata_filename|
  pbSEPlay("Door Slide",80,70)
  pbWait(Graphics.frame_rate)
  Dir.each_child(location) do |filename|
	#next if file is not an rxdata File
	next if File.extname(filename) != ".rxdata"
     #check for a specific variable's value in the save File
	 #if variable, variable number, value is NOT greater than or equal to number
	 #if the variable for demo version is less than THIS number, push to eligibleSaveFiles
	 #increase this number with every demo release
	 filenameNoExt = filename.gsub(".rxdata", "")
	 next if $player.save_slot == filenameNoExt
	 file_path = File.join(location, filename)
	 save_data = SaveData.get_data_from_file(file_path)
	 #a save is eligible if variable X is less than value Y in the statement below at the part "Variable",[X,Y]
	 eligibleSaveFiles.push([filenameNoExt,save_data,file_path]) if !timeMachineSaveTest("project-untamed","Variable",[51,2],ver=20,save_data)
  end
  return eligibleSaveFiles
end

def timeMachineSaveTest(name,test,param=nil,ver=20, save_data)
  save = save_data
  result = false
  test = test.capitalize
	if save
		case test
		when "Exist"
			result = true
		when "Map"
			result = (save[:map_factory].map.map_id == param)
		when "Name"
			result = (save[:player].name == param)
		when "Switch"
			result = (save[:switches][param] == true)
		when "Variable"
			varnum = param[0]
			varval = param[1]
			if varval.is_a?(Numeric)
				result = (save[:variables][varnum] >= varval)
			else
				result = (save[:variables][varnum] == varval)
			end
		when "Party"
			party = save[:player].party
			for i in 0...party.length
				poke = party[i]
				result = true if poke.species == param
			end
		when "Seen"
			if ver == 18
				result = save[:player].seen[param]
			else
				result = (save[:player].pokedex.seen?(param))
			end
		when "Owned"
			if ver == 18
				result = save[:player].owned[param]
			else
				result = (save[:player].pokedex.owned?(param))
			end
		when "Item"
			if ver == 18
				oldbag = save[:bag].clone
				for i in 0...oldbag.pockets.length
					pocket = oldbag.pockets[i]
					for j in 0...pocket.length
						item = pocket[j]
						if item[0] == param
							result = true
							break
						end
					end
				end
			else
				result = (save[:bag].has?(param))
			end
		end
    end
  return result
end

#Old utilities to convert prior data
class PokeBattle_Trainer
  attr_accessor :trainertype, :name, :id, :metaID, :outfit, :language
  attr_accessor :party, :badges, :money
  attr_accessor :seen, :owned, :formseen, :formlastseen, :shadowcaught
  attr_accessor :pokedex, :pokegear
  attr_accessor :mysterygiftaccess, :mysterygift

  def self.convert(trainer)
    validate trainer => self
    ret = Player.new(trainer.name, trainer.trainertype)
    ret.id                    = trainer.id
    ret.character_ID          = trainer.metaID if trainer.metaID
    ret.outfit                = trainer.outfit if trainer.outfit
    ret.language              = trainer.language if trainer.language
    trainer.party.each { |p| ret.party.push(PokeBattle_Pokemon.convert(p)) }
    ret.badges                = trainer.badges.clone
    ret.money                 = trainer.money
    trainer.seen.each_with_index { |value, i| ret.pokedex.set_seen(i, false) if value }
    trainer.owned.each_with_index { |value, i| ret.pokedex.set_owned(i, false) if value }
    trainer.formseen.each_with_index do |value, i|
      species_id = GameData::Species.try_get(i)&.species
      next if species_id.nil? || value.nil?
      ret.pokedex.seen_forms[species_id] = [value[0].clone, value[1].clone] if value
    end
    trainer.formlastseen.each_with_index do |value, i|
      species_id = GameData::Species.try_get(i)&.species
      next if species_id.nil? || value.nil?
      ret.pokedex.set_last_form_seen(species_id, value[0], value[1]) if value
    end
    if trainer.shadowcaught
      trainer.shadowcaught.each_with_index do |value, i|
        ret.pokedex.set_shadow_pokemon_owned(i) if value
      end
    end
    ret.pokedex.refresh_accessible_dexes
    ret.has_pokedex           = trainer.pokedex
    ret.has_pokegear          = trainer.pokegear
    ret.mystery_gift_unlocked = trainer.mysterygiftaccess if trainer.mysterygiftaccess
    ret.mystery_gifts         = trainer.mysterygift.clone if trainer.mysterygift
    return ret
  end
end

class PokeBattle_Pokemon
  attr_accessor :name, :species, :form, :formTime, :forcedForm, :fused
  attr_accessor :personalID, :exp, :hp, :status, :statusCount
  attr_accessor :abilityflag, :genderflag, :natureflag, :natureOverride, :shinyflag
  attr_accessor :moves, :firstmoves
  attr_accessor :item, :mail
  attr_accessor :iv, :ivMaxed, :ev
  attr_accessor :happiness, :eggsteps, :pokerus
  attr_accessor :ballused, :markings, :ribbons
  attr_accessor :obtainMode, :obtainMap, :obtainText, :obtainLevel, :hatchedMap
  attr_accessor :timeReceived, :timeEggHatched
  attr_accessor :cool, :beauty, :cute, :smart, :tough, :sheen
  attr_accessor :trainerID, :ot, :otgender, :language
  attr_accessor :shadow, :heartgauge, :savedexp, :savedev, :hypermode, :shadowmoves

  def initialize(*args)
    raise "PokeBattle_Pokemon.new is deprecated. Use Pokemon.new instead."
  end

  def self.convert(pkmn)
    return pkmn if pkmn.is_a?(Pokemon)
    owner = Pokemon::Owner.new(pkmn.trainerID, pkmn.ot, pkmn.otgender, pkmn.language)
    natdex = [:NONE]
    GameData::Species.each_species { |s| natdex.push(s.id) }
    pkmn.species = natdex[pkmn.species]
    # Set level to 1 initially, as it will be recalculated later
    ret = Pokemon.new(pkmn.species, 1, owner, false, false)
    ret.forced_form      = pkmn.forcedForm if pkmn.forcedForm
    ret.time_form_set    = pkmn.formTime
    ret.exp              = pkmn.exp
    ret.steps_to_hatch   = pkmn.eggsteps
    GameData::Status.each do |s|
      pkmn.status = s.id if s.icon_position == pkmn.status
    end
    ret.status           = pkmn.status
    ret.statusCount      = pkmn.statusCount
    ret.gender           = pkmn.genderflag
    ret.shiny            = pkmn.shinyflag
    ret.ability_index    = pkmn.abilityflag
    ret.nature           = pkmn.natureflag
    ret.nature_for_stats = pkmn.natureOverride
    ret.item             = pkmn.item
    ret.mail             = PokemonMail.convert(pkmn.mail) if pkmn.mail
    pkmn.moves.each { |m| ret.moves.push(PBMove.convert(m)) if m && m.id > 0 }
    if pkmn.firstmoves
      pkmn.firstmoves.each { |m| ret.add_first_move(m) }
    end
    if pkmn.ribbons
      pkmn.ribbons.each { |r| ret.giveRibbon(r) }
    end
    ret.cool             = pkmn.cool if pkmn.cool
    ret.beauty           = pkmn.beauty if pkmn.beauty
    ret.cute             = pkmn.cute if pkmn.cute
    ret.smart            = pkmn.smart if pkmn.smart
    ret.tough            = pkmn.tough if pkmn.tough
    ret.sheen            = pkmn.sheen if pkmn.sheen
    ret.pokerus          = pkmn.pokerus if pkmn.pokerus
    ret.name             = pkmn.name if pkmn.name != ret.speciesName
    ret.happiness        = pkmn.happiness
    ret.poke_ball        = pbBallTypeToItem(pkmn.ballused).id
    ret.markings         = pkmn.markings if pkmn.markings
    GameData::Stat.each_main do |s|
      ret.iv[s.id]       = pkmn.iv[s.id_number]
      ret.ivMaxed[s.id]  = pkmn.ivMaxed[s.id_number] if pkmn.ivMaxed
      ret.ev[s.id]       = pkmn.ev[s.id_number]
    end
    ret.obtain_method    = pkmn.obtainMode
    ret.obtain_map       = pkmn.obtainMap
    ret.obtain_text      = pkmn.obtainText
    ret.obtain_level     = pkmn.obtainLevel if pkmn.obtainLevel
    ret.hatched_map      = pkmn.hatchedMap
    ret.timeReceived     = pkmn.timeReceived
    ret.timeEggHatched   = pkmn.timeEggHatched
    if pkmn.fused
      ret.fused = PokeBattle_Pokemon.convert(pkmn.fused) if pkmn.fused.is_a?(PokeBattle_Pokemon)
      ret.fused = pkmn.fused if pkmn.fused.is_a?(Pokemon)
    end
    ret.personalID       = pkmn.personalID
    ret.hp               = pkmn.hp
    if pkmn.shadow
      ret.shadow         = pkmn.shadow
      ret.heart_gauge    = pkmn.heartgauge
      ret.hyper_mode     = pkmn.hypermode
      ret.saved_exp      = pkmn.savedexp
      if pkmn.savedev
        GameData::Stat.each_main { |s| ret.saved_ev[s.id] = pkmn.savedev[s.pbs_order] if s.pbs_order >= 0 }
      end
      ret.shadow_moves   = []
      pkmn.shadowmoves.each_with_index do |move, i|
        ret.shadow_moves[i] = GameData::Move.get(move).id if move
      end
    end
    # NOTE: Intentionally set last, as it recalculates stats.
    ret.form_simple      = pkmn.form || 0
    return ret
  end
end

class PBMove
  attr_accessor :id, :pp, :ppup

  def self.convert(move)
    ret = Pokemon::Move.new(move.id)
    ret.ppup = move.ppup
    ret.pp = move.pp
    return ret
  end
end

class PokemonMail
  attr_accessor :item, :message, :sender, :poke1, :poke2, :poke3

  def self.convert(mail)
    return mail if mail.is_a?(Mail)
    item.poke1[0] = GameData::Species.get(item.poke1[0]).id if item.poke1
    item.poke2[0] = GameData::Species.get(item.poke2[0]).id if item.poke2
    item.poke3[0] = GameData::Species.get(item.poke3[0]).id if item.poke3
    return Mail.new(mail.item, item.message, item.sender, item.poke1, item.poke2, item.poke3)
  end
end

#save to file
module TimeMachineSaveData
  # Contains the file path of the save file.
  FILE_PATH = if File.directory?(System.data_directory)
                System.data_directory + "/Game.rxdata"
              else
                "./Game.rxdata"
              end

  # @return [Boolean] whether the save file exists
  def self.exists?
    return File.file?(FILE_PATH)
  end

  # Fetches the save data from the given file.
  # Returns an Array in the case of a pre-v19 save file.
  # @param file_path [String] path of the file to load from
  # @return [Hash, Array] loaded save data
  # @raise [IOError, SystemCallError] if file opening fails
  def self.get_data_from_file(file_path)
    validate file_path => String
    save_data = nil
    File.open(file_path) do |file|
      data = Marshal.load(file)
      if data.is_a?(Hash)
        save_data = data
        next
      end
      save_data = [data]
      save_data << Marshal.load(file) until file.eof?
    end
    return save_data
  end

  # Fetches save data from the given file. If it needed converting, resaves it.
  # @param file_path [String] path of the file to read from
  # @return [Hash] save data in Hash format
  # @raise (see .get_data_from_file)
  def self.read_from_file(file_path)
    validate file_path => String
    save_data = get_data_from_file(file_path)
    save_data = to_hash_format(save_data) if save_data.is_a?(Array)
    if !save_data.empty? && run_conversions(save_data)
      File.open(file_path, "wb") { |file| Marshal.dump(save_data, file) }
    end
    return save_data
  end

  # Compiles the save data and saves a marshaled version of it into
  # the given file.
  # @param file_path [String] path of the file to save into
  # @raise [InvalidValueError] if an invalid value is being saved
  def self.save_to_file(file_path, save_data)
    validate file_path => String
    #save_data = self.compile_save_hash
	#save file has no global metadata after saving to it. I suspect the save_data hash I'm passing to this method is missing stuff
    File.open(file_path, "wb") { |file| Marshal.dump(save_data[1], file) }
  end

  # Deletes the save file (and a possible .bak backup file if one exists)
  # @raise [Error::ENOENT]
  def self.delete_file
    File.delete(FILE_PATH)
    File.delete(FILE_PATH + ".bak") if File.file?(FILE_PATH + ".bak")
  end

  # Converts the pre-v19 format data to the new format.
  # @param old_format [Array] pre-v19 format save data
  # @return [Hash] save data in new format
  def self.to_hash_format(old_format)
    validate old_format => Array
    hash = {}
    @values.each do |value|
      data = value.get_from_old_format(old_format)
      hash[value.id] = data unless data.nil?
    end
    return hash
  end

  # Moves a save file from the old Saved Games folder to the new
  # location specified by {FILE_PATH}. Does nothing if a save file
  # already exists in {FILE_PATH}.
  def self.move_old_windows_save
    return if File.file?(FILE_PATH)
    game_title = System.game_title.gsub(/[^\w ]/, "_")
    home = ENV["HOME"] || ENV["HOMEPATH"]
    return if home.nil?
    old_location = File.join(home, "Saved Games", game_title)
    return unless File.directory?(old_location)
    old_file = File.join(old_location, "Game.rxdata")
    return unless File.file?(old_file)
    File.move(old_file, FILE_PATH)
  end
end

module TimeMachineSaveData
  # Contains Value objects for each save element.
  # Populated during runtime by SaveData.register calls.
  # @type [Array<Value>]
  @values = []

  # An error raised if an invalid save value is being saved or loaded.
  class InvalidValueError < RuntimeError; end

  #=============================================================================
  # Represents a single value in save data.
  # New values are added using {SaveData.register}.
  class Value
    # @return [Symbol] the value id
    attr_reader :id

    # @param id [Symbol] value id
    def initialize(id, &block)
      validate id => Symbol, block => Proc
      @id = id
      @loaded = false
      @load_in_bootup = false
      instance_eval(&block)
      raise "No save_value defined for save value #{id.inspect}" if @save_proc.nil?
      raise "No load_value defined for save value #{id.inspect}" if @load_proc.nil?
    end

    # @param value [Object] value to check
    # @return [Boolean] whether the given value is valid
    def valid?(value)
      return true if @ensured_class.nil?
      return value.is_a?(Object.const_get(@ensured_class))
    end

    # Calls the value's load proc with the given argument passed into it.
    # @param value [Object] load proc argument
    # @raise [InvalidValueError] if an invalid value is being loaded
    def load(value)
      validate_value(value)
      @load_proc.call(value)
      @loaded = true
    end

    # Calls the value's save proc and returns its value.
    # @return [Object] save proc value
    # @raise [InvalidValueError] if an invalid value is being saved
    def save
      value = @save_proc.call
      validate_value(value)
      return value
    end

    # @return [Boolean] whether the value has a new game value proc defined
    def has_new_game_proc?
      return @new_game_value_proc.is_a?(Proc)
    end

    # Calls the save value's load proc with the value fetched
    # from the defined new game value proc.
    # @raise (see #load)
    def load_new_game_value
      unless self.has_new_game_proc?
        raise "Save value #{@id.inspect} has no new_game_value defined"
      end
      self.load(@new_game_value_proc.call)
    end

    # @return [Boolean] whether the value should be loaded during bootup
    def load_in_bootup?
      return @load_in_bootup
    end

    # @return [Boolean] whether the value has been loaded
    def loaded?
      return @loaded
    end

    # Marks value as unloaded.
    def mark_as_unloaded
      @loaded = false
    end

    # Uses the {#from_old_format} proc to select the correct data from
    # +old_format+ and return it.
    # Returns nil if the proc is undefined.
    # @param old_format [Array] old format to load value from
    # @return [Object] data from the old format
    def get_from_old_format(old_format)
      return nil if @old_format_get_proc.nil?
      return @old_format_get_proc.call(old_format)
    end

    private

    # Raises an {InvalidValueError} if the given value is invalid.
    # @param value [Object] value to check
    # @raise [InvalidValueError] if the value is invalid
    def validate_value(value)
      return if self.valid?(value)
      raise InvalidValueError, "Save value #{@id.inspect} is not a #{@ensured_class} (#{value.class.name} given)"
    end

    # @!group Configuration

    # If present, ensures that the value is of the given class.
    # @param class_name [Symbol] class to enforce
    # @see SaveData.register
    def ensure_class(class_name)
      validate class_name => Symbol
      @ensured_class = class_name
    end

    # Defines how the loaded value is placed into a global variable.
    # Requires a block with the loaded value as its parameter.
    # @see SaveData.register
    def load_value(&block)
      raise ArgumentError, "No block given to load_value" unless block_given?
      @load_proc = block
    end

    # Defines what is saved into save data. Requires a block.
    # @see SaveData.register
    def save_value(&block)
      raise ArgumentError, "No block given to save_value" unless block_given?
      @save_proc = block
    end

    # If present, defines what the value is set to at the start of a new game.
    # @see SaveData.register
    def new_game_value(&block)
      raise ArgumentError, "No block given to new_game_value" unless block_given?
      @new_game_value_proc = block
    end

    # If present, sets the value to be loaded during bootup.
    # @see SaveData.register
    def load_in_bootup
      @load_in_bootup = true
    end

    # If present, defines how the value should be fetched from the pre-v19
    # save format. Requires a block with the old format array as its parameter.
    # @see SaveData.register
    def from_old_format(&block)
      raise ArgumentError, "No block given to from_old_format" unless block_given?
      @old_format_get_proc = block
    end

    # @!endgroup
  end

  #=============================================================================
  # Registers a {Value} to be saved into save data.
  # Takes a block which defines the value's saving ({Value#save_value})
  # and loading ({Value#load_value}) procedures.
  #
  # It is also possible to provide a proc for fetching the value
  # from the pre-v19 format ({Value#from_old_format}), define
  # a value to be set upon starting a new game with {Value#new_game_value}
  # and ensure that the saved and loaded value is of the correct
  # class with {Value#ensure_class}.
  #
  # Values can be registered to be loaded on bootup with
  # {Value#load_in_bootup}. If a new_game_value proc is defined, it
  # will be called when the game is launched for the first time,
  # or if the save data does not contain the value in question.
  #
  # @example Registering a new value
  #   SaveData.register(:foo) do
  #     ensure_class :Foo
  #     save_value { $foo }
  #     load_value { |value| $foo = value }
  #     new_game_value { Foo.new }
  #     from_old_format { |old_format| old_format[16] if old_format[16].is_a?(Foo) }
  #   end
  # @example Registering a value to be loaded on bootup
  #   SaveData.register(:bar) do
  #     load_in_bootup
  #     save_value { $bar }
  #     load_value { |value| $bar = value }
  #     new_game_value { Bar.new }
  #   end
  # @param id [Symbol] value id
  # @yield the block of code to be saved as a Value
  def self.register(id, &block)
    validate id => Symbol
    unless block_given?
      raise ArgumentError, "No block given to SaveData.register"
    end
    @values << Value.new(id, &block)
  end

  # @param save_data [Hash] save data to validate
  # @return [Boolean] whether the given save data is valid
  def self.valid?(save_data)
    validate save_data => Hash
    return @values.all? { |value| value.valid?(save_data[value.id]) }
  end

  # Loads values from the given save data.
  # An optional condition can be passed.
  # @param save_data [Hash] save data to load from
  # @param condition_block [Proc] optional condition
  # @api private
  def self.load_values(save_data, &condition_block)
    @values.each do |value|
      next if block_given? && !condition_block.call(value)
      if save_data.has_key?(value.id)
        value.load(save_data[value.id])
      elsif value.has_new_game_proc?
        value.load_new_game_value
      end
    end
  end

  # Loads the values from the given save data by
  # calling each {Value} object's {Value#load_value} proc.
  # Values that are already loaded are skipped.
  # If a value does not exist in the save data and has
  # a {Value#new_game_value} proc defined, that value
  # is loaded instead.
  # @param save_data [Hash] save data to load
  # @raise [InvalidValueError] if an invalid value is being loaded
  def self.load_all_values(save_data)
    validate save_data => Hash
    load_values(save_data) { |value| !value.loaded? }
  end

  # Marks all values that aren't loaded on bootup as unloaded.
  def self.mark_values_as_unloaded
    @values.each do |value|
      value.mark_as_unloaded unless value.load_in_bootup?
    end
  end

  # Loads each value from the given save data that has
  # been set to be loaded during bootup. Done when a save file exists.
  # @param save_data [Hash] save data to load
  # @raise [InvalidValueError] if an invalid value is being loaded
  def self.load_bootup_values(save_data)
    validate save_data => Hash
    load_values(save_data) { |value| !value.loaded? && value.load_in_bootup? }
  end

  # Goes through each value with {Value#load_in_bootup} enabled and loads their
  # new game value, if one is defined. Done when no save file exists.
  def self.initialize_bootup_values
    @values.each do |value|
      next unless value.load_in_bootup?
      value.load_new_game_value if value.has_new_game_proc? && !value.loaded?
    end
  end

  # Loads each {Value}'s new game value, if one is defined. Done when starting a
  # new game.
  def self.load_new_game_values
    @values.each do |value|
      value.load_new_game_value if value.has_new_game_proc? && !value.loaded?
    end
  end

  # @return [Hash{Symbol => Object}] a hash representation of the save data
  # @raise [InvalidValueError] if an invalid value is being saved
  def self.compile_save_hash
    save_data = {}
    @values.each { |value| save_data[value.id] = value.save }
	return save_data
  end
end