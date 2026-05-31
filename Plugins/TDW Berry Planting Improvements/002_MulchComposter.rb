#===============================================================================
# Composter
#===============================================================================

def pbMulchComposter
    if !PluginManager.installed?("TDW Berry Core and Dex","1.1")
        Console.echo_warn("TDW Berry Core and Dex v1.1 is required to use composter.") 
        return pbMessage(_INTL("The composter cannot be used."))
    end
    if $player.composter_seen
        # return if !pbConfirmMessage(_INTL("It's a composter.\nCompost some Berries to make Mulch?"))
        cmds = [_INTL("Yes"), _INTL("No"),_INTL("Read lid")]
        loop do
          cmd = pbMessage(_INTL("It's a composter.\nCompost some Berries to make Mulch?"), cmds, -1)
          case cmd
          when -1, 1
            return
          when 2
            pbReadComposterLid
          else
            break
          end
        end
    else
        $player.composter_seen = true
        pbMessage(_INTL("It's a composter!\nThe instructions are written on the lid..."))
        pbReadComposterLid
        return if !pbConfirmMessage(_INTL("Do you want to compost some Berries to make Mulch?"))
    end
    berries = pbChooseBerryMultiple(Settings::COMPOSTER_BERRY_AMOUNT, false)
    return if !berries || berries.empty?
    berry_names = ""
    berries.each_with_index { |b,i|
        name = b.real_name
        berry_names += (name.starts_with_vowel? ? "an " : "a ") + name
        berry_names += ", " unless i+1 == berries.length
        berry_names += "and " if i == berries.length-2
    }
    pbMessage(_INTL("{1} put {2} into the composter!",$player.name,berry_names))

    count = Settings::COMPOSTER_DISPENSE_AMOUNT
    result = pbProcessComposterRecipe(berries)
    pbReceiveItem(result,count)
end

def pbReadComposterLid
    pbMessage(_INTL("\\w[signskin]Put {1} Berries in, and you can make Mulch.",Settings::COMPOSTER_BERRY_AMOUNT))
    pbMessage(_INTL("\\w[signskin]Using Mulch on the soil before planting a Berry helps the Berries grow."))
end

alias pbComposter pbMulchComposter

def pbProcessComposterRecipe(berries)
    recipes = Settings::COMPOSTER_RECIPES
    colors = []
    berry_ids = []
    berries.each { |b| 
        colors.push(GameData::BerryData.get(b.id).color)
        berry_ids.push(b.id)
    }
    recipes.each { |key,value|
        return key if value == :DifferentColors && colors.length == colors.uniq.length
        if value.is_a?(Array) && value[0].is_a?(Array) #Specific Berries
            clone = berry_ids.clone
            satisfied = 0
            value.each_with_index { |i,index|
                break if satisfied < index
                i.each { |j|
                    if clone.include?(j)
                        satisfied += 1
                        clone.delete_at(clone.index(j))
                        break
                    end
                }
            }
            return key if satisfied == value.length
        elsif value.is_a?(Array) && value[0].is_a?(Integer) #Counts
            tally = colors.tally
            tally.each { |t_key,t_value| return key if t_value >= value[0] && [t_key, :Any].include?(value[1]) }
        end
    }
    return Settings::COMPOSTER_DEFAULT_MULCH
end

#===============================================================================
# Player
#===============================================================================
class Player < Trainer
    attr_accessor :composter_seen

    alias tdw_berry_composter_init initialize
    def initialize(name, trainer_type)
        tdw_berry_composter_init(name, trainer_type)
        @composter_seen = false
    end
end