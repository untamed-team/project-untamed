#===============================================================================
# Data
#=============================================================================== 

module GameData
    class BerryColor
        attr_reader :id
        attr_reader :real_name
        attr_reader :base_color
        attr_reader :shadow_color
    
        DATA = {}
    
        extend ClassMethodsSymbols
        include InstanceMethods
    
        def self.load; end
        def self.save; end
    
        def initialize(hash)
            @id        	= hash[:id]
            @real_name 	= hash[:name] || "Unnamed"
            @base_color 	= hash[:base_color]
            @shadow_color	= hash[:shadow_color]
        end
    
        # @return [String] the translated name of this body color
        def name
            return _INTL(@real_name)
        end
    end
end
  
#===============================================================================
# Definitions
#=============================================================================== 
 
GameData::BerryColor.register({
    :id   => :Red,
    :name => _INTL("Red"),
    :base_color => Color.new(232, 32, 16),
    :shadow_color => Color.new(248, 168, 184)
})

GameData::BerryColor.register({
    :id   => :Yellow,
    :name => _INTL("Yellow"),
    :base_color => Color.new(232, 208, 32),
    :shadow_color => Color.new(248, 232, 136)
})

GameData::BerryColor.register({
    :id   => :Green,
    :name => _INTL("Green"),
    :base_color => Color.new(96, 176, 72),
    :shadow_color => Color.new(176, 208, 144)
})

GameData::BerryColor.register({
    :id   => :Blue,
    :name => _INTL("Blue"),
    :base_color => Color.new(0, 112, 248),
    :shadow_color => Color.new(120, 184, 232)
})

GameData::BerryColor.register({
    :id   => :Purple,
    :name => _INTL("Purple"),
    :base_color => Color.new(144, 64, 232),
    :shadow_color => Color.new(184, 168, 224)
})

GameData::BerryColor.register({
    :id   => :Pink,
    :name => _INTL("Pink"),
    :base_color => Color.new(208, 56, 184),
    :shadow_color => Color.new(232, 160, 224)
})