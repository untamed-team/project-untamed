#===============================================================================
# Common Functions
#=============================================================================== 

def pbToggleBerryDex(set = nil)
    $player.initialize_berrydex if !$player.berrydex
    $player.has_berrydex = set.nil? ? !$player.has_berrydex : set
end

def pbBerryDex
    if !pbCanViewBerryDex?
        pbMessage(_INTL("You don't have any Berries registered.")) if pbBerryDexCount < 1 && $player.has_berrydex
        Console.echo_warn _INTL("$player.has_berrydex is currently false") if !$player.has_berrydex
        Console.echo_warn _INTL("Switch #{Settings::ACCESS_BERRYDEX_SWITCH_ID} is currently false") if Settings::ACCESS_BERRYDEX_SWITCH_ID > 0 && !$game_switches[Settings::ACCESS_BERRYDEX_SWITCH_ID]
        return
    end
    pbFadeOutIn {
        scene = PokemonBerrydex_Scene.new
        screen = PokemonBerrydexScreen.new(scene)
        screen.pbStartScreen
    }
end

def pbRegisterBerry(berry)
    return $player.berrydex.register(berry)
end

def pbUnregisterBerry(berry)
    return $player.berrydex.unregister(berry)
end

def pbBerryRegistered?(berry)
    return $player.berrydex.registered?(berry)
end

def pbBerryDexCount
    return 0 if !$player.has_berrydex
    return $player.berrydex.count
end

def pbCanViewBerryDex?
    return $player.has_berrydex && (pbBerryDexCount >= 1 || Settings::BERRYDEX_SHOW_ENTIRE_LIST) && 
        (Settings::ACCESS_BERRYDEX_SWITCH_ID <= 0 || $game_switches[Settings::ACCESS_BERRYDEX_SWITCH_ID])
end

def pbChooseBerry(var = 0)
    ret = nil
    pbFadeOutIn {
        scene = PokemonBag_Scene.new
        screen = PokemonBagScreen.new(scene, $bag)
        ret = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).is_berry? })
    }
    $game_variables[var] = ret || :NONE if var > 0
    return ret
end

#===============================================================================
# Player
#=============================================================================== 

class Player < Trainer
    attr_accessor :berrydex
    attr_accessor :has_berrydex

    alias tdw_berry_dex_init initialize
    def initialize(name, trainer_type)
        tdw_berry_dex_init(name, trainer_type)
        initialize_berrydex
    end

    def initialize_berrydex
        @berrydex       = Berrydex.new
        @has_berrydex   = false
    end

    def berrydex
        initialize_berrydex if !@berrydex
        return @berrydex
    end

    def berryRegistered?(berry)
        @berrydex.registered?(berry)
    end

    class Berrydex
        def initialize
            @registered = {}
            @unlocked_dexes = []
            0.upto(pbLoadBerryDexes.length) do |i|
                @unlocked_dexes[i] = (i == 0)
            end
        end

        def register(berry)
            return false if !$player.has_berrydex
            data = GameData::BerryData.try_get(berry)
            return false if !data
            return false if @registered[berry]
            @registered[berry] = true
            return true
        end

        def unregister(berry)
            return false if !$player.has_berrydex
            data = GameData::BerryData.try_get(berry)
            return false if !data
            return false if !@registered[berry]
            @registered.delete(berry)
            return true
        end

        def registered?(berry)
            berry = berry.id if !berry.is_a?(Symbol)
            return @registered[berry]
        end

        def count
            return @registered.size
        end
    end
end

#===============================================================================
# Bag
#=============================================================================== 

class PokemonBag
    alias tdw_berry_dex_bag_add add
    def add(item, qty = 1)
        ret = tdw_berry_dex_bag_add(item, qty)
        item = item.id if !item.is_a?(Symbol)
        pbRegisterBerry(item) if ret && GameData::BerryData.try_get(item)
        return ret
    end
end

#===============================================================================
# Game_Temp
#=============================================================================== 
class Game_Temp
    attr_accessor :berry_dexes_data
end

alias tdw_berry_data_clear pbClearData
def pbClearData
    tdw_berry_data_clear
    $game_temp.berry_dexes_data = nil if $game_temp
end

#===============================================================================
# Method to get Berry Dexes data.
#===============================================================================
def pbLoadBerryDexes
    $game_temp = Game_Temp.new if !$game_temp
    $game_temp.berry_dexes_data = load_data("Data/berry_dexes.dat") if !$game_temp.berry_dexes_data
    return $game_temp.berry_dexes_data
end

def pbGetBerrydexNumber(berry, region = 0)
    dex_list = pbLoadBerryDexes[region]
    return 0 if !dex_list || dex_list.length == 0
    berry_data = GameData::BerryData.try_get(berry)
    return 0 if !berry_data
    dex_list.each_with_index { |s, index| return index + 1 if s.id == berry_data.id }
    return 0
end

#===============================================================================
# Debug Commands
#===============================================================================
MenuHandlers.add(:debug_menu, :toggle_berrydex, {
    "name"        => _INTL("Toggle Berrydex"),
    "parent"      => :player_menu,
    "description" => _INTL("Toggle possession of the Berrydex"),
    "effect"      => proc {
        pbToggleBerryDex
        pbMessage(_INTL("Gave Berrydex.")) if $player.has_berrydex
        pbMessage(_INTL("Lost Berrydex.")) if !$player.has_berrydex
    }
})

def pbAddEachBerry
    return if !$DEBUG
    dex_list = pbLoadBerryDexes[0]
    dex_list.length.times { |i| $bag.add(dex_list[i].id) }
end